from pathlib import Path

from databuilder.codes import REGISTRY, Codelist, codelist_from_csv

CODELIST_DIR = Path("codelists")


def codelist(codes, system):
    code_class = REGISTRY[system]
    return Codelist(
        codes={code_class(code) for code in codes},
        category_maps={},
    )


covid_icd10 = codelist_from_csv(
    CODELIST_DIR / "opensafely-covid-identification.csv",
    system="icd10",
    column="icd10_code",
)

covid_emergency = codelist(
    ["1240751000000100"],
    system="snomedct",
)

covid_primary_care_positive_test = codelist_from_csv(
    CODELIST_DIR / "opensafely-covid-identification-in-primary-care-probable-covid-positive-test.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_primary_care_code = codelist_from_csv(
    CODELIST_DIR / "opensafely-covid-identification-in-primary-care-probable-covid-clinical-code.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_primary_care_sequelae = codelist_from_csv(
    CODELIST_DIR / "opensafely-covid-identification-in-primary-care-probable-covid-sequelae.csv",
    system="ctv3",
    column="CTV3ID",
)

ethnicity = codelist_from_csv(
    CODELIST_DIR / "opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
)

carehome = codelist_from_csv(
    CODELIST_DIR / "primis-covid19-vacc-uptake-longres.csv",
    system="snomedct",
    column="code",
)
