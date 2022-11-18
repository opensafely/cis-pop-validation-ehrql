# To test dataset definition run the following command in the terminal:
# pytest tests/test_dataset_definition.py
import os

import pandas as pd


def test_dataset_definition():
    # arrange
    cwd = os.getcwd()
    df_output = pd.read_csv(f"{cwd}/output/dataset_ehrql_2022-09-25.csv")

    # act
    pt7 = df_output.iloc[0].to_dict()

    # assert
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
