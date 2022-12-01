# Load packages
library(magrittr)

# Get output files
dir_outputs <- fs::dir_ls(path = "output", glob = "*.csv$")


# Read outputfiles into one dataframe
# Convert all variables to appropriate type
df_outputs <- purrr::map_dfr(dir_outputs,
  readr::read_csv,
  .id = "file_name",
  col_types = list(
    patient_id = readr::col_integer(),
    registered = readr::col_logical(),
    sex = readr::col_character(),
    age = readr::col_double(),
    msoa = readr::col_logical(),
    has_died = readr::col_logical(),
    care_home_tpp = readr::col_character(),
    care_home_code = readr::col_logical(),
    included = readr::col_logical()
  )
) %>%
  dplyr::relocate(
    patient_id, registered, sex, age, msoa, has_died,
    care_home_tpp, care_home_code, included
  ) %>%
  dplyr::arrange(patient_id)

# Extract opensafely method (cohortextractor vs ehrql) from file name
# This currently assumes that there is only 1 file for each method
# TODO: It might be helpful to also extract the date from the file name
pattern_opensafely <- "cohortextractor|ehrql"
pattern_date <- "[:digit:]{4}-[:digit:]{2}-[:digit:]{2}"

df_outputs <- dplyr::mutate(df_outputs,
  opensafely = stringr::str_extract(file_name, pattern_opensafely),
  index_date = stringr::str_extract(file_name, pattern_date)
)

# Calculate summary statistics by group
df_summary <- df_outputs %>%
  dplyr::select(-file_name) %>%
  dplyr::group_by(opensafely, index_date) %>%
  dplyr::summarise(
    n = dplyr::n(),
    min_age = round(min(age, na.rm = TRUE), -1),
    max_age = round(max(age, na.rm = TRUE), -1),
    median_age = median(age, na.rm = TRUE),
    sd_age = round(median(age, na.rm = TRUE), .1),
    n_female = sum(sex == "F" | sex == "female", na.rm = TRUE),
    n_male = sum(sex == "M" | sex == "male", na.rm = TRUE),
    n_registered = sum(registered, na.rm = TRUE),
    n_msoa = sum(msoa, na.rm = TRUE),
    n_has_died = sum(has_died, na.rm = TRUE),
    n_care_home_tpp = sum(care_home_tpp == "care_or_nursing_home" | care_home_tpp == "T", na.rm = TRUE),
    n_care_home_code = sum(care_home_code, na.rm = TRUE),
    n_included = sum(included, na.rm = TRUE),
    n_included_missing = sum(is.na(included))
  )


# Create final dataframe for comparison
df_comparison <- df_summary %>%
  tidyr::pivot_longer(cols = c(
    n,
    min_age,
    max_age,
    median_age,
    sd_age,
    n_female,
    n_male,
    n_registered,
    n_msoa,
    n_has_died,
    n_care_home_tpp,
    n_care_home_code,
    n_included,
    n_included_missing
  ), names_to = "comparison") %>%
  tidyr::pivot_wider(
    id_cols = c(comparison, index_date),
    names_from = opensafely,
    values_from = value
  ) %>%
  dplyr::mutate(
    cohortextractor = round(cohortextractor, -1),
    ehrql = round(ehrql, -1)
  ) %>%
  dplyr::mutate(raw_diff = cohortextractor - ehrql)


# Write dataframe for comparison to dataset_diff.csv
# First create new folder results
fs::dir_create(here::here("output", "diff"))
readr::write_csv(df_comparison, here::here("output", "diff", "dataset_diff_summary.csv"))
