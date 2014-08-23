# R Benchmark 2.5 (06/2008) [Simon Urbanek]
# version 2.5: scaled to get roughly 1s per test, R 2.7.0 @ 2.6GHz Mac Pro
# R Benchmark 2.4 (06/2008) [Simon Urbanek]
# version 2.4 adapted to more recent Matrix package
# R Benchmark 2.3 (21 April 2004)
# Warning: changes are not carefully checked yet!
# version 2.3 adapted to R 1.9.0
# Many thanks to Douglas Bates (bates@stat.wisc.edu) for improvements!
# version 2.2 adapted to R 1.8.0
# version 2.1 adapted to R 1.7.0
# version 2, scaled to get 1 +/- 0.1 sec with R 1.6.2
# using the standard ATLAS library (Rblas.dll)
# on a Pentium IV 1.6 Ghz with 1 Gb Ram on Win XP pro

# revised and optimized for R v. 1.5.x, 8 June 2002
# Requires additionnal libraries: Matrix, SuppDists
# Author : Philippe Grosjean
# eMail  : phgrosjean@sciviews.org
# Web    : http://www.sciviews.org
# License: GPL 2 or above at your convenience (see: http://www.gnu.org)
#
# Several tests are adapted from the Splus Benchmark Test V. 2
# by Stephan Steinhaus (stst@informatik.uni-frankfurt.de) 
# Reference for Escoufier's equivalents vectors (test III.5):
# Escoufier Y., 1970. Echantillonnage dans une population de variables
# aleatoires réelles. Publ. Inst. Statis. Univ. Paris 19 Fasc 4, 1-47.
#
# type source("c:/<dir>/R2.R") to start the test

runs <- 1			# Number of times the tests are executed
times <- rep(0, 15); dim(times) <- c(5,3)
require(Matrix)		# Optimized matrix operations
require(SuppDists)	# Optimized random number generators
#Runif <- rMWC1019	# The fast uniform number generator
Runif <- runif
# If you don't have SuppDists, you can use: Runif <- runif
#a <- rMWC1019(10, new.start=TRUE, seed=492166)	# Init. the generator
#Rnorm <- rziggurat	# The fast normal number generator
# If you don't have SuppDists, you can use: Rnorm <- rnorm
#b <- rziggurat(10, new.start=TRUE)	# Init. the generator
Rnorm <- rnorm
remove("a", "b")
options(object.size=100000000)


# (5)
cumulate <- 0; b <- 0
for (i in 1:runs) {
  a <- new("dgeMatrix", x = Rnorm(1600*1600), Dim = as.integer(c(1600, 1600)))
#  invisible(gc())
  #a <- Rnorm(400*400); dim(a) <- c(400, 400)
  timing <- system.time({
  #  b <- qr.solve(a)
    # Rem: a little faster than
    b <- solve(a)
  })[3]
  cumulate <- cumulate + timing
}
timing <- cumulate/runs
times[5, 2] <- timing
cat(c("Inverse of a 1600x1600 random matrix________________ (sec): ", timing, "\n"))
remove("a", "b")
if (R.Version()$os == "Win32" || R.Version()$os == "mingw32") flush.console()

