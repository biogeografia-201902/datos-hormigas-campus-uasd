verexp <- function(x) {
  require(readr)
  View(x)
  write_csv(x, paste0('export/tabla_', deparse(substitute(x)), '.csv'))
}
