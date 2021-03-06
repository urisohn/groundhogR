% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get.snowball.R
\name{get.snowball}
\alias{get.snowball}
\title{Figure out in which order dependencies should be installed to avoid conflicts}
\usage{
get.snowball(
  pkg,
  date,
  include.suggests = FALSE,
  force.source = FALSE,
  current.deps = "Rcpp"
)
}
\arguments{
\item{include.suggests}{Logical. Should suggested packages be installed?}

\item{force.source}{Logical (defaults to \code{FALSE}). If \code{TRUE},` will skip CRAN
and MRAN attempts, download tar.gz, and install from it.}

\item{current.deps}{Dependencies that will install current version regardless
of date.}

\item{force.install}{Logical (defaults to \code{FALSE}). If \code{TRUE}, even if
package is found for this R-build, it will reinstall it.}
}
\description{
Figure out in which order dependencies should be installed to avoid conflicts
}
