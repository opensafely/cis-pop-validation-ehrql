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
    age = readr::col_double(),
    sex = readr::col_factor(),
    msoa = readr::col_factor(),
    stp = readr::col_factor(),
    region = readr::col_factor(),
    postest_01 = readr::col_logical(),
    primary_care_covid_case_01 = readr::col_logical(),
    covidemergency_01 = readr::col_logical(),
    covidadmitted_01 = readr::col_logical(),
    any_infection_or_disease_01 = readr::col_logical(),
    postest_14 = readr::col_logical(),
    primary_care_covid_case_14 = readr::col_logical(),
    covidemergency_14 = readr::col_logical(),
    covidadmitted_14 = readr::col_logical(),
    any_infection_or_disease_14 = readr::col_logical(),
    postest_ever = readr::col_logical(),
    primary_care_covid_case_ever = readr::col_logical(),
    covidemergency_ever = readr::col_logical(),
    covidadmitted_ever = readr::col_logical(),
    any_infection_or_disease_ever = readr::col_logical()
  )
)

# Extract opensafely method (cohortextractor vs ehrql) from file name
# This currently assumes that there is only 1 file for each method
# TODO: It might be helpful to also extract the date from the file name
df_outputs <- df_outputs %>%
  dplyr::mutate(opensafely = stringr::str_extract(
    file_name,
    "cohortextractor|ehrql"
  ),
  index_date = stringr::str_extract(
    file_name,
    "[:digit:]{4}-[:digit:]{2}-[:digit:]{2}")
  )


# Calculate summary statistics by group
df_summary <- df_outputs %>%
  dplyr::group_by(opensafely, index_date) %>%
  dplyr::summarise(
    n = dplyr::n(),
    n_female = sum(sex == "F" | sex == "female", na.rm = TRUE),
    n_male = sum(sex == "M" | sex == "male", na.rm = TRUE),
    min_age = round(min(age, na.rm = TRUE), -1),
    max_age = round(max(age, na.rm = TRUE), -1),
    median_age = median(age, na.rm = TRUE),
    sd_age = round(median(age, na.rm = TRUE), .1),
    unique_msoa = dplyr::n_distinct(msoa),
    unique_stp = dplyr::n_distinct(stp),
    unique_region = dplyr::n_distinct(region),
    sum_postest_01 = sum(postest_01, na.rm = TRUE),
    sum_primary_care_covid_case_01 = sum(primary_care_covid_case_01, na.rm = TRUE),
    sum_covidemergency_01 = sum(covidemergency_01, na.rm = TRUE),
    sum_covidadmitted_01 = sum(covidadmitted_01, na.rm = TRUE),
    sum_any_infection_or_disease_01 = sum(any_infection_or_disease_01, na.rm = TRUE),
    sum_postest_14 = sum(postest_14, na.rm = TRUE),
    sum_primary_care_covid_case_14 = sum(primary_care_covid_case_14, na.rm = TRUE),
    sum_covidemergency_14 = sum(covidemergency_14, na.rm = TRUE),
    sum_covidadmitted_14 = sum(covidadmitted_14, na.rm = TRUE),
    sum_any_infection_or_disease_14 = sum(any_infection_or_disease_14, na.rm = TRUE),
    sum_postest_ever = sum(postest_ever, na.rm = TRUE),
    sum_primary_care_covid_case_ever = sum(primary_care_covid_case_ever, na.rm = TRUE),
    sum_covidemergency_ever = sum(covidemergency_ever, na.rm = TRUE),
    sum_covidadmitted_ever = sum(covidadmitted_ever, na.rm = TRUE),
    sum_any_infection_or_disease_ever = sum(any_infection_or_disease_ever, na.rm = TRUE)
  )


# Create final dataframe for comparison
df_comparison <- df_summary %>%
  tidyr::pivot_longer(cols = c(
    n,
    n_female,
    n_male,
    min_age,
    max_age,
    median_age,
    sd_age,
    unique_msoa,
    unique_stp,
    unique_region,
    sum_postest_01,
    sum_primary_care_covid_case_01,
    sum_covidemergency_01,
    sum_covidadmitted_01,
    sum_any_infection_or_disease_01,
    sum_postest_14,
    sum_primary_care_covid_case_14,
    sum_covidemergency_14,
    sum_covidadmitted_14,
    sum_any_infection_or_disease_14,
    sum_postest_ever,
    sum_primary_care_covid_case_ever,
    sum_covidemergency_ever,
    sum_covidadmitted_ever,
    sum_any_infection_or_disease_ever
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
  dplyr::mutate(raw_diff = abs(cohortextractor - ehrql))


# Write dataframe for comparison to dataset_diff.csv
# First create new folder results
fs::dir_create(here::here("output", "diff"))
readr::write_csv(df_comparison, here::here("output", "diff", "dataset_diff_summary.csv"))
