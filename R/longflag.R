#' Flag meaningful changes across repeated timepoints within subjects
#'
#' \code{longflag()} identifies changes in a repeated-measures dataset based on
#' selected methods. The function takes a long-format dataset and evaluates
#' whether a meaningful change has occurred using one of three approaches.
#'
#'
#' @param data A long-format data frame or tibble containing repeated observations.
#' @param id A string supplying the column name representing unique subject IDs.
#' @param time A string supplying the column name representing the ordered timepoints.
#' @param value A string supplying the column name of the numeric variable to evaluate.
#' @param threshold User-defined numeric cutoff defining what magnitude of change should be flagged.
#' @param method One of \code{first_last}, \code{mean_change}, or \code{all_timepoints}.
#'   Determines how change is calculated. See details.
#'
#' @details
#'
#' The meaningful change logic depends on the chosen method:
#'
#' \itemize{
#'   \item \code{first_last}: Change is defined as:
#' \deqn{change = \text{last(value)} - \text{first(value)}}
#'   \item \code{mean_change}: Mean of all stepwise changes.
#'   \item \code{all_timepoints}: Returns a row-wise change between consecutive timepoints.}
#'
#'
#' A subject or timepoint pair is flagged when the magnitude of change meets or exceeds a user-defined \code{threshold}.
#'
#' @returns
#' A tibble summarizing observed changes:
#'
#' If \code{method = first_last} or \code{mean_change}:
#' \itemize{
#' \item One row per subject.
#' \item Columns: \code{ID}, \code{change}, \code{flagged} (plus method-specific summary columns).
#' \item Column \code{flagged} being a logical indicator corresponding to the user-defined threshold.}
#'
#' If \code{method = all_timepoints}:
#' \itemize{
#' \item One row per subject-time comparison.
#' \item Produces multiple rows per subject, comparing each timepoint to the previous one.
#' \item For the first timepoint, no previous comparison exists, so \code{NA} is returned by design.
#' \item Columns: \code{ID}, \code{from_time}, \code{to_time}, \code{change}, \code{flagged}}
#'
#' @export
#'
#' @importFrom dplyr %>% group_by summarise mutate arrange lag ungroup
#' @importFrom stats quantile
#'
#' @examples
#' # Example dataset
#' test_data <- data.frame(
#'   Person = rep(1:3, each = 3),
#'   Time = rep(c(1, 2, 3), 3),
#'   Score = c(10, 12, 15,   20, 20, 22,   5, 5, 5)
#' )
#'
#' # Example 1: Compare only first and last values
#' longflag(
#'   data = test_data,
#'   id = "Person",
#'   time = "Time",
#'   value = "Score",
#'   threshold = 3,
#'   method = "first_last"
#' )
#'
#' # Example 2: Compare mean of consecutive stepwise changes
#' longflag(
#'   data = test_data,
#'   id = "Person",
#'   time = "Time",
#'   value = "Score",
#'   threshold = 2,
#'   method = "mean_change"
#' )
#'
#' # Example 3: Compare consecutive timepoints
#' longflag(
#'   data = test_data,
#'   id = "Person",
#'   time = "Time",
#'   value = "Score",
#'   threshold = 4,
#'   method = "all_timepoints"
#' )
#'

longflag <- function(data, id, time, value, threshold,
                                 method = c("first_last", "mean_change", "all_timepoints")) {

  method <- match.arg(method)

  df <- data[, c(id, time, value)]
  colnames(df) <- c("ID", "Time", "Value")

  df <- df %>%
    dplyr::mutate(
      Time = as.numeric(Time),
      Value = as.numeric(Value)
    ) %>%
    dplyr::arrange(ID, Time)


  if (method == "first_last") {
    return(
      df %>%
        dplyr::group_by(ID) %>%
        dplyr::summarise(
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
        dplyr::group_by(ID) %>%
        dplyr::mutate(step_change = Value - lag(Value)) %>%
        dplyr::filter(!is.na(step_change)) %>%
        dplyr::summarise(
          change = mean(step_change),
          flagged = abs(change) >= threshold,
          .groups = "drop"
        )
    )
  }

  if (method == "all_timepoints") {
    return(
      df %>%
        dplyr::group_by(ID) %>%
        dplyr::mutate(
          from_time = Time,
          to_time   = lead(Time),
          change    = lead(Value) - Value
        ) %>%
        dplyr::filter(!is.na(change)) %>%
        dplyr::mutate(flagged = abs(change) >= threshold) %>%
        dplyr::select(ID, from_time, to_time, change, flagged)
    )
  }
}
