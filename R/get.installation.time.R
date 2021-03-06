#' Get installation time
get.installation.time <- function(pkg, vrs) {

  cran.times <- .pkgenv[["cran.times"]]

  dfk <- cran.times[cran.times$pkg_vrs == paste0(pkg, "_", vrs), ] # subset of package
  if (nrow(dfk) == 1) {
    return(dfk$installation.time) # lookup installation times
  } else {
    return(180)
  } # if not found, assume 3 minutes
}
