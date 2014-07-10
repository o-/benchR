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
cumulate <- 0; c <- 0; qra <-0
for (i in 1:runs) {
  a <- new("dgeMatrix", x = Rnorm(2000*2000), Dim = as.integer(c(2000,2000)))
  b <- as.double(1:2000)
  invisible(gc())
  timing <- system.time({
    c <- solve(crossprod(a), crossprod(a,b))
  })[3]
  cumulate <- cumulate + timing
  
  # This is the old method
  #a <- Rnorm(600*600); dim(a) <- c(600,600)
  #b <- 1:600
  #invisible(gc())
  #timing <- system.time({
  #  qra <- qr(a, tol = 1e-7);
  #  c <- qr.coef(qra, b)
  #  #Rem: a little faster than c <- lsfit(a, b, inter=F)$coefficients
  #})[3]
  #cumulate <- cumulate + timing
}
timing <- cumulate/runs
times[5, 1] <- timing
cat(c("Linear regr. over a 3000x3000 matrix (c = a \\ b')___ (sec): ", timing, "\n"))
remove("a", "b", "c", "qra")
if (R.Version()$os == "Win32" || R.Version()$os == "mingw32") flush.console()
