#' Determine R Paths to search for an already installed package (versions of same minor, in reverse chronological order)
get.pkg_search_paths <- function(pkg, vrs) {
  # R versions
  R.toc <- toc("R")
  R.toc$major <- sapply(strsplit(R.toc$Version, "\\."), `[`, 1)
  R.toc$minor <- sapply(strsplit(R.toc$Version, "\\."), `[`, 2)
  R.toc$path <- sapply(strsplit(R.toc$Version, "\\."), `[`, 3)
  R.toc$Published <- as.DateYMD(R.toc$Published)

  # Subset of R.toc for same minor as r.using
  rv <- r.version.check("2019-01-01") # use arbitrary date for we don't use 'r.need', just r.using
  subset.R.toc <- R.toc[R.toc$minor == rv$r.using.minor &
    R.toc$major == rv$r.using.major &
    R.toc$Published <= get.rdate(), ]

  # Sort versions from most recent
  subset.R.toc <- subset.R.toc[order(subset.R.toc$Published, decreasing = TRUE), ]

  # paths
  pkg_search_paths <- paste0(.pkgenv[["groundhogR.folder"]], "/R-", subset.R.toc$Version, "/", pkg, "_", vrs)

  # Ensure directories exist
  return(pkg_search_paths)
}
