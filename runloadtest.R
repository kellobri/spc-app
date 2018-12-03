library(shinyloadtest)

# replace with the (...) -> Open Solo URL for your app
deployed_app_url <- 'http://colorado.rstudio.com/rsc/content/1703/'

# first record our app
record_session(deployed_app_url)


# run our first baseline load test
cmd <- glue::glue(
  "shinycannon recording.log {deployed_app_url} --workers 1 --loaded-duration-minutes 5 --output-dir baseline"
)
rstudioapi::terminalExecute(
  cmd,
  show = TRUE
)

# run our second 25 user test
cmd <- glue::glue(
  "shinycannon recording.log {deployed_app_url} --workers 25 --loaded-duration-minutes 5 --output-dir twentyfive"
)
rstudioapi::terminalExecute(
  cmd,
  show = TRUE
)
 
# compare results
loadtest <- load_runs(
  baseline = "baseline",
  twentyfive = "twentyfive"
)

shinyloadtest_report(loadtest)

#----------
# STOP and update your app to use renderCachedPlot
#----------

# run our second 25 user test with the cache'd version
cmd <- glue::glue(
  "shinycannon recording.log {deployed_app_url} --workers 25 --loaded-duration-minutes 5 --output-dir cached"
)
rstudioapi::terminalExecute(
  cmd,
  show = TRUE
)

# compare new results again
loadtest <- load_runs(
  baseline = "baseline",
  twentyfive = "twentyfive", 
  cached_twentyfive = "cached"
)

shinyloadtest_report(loadtest)

#----------
# STOP and update your app to use different 
# RSC runtime settings
# (Remember to sign out of RSC again before running load test)
#----------

# run our third 25 user test with the cache'd version & more R procs
cmd <- glue::glue(
  "shinycannon recording.log {deployed_app_url} --workers 25 --loaded-duration-minutes 5 --output-dir scaled"
)
rstudioapi::terminalExecute(
  cmd,
  show = TRUE
)

# compare new results again
loadtest <- load_runs(
  baseline = "baseline",
  twentyfive = "twentyfive", 
  cached_twentyfive = "cached",
  scaled_twentyfive = "scaled"
)

shinyloadtest_report(loadtest)
