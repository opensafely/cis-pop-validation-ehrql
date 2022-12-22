# cis-pop-validation-ehrql

This project translates parts of the original [CIS-pop-validation](https://github.com/opensafely/CIS-pop-validation) study written using [cohort-extractor](https://github.com/opensafely-core/cohort-extractor) into [ehrQL (Electronic Health Record Query Language](https://docs.opensafely.org/ehrql-intro/) using [databuilder](https://github.com/opensafely-core/databuilder).
The aim of this project is to compare the populations defined by each method (`cohort-extractor` vs `databuilder`).

## Project navigation

### cohort-extractor implementation

- Study definition: [analysis/study_definition.py](analysis/study_definition.py)
- Clinical codes: [analysis/codelists_cohortextractor.py](analysis/codelists_cohortextractor.py)

### ehrQL translation

- Dataset definition: [analysis/dataset_definition.py](analysis/dataset_definition.py)
- Clinical codes: [analysis/codelists_ehrql.py](analysis/codelists_ehrql.py)

### Analysis of differences 

- Analysis script: [analysis/dataset_diff.R](analysis/dataset_diff.R)

### Dummy data

The dummy data in [dummy_data/](dummy_data/) was manually defined to test whether the results of the dataset definition are as expected (see [tests/test_datasets.py](tests/test_datasets.py)).

# About the OpenSAFELY framework

The OpenSAFELY framework is a Trusted Research Environment (TRE) for electronic
health records research in the NHS, with a focus on public accountability and
research quality.

Read more at [OpenSAFELY.org](https://opensafely.org).

# Licences
As standard, research projects have a MIT license. 
