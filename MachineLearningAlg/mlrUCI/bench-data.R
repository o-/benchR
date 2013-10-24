library(BBmisc)
library(mlr)

args = as.list(commandArgs(TRUE))
stopifnot(length(args) == 4L)
names(args) = c("type", "task", "learner", "repls")
args$repls = as.integer(args$repls)

# FIXME we move this to openml soon
task = load2(file.path("mlrdata-cache", sprintf("%s_%s.RData", args$type, args$task)))
learner = makeLearner(sprintf("%s.%s", args$type, args$learner))
rdesc = makeResampleDesc("Subsample", iters = args$repls)
resampled = resample(learner, task, rdesc)
print(resampled$aggr[1L])
