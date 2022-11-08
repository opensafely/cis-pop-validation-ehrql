from datetime import date, timedelta

from databuilder.ehrql import Dataset
from databuilder.tables.beta.tpp import patients

from variable_lib import (
    age_as_of,
    has_died,
)


index_date = date(2022, 9, 25)

dataset = Dataset()

# Demographic variables
dataset.sex = patients.sex
dataset.age = age_as_of(index_date)

# Select the study population: only living women between 2 and 120
is_female = (dataset.sex == "female")
is_between_2_and_120 = (dataset.age >=2) & (dataset.age <= 120)

dataset.set_population(is_female & is_between_2_and_120)
