#' Clean up Header Meta Data
#'
#' Make the header meta conform to current spec and format
#' in preparation for writing to an external text file.
#' This function an internal to `write_adat()`.
#'
#' @param x A `soma_adat` to be written.
#' @return The ADAT attributes after `Header.Meta` and `Col.Meta` clean up.
#' @author Stu Field
#' @keywords internal
#' @noRd
prepHeaderMeta <- function(data) {

  if ( is.intact.attributes(data) ) {
    x <- attributes(data)
    x$Col.Meta$Dilution2 <- NULL   # rm Dilution2
  } else {
    # this is a bit of a KLUGE :(
    if ( interactive() ) {
      cat(
        "\n Please fix ADAT attributes prior to calling",
        .code("write_adat()"), "\n Calling",
        .code("is.intact.attributes(data)"), "must be TRUE\n Perhaps",
        .code("createChildAttributes()"), "can help?\n Example:\n  ",
        .code("data <- createChildAttributes(data, parent)"), "\n\n"
      )
    }
    stop("Stopping while you fix the attributes of `data`.", call. = FALSE)
  }

  # Sync COL_DATA NAME & Type vectors
  map <- as.list(x$Header.Meta$COL_DATA$Type)
  names(map) <- x$Header.Meta$COL_DATA$Name
  x$Header.Meta$COL_DATA$Name <- names(x$Col.Meta)
  x$Header.Meta$COL_DATA$Type <- unname(unlist(map[names(x$Col.Meta)]))

  # Update the ROW_DATA -> Name & Type vectors
  data <- data[, getMeta(data)]
  x$Header.Meta$ROW_DATA$Name <- names(data)
  x$Header.Meta$ROW_DATA$Type <- vapply(data, typeof, FUN.VALUE = "")

  # zap commas with semicolons in chr Col.Meta
  idx <- which(vapply(x$Col.Meta, is.character, NA))
  for ( i in idx ) x$Col.Meta[[i]] <- gsub(",", ";", x$Col.Meta[[i]])

  if ( "CreatedByHistory" %in% names(x$Header.Meta$HEADER) ) {
    x$Header.Meta$HEADER$CreatedByHistory <-
      paste0(x$Header.Meta$HEADER$CreatedBy,
             "|",
             x$Header.Meta$HEADER$CreatedByHistory)
  } else {
    x$Header.Meta$HEADER$CreatedByHistory <- x$Header.Meta$HEADER$CreatedBy
  }

  if ( "CreatedDateHistory" %in% names(x$Header.Meta$HEADER) ) {
    x$Header.Meta$HEADER$CreatedDateHistory <-
      paste0(x$Header.Meta$HEADER$CreatedDate,
             "|",
             x$Header.Meta$HEADER$CreatedDateHistory)
  } else {
    x$Header.Meta$HEADER$CreatedDateHistory <- x$Header.Meta$HEADER$CreatedDate
  }

  # version number stuff
  if ( !("Version" %in% names(x$Header.Meta$HEADER) &&
         x$Header.Meta$HEADER$Version == "1.2") ) {
    x$Header.Meta$HEADER$Version <- "1.2"
    .done("Updating ADAT version to: {.value('1.2')}")
  }

  x$Header.Meta$HEADER$CreatedDate <- format(Sys.time(), "%Y-%m-%d")
  user     <- ifelse(grepl("linux|darwin", R.version$platform),
                     Sys.getenv("USER"),
                     Sys.getenv("USERNAME"))
  pkg     <- utils::packageName()
  pkg_ver <- as.character(utils::packageVersion(pkg))

  x$Header.Meta$HEADER$CreatedBy <-
    sprintf("User: %s; Package: %s_%s; using %s; Platform: %s",
            user, pkg, pkg_ver, R.version$version.string, R.version$system)
  x
}
