#' 8 Function 8 - Install snowball
#'
#' @inheritParams get.snowball
#' @param plot.console Logical (defaults to `TRUE`). Should information on
#'   installation time left be printed in plots dialogue when installing from
#'   source.
#' @param quiet.install Logical (defaults to `TRUE`).Run [install.packages()]
#'   with `quiet = TRUE`?
#'
#' @importFrom utils install.packages
install.snowball <- function(pkg, date, include.suggests, force.install = FALSE,
                             force.source = FALSE, plot.console = TRUE,
                             quiet.install = TRUE, current.deps = "Rcpp") {
  # 0 Get the snowball
  snowball <- get.snowball(pkg, date, include.suggests, force.install, current.deps)

  # 0.1 pkg_vrs for target package
  pkg_vrs <- as.character(snowball[nrow(snowball), "pkg_vrs"])

  # Don't display progress if no package is missing or installs from source
  if (!any(!snowball$installed & snowball$from == "source")) {
    plot.console <- FALSE
  }

  # 1. FORCE INSTALL
  if (any(snowball$installed) & force.install) {
    # Subset of packages that are installed
    snowball.installed <- snowball[snowball$installed, ]
    # Get their path
    snowball.installed$paths <- mapply(get.installed_path, snowball.installed$pkg, snowball.installed$vrs)
    # Rename the paths so they are not found and installation takes place
    snowball.installed$paths_rename <- paste0(snowball.installed$paths, "_forcing.reinstall") # new names
    file.rename(snowball.installed$paths, snowball.installed$paths_rename) # assign them
  } # End #1 force

  # 2. FORCE SOURCE
  if (force.source) {
    # Change values from optimized, to 'source'
    snowball$from <- "source"
  }

  # FIXME: this is a temporary workaround so that the script doesn't try
  # to install binaries from MRAN on Linux
  if (.Platform$OS.type == "unix") {
    snowball[, "from"] <- "source"
  }

  # 3 INSTALLATION LOOP

  start.time <- Sys.time() # When loops starts, to compute actual completion time
  for (k in 1:nrow(snowball)) {
    # 3.0 Assign path
    lib.k <- as.character(snowball[k, "installation.path"])

    # 3.1 Install if needed
    if (!snowball[k, "installed"]) {

      # 3.2 Feedback to user on time and pogresss
      installation.feedback(k, date, snowball, start.time, plot.console = TRUE)

      # 3.3 Shorter variable names
      pkg.k <- snowball[k, "pkg"]
      vrs.k <- snowball[k, "vrs"]
      pkg_vrs.k <- snowball[k, "pkg_vrs"]
      from.k <- snowball[k, "from"]
      mran.date.k <- snowball[k, "MRAN.date"]

      # 3.4 Create directory
      dir.create(lib.k, recursive = TRUE, showWarnings = FALSE)

      # 3.5 INSTALL K FROM CRAN
      if (from.k == "CRAN") {
        install.packages(pkg.k, dependencies = FALSE, lib = lib.k, repos = "https://cloud.r-project.org", type = "both", quiet = quiet.install, INSTALL_opts = "--no-staged-install")
      }

      # 3.6 INSTALL K FROM MRAN
      if (from.k == "MRAN") {
        # Try MRAN 1
        install.packages(pkg.k, lib = lib.k, type = "binary", repos = paste0("https://mran.microsoft.com/snapshot/", mran.date.k, "/"), dependencies = FALSE, quiet = quiet.install, INSTALL_opts = "--no-staged-install")
        # Try MRAN 2: If still not installed, try day after (some MRAN days are missing)
        if (!is.pkg_vrs.installed(pkg.k, vrs.k)) {
          install.packages(pkg.k, lib = lib.k, type = "binary", repos = paste0("https://mran.microsoft.com/snapshot/", mran.date.k + 1, "/"), dependencies = FALSE, quiet = quiet.install, INSTALL_opts = "--no-staged-install")
        }
        # Try MRAN 3: If still not installed, try 2 days earlier
        if (!is.pkg_vrs.installed(pkg.k, vrs.k)) {
          install.packages(pkg.k, lib = lib.k, type = "binary", repos = paste0("https://mran.microsoft.com/snapshot/", mran.date.k - 2, "/"), dependencies = FALSE, quiet = quiet.install, INSTALL_opts = "--no-staged-install")
        }
      } # end MRAN


      # 3.7 INSTALL K FROM SOURCE IF SUPPOSED TO, OR I STILL NOT INSTALLED
      if (from.k == "source" | !is.pkg_vrs.installed(pkg.k, vrs.k)) {
        install.source(pkg_vrs.k, lib.k, date)
      }

      # 3.8 VERIFY INSTALL
      now.installed <- is.pkg_vrs.installed(pkg.k, vrs.k)

      # 3.8.5 If not success, try source again, forcing download of file
      if (!now.installed) {
        install.source(pkg_vrs.k, lib.k, date, force.download = TRUE, quiet = quiet.install)
      }

      # 3.8.6 Verify install again
      now.installed <- is.pkg_vrs.installed(pkg.k, vrs.k)

      # 3.9 Installation failed
      if (!now.installed) {

        # If using different R version, attribute to that:
        rv <- r.version.check(date)
        if ((rv$r.using.minor != rv$r.need.minor) | (rv$r.using.major != rv$r.need.major)) {
          message2()
          message1(
            "As mentioned before, there is a discrepancy between the R Version you are using R-", rv$r.using.full,
            "\nand the one that matches the date (", date, ") you entered: R-", rv$r.need.full, ". ",
            "It was worth a try \nbut the install did not work. Follow the instructions below to",
            " try this script in the correct R version."
          )
          cat1.plot(paste0("> The installation of ", pkg_vrs, " failed. Please see console for details."))

          # Long instructions written above
          message1(msg.R.switch(date))
        }

        # PENDINGrename back the flders taht were renamed
        #

        # Stop the script
        message2("\n\n\n--------------------   The package ", pkg_vrs, " did NOT install.-----------------")
        opt <- options(show.error.messages = FALSE)
        on.exit(options(opt))
        stop()
      }

      # Installation succeded
      if (now.installed) {
        message2()
        message1(pkg_vrs.k, " installed succesfully. Saved to: ", lib.k)
        # delete temporary renamed foler if they were created
      }
    } # End of check for whetehr already installed

    # Add to libpath, unless it is the one to be installed
    .libPaths(c(lib.k, .libPaths()))
  } # End loop install
  if (plot.console) {
    cat1.plot(paste0(
      "> Installation of ", pkg_vrs, " has completed.\n\n\n",
      "You may clear this window executing 'dev.off()'"
    ))
  }
} # End install.snowball()
