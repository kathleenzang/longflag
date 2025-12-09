#' Example longitudinal dataset
#'
#' A small example dataset used to demonstrate the `longflag()` function.
#'
#' @format A data frame with 50 rows and 3 variables:
#' \describe{
#'   \item{Person}{Integer ID of the subject.}
#'   \item{Time}{Numeric timepoint or visit number.}
#'   \item{Score}{Numeric outcome measured at each timepoint.}
#' }
#'
#' @usage data("dataset_ex")
#'
#' @source Simulated data for teaching purposes.
"dataset_ex"


#' Internal global variable definitions
#'
#' This is used for R CMD check NOTES about variables that are
#' created by dplyr pipelines (non-standard evaluation).
#'
#' @noRd
utils::globalVariables(c(
  "ID", "Time", "Value",
  "first_value", "last_value", "change", "step_change",
  "from_time", "to_time", "flagged"
))
