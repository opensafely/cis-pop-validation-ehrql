-- Setup query 001 / 036
SELECT * INTO [#tmp_1] FROM (SELECT anon_2.patient_id AS patient_id, anon_2.msoa_code AS msoa_code, anon_2.care_home_is_potential_match AS care_home_is_potential_match 
FROM (SELECT addresses.patient_id AS patient_id, addresses.msoa_code AS msoa_code, addresses.care_home_is_potential_match AS care_home_is_potential_match, row_number() OVER (PARTITION BY addresses.patient_id ORDER BY addresses.start_date, addresses.end_date, CASE WHEN (addresses.has_postcode = 1) THEN 1 ELSE 0 END, addresses.address_id, CASE WHEN (addresses.care_home_is_potential_match = 1) THEN 2 WHEN (addresses.care_home_is_potential_match != 1) THEN 1 ELSE 0 END, addresses.msoa_code) AS anon_3 
FROM (
            SELECT
                addr.Patient_ID AS patient_id,
                addr.PatientAddress_ID AS address_id,
                addr.StartDate AS start_date,
                addr.EndDate AS end_date,
                addr.AddressType AS address_type,
                addr.RuralUrbanClassificationCode AS rural_urban_classification,
                addr.ImdRankRounded AS imd_rounded,
                CASE
                    WHEN addr.MSOACode != 'NPC' THEN addr.MSOACode
                END AS msoa_code,
                CASE
                    WHEN addr.MSOACode != 'NPC' THEN 1
                    ELSE 0
                END AS has_postcode,
                CASE
                    WHEN carehm.PatientAddress_ID IS NOT NULL THEN 1
                    ELSE 0
                END AS care_home_is_potential_match,
                CASE
                    WHEN carehm.LocationRequiresNursing = 'Y' THEN 1
                    WHEN carehm.LocationRequiresNursing = 'N' THEN 0
                 END AS care_home_requires_nursing,
                CASE
                    WHEN carehm.LocationDoesNotRequireNursing = 'Y' THEN 1
                    WHEN carehm.LocationDoesNotRequireNursing = 'N' THEN 0
                 END AS care_home_does_not_require_nursing
            FROM PatientAddress AS addr
            LEFT JOIN PotentialCareHomeAddress AS carehm
            ON addr.PatientAddress_ID = carehm.PatientAddress_ID
        ) AS addresses 
WHERE addresses.start_date <= '20220925' AND (addresses.end_date > '20220925' OR addresses.end_date IS NULL)) AS anon_2 
WHERE anon_2.anon_3 = 1) AS anon_1;

-- Setup query 002 / 036
CREATE CLUSTERED INDEX [ix_#tmp_1_patient_id] ON [#tmp_1] (patient_id);

-- Setup query 003 / 036
SELECT * INTO [#tmp_15] FROM (SELECT DISTINCT practice_registrations.patient_id AS patient_id 
FROM (
            SELECT
                reg.Patient_ID AS patient_id,
                reg.StartDate AS start_date,
                reg.EndDate AS end_date,
                org.Organisation_ID AS practice_pseudo_id,
                org.STPCode AS practice_stp,
                org.Region AS practice_nuts1_region_name
            FROM RegistrationHistory AS reg
            LEFT OUTER JOIN Organisation AS org
            ON reg.Organisation_ID = org.Organisation_ID
        ) AS practice_registrations) AS anon_1;

-- Setup query 004 / 036
CREATE CLUSTERED INDEX [ix_#tmp_15_patient_id] ON [#tmp_15] (patient_id);

-- Setup query 005 / 036
SELECT * INTO [#tmp_16] FROM (SELECT DISTINCT clinical_events.patient_id AS patient_id 
FROM (
            SELECT
                Patient_ID AS patient_id,
                CAST(ConsultationDate AS date) AS date,
                NULL AS snomedct_code,
                CTV3Code AS ctv3_code,
                NumericValue AS numeric_value
            FROM CodedEvent
            UNION ALL
            SELECT
                Patient_ID AS patient_id,
                CAST(ConsultationDate AS date) AS date,
                ConceptID AS snomedct_code,
                NULL AS ctv3_code,
                NumericValue AS numeric_value
            FROM CodedEvent_SNOMED
        ) AS clinical_events 
WHERE 1 = 1 AND clinical_events.snomedct_code IN ('394923006', '1024771000000108', '224224003', '248171000000108', '160734000', '160737007')) AS anon_1;

-- Setup query 006 / 036
CREATE CLUSTERED INDEX [ix_#tmp_16_patient_id] ON [#tmp_16] (patient_id);

-- Setup query 007 / 036
SELECT * INTO [#tmp_2] FROM (SELECT anon_2.patient_id AS patient_id, anon_2.practice_stp AS practice_stp, anon_2.practice_nuts1_region_name AS practice_nuts1_region_name 
FROM (SELECT practice_registrations.patient_id AS patient_id, practice_registrations.practice_stp AS practice_stp, practice_registrations.practice_nuts1_region_name AS practice_nuts1_region_name, row_number() OVER (PARTITION BY practice_registrations.patient_id ORDER BY practice_registrations.start_date, practice_registrations.end_date, practice_registrations.practice_nuts1_region_name, practice_registrations.practice_stp) AS anon_3 
FROM (
            SELECT
                reg.Patient_ID AS patient_id,
                reg.StartDate AS start_date,
                reg.EndDate AS end_date,
                org.Organisation_ID AS practice_pseudo_id,
                org.STPCode AS practice_stp,
                org.Region AS practice_nuts1_region_name
            FROM RegistrationHistory AS reg
            LEFT OUTER JOIN Organisation AS org
            ON reg.Organisation_ID = org.Organisation_ID
        ) AS practice_registrations 
WHERE practice_registrations.start_date <= '20220925' AND (practice_registrations.end_date > '20220925' OR practice_registrations.end_date IS NULL)) AS anon_2 
WHERE anon_2.anon_3 = 1) AS anon_1;

-- Setup query 008 / 036
CREATE CLUSTERED INDEX [ix_#tmp_2_patient_id] ON [#tmp_2] (patient_id);

-- Setup query 009 / 036
SELECT * INTO [#tmp_3] FROM (SELECT DISTINCT sgss_covid_all_tests.patient_id AS patient_id 
FROM (
            SELECT
                Patient_ID AS patient_id,
                Specimen_Date AS specimen_taken_date,
                1 AS is_positive
            FROM SGSS_AllTests_Positive
            UNION ALL
            SELECT
                Patient_ID AS patient_id,
                Specimen_Date AS specimen_taken_date,
                0 AS is_positive
            FROM SGSS_AllTests_Negative
        ) AS sgss_covid_all_tests 
WHERE sgss_covid_all_tests.specimen_taken_date <= '20220925' AND sgss_covid_all_tests.specimen_taken_date = '20220925' AND sgss_covid_all_tests.is_positive = 1) AS anon_1;

-- Setup query 010 / 036
CREATE CLUSTERED INDEX [ix_#tmp_3_patient_id] ON [#tmp_3] (patient_id);

-- Setup query 011 / 036
SELECT * INTO [#tmp_4] FROM (SELECT DISTINCT clinical_events.patient_id AS patient_id 
FROM (
            SELECT
                Patient_ID AS patient_id,
                CAST(ConsultationDate AS date) AS date,
                NULL AS snomedct_code,
                CTV3Code AS ctv3_code,
                NumericValue AS numeric_value
            FROM CodedEvent
            UNION ALL
            SELECT
                Patient_ID AS patient_id,
                CAST(ConsultationDate AS date) AS date,
                ConceptID AS snomedct_code,
                NULL AS ctv3_code,
                NumericValue AS numeric_value
            FROM CodedEvent_SNOMED
        ) AS clinical_events 
WHERE clinical_events.ctv3_code IN ('Y240b', 'Y211c', 'X73lF', 'Y20ff', 'Y23fd', 'Y20fa', 'Y228e', 'Y210a', 'Y213a', 'XaLTE', 'Y23f7', 'Y20fc', 'A7y00', 'X73lE', 'Y20fb', 'Y246c', 'Y2a3b', 'Y20d1', 'Y22a4', 'Y269d', 'Y22a5', 'Y22aa', 'Y229c', 'AyuDC', 'A795.', 'Y210b', 'Y228d', 'Y20fe') AND clinical_events.date = '20220925') AS anon_1;

-- Setup query 012 / 036
CREATE CLUSTERED INDEX [ix_#tmp_4_patient_id] ON [#tmp_4] (patient_id);

-- Setup query 013 / 036
SELECT * INTO [#tmp_5] FROM (SELECT DISTINCT emergency_care_attendances.patient_id AS patient_id 
FROM (
            SELECT
                EC.Patient_ID AS patient_id,
                EC.EC_Ident AS id,
                EC.Arrival_Date AS arrival_date,
                EC.Discharge_Destination_SNOMED_CT AS discharge_destination,
                diag.EC_Diagnosis_01 AS diagnosis_01, diag.EC_Diagnosis_02 AS diagnosis_02, diag.EC_Diagnosis_03 AS diagnosis_03, diag.EC_Diagnosis_04 AS diagnosis_04, diag.EC_Diagnosis_05 AS diagnosis_05, diag.EC_Diagnosis_06 AS diagnosis_06, diag.EC_Diagnosis_07 AS diagnosis_07, diag.EC_Diagnosis_08 AS diagnosis_08, diag.EC_Diagnosis_09 AS diagnosis_09, diag.EC_Diagnosis_10 AS diagnosis_10, diag.EC_Diagnosis_11 AS diagnosis_11, diag.EC_Diagnosis_12 AS diagnosis_12, diag.EC_Diagnosis_13 AS diagnosis_13, diag.EC_Diagnosis_14 AS diagnosis_14, diag.EC_Diagnosis_15 AS diagnosis_15, diag.EC_Diagnosis_16 AS diagnosis_16, diag.EC_Diagnosis_17 AS diagnosis_17, diag.EC_Diagnosis_18 AS diagnosis_18, diag.EC_Diagnosis_19 AS diagnosis_19, diag.EC_Diagnosis_20 AS diagnosis_20, diag.EC_Diagnosis_21 AS diagnosis_21, diag.EC_Diagnosis_22 AS diagnosis_22, diag.EC_Diagnosis_23 AS diagnosis_23, diag.EC_Diagnosis_24 AS diagnosis_24
            FROM EC
            LEFT JOIN EC_Diagnosis AS diag
            ON EC.EC_Ident = diag.EC_Ident
        ) AS emergency_care_attendances 
WHERE (emergency_care_attendances.diagnosis_01 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_02 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_03 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_04 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_05 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_06 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_07 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_08 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_09 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_10 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_11 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_12 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_13 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_14 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_15 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_16 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_17 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_18 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_19 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_20 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_21 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_22 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_23 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_24 IN ('1240751000000100')) AND emergency_care_attendances.arrival_date = '20220925') AS anon_1;

-- Setup query 014 / 036
CREATE CLUSTERED INDEX [ix_#tmp_5_patient_id] ON [#tmp_5] (patient_id);

-- Setup query 015 / 036
SELECT * INTO [#tmp_6] FROM (SELECT DISTINCT hospital_admissions.patient_id AS patient_id 
FROM (
            SELECT
                apcs.Patient_ID AS patient_id,
                apcs.APCS_Ident AS id,
                apcs.Admission_Date AS admission_date,
                apcs.Discharge_Date AS discharge_date,
                apcs.Admission_Method AS admission_method,
                apcs.Der_Diagnosis_All AS all_diagnoses,
                apcs.Patient_Classification AS patient_classification,
                CAST(der.Spell_PbR_CC_Day AS INTEGER) AS days_in_critical_care
            FROM APCS AS apcs
            LEFT JOIN APCS_Der AS der
            ON apcs.APCS_Ident = der.APCS_Ident
        ) AS hospital_admissions 
WHERE (hospital_admissions.all_diagnoses LIKE '%U071%' ESCAPE '/' OR hospital_admissions.all_diagnoses LIKE '%U072%' ESCAPE '/') AND hospital_admissions.admission_date = '20220925' AND hospital_admissions.admission_method IN ('2C', '2B', '21', '25', '2D', '22', '28', '24', '2A', '23')) AS anon_1;

-- Setup query 016 / 036
CREATE CLUSTERED INDEX [ix_#tmp_6_patient_id] ON [#tmp_6] (patient_id);

-- Setup query 017 / 036
SELECT * INTO [#tmp_7] FROM (SELECT DISTINCT sgss_covid_all_tests.patient_id AS patient_id 
FROM (
            SELECT
                Patient_ID AS patient_id,
                Specimen_Date AS specimen_taken_date,
                1 AS is_positive
            FROM SGSS_AllTests_Positive
            UNION ALL
            SELECT
                Patient_ID AS patient_id,
                Specimen_Date AS specimen_taken_date,
                0 AS is_positive
            FROM SGSS_AllTests_Negative
        ) AS sgss_covid_all_tests 
WHERE sgss_covid_all_tests.specimen_taken_date <= '20220925' AND sgss_covid_all_tests.specimen_taken_date >= '20220911' AND sgss_covid_all_tests.specimen_taken_date <= '20220925' AND sgss_covid_all_tests.is_positive = 1) AS anon_1;

-- Setup query 018 / 036
CREATE CLUSTERED INDEX [ix_#tmp_7_patient_id] ON [#tmp_7] (patient_id);

-- Setup query 019 / 036
SELECT * INTO [#tmp_8] FROM (SELECT DISTINCT clinical_events.patient_id AS patient_id 
FROM (
            SELECT
                Patient_ID AS patient_id,
                CAST(ConsultationDate AS date) AS date,
                NULL AS snomedct_code,
                CTV3Code AS ctv3_code,
                NumericValue AS numeric_value
            FROM CodedEvent
            UNION ALL
            SELECT
                Patient_ID AS patient_id,
                CAST(ConsultationDate AS date) AS date,
                ConceptID AS snomedct_code,
                NULL AS ctv3_code,
                NumericValue AS numeric_value
            FROM CodedEvent_SNOMED
        ) AS clinical_events 
WHERE clinical_events.ctv3_code IN ('Y240b', 'Y211c', 'X73lF', 'Y20ff', 'Y23fd', 'Y20fa', 'Y228e', 'Y210a', 'Y213a', 'XaLTE', 'Y23f7', 'Y20fc', 'A7y00', 'X73lE', 'Y20fb', 'Y246c', 'Y2a3b', 'Y20d1', 'Y22a4', 'Y269d', 'Y22a5', 'Y22aa', 'Y229c', 'AyuDC', 'A795.', 'Y210b', 'Y228d', 'Y20fe') AND clinical_events.date >= '20220911' AND clinical_events.date <= '20220925') AS anon_1;

-- Setup query 020 / 036
CREATE CLUSTERED INDEX [ix_#tmp_8_patient_id] ON [#tmp_8] (patient_id);

-- Setup query 021 / 036
SELECT * INTO [#tmp_9] FROM (SELECT DISTINCT emergency_care_attendances.patient_id AS patient_id 
FROM (
            SELECT
                EC.Patient_ID AS patient_id,
                EC.EC_Ident AS id,
                EC.Arrival_Date AS arrival_date,
                EC.Discharge_Destination_SNOMED_CT AS discharge_destination,
                diag.EC_Diagnosis_01 AS diagnosis_01, diag.EC_Diagnosis_02 AS diagnosis_02, diag.EC_Diagnosis_03 AS diagnosis_03, diag.EC_Diagnosis_04 AS diagnosis_04, diag.EC_Diagnosis_05 AS diagnosis_05, diag.EC_Diagnosis_06 AS diagnosis_06, diag.EC_Diagnosis_07 AS diagnosis_07, diag.EC_Diagnosis_08 AS diagnosis_08, diag.EC_Diagnosis_09 AS diagnosis_09, diag.EC_Diagnosis_10 AS diagnosis_10, diag.EC_Diagnosis_11 AS diagnosis_11, diag.EC_Diagnosis_12 AS diagnosis_12, diag.EC_Diagnosis_13 AS diagnosis_13, diag.EC_Diagnosis_14 AS diagnosis_14, diag.EC_Diagnosis_15 AS diagnosis_15, diag.EC_Diagnosis_16 AS diagnosis_16, diag.EC_Diagnosis_17 AS diagnosis_17, diag.EC_Diagnosis_18 AS diagnosis_18, diag.EC_Diagnosis_19 AS diagnosis_19, diag.EC_Diagnosis_20 AS diagnosis_20, diag.EC_Diagnosis_21 AS diagnosis_21, diag.EC_Diagnosis_22 AS diagnosis_22, diag.EC_Diagnosis_23 AS diagnosis_23, diag.EC_Diagnosis_24 AS diagnosis_24
            FROM EC
            LEFT JOIN EC_Diagnosis AS diag
            ON EC.EC_Ident = diag.EC_Ident
        ) AS emergency_care_attendances 
WHERE (emergency_care_attendances.diagnosis_01 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_02 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_03 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_04 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_05 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_06 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_07 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_08 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_09 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_10 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_11 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_12 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_13 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_14 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_15 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_16 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_17 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_18 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_19 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_20 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_21 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_22 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_23 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_24 IN ('1240751000000100')) AND emergency_care_attendances.arrival_date >= '20220911' AND emergency_care_attendances.arrival_date <= '20220925') AS anon_1;

-- Setup query 022 / 036
CREATE CLUSTERED INDEX [ix_#tmp_9_patient_id] ON [#tmp_9] (patient_id);

-- Setup query 023 / 036
SELECT * INTO [#tmp_10] FROM (SELECT DISTINCT hospital_admissions.patient_id AS patient_id 
FROM (
            SELECT
                apcs.Patient_ID AS patient_id,
                apcs.APCS_Ident AS id,
                apcs.Admission_Date AS admission_date,
                apcs.Discharge_Date AS discharge_date,
                apcs.Admission_Method AS admission_method,
                apcs.Der_Diagnosis_All AS all_diagnoses,
                apcs.Patient_Classification AS patient_classification,
                CAST(der.Spell_PbR_CC_Day AS INTEGER) AS days_in_critical_care
            FROM APCS AS apcs
            LEFT JOIN APCS_Der AS der
            ON apcs.APCS_Ident = der.APCS_Ident
        ) AS hospital_admissions 
WHERE (hospital_admissions.all_diagnoses LIKE '%U071%' ESCAPE '/' OR hospital_admissions.all_diagnoses LIKE '%U072%' ESCAPE '/') AND hospital_admissions.admission_date >= '20220911' AND hospital_admissions.admission_date <= '20220925' AND hospital_admissions.admission_method IN ('2C', '2B', '21', '25', '2D', '22', '28', '24', '2A', '23')) AS anon_1;

-- Setup query 024 / 036
CREATE CLUSTERED INDEX [ix_#tmp_10_patient_id] ON [#tmp_10] (patient_id);

-- Setup query 025 / 036
SELECT * INTO [#tmp_11] FROM (SELECT DISTINCT sgss_covid_all_tests.patient_id AS patient_id 
FROM (
            SELECT
                Patient_ID AS patient_id,
                Specimen_Date AS specimen_taken_date,
                1 AS is_positive
            FROM SGSS_AllTests_Positive
            UNION ALL
            SELECT
                Patient_ID AS patient_id,
                Specimen_Date AS specimen_taken_date,
                0 AS is_positive
            FROM SGSS_AllTests_Negative
        ) AS sgss_covid_all_tests 
WHERE sgss_covid_all_tests.specimen_taken_date <= '20220925' AND sgss_covid_all_tests.specimen_taken_date <= '20220925' AND sgss_covid_all_tests.is_positive = 1) AS anon_1;

-- Setup query 026 / 036
CREATE CLUSTERED INDEX [ix_#tmp_11_patient_id] ON [#tmp_11] (patient_id);

-- Setup query 027 / 036
SELECT * INTO [#tmp_12] FROM (SELECT DISTINCT clinical_events.patient_id AS patient_id 
FROM (
            SELECT
                Patient_ID AS patient_id,
                CAST(ConsultationDate AS date) AS date,
                NULL AS snomedct_code,
                CTV3Code AS ctv3_code,
                NumericValue AS numeric_value
            FROM CodedEvent
            UNION ALL
            SELECT
                Patient_ID AS patient_id,
                CAST(ConsultationDate AS date) AS date,
                ConceptID AS snomedct_code,
                NULL AS ctv3_code,
                NumericValue AS numeric_value
            FROM CodedEvent_SNOMED
        ) AS clinical_events 
WHERE clinical_events.ctv3_code IN ('Y240b', 'Y211c', 'X73lF', 'Y20ff', 'Y23fd', 'Y20fa', 'Y228e', 'Y210a', 'Y213a', 'XaLTE', 'Y23f7', 'Y20fc', 'A7y00', 'X73lE', 'Y20fb', 'Y246c', 'Y2a3b', 'Y20d1', 'Y22a4', 'Y269d', 'Y22a5', 'Y22aa', 'Y229c', 'AyuDC', 'A795.', 'Y210b', 'Y228d', 'Y20fe') AND clinical_events.date <= '20220925') AS anon_1;

-- Setup query 028 / 036
CREATE CLUSTERED INDEX [ix_#tmp_12_patient_id] ON [#tmp_12] (patient_id);

-- Setup query 029 / 036
SELECT * INTO [#tmp_13] FROM (SELECT DISTINCT emergency_care_attendances.patient_id AS patient_id 
FROM (
            SELECT
                EC.Patient_ID AS patient_id,
                EC.EC_Ident AS id,
                EC.Arrival_Date AS arrival_date,
                EC.Discharge_Destination_SNOMED_CT AS discharge_destination,
                diag.EC_Diagnosis_01 AS diagnosis_01, diag.EC_Diagnosis_02 AS diagnosis_02, diag.EC_Diagnosis_03 AS diagnosis_03, diag.EC_Diagnosis_04 AS diagnosis_04, diag.EC_Diagnosis_05 AS diagnosis_05, diag.EC_Diagnosis_06 AS diagnosis_06, diag.EC_Diagnosis_07 AS diagnosis_07, diag.EC_Diagnosis_08 AS diagnosis_08, diag.EC_Diagnosis_09 AS diagnosis_09, diag.EC_Diagnosis_10 AS diagnosis_10, diag.EC_Diagnosis_11 AS diagnosis_11, diag.EC_Diagnosis_12 AS diagnosis_12, diag.EC_Diagnosis_13 AS diagnosis_13, diag.EC_Diagnosis_14 AS diagnosis_14, diag.EC_Diagnosis_15 AS diagnosis_15, diag.EC_Diagnosis_16 AS diagnosis_16, diag.EC_Diagnosis_17 AS diagnosis_17, diag.EC_Diagnosis_18 AS diagnosis_18, diag.EC_Diagnosis_19 AS diagnosis_19, diag.EC_Diagnosis_20 AS diagnosis_20, diag.EC_Diagnosis_21 AS diagnosis_21, diag.EC_Diagnosis_22 AS diagnosis_22, diag.EC_Diagnosis_23 AS diagnosis_23, diag.EC_Diagnosis_24 AS diagnosis_24
            FROM EC
            LEFT JOIN EC_Diagnosis AS diag
            ON EC.EC_Ident = diag.EC_Ident
        ) AS emergency_care_attendances 
WHERE (emergency_care_attendances.diagnosis_01 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_02 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_03 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_04 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_05 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_06 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_07 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_08 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_09 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_10 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_11 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_12 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_13 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_14 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_15 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_16 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_17 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_18 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_19 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_20 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_21 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_22 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_23 IN ('1240751000000100') OR emergency_care_attendances.diagnosis_24 IN ('1240751000000100')) AND emergency_care_attendances.arrival_date <= '20220925') AS anon_1;

-- Setup query 030 / 036
CREATE CLUSTERED INDEX [ix_#tmp_13_patient_id] ON [#tmp_13] (patient_id);

-- Setup query 031 / 036
SELECT * INTO [#tmp_14] FROM (SELECT DISTINCT hospital_admissions.patient_id AS patient_id 
FROM (
            SELECT
                apcs.Patient_ID AS patient_id,
                apcs.APCS_Ident AS id,
                apcs.Admission_Date AS admission_date,
                apcs.Discharge_Date AS discharge_date,
                apcs.Admission_Method AS admission_method,
                apcs.Der_Diagnosis_All AS all_diagnoses,
                apcs.Patient_Classification AS patient_classification,
                CAST(der.Spell_PbR_CC_Day AS INTEGER) AS days_in_critical_care
            FROM APCS AS apcs
            LEFT JOIN APCS_Der AS der
            ON apcs.APCS_Ident = der.APCS_Ident
        ) AS hospital_admissions 
WHERE (hospital_admissions.all_diagnoses LIKE '%U071%' ESCAPE '/' OR hospital_admissions.all_diagnoses LIKE '%U072%' ESCAPE '/') AND hospital_admissions.admission_date <= '20220925' AND hospital_admissions.admission_method IN ('2C', '2B', '21', '25', '2D', '22', '28', '24', '2A', '23')) AS anon_1;

-- Setup query 032 / 036
CREATE CLUSTERED INDEX [ix_#tmp_14_patient_id] ON [#tmp_14] (patient_id);

-- Setup query 033 / 036
SELECT * INTO [#tmp_17] FROM (SELECT [#tmp_15].patient_id AS patient_id 
FROM [#tmp_15] UNION SELECT patients.patient_id AS patient_id 
FROM (
            SELECT
                Patient_ID as patient_id,
                DateOfBirth as date_of_birth,
                CASE
                    WHEN Sex = 'M' THEN 'male'
                    WHEN Sex = 'F' THEN 'female'
                    WHEN Sex = 'I' THEN 'intersex'
                    ELSE 'unknown'
                END AS sex,
                CASE
                    WHEN DateOfDeath != '99991231' THEN DateOfDeath
                END As date_of_death
            FROM Patient
        ) AS patients UNION SELECT [#tmp_1].patient_id AS patient_id 
FROM [#tmp_1] UNION SELECT [#tmp_16].patient_id AS patient_id 
FROM [#tmp_16]) AS anon_1;

-- Setup query 034 / 036
CREATE CLUSTERED INDEX [ix_#tmp_17_patient_id] ON [#tmp_17] (patient_id);

-- Setup query 035 / 036
SELECT * INTO [#results] FROM (SELECT [#tmp_17].patient_id AS patient_id, patients.sex AS sex, (YEAR('20220925') - YEAR(patients.date_of_birth)) - CASE WHEN ((MONTH('20220925') - MONTH(patients.date_of_birth)) * -31 > DAY('20220925') - DAY(patients.date_of_birth)) THEN 1 ELSE 0 END AS age, [#tmp_1].msoa_code AS msoa, [#tmp_2].practice_stp AS stp, [#tmp_2].practice_nuts1_region_name AS region, CASE WHEN ([#tmp_3].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_3].patient_id IS NULL) THEN 0 END AS postest_01, CASE WHEN ([#tmp_4].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_4].patient_id IS NULL) THEN 0 END AS primary_care_covid_case_01, CASE WHEN ([#tmp_5].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_5].patient_id IS NULL) THEN 0 END AS covidemergency_01, CASE WHEN ([#tmp_6].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_6].patient_id IS NULL) THEN 0 END AS covidadmitted_01, CASE WHEN ([#tmp_3].patient_id IS NOT NULL OR [#tmp_4].patient_id IS NOT NULL OR [#tmp_5].patient_id IS NOT NULL OR [#tmp_6].patient_id IS NOT NULL) THEN 1 WHEN (NOT ([#tmp_3].patient_id IS NOT NULL OR [#tmp_4].patient_id IS NOT NULL OR [#tmp_5].patient_id IS NOT NULL OR [#tmp_6].patient_id IS NOT NULL)) THEN 0 END AS any_infection_or_disease_01, CASE WHEN ([#tmp_7].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_7].patient_id IS NULL) THEN 0 END AS postest_14, CASE WHEN ([#tmp_8].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_8].patient_id IS NULL) THEN 0 END AS primary_care_covid_case_14, CASE WHEN ([#tmp_9].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_9].patient_id IS NULL) THEN 0 END AS covidemergency_14, CASE WHEN ([#tmp_10].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_10].patient_id IS NULL) THEN 0 END AS covidadmitted_14, CASE WHEN ([#tmp_7].patient_id IS NOT NULL OR [#tmp_8].patient_id IS NOT NULL OR [#tmp_9].patient_id IS NOT NULL OR [#tmp_10].patient_id IS NOT NULL) THEN 1 WHEN (NOT ([#tmp_7].patient_id IS NOT NULL OR [#tmp_8].patient_id IS NOT NULL OR [#tmp_9].patient_id IS NOT NULL OR [#tmp_10].patient_id IS NOT NULL)) THEN 0 END AS any_infection_or_disease_14, CASE WHEN ([#tmp_11].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_11].patient_id IS NULL) THEN 0 END AS postest_ever, CASE WHEN ([#tmp_12].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_12].patient_id IS NULL) THEN 0 END AS primary_care_covid_case_ever, CASE WHEN ([#tmp_13].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_13].patient_id IS NULL) THEN 0 END AS covidemergency_ever, CASE WHEN ([#tmp_14].patient_id IS NOT NULL) THEN 1 WHEN ([#tmp_14].patient_id IS NULL) THEN 0 END AS covidadmitted_ever, CASE WHEN ([#tmp_11].patient_id IS NOT NULL OR [#tmp_12].patient_id IS NOT NULL OR [#tmp_13].patient_id IS NOT NULL OR [#tmp_14].patient_id IS NOT NULL) THEN 1 WHEN (NOT ([#tmp_11].patient_id IS NOT NULL OR [#tmp_12].patient_id IS NOT NULL OR [#tmp_13].patient_id IS NOT NULL OR [#tmp_14].patient_id IS NOT NULL)) THEN 0 END AS any_infection_or_disease_ever 
FROM [#tmp_17] LEFT OUTER JOIN (
            SELECT
                Patient_ID as patient_id,
                DateOfBirth as date_of_birth,
                CASE
                    WHEN Sex = 'M' THEN 'male'
                    WHEN Sex = 'F' THEN 'female'
                    WHEN Sex = 'I' THEN 'intersex'
                    ELSE 'unknown'
                END AS sex,
                CASE
                    WHEN DateOfDeath != '99991231' THEN DateOfDeath
                END As date_of_death
            FROM Patient
        ) AS patients ON patients.patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_1] ON [#tmp_1].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_2] ON [#tmp_2].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_3] ON [#tmp_3].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_4] ON [#tmp_4].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_5] ON [#tmp_5].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_6] ON [#tmp_6].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_7] ON [#tmp_7].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_8] ON [#tmp_8].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_9] ON [#tmp_9].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_10] ON [#tmp_10].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_11] ON [#tmp_11].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_12] ON [#tmp_12].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_13] ON [#tmp_13].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_14] ON [#tmp_14].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_15] ON [#tmp_15].patient_id = [#tmp_17].patient_id LEFT OUTER JOIN [#tmp_16] ON [#tmp_16].patient_id = [#tmp_17].patient_id 
WHERE [#tmp_15].patient_id IS NOT NULL AND (patients.sex = N'female' OR patients.sex = N'male') AND (YEAR('20220925') - YEAR(patients.date_of_birth)) - CASE WHEN ((MONTH('20220925') - MONTH(patients.date_of_birth)) * -31 > DAY('20220925') - DAY(patients.date_of_birth)) THEN 1 ELSE 0 END >= 2 AND (YEAR('20220925') - YEAR(patients.date_of_birth)) - CASE WHEN ((MONTH('20220925') - MONTH(patients.date_of_birth)) * -31 > DAY('20220925') - DAY(patients.date_of_birth)) THEN 1 ELSE 0 END <= 120 AND NOT (patients.date_of_death IS NOT NULL AND patients.date_of_death < '20220925') AND NOT (CASE WHEN ([#tmp_1].care_home_is_potential_match = 1) THEN 1 ELSE 0 END = 1 OR [#tmp_16].patient_id IS NOT NULL) AND [#tmp_1].msoa_code IS NOT NULL) AS anon_1;

-- Setup query 036 / 036
CREATE CLUSTERED INDEX [ix_#results_patient_id] ON [#results] (patient_id);

-- Results query
SELECT [#results].patient_id, [#results].sex, [#results].age, [#results].msoa, [#results].stp, [#results].region, [#results].postest_01, [#results].primary_care_covid_case_01, [#results].covidemergency_01, [#results].covidadmitted_01, [#results].any_infection_or_disease_01, [#results].postest_14, [#results].primary_care_covid_case_14, [#results].covidemergency_14, [#results].covidadmitted_14, [#results].any_infection_or_disease_14, [#results].postest_ever, [#results].primary_care_covid_case_ever, [#results].covidemergency_ever, [#results].covidadmitted_ever, [#results].any_infection_or_disease_ever 
FROM [#results];

