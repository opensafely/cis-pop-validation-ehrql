from datetime import date, timedelta

from databuilder.ehrql import Dataset, case, when
from databuilder.tables.beta.tpp import (
    clinical_events,
    emergency_care_attendances,
    hospital_admissions,
    patients,
    practice_registrations,
    sgss_covid_all_tests,
)

import codelists
from analysis.variable_lib import (
    has_prior_event,
    combine_codelists,
    address_as_of,
    age_as_of,
    emergency_care_diagnosis_matches,
    has_died,
    hospitalisation_diagnosis_matches,
    practice_registration_as_of,
)

# COMBINE CODELISTS
# contraining primary care covid events
primary_care_covid_events = clinical_events.take(
    clinical_events.ctv3_code.is_in(
        combine_codelists(
            codelists.covid_primary_care_code,
            codelists.covid_primary_care_positive_test,
            codelists.covid_primary_care_sequelae,
        )
    )
)

# Set index date
# TODO this is just an example for testing, something like --index-date-range
# needs to be added https://github.com/opensafely-core/databuilder/issues/741
index_date = date(2022, 6, 1)

# Create dataset
dataset = Dataset()

###############################################################################
# Preprocessing data for later use
###############################################################################

address = address_as_of(index_date)
prior_events = clinical_events.take(clinical_events.date.is_on_or_before(index_date))
practice_reg = practice_registration_as_of(index_date)
prior_tests = sgss_covid_all_tests.take(
    sgss_covid_all_tests.specimen_taken_date.is_on_or_before(index_date)
)

###############################################################################
# Define and extract demographic dataset variables
###############################################################################

# Demographic variables
dataset.sex = patients.sex
dataset.age = age_as_of(index_date)
dataset.has_died = has_died(index_date)

# TPP care home flag
dataset.care_home_tpp = case(
    when(address.care_home_is_potential_match).then(True), default=False
)

# Patients in long-stay nursing and residential care
dataset.care_home_code = has_prior_event(clinical_events, codelists.carehome)

# Middle Super Output Area (MSOA)
dataset.msoa = address.msoa_code

# STP is an NHS administration region based on geography
dataset.stp = practice_reg.practice_stp

# NHS administrative region
dataset.region = practice_reg.practice_nuts1_region_name

###############################################################################
# Define and extract SINGLE-DAY EVENTS
# Did any event occur on this day?
###############################################################################

# Positive COVID test
dataset.postest_01 = prior_tests.take(
    (prior_tests.specimen_taken_date == index_date) & (prior_tests.is_positive)
).exists_for_patient()

# Positive case identification
dataset.primary_care_covid_case_01 = primary_care_covid_events.take(
    (clinical_events.date == index_date)
).exists_for_patient()

# Emergency attendance for COVID
dataset.covidemergency_01 = (
    emergency_care_diagnosis_matches(
        emergency_care_attendances, codelists.covid_emergency
    )
    .take(emergency_care_attendances.arrival_date == index_date)
    .exists_for_patient()
)

# COVID hospital admission
dataset.covidadmitted_01 = (
    hospitalisation_diagnosis_matches(hospital_admissions, codelists.covid_icd10)
    .take(hospital_admissions.admission_date == index_date)
    .take(
        hospital_admissions.admission_method.is_in(
            ["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"]
        )
    )
    .exists_for_patient()
)

# Composite single-day variable
dataset.any_infection_or_disease_01 = (
    dataset.postest_01
    | dataset.primary_care_covid_case_01
    | dataset.covidemergency_01
    | dataset.covidadmitted_01
)

###############################################################################
# Define and extract 14-DAY EVENTS
# Did any event occur within the last 14 days?
###############################################################################

# Positive COVID test
dataset.postest_14 = prior_tests.take(
    (prior_tests.specimen_taken_date >= (index_date - timedelta(days=14)))
    & (prior_tests.specimen_taken_date <= index_date)
    & (prior_tests.is_positive)
).exists_for_patient()

# Positive case identification
dataset.primary_care_covid_case_14 = primary_care_covid_events.take(
    (clinical_events.date >= (index_date - timedelta(days=14)))
    & (clinical_events.date <= index_date)
).exists_for_patient()

# Emergency attendance for COVID
dataset.covidemergency_14 = (
    emergency_care_diagnosis_matches(
        emergency_care_attendances, codelists.covid_emergency
    )
    .take(
        (emergency_care_attendances.arrival_date >= (index_date - timedelta(days=14)))
        & (emergency_care_attendances.arrival_date <= index_date)
    )
    .exists_for_patient()
)

# COVID hospital admission
dataset.covidadmitted_14 = (
    hospitalisation_diagnosis_matches(hospital_admissions, codelists.covid_icd10)
    .take(
        (hospital_admissions.admission_date >= (index_date - timedelta(days=14)))
        & (hospital_admissions.admission_date <= index_date)
    )
    .take(
        hospital_admissions.admission_method.is_in(
            ["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"]
        )
    )
    .exists_for_patient()
)

# Composite 14-day variable
dataset.any_infection_or_disease_14 = (
    dataset.postest_14
    | dataset.primary_care_covid_case_14
    | dataset.covidemergency_14
    | dataset.covidadmitted_14
)

###############################################################################
# Define and extract EVER-DAY EVENTS
# Did any event occur any time up to and including this day?
###############################################################################

# Positive COVID test
dataset.postest_ever = prior_tests.take(
    (prior_tests.specimen_taken_date <= index_date) & (prior_tests.is_positive)
).exists_for_patient()

# Positive case identification
dataset.primary_care_covid_case_ever = primary_care_covid_events.take(
    (clinical_events.date <= index_date)
).exists_for_patient()

# Emergency attendance for COVID
dataset.covidemergency_ever = (
    emergency_care_diagnosis_matches(
        emergency_care_attendances, codelists.covid_emergency
    )
    .take((emergency_care_attendances.arrival_date <= index_date))
    .exists_for_patient()
)

# COVID hospital admission
dataset.covidadmitted_ever = (
    hospitalisation_diagnosis_matches(hospital_admissions, codelists.covid_icd10)
    .take((hospital_admissions.admission_date <= index_date))
    .take(
        hospital_admissions.admission_method.is_in(
            ["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"]
        )
    )
    .exists_for_patient()
)

# Composite "ever" variable
dataset.any_infection_or_disease_ever = (
    dataset.postest_ever
    | dataset.primary_care_covid_case_ever
    | dataset.covidemergency_ever
    | dataset.covidadmitted_ever
)

###############################################################################
# Define dataset restrictions
###############################################################################

set_registered = practice_registrations.exists_for_patient()
set_sex_fm = (dataset.sex == "female") | (dataset.sex == "male")
set_age_ge2_le120 = (dataset.age >= 2) & (dataset.age <= 120)
set_has_not_died = ~dataset.has_died

###############################################################################
# Apply dataset restrictions and define study population
###############################################################################

dataset.set_population(
    set_registered & set_sex_fm & set_age_ge2_le120 & set_has_not_died
)
