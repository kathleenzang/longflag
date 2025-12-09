test_that("longflag works correctly on dataset_ex", {

  # first_last method
  res_first_last <- longflag(dataset_ex,
                             id = "Person",
                             time = "Time",
                             value = "Score",
                             threshold = 3,
                             method = "first_last")
  expect_true(all(c("ID", "first_value", "last_value", "change", "flagged") %in% colnames(res_first_last)))
  expect_equal(res_first_last$change, c(6, 5, 2, 4, 4, 2, 3, 4, 2, 4))
  expect_equal(res_first_last$flagged, c(TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE))

  # mean_change method
  res_mean_change <- longflag(dataset_ex,
                              id = "Person",
                              time = "Time",
                              value = "Score",
                              threshold = 2,
                              method = "mean_change")
  expect_true(all(c("ID", "change", "flagged") %in% colnames(res_mean_change)))
  expect_type(res_mean_change$flagged, "logical")

  # all_timepoints method
  res_all_timepoints <- longflag(dataset_ex,
                                 id = "Person",
                                 time = "Time",
                                 value = "Score",
                                 threshold = 4,
                                 method = "all_timepoints")
  expect_true(all(c("ID", "from_time", "to_time", "change", "flagged") %in% colnames(res_all_timepoints)))
  expect_type(res_all_timepoints$flagged, "logical")
  # There should be 4 comparisons per subject (5 timepoints → 4 changes)
  expect_equal(nrow(res_all_timepoints), 10 * 4)
})


