# longflag

`longflag` is an R package for **identifying meaningful changes** over time in repeated-measures (longitudinal) data. 
It takes a long-format dataset and evaluates whether a meaningful change has occurred within subjects using one of three user-selected approaches.

---

## Rationale

In longitudinal studies, it is often important to flag subjects who experienced a clinically 
meaningful change in a variable of interest (for example, a large improvement or deterioration in a test score).

Manually computing and checking changes for each subject can be tedious and error-prone, especially 
when there are many timepoints. The `longflag()` function aims to streamline this process by:

- Allowing the user to **specify a numeric threshold** for what constitutes a “meaningful” change;
- Providing **three different methods** for defining change; and
- Returning a tidy tibble indicating which subjects or timepoint pairs meet the specified criteria.


---

## Function Overview

`longflag()` is intended for long-format data, where each row corresponds to one subject at one timepoint.

The user specifies:

- `data` – a data frame or tibble in long format  
- `id` – name of the subject ID column (character)  
- `time` – name of the time variable (character)  
- `value` – name of the numeric variable of interest (character)  
- `threshold` – numeric cutoff for what constitutes a meaningful change  
- `method` – one of `"first_last"`, `"mean_change"`, or `"all_timepoints"`


### Methods

`longflag()` currently supports three definitions of change:

- `"first_last"` – overall change from the first to the last observed value per subject.
- `"mean_change"` – mean of stepwise changes between consecutive timepoints.
- `"all_timepoints"` – change between each pair of consecutive timepoints.

---

## Installation

The development version of `longflag` can be installed from GitHub using the **devtools** package:

```r
install.packages("devtools")
library(devtools)

install_github("kathleenzang/longflag")
library(longflag)
```

---

## Example

Here is a simple example with a small synthetic dataset:

```r
library(longflag)

# Example dataset
test_data <- data.frame(
  Person = rep(1:3, each = 3),
  Time   = rep(c(1, 2, 3), 3),
  Score  = c(10, 12, 15,   20, 20, 22,   5, 5, 5)
)

test_data
```

### 1. Compare only first and last values

```r
res_first_last <- longflag(
  data      = test_data,
  id        = "Person",
  time      = "Time",
  value     = "Score",
  threshold = 3,
  method    = "first_last"
)

res_first_last
```

### 2. Compare mean of consecutive stepwise changes

```r
res_mean_change <- longflag(
  data      = test_data,
  id        = "Person",
  time      = "Time",
  value     = "Score",
  threshold = 2,
  method    = "mean_change"
)

res_mean_change
```

### 3. Compare every pair of consecutive timepoints

```r
res_all_timepoints <- longflag(
  data      = test_data,
  id        = "Person",
  time      = "Time",
  value     = "Score",
  threshold = 4,
  method    = "all_timepoints"
)

res_all_timepoints
```

---

## Included example dataset

The package also includes an example dataset, `dataset_ex`, illustrating a more realistic repeated-measures structure.

```r
data("dataset_ex")
head(dataset_ex)
```

This dataset is used in the vignette to demonstrate longflag() in more depth.

---

## References
Wickham H, Bryan J (2023). R Packages (2nd ed.)


## Vignette (HTML)

For a more detailed, step-by-step tutorial, see the vignette.

A rendered HTML version of the vignette is available here:  
https://htmlpreview.github.io/?https://raw.githubusercontent.com/kathleenzang/longflag/refs/heads/main/vignettes/longflag.html


## Credits

The `longflag` package was created by:

- Kathleen Zang – <kathleen.zang@mail.utoronto.ca>  
- Isha Sharma – <mail.isha24@gmail.com>  
This package was developed as part of CHL5233H: Statistical Programming and Computation for Health Data at the University of Toronto.
