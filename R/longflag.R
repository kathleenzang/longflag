#' Flag meaningful changes across repeated timepoints within subjects
#'
#' `longflag()` identifies changes in a repeated-measures dataset based on
#' selected methods. The function takes a long-format dataset and evaluates
#' whether meaningful change has occurred using one of three approaches:
#'
#' * `"first_last"` – change = last value – first value
#' * `"mean_change"` – change = mean(value) – first value
#' * `"all_timepoints"` – returns a row-wise change between consecutive timepoints
#'
#' @param data A long-format data frame or tibble containing repeated observations.
#' @param id A string supplying the column name representing unique subject IDs.
#' @param time A string supplying the column name representing the ordered timepoints.
#' @param value A string supplying the column name of the numeric variable to evaluate.
#' @param threshold Numeric cutoff defining what magnitude of change should be flagged.
#' @param method One of `"first_last"`, `"mean_change"`, or `"all_timepoints"`.
#'   Determines how change is calculated. See details.
#'
#' @details
#' The change logic depends on the chosen method:
#'
#' **Method `"first_last"`**
#' Produces one row per subject. Change is defined as:
#' \deqn{change = last(value) - first(value)}
#'
#' **Method `"mean_change"`**
#' Produces one row per subject. Change is defined as:
#' \deqn{change = mean(value) - first(value)}
#'
#' **Method `"all_timepoints"`**
#' Produces multiple rows per subject, comparing each timepoint to the previous one.
#' For the first timepoint, no previous comparison exists, so `NA` is returned by design.
#'
#' A subject or timepoint pair is flagged when the magnitude of change meets or exceeds
#' `threshold`.
#'
#' @returns
#' A tibble summarizing observed changes:
#'
#' If `method = "first_last"` or `"mean_change"`:
#'   * one row per subject
#'   * columns: ID, change, flagged (plus method-specific summary columns)
#'
#' If `method = "all_timepoints"`:
#'   * one row per subject-time comparison
#'   * columns: ID, from_time, to_time, change, flagged
#'
#' @export
#'
#' @importFrom dplyr %>% group_by summarise mutate arrange lag ungroup
#' @importFrom stats quantile
#'
#' @examples
#' ## Example dataset
#' test_data <- data.frame(
#'   Person = rep(1:3, each = 3),
#'   Time = rep(c(1, 2, 3), 3),
#'   Score = c(10, 12, 15,   20, 20, 22,   5, 5, 5)
#' )
#'
#' ## Example 1: Compare only first and last values
#' longflag(
#'   data = test_data,
#'   id = "Person",
#'   time = "Time",
#'   value = "Score",
#'   threshold = 3,
#'   method = "first_last"
#' )
#'
#' ## Example 2: Compare mean value to first value
#' longflag(
#'   data = test_data,
#'   id = "Person",
#'   time = "Time",
#'   value = "Score",
#'   threshold = 2,
#'   method = "mean_change"
#' )
#'
#' ## Example 3: Compare consecutive timepoints
#' longflag(
#'   data = test_data,
#'   id = "Person",
#'   time = "Time",
#'   value = "Score",
#'   threshold = 4,
#'   method = "all_timepoints"
#' )

longflag <- function(data, id, time, value, threshold,
                                 method = c("first_last", "mean_change", "all_timepoints")) {

  method <- match.arg(method)

  library(dplyr)

  df <- data[, c(id, time, value)]
  colnames(df) <- c("ID", "Time", "Value")

  df <- df %>%
    mutate(
      ID = as.integer(ID),
      Time = as.numeric(Time),
      Value = as.numeric(Value)
    ) %>%
    arrange(ID, Time)


  if (method == "first_last") {
    return(
      df %>%
        group_by(ID) %>%
        summarise(
          first_value = first(Value),
          last_value = last(Value),
          change = last_value - first_value,
          flagged = abs(change) >= threshold,
          .groups = "drop"
        )
    )
  }

  if (method == "mean_change") {
    return(
      df %>%
        group_by(ID) %>%
        mutate(step_change = Value - lag(Value)) %>%
        filter(!is.na(step_change)) %>%
        summarise(
          change = mean(step_change),
          flagged = abs(change) >= threshold,
          .groups = "drop"
        )
    )
  }

  if (method == "all_timepoints") {
    return(
      df %>%
        group_by(ID) %>%
        mutate(
          from_time = Time,
          to_time   = lead(Time),
          change    = lead(Value) - Value
        ) %>%
        filter(!is.na(change)) %>%
        mutate(flagged = abs(change) >= threshold) %>%
        select(ID, from_time, to_time, change, flagged)
    )
  }
}
