# ------------------------------------------------------------------
# Contributed by Michel Lang, TU Dortmund
# ------------------------------------------------------------------
#
# Simple greedy bin packing algorithm.
# Same capacity for all bins. Number of bins auto-determined.
# Used to chunk short computational jobs together to meet walltime
# requirements on a HPC cluster.
#
# Returns list with two elements:
# * packs: list of indicies of x, in a ?split-like fashion
# * sums: numeric of bin sums
binPack = function(x, capacity) {
  if (!is.numeric(x) || length(x) == 0L || any(is.na(x)))
    stop("Argument 'x' must be a non-empty numeric vector w/o NAs")
  if (!is.numeric(capacity) || length(capacity) != 1L || is.na(capacity))
    stop("Argument 'capacity' must be a scalar numeric")
  too.big = head(which(x > capacity), 1L)
  if (length(too.big))
    stop(sprintf("Capacity not sufficient. Item %i (x=%f) does not fit",
        too.big, x[too.big]))

  packs = list(numeric(0L))
  sums = 0

  for(j in order(x, decreasing=TRUE)) {
    x.cur = x[j]
    pos = head(which(x.cur + sums <= capacity), 1L)
    if (length(pos)) {
      # we found an existing bin where the x.cur fits in
      packs[[pos]] = c(packs[[pos]], j)
      sums[pos] = sums[pos] + x.cur
    } else {
      # append a new bin with x.cur
      packs = c(packs, list(j))
      sums = c(sums, x.cur)
    }
  }
  return(list(packs = packs, sums = sums))
}


# change for suitable runtime
# more items -> more iterations
# less capacity -> more duplications
items = 82000
capacity = 4200

x = runif(items, 1, min(900, capacity-1))
result = binPack(x, capacity)
#print(result)
