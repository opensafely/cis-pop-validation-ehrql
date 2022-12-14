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
    msoa = readr::col_character(),
    has_died = readr::col_logical(),
    care_home_tpp = readr::col_character(),
    care_home_code = readr::col_logical(),
    stp = readr::col_character(),
    region = readr::col_character(),
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
) %>%
  dplyr::select(
    patient_id, registered, sex, age, msoa, has_died,
    care_home_tpp, care_home_code, file_name
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


# Calculate summary statistics by group ----
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
    n_msoa = sum(!is.na(msoa)),
    n_msoa_missing = sum(is.na(msoa)),
    n_unique_msoa = dplyr::n_distinct(msoa),
    n_registered = sum(registered, na.rm = TRUE),
    n_registered_missing = sum(is.na(registered)),
    n_has_died = sum(has_died, na.rm = TRUE),
    n_has_died_missing = sum(is.na(has_died)),
    n_care_home_tpp = sum(care_home_tpp == "care_or_nursing_home" | care_home_tpp == "T", na.rm = TRUE),
    n_care_home_tpp_missing = sum(is.na(care_home_tpp) | is.na(care_home_tpp)),
    n_care_home_code = sum(care_home_code, na.rm = TRUE),
    n_care_home_code_missing = sum(is.na(care_home_code))
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
    n_msoa,
    n_msoa_missing,
    n_unique_msoa,
    n_registered,
    n_registered_missing,
    n_has_died,
    n_has_died_missing,
    n_care_home_tpp,
    n_care_home_tpp_missing,
    n_care_home_code,
    n_care_home_code_missing
  ), names_to = "comparison") %>%
  dplyr::mutate(
    value = round(value, -1)
  ) %>%
  tidyr::pivot_wider(
    id_cols = c(comparison, index_date),
    names_from = opensafely,
    values_from = value
  ) %>%
  dplyr::mutate(raw_diff = cohortextractor - ehrql)


# Write dataframe for comparison to dataset_diff.csv
# First create new folder results
fs::dir_create(here::here("output", "diff"))
readr::write_csv(df_comparison, here::here("output", "diff", "dataset_diff_summary.csv"))


# Explore differences in care_home_tpp
df_comparison_care_home_tpp <- df_outputs %>%
  dplyr::group_by(
    opensafely,
    index_date,
    care_home_tpp,
    registered
  ) %>%
  dplyr::count() %>%
  dplyr::mutate(n = round(n, -1))

readr::write_csv(df_comparison_care_home_tpp, here::here("output", "diff", "dataset_diff_care_home_tpp.csv"))


# Explore differences by sex
df_comparison_sex <- df_outputs %>%
  dplyr::group_by(
    opensafely,
    index_date,
    sex
  ) %>%
  dplyr::count() %>%
  dplyr::mutate(n = round(n, -1))

readr::write_csv(df_comparison_sex, here::here("output", "diff", "dataset_diff_sex.csv"))
