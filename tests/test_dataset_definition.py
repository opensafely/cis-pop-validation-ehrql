# To test dataset definition run the following command in the terminal:
# pytest tests/test_dataset_definition.py
import os

import pandas as pd
import pytest


def test_dataset_definition():
    # arrange
    cwd = os.getcwd()
    df_output = pd.read_csv(f"{cwd}/output/dataset.csv")

    # act
    pt2 = df_output.iloc[0].to_dict()
    pt3 = df_output.iloc[1].to_dict()
    pt7 = df_output.iloc[2].to_dict()

    # assert
    assert pt2 == {
        "patient_id": 2,
        "sex": "female",
        "age": 72,
        "has_died": "F",
        "care_home_tpp": "F",
        "care_home_code": "T",
        "msoa": 1,
        "stp": 1,
        "region": "region_practice1",
        "postest_01": "T",
        "postest_14": "T",
        "postest_ever": "T",
        "primary_care_covid_case_01": "T",
        "primary_care_covid_case_14": "T",
        "primary_care_covid_case_ever": "T",
        "covidemergency_01": "T",
        "covidemergency_14": "T",
        "covidemergency_ever": "T",
        "covidadmitted_01": "T",
        "covidadmitted_14": "T",
        "covidadmitted_ever": "T",
        "any_infection_or_disease_01": "T",
        "any_infection_or_disease_14": "T",
        "any_infection_or_disease_ever": "T",
    }
    assert pt3 == {
        "patient_id": 3,
        "sex": "female",
        "age": 62,
        "has_died": "F",
        "care_home_tpp": "T",
        "care_home_code": "T",
        "msoa": 1,
        "stp": 2,
        "region": "region_practice2",
        "postest_01": "F",
        "postest_14": "T",
        "postest_ever": "T",
        "primary_care_covid_case_01": "F",
        "primary_care_covid_case_14": "T",
        "primary_care_covid_case_ever": "T",
        "covidemergency_01": "F",
        "covidemergency_14": "T",
        "covidemergency_ever": "T",
        "covidadmitted_01": "F",
        "covidadmitted_14": "T",
        "covidadmitted_ever": "T",
        "any_infection_or_disease_01": "F",
        "any_infection_or_disease_14": "T",
        "any_infection_or_disease_ever": "T",
    }
    assert pt7 == {
        "patient_id": 7,
        "sex": "male",
        "age": 22,
        "has_died": "F",
        "care_home_tpp": "F",
        "care_home_code": "F",
        "msoa": 1,
        "stp": 3,
        "region": "region_practice3",
        "postest_01": "F",
        "postest_14": "F",
        "postest_ever": "T",
        "primary_care_covid_case_01": "F",
        "primary_care_covid_case_14": "F",
        "primary_care_covid_case_ever": "F",
        "covidemergency_01": "F",
        "covidemergency_14": "F",
        "covidemergency_ever": "F",
        "covidadmitted_01": "F",
        "covidadmitted_14": "F",
        "covidadmitted_ever": "T",
        "any_infection_or_disease_01": "F",
        "any_infection_or_disease_14": "F",
        "any_infection_or_disease_ever": "T",
    }
