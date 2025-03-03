#' Diff Two ADAT Objects
#'
#' Diff tool for the differences between two `soma_adat` objects.
#' When diffs of the table *values* are interrogated, **only**
#' the intersect of the column meta data or feature data is considered
#'
#' @param adat1 First `soma_adat` object.
#' @param adat2 Second `soma_adat` object.
#' @param tolerance Tolerance for the difference between
#' numeric vectors (i.e. SOMAmer/feature data). Passed to [all.equal()].
#' @note Diffs of the column *intersect* names are considered.
#' @author Stu Field
#' @examples
#' diffAdats(example_data, example_data)
#'
#' # remove random column
#' rm <- withr::with_seed(123, sample(1:ncol(example_data), 1))
#' diffAdats(example_data, example_data[, -rm])
#'
#' # change Subarray randomly
#' diffAdats(example_data, dplyr::mutate(example_data, Subarray = sample(Subarray)))
#'
#' # modify 2 RFUs randomly
#' new <- example_data
#' new[5, c(rm, rm + 1)] <- 999
#' diffAdats(example_data, new)
#' @export
diffAdats <- function(adat1, adat2, tolerance = 1e-06) {

  if ( !(inherits(adat1, "data.frame") & inherits(adat2, "data.frame")) ) {
    stop(
      "Both `adat1` & `adat2` must inherit from class `data.frame`.",
      call. = FALSE
    )
  }

  map_mark <- function(.x) {
    ifelse(.x, cr_green(symb_tick), cr_red(symb_cross))
  }

  writeLines(
    cli_rule(
      "Checking ADAT attributes & characteristics", line_col = "blue", line = 2
    )
  )

  # Attribute names ----
  pad <- 35
  mark <- names(attributes(adat1)) %==% names(attributes(adat2))
  msg  <- .pad("Attribute names are identical", width = pad) # nolint
  .todo("{msg} {map_mark(mark)}")

  # Attributes ----
  mark <- attributes(adat1) %==% attributes(adat2)
  msg  <- .pad("Attributes are identical", width = pad)
  .todo("{msg} {map_mark(mark)}")

  # ADAT dimensions ----
  mark <- all(dim(adat1) == dim(adat2))
  msg  <- .pad("ADAT dimensions are identical", width = pad)
  .todo("{msg} {map_mark(mark)}")

  if ( !mark ) {
    mark <- nrow(adat1) == nrow(adat2)
    msg  <- .pad("  ADATs have same # of rows", width = pad)
    .todo("{msg} {map_mark(mark)}")

    mark <- ncol(adat1) == ncol(adat2)
    msg  <- .pad("  ADATs have same # of columns", width = pad)
    .todo("{msg} {map_mark(mark)}")

    mark <- getAnalytes(adat1, n = TRUE) %==% getAnalytes(adat2, n = TRUE)
    msg  <- .pad("  ADATs have same # of features", width = pad)
    .todo("{msg} {map_mark(mark)}")

    mark <- getMeta(adat1, n = TRUE) %==% getMeta(adat2, n = TRUE)
    msg  <- .pad("  ADATs have same # of meta data", width = pad)
    .todo("{msg} {map_mark(mark)}")
  }

  # Adat row names ----
  mark <- rownames(adat1) %==% rownames(adat2)
  msg  <- .pad("ADAT row names are identical", width = pad)
  .todo("{msg} {map_mark(mark)}")

  # Adat feature names ----
  same_ft_names <- getAnalytes(adat1) %==% getAnalytes(adat2)
  msg <- .pad("ADATs contain identical Features", width = pad)
  .todo("{msg} {map_mark(same_ft_names)}")

  # Adat meta names ----
  same_meta_names <- getMeta(adat1) %==% getMeta(adat2)
  msg <- .pad("ADATs contain same Meta Fields", width = pad)
  .todo("{msg} {map_mark(same_meta_names)}")

  if ( !(same_meta_names & same_ft_names) ) {
    ipad    <- 20   # internal padding
    apts1_2 <- setdiff(getAnalytes(adat1), getAnalytes(adat2))
    apts2_1 <- setdiff(getAnalytes(adat2), getAnalytes(adat1))
    meta1_2 <- setdiff(getMeta(adat1), getMeta(adat2))
    meta2_1 <- setdiff(getMeta(adat2), getMeta(adat1))

    if ( length(apts1_2) > 0 ) {
      sprintf(
        "Features in %s but not %s:",
        .value(deparse(substitute(adat1))),
        .value(deparse(substitute(adat2)))
      ) %>% writeLines()
      lapply(.pad(apts1_2, ipad, "left"), writeLines)
    }

    if ( length(apts2_1) > 0 ) {
      sprintf(
        "Features in %s but not %s:",
        .value(deparse(substitute(adat2))),
        .value(deparse(substitute(adat1)))
      ) %>% writeLines()
      lapply(.pad(apts2_1, ipad, "left"), writeLines)
    }

    if ( length(meta1_2) > 0 ) {
      sprintf(
        "Meta data in %s but not %s:",
        .value(deparse(substitute(adat1))),
        .value(deparse(substitute(adat2)))
      ) %>% writeLines()
      lapply(.pad(meta1_2, ipad, "left"), writeLines)
    }

    if ( length(meta2_1) > 0 ) {
      sprintf(
        "Meta data in %s but not %s:",
        .value(deparse(substitute(adat2))),
        .value(deparse(substitute(adat1)))
      ) %>% writeLines()
      lapply(.pad(meta2_1, ipad, "left"), writeLines)
    }
    cat("\n")
    .done(
      "Continuing on the {.value('*INTERSECT*')} of ADAT columns"
    )
  }

  # up to here, all but content/values identical
  # Next -> check values
  writeLines(cli_rule("Checking the data matrix", line_col = "blue"))
  .diffAdatColumns(adat1, adat2, meta = TRUE)
  .diffAdatColumns(adat1, adat2, tolerance = tolerance)
  writeLines(cli_rule(line_col = "green", line = 2))
}


#' Diff Columns of an ADAT
#'
#' This function checks either the feature or meta data
#' of an ADAT object. It diffs the values in each column
#' against each other
#'
#' @note This function is an internal only -> to `diffAdats()`
#'
#' @param x First ADAT to check.
#' @param y Second ADAT to check.
#' @param meta Logical. Whether to check the meta data columns.
#' Otherwise, feature data is checked.
#' @param tolerance Numeric level of tolerance.
#' @author Stu Field
#' @keywords internal
#' @noRd
.diffAdatColumns <- function(x, y, meta = FALSE, tolerance) {

  type <- ifelse(meta, "Clinical", "Feature")
  .fun <- switch(type, Clinical = getMeta, Feature = getAnalytes)
  args <- switch(type, Clinical = list(check.names = FALSE),
                       Feature  = list(tolerance = tolerance))
  f_bool <- function(col) {
    args$target  <- x[[col]]
    args$current <- y[[col]]
    isTRUE(do.call(all.equal, args))
  }
  diff_lgl <- !vapply(intersect(.fun(x), .fun(y)), f_bool, NA) # vars that differ
  msg <- .pad(sprintf("All %s data is identical", type), 35)

  if ( any(diff_lgl) ) {
    .todo("{msg} {cr_red(symb_cross)}")
    prnt <- paste(.pad("    No. fields that differ ", 37), sum(diff_lgl))
    writeLines(prnt)
    writeLines(cli_rule(sprintf("%s data diffs", type), line_col = "magenta"))
    print(.value(names(Filter(isTRUE, diff_lgl))))
  } else {
    .todo("{msg} {cr_green(symb_tick)}")
  }
  invisible(NULL)
}
