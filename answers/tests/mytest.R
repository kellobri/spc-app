app <- ShinyDriver$new("../", seed = 33)
app$snapshotInit("mytest")

app$snapshot()
