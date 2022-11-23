-- Query for age
SELECT * INTO #age FROM (
        SELECT
          Patient.Patient_ID AS patient_id,
          CASE WHEN
             dateadd(year, datediff (year, DateOfBirth, '20200426'), DateOfBirth) > '20200426'
          THEN
             datediff(year, DateOfBirth, '20200426') - 1
          ELSE
             datediff(year, DateOfBirth, '20200426')
          END AS value
        FROM Patient
        
        ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #age (patient_id)
GO

-- Query for sex
SELECT * INTO #sex FROM (
        SELECT
          Patient_ID AS patient_id,
          Sex AS value
        FROM Patient
        ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #sex (patient_id)
GO

-- Query for msoa
SELECT * INTO #msoa FROM (
        SELECT
          t.Patient_ID AS patient_id,
          MSOACode AS msoa
        FROM (
          SELECT PatientAddress.Patient_ID, MSOACode,
          ROW_NUMBER() OVER (
            PARTITION BY PatientAddress.Patient_ID
            ORDER BY
              StartDate DESC,
              EndDate DESC,
              IIF(MSOACode = 'NPC', 1, 0),
              PatientAddress_ID
          ) AS rownum
          FROM PatientAddress
          
          WHERE StartDate <= '20200426' AND EndDate > '20200426'
        ) t
        WHERE rownum = 1
        ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #msoa (patient_id)
GO

-- Query for stp
SELECT * INTO #stp FROM (
        SELECT
          t.Patient_ID AS patient_id,
          Organisation.STPCode AS stp_code
        FROM (
          SELECT RegistrationHistory.Patient_ID, Organisation_ID,
          ROW_NUMBER() OVER (
            PARTITION BY RegistrationHistory.Patient_ID
            ORDER BY StartDate DESC, EndDate DESC, Registration_ID
          ) AS rownum
          FROM RegistrationHistory
          
          WHERE StartDate <= '20200426' AND EndDate > '20200426'
        ) t
        LEFT JOIN Organisation
        ON Organisation.Organisation_ID = t.Organisation_ID
        WHERE t.rownum = 1
        ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #stp (patient_id)
GO

-- Query for region
SELECT * INTO #region FROM (
        SELECT
          t.Patient_ID AS patient_id,
          Organisation.Region AS nuts1_region_name
        FROM (
          SELECT RegistrationHistory.Patient_ID, Organisation_ID,
          ROW_NUMBER() OVER (
            PARTITION BY RegistrationHistory.Patient_ID
            ORDER BY StartDate DESC, EndDate DESC, Registration_ID
          ) AS rownum
          FROM RegistrationHistory
          
          WHERE StartDate <= '20200426' AND EndDate > '20200426'
        ) t
        LEFT JOIN Organisation
        ON Organisation.Organisation_ID = t.Organisation_ID
        WHERE t.rownum = 1
        ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #region (patient_id)
GO

-- Query for postest_01
SELECT * INTO #postest_01 FROM (
            SELECT
              t2.patient_id AS patient_id,
              t2.date AS date,
              1 AS binary_flag
            FROM (
              SELECT t1.*,
                ROW_NUMBER() OVER (
                  PARTITION BY t1.patient_id
                  ORDER BY t1.date ASC
                ) AS rownum
              FROM (
                
            SELECT
              Patient_ID AS patient_id,
              Specimen_Date AS date,
              Variant AS variant,
              VariantDetectionMethod AS variant_detection_method,
              Symptomatic AS symptomatic,
              SGTF AS sgtf
            FROM SGSS_AllTests_Positive
            
              ) t1
              
              WHERE CAST(t1.date AS date) BETWEEN CAST('20200426' AS date) AND CAST('20200426' AS date)
            ) t2
            WHERE t2.rownum = 1
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #postest_01 (patient_id)
GO


            -- Uploading codelist for primary_care_covid_case_01
            CREATE TABLE #tmp1_primary_care_covid_case_01_codelist (
              code VARCHAR(5) COLLATE Latin1_General_BIN,
              category VARCHAR(MAX)
            )
            
GO

INSERT INTO [#tmp1_primary_care_covid_case_01_codelist] ([code], [category]) VALUES
('A795.', ''),
('A7y00', ''),
('AyuDC', ''),
('X73lE', ''),
('X73lF', ''),
('Y20fa', ''),
('Y210b', ''),
('Y211c', ''),
('Y228e', ''),
('Y229c', ''),
('Y22a4', ''),
('Y22a5', ''),
('Y22aa', ''),
('Y246c', ''),
('XaLTE', ''),
('Y20d1', ''),
('Y213a', ''),
('Y228d', ''),
('Y23f7', ''),
('Y240b', ''),
('Y2a3b', ''),
('Y269d', ''),
('Y20fb', ''),
('Y20fc', ''),
('Y20fe', ''),
('Y20ff', ''),
('Y210a', ''),
('Y23fd', '')
GO

CREATE CLUSTERED INDEX code_ix ON #tmp1_primary_care_covid_case_01_codelist (code)
GO

-- Query for primary_care_covid_case_01
SELECT * INTO #primary_care_covid_case_01 FROM (
            SELECT
              CodedEvent.Patient_ID AS patient_id,
              1 AS binary_flag,
              MIN(ConsultationDate) AS date
            FROM CodedEvent
            INNER JOIN #tmp1_primary_care_covid_case_01_codelist
            ON CTV3Code = #tmp1_primary_care_covid_case_01_codelist.code
            
            WHERE CAST(ConsultationDate AS date) BETWEEN CAST('20200426' AS date) AND CAST('20200426' AS date)
              AND NOT 0 = 1
              AND 1 = 1
            GROUP BY CodedEvent.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #primary_care_covid_case_01 (patient_id)
GO

-- Query for covidemergency_01
SELECT * INTO #covidemergency_01 FROM (
            SELECT
              EC.Patient_ID AS patient_id,
              1 AS binary_flag
            FROM EC
            INNER JOIN EC_Diagnosis
              ON EC.EC_Ident = EC_Diagnosis.EC_Ident
            
            WHERE CAST(Arrival_Date AS date) BETWEEN CAST('20200426' AS date) AND CAST('20200426' AS date) AND (EC_Diagnosis_01 IN ('1240751000000100') OR EC_Diagnosis_02 IN ('1240751000000100') OR EC_Diagnosis_03 IN ('1240751000000100') OR EC_Diagnosis_04 IN ('1240751000000100') OR EC_Diagnosis_05 IN ('1240751000000100') OR EC_Diagnosis_06 IN ('1240751000000100') OR EC_Diagnosis_07 IN ('1240751000000100') OR EC_Diagnosis_08 IN ('1240751000000100') OR EC_Diagnosis_09 IN ('1240751000000100') OR EC_Diagnosis_10 IN ('1240751000000100') OR EC_Diagnosis_11 IN ('1240751000000100') OR EC_Diagnosis_12 IN ('1240751000000100') OR EC_Diagnosis_13 IN ('1240751000000100') OR EC_Diagnosis_14 IN ('1240751000000100') OR EC_Diagnosis_15 IN ('1240751000000100') OR EC_Diagnosis_16 IN ('1240751000000100') OR EC_Diagnosis_17 IN ('1240751000000100') OR EC_Diagnosis_18 IN ('1240751000000100') OR EC_Diagnosis_19 IN ('1240751000000100') OR EC_Diagnosis_20 IN ('1240751000000100') OR EC_Diagnosis_21 IN ('1240751000000100') OR EC_Diagnosis_22 IN ('1240751000000100') OR EC_Diagnosis_23 IN ('1240751000000100') OR EC_Diagnosis_24 IN ('1240751000000100'))
            GROUP BY EC.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #covidemergency_01 (patient_id)
GO

-- Query for covidadmitted_01
SELECT * INTO #covidadmitted_01 FROM (
            SELECT
              APCS.Patient_ID AS patient_id,
              1 AS binary_flag
            FROM APCS
            INNER JOIN APCS_Der
              ON APCS.APCS_Ident = APCS_Der.APCS_Ident
            
            WHERE CAST(Admission_Date AS date) BETWEEN CAST('20200426' AS date) AND CAST('20200426' AS date) AND Admission_Method IN ('21', '22', '23', '24', '25', '2A', '2B', '2C', '2D', '28') AND (Der_Diagnosis_All LIKE '%[^A-Za-z0-9]U071%' ESCAPE '!' OR Der_Diagnosis_All LIKE '%[^A-Za-z0-9]U072%' ESCAPE '!')
            GROUP BY APCS.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #covidadmitted_01 (patient_id)
GO

-- Query for postest_14
SELECT * INTO #postest_14 FROM (
            SELECT
              t2.patient_id AS patient_id,
              t2.date AS date,
              1 AS binary_flag
            FROM (
              SELECT t1.*,
                ROW_NUMBER() OVER (
                  PARTITION BY t1.patient_id
                  ORDER BY t1.date ASC
                ) AS rownum
              FROM (
                
            SELECT
              Patient_ID AS patient_id,
              Specimen_Date AS date,
              Variant AS variant,
              VariantDetectionMethod AS variant_detection_method,
              Symptomatic AS symptomatic,
              SGTF AS sgtf
            FROM SGSS_AllTests_Positive
            
              ) t1
              
              WHERE CAST(t1.date AS date) BETWEEN CAST('20200413' AS date) AND CAST('20200426' AS date)
            ) t2
            WHERE t2.rownum = 1
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #postest_14 (patient_id)
GO


            -- Uploading codelist for primary_care_covid_case_14
            CREATE TABLE #tmp2_primary_care_covid_case_14_codelist (
              code VARCHAR(5) COLLATE Latin1_General_BIN,
              category VARCHAR(MAX)
            )
            
GO

INSERT INTO [#tmp2_primary_care_covid_case_14_codelist] ([code], [category]) VALUES
('A795.', ''),
('A7y00', ''),
('AyuDC', ''),
('X73lE', ''),
('X73lF', ''),
('Y20fa', ''),
('Y210b', ''),
('Y211c', ''),
('Y228e', ''),
('Y229c', ''),
('Y22a4', ''),
('Y22a5', ''),
('Y22aa', ''),
('Y246c', ''),
('XaLTE', ''),
('Y20d1', ''),
('Y213a', ''),
('Y228d', ''),
('Y23f7', ''),
('Y240b', ''),
('Y2a3b', ''),
('Y269d', ''),
('Y20fb', ''),
('Y20fc', ''),
('Y20fe', ''),
('Y20ff', ''),
('Y210a', ''),
('Y23fd', '')
GO

CREATE CLUSTERED INDEX code_ix ON #tmp2_primary_care_covid_case_14_codelist (code)
GO

-- Query for primary_care_covid_case_14
SELECT * INTO #primary_care_covid_case_14 FROM (
            SELECT
              CodedEvent.Patient_ID AS patient_id,
              1 AS binary_flag,
              MIN(ConsultationDate) AS date
            FROM CodedEvent
            INNER JOIN #tmp2_primary_care_covid_case_14_codelist
            ON CTV3Code = #tmp2_primary_care_covid_case_14_codelist.code
            
            WHERE CAST(ConsultationDate AS date) BETWEEN CAST('20200413' AS date) AND CAST('20200426' AS date)
              AND NOT 0 = 1
              AND 1 = 1
            GROUP BY CodedEvent.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #primary_care_covid_case_14 (patient_id)
GO

-- Query for covidemergency_14
SELECT * INTO #covidemergency_14 FROM (
            SELECT
              EC.Patient_ID AS patient_id,
              1 AS binary_flag
            FROM EC
            INNER JOIN EC_Diagnosis
              ON EC.EC_Ident = EC_Diagnosis.EC_Ident
            
            WHERE CAST(Arrival_Date AS date) BETWEEN CAST('20200413' AS date) AND CAST('20200426' AS date) AND (EC_Diagnosis_01 IN ('1240751000000100') OR EC_Diagnosis_02 IN ('1240751000000100') OR EC_Diagnosis_03 IN ('1240751000000100') OR EC_Diagnosis_04 IN ('1240751000000100') OR EC_Diagnosis_05 IN ('1240751000000100') OR EC_Diagnosis_06 IN ('1240751000000100') OR EC_Diagnosis_07 IN ('1240751000000100') OR EC_Diagnosis_08 IN ('1240751000000100') OR EC_Diagnosis_09 IN ('1240751000000100') OR EC_Diagnosis_10 IN ('1240751000000100') OR EC_Diagnosis_11 IN ('1240751000000100') OR EC_Diagnosis_12 IN ('1240751000000100') OR EC_Diagnosis_13 IN ('1240751000000100') OR EC_Diagnosis_14 IN ('1240751000000100') OR EC_Diagnosis_15 IN ('1240751000000100') OR EC_Diagnosis_16 IN ('1240751000000100') OR EC_Diagnosis_17 IN ('1240751000000100') OR EC_Diagnosis_18 IN ('1240751000000100') OR EC_Diagnosis_19 IN ('1240751000000100') OR EC_Diagnosis_20 IN ('1240751000000100') OR EC_Diagnosis_21 IN ('1240751000000100') OR EC_Diagnosis_22 IN ('1240751000000100') OR EC_Diagnosis_23 IN ('1240751000000100') OR EC_Diagnosis_24 IN ('1240751000000100'))
            GROUP BY EC.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #covidemergency_14 (patient_id)
GO

-- Query for covidadmitted_14
SELECT * INTO #covidadmitted_14 FROM (
            SELECT
              APCS.Patient_ID AS patient_id,
              1 AS binary_flag
            FROM APCS
            INNER JOIN APCS_Der
              ON APCS.APCS_Ident = APCS_Der.APCS_Ident
            
            WHERE CAST(Admission_Date AS date) BETWEEN CAST('20200413' AS date) AND CAST('20200426' AS date) AND Admission_Method IN ('21', '22', '23', '24', '25', '2A', '2B', '2C', '2D', '28') AND (Der_Diagnosis_All LIKE '%[^A-Za-z0-9]U071%' ESCAPE '!' OR Der_Diagnosis_All LIKE '%[^A-Za-z0-9]U072%' ESCAPE '!')
            GROUP BY APCS.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #covidadmitted_14 (patient_id)
GO

-- Query for postest_ever
SELECT * INTO #postest_ever FROM (
            SELECT
              t2.patient_id AS patient_id,
              t2.date AS date,
              1 AS binary_flag
            FROM (
              SELECT t1.*,
                ROW_NUMBER() OVER (
                  PARTITION BY t1.patient_id
                  ORDER BY t1.date ASC
                ) AS rownum
              FROM (
                
            SELECT
              Patient_ID AS patient_id,
              Specimen_Date AS date,
              Variant AS variant,
              VariantDetectionMethod AS variant_detection_method,
              Symptomatic AS symptomatic,
              SGTF AS sgtf
            FROM SGSS_AllTests_Positive
            
              ) t1
              
              WHERE CAST(t1.date AS date) <= CAST('20200426' AS date)
            ) t2
            WHERE t2.rownum = 1
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #postest_ever (patient_id)
GO


            -- Uploading codelist for primary_care_covid_case_ever
            CREATE TABLE #tmp3_primary_care_covid_case_ever_codelist (
              code VARCHAR(5) COLLATE Latin1_General_BIN,
              category VARCHAR(MAX)
            )
            
GO

INSERT INTO [#tmp3_primary_care_covid_case_ever_codelist] ([code], [category]) VALUES
('A795.', ''),
('A7y00', ''),
('AyuDC', ''),
('X73lE', ''),
('X73lF', ''),
('Y20fa', ''),
('Y210b', ''),
('Y211c', ''),
('Y228e', ''),
('Y229c', ''),
('Y22a4', ''),
('Y22a5', ''),
('Y22aa', ''),
('Y246c', ''),
('XaLTE', ''),
('Y20d1', ''),
('Y213a', ''),
('Y228d', ''),
('Y23f7', ''),
('Y240b', ''),
('Y2a3b', ''),
('Y269d', ''),
('Y20fb', ''),
('Y20fc', ''),
('Y20fe', ''),
('Y20ff', ''),
('Y210a', ''),
('Y23fd', '')
GO

CREATE CLUSTERED INDEX code_ix ON #tmp3_primary_care_covid_case_ever_codelist (code)
GO

-- Query for primary_care_covid_case_ever
SELECT * INTO #primary_care_covid_case_ever FROM (
            SELECT
              CodedEvent.Patient_ID AS patient_id,
              1 AS binary_flag,
              MIN(ConsultationDate) AS date
            FROM CodedEvent
            INNER JOIN #tmp3_primary_care_covid_case_ever_codelist
            ON CTV3Code = #tmp3_primary_care_covid_case_ever_codelist.code
            
            WHERE CAST(ConsultationDate AS date) <= CAST('20200426' AS date)
              AND NOT 0 = 1
              AND 1 = 1
            GROUP BY CodedEvent.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #primary_care_covid_case_ever (patient_id)
GO

-- Query for covidemergency_ever
SELECT * INTO #covidemergency_ever FROM (
            SELECT
              EC.Patient_ID AS patient_id,
              1 AS binary_flag
            FROM EC
            INNER JOIN EC_Diagnosis
              ON EC.EC_Ident = EC_Diagnosis.EC_Ident
            
            WHERE CAST(Arrival_Date AS date) <= CAST('20200426' AS date) AND (EC_Diagnosis_01 IN ('1240751000000100') OR EC_Diagnosis_02 IN ('1240751000000100') OR EC_Diagnosis_03 IN ('1240751000000100') OR EC_Diagnosis_04 IN ('1240751000000100') OR EC_Diagnosis_05 IN ('1240751000000100') OR EC_Diagnosis_06 IN ('1240751000000100') OR EC_Diagnosis_07 IN ('1240751000000100') OR EC_Diagnosis_08 IN ('1240751000000100') OR EC_Diagnosis_09 IN ('1240751000000100') OR EC_Diagnosis_10 IN ('1240751000000100') OR EC_Diagnosis_11 IN ('1240751000000100') OR EC_Diagnosis_12 IN ('1240751000000100') OR EC_Diagnosis_13 IN ('1240751000000100') OR EC_Diagnosis_14 IN ('1240751000000100') OR EC_Diagnosis_15 IN ('1240751000000100') OR EC_Diagnosis_16 IN ('1240751000000100') OR EC_Diagnosis_17 IN ('1240751000000100') OR EC_Diagnosis_18 IN ('1240751000000100') OR EC_Diagnosis_19 IN ('1240751000000100') OR EC_Diagnosis_20 IN ('1240751000000100') OR EC_Diagnosis_21 IN ('1240751000000100') OR EC_Diagnosis_22 IN ('1240751000000100') OR EC_Diagnosis_23 IN ('1240751000000100') OR EC_Diagnosis_24 IN ('1240751000000100'))
            GROUP BY EC.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #covidemergency_ever (patient_id)
GO

-- Query for covidadmitted_ever
SELECT * INTO #covidadmitted_ever FROM (
            SELECT
              APCS.Patient_ID AS patient_id,
              1 AS binary_flag
            FROM APCS
            INNER JOIN APCS_Der
              ON APCS.APCS_Ident = APCS_Der.APCS_Ident
            
            WHERE CAST(Admission_Date AS date) <= CAST('20200426' AS date) AND Admission_Method IN ('21', '22', '23', '24', '25', '2A', '2B', '2C', '2D', '28') AND (Der_Diagnosis_All LIKE '%[^A-Za-z0-9]U071%' ESCAPE '!' OR Der_Diagnosis_All LIKE '%[^A-Za-z0-9]U072%' ESCAPE '!')
            GROUP BY APCS.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #covidadmitted_ever (patient_id)
GO

-- Query for registered
SELECT * INTO #registered FROM (
        SELECT DISTINCT Patient.Patient_ID AS patient_id, 1 AS value
        FROM Patient
        INNER JOIN RegistrationHistory
        ON RegistrationHistory.Patient_ID = Patient.Patient_ID
        INNER JOIN Organisation
        ON RegistrationHistory.Organisation_ID = Organisation.Organisation_ID
        
        WHERE StartDate <= '20200426' AND EndDate > '20200426'
        
        ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #registered (patient_id)
GO

-- Query for has_died
SELECT * INTO #has_died FROM (
        SELECT
          ONS_Deaths.Patient_ID as patient_id,
          1 AS binary_flag
        FROM ONS_Deaths
        
        WHERE (1 = 1) AND CAST(dod AS date) <= CAST('20200426' AS date)
        GROUP BY ONS_Deaths.Patient_ID
        ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #has_died (patient_id)
GO

-- Query for care_home_tpp
SELECT * INTO #care_home_tpp FROM (
        SELECT
          t.Patient_ID AS patient_id,
          CASE WHEN (( ISNULL(PotentialCareHomeAddressID, 0) != 0 )) THEN 'care_or_nursing_home' ELSE '' END AS value
        FROM (
          SELECT
            PatientAddress.Patient_ID AS Patient_ID,
            PotentialCareHomeAddress.PatientAddress_ID AS PotentialCareHomeAddressID,
            LocationRequiresNursing,
            LocationDoesNotRequireNursing,
            ROW_NUMBER() OVER (
              PARTITION BY PatientAddress.Patient_ID
              ORDER BY
                StartDate DESC,
                EndDate DESC,
                IIF(MSOACode = 'NPC', 1, 0),
                PatientAddress.PatientAddress_ID
              ) AS rownum
          FROM PatientAddress
          LEFT JOIN PotentialCareHomeAddress
          ON PatientAddress.PatientAddress_ID = PotentialCareHomeAddress.PatientAddress_ID
          
          WHERE StartDate <= '20200426' AND EndDate > '20200426'
        ) t
        WHERE rownum = 1
        ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #care_home_tpp (patient_id)
GO


            -- Uploading codelist for care_home_code
            CREATE TABLE #tmp4_care_home_code_codelist (
              code VARCHAR(16) COLLATE Latin1_General_BIN,
              category VARCHAR(MAX)
            )
            
GO

INSERT INTO [#tmp4_care_home_code_codelist] ([code], [category]) VALUES
('1024771000000108', ''),
('160734000', ''),
('160737007', ''),
('224224003', ''),
('248171000000108', ''),
('394923006', '')
GO

CREATE CLUSTERED INDEX code_ix ON #tmp4_care_home_code_codelist (code)
GO

-- Query for care_home_code
SELECT * INTO #care_home_code FROM (
            SELECT
              CodedEvent_SNOMED.Patient_ID AS patient_id,
              1 AS binary_flag,
              MAX(ConsultationDate) AS date
            FROM CodedEvent_SNOMED
            INNER JOIN #tmp4_care_home_code_codelist
            ON ConceptID = #tmp4_care_home_code_codelist.code
            
            WHERE CAST(ConsultationDate AS date) <= CAST('20200426' AS date)
              AND NOT 0 = 1
              AND 1 = 1
            GROUP BY CodedEvent_SNOMED.Patient_ID
            ) t
GO

CREATE CLUSTERED INDEX patient_id_ix ON #care_home_code (patient_id)
GO


        -- Join all columns for final output
        SELECT
          Patient.Patient_ID AS [patient_id],
          ISNULL(#age.[value], 0) AS [age],
          ISNULL(#sex.[value], '') AS [sex],
          ISNULL(#msoa.[msoa], '') AS [msoa],
          ISNULL(#stp.[stp_code], '') AS [stp],
          ISNULL(#region.[nuts1_region_name], '') AS [region],
          ISNULL(#postest_01.[binary_flag], 0) AS [postest_01],
          ISNULL(#primary_care_covid_case_01.[binary_flag], 0) AS [primary_care_covid_case_01],
          ISNULL(#covidemergency_01.[binary_flag], 0) AS [covidemergency_01],
          ISNULL(#covidadmitted_01.[binary_flag], 0) AS [covidadmitted_01],
          CASE WHEN (( ISNULL(#postest_01.[binary_flag], 0) != 0 ) OR ( ISNULL(#primary_care_covid_case_01.[binary_flag], 0) != 0 ) OR ( ISNULL(#covidemergency_01.[binary_flag], 0) != 0 ) OR ( ISNULL(#covidadmitted_01.[binary_flag], 0) != 0 )) THEN 1 ELSE 0 END AS [any_infection_or_disease_01],
          ISNULL(#postest_14.[binary_flag], 0) AS [postest_14],
          ISNULL(#primary_care_covid_case_14.[binary_flag], 0) AS [primary_care_covid_case_14],
          ISNULL(#covidemergency_14.[binary_flag], 0) AS [covidemergency_14],
          ISNULL(#covidadmitted_14.[binary_flag], 0) AS [covidadmitted_14],
          CASE WHEN (( ISNULL(#postest_14.[binary_flag], 0) != 0 ) OR ( ISNULL(#primary_care_covid_case_14.[binary_flag], 0) != 0 ) OR ( ISNULL(#covidemergency_14.[binary_flag], 0) != 0 ) OR ( ISNULL(#covidadmitted_14.[binary_flag], 0) != 0 )) THEN 1 ELSE 0 END AS [any_infection_or_disease_14],
          ISNULL(#postest_ever.[binary_flag], 0) AS [postest_ever],
          ISNULL(#primary_care_covid_case_ever.[binary_flag], 0) AS [primary_care_covid_case_ever],
          ISNULL(#covidemergency_ever.[binary_flag], 0) AS [covidemergency_ever],
          ISNULL(#covidadmitted_ever.[binary_flag], 0) AS [covidadmitted_ever],
          CASE WHEN (( ISNULL(#postest_ever.[binary_flag], 0) != 0 ) OR ( ISNULL(#primary_care_covid_case_ever.[binary_flag], 0) != 0 ) OR ( ISNULL(#covidemergency_ever.[binary_flag], 0) != 0 ) OR ( ISNULL(#covidadmitted_ever.[binary_flag], 0) != 0 )) THEN 1 ELSE 0 END AS [any_infection_or_disease_ever]
        FROM
          Patient
          LEFT JOIN #age ON #age.patient_id = Patient.Patient_ID
          LEFT JOIN #sex ON #sex.patient_id = Patient.Patient_ID
          LEFT JOIN #msoa ON #msoa.patient_id = Patient.Patient_ID
          LEFT JOIN #stp ON #stp.patient_id = Patient.Patient_ID
          LEFT JOIN #region ON #region.patient_id = Patient.Patient_ID
          LEFT JOIN #postest_01 ON #postest_01.patient_id = Patient.Patient_ID
          LEFT JOIN #primary_care_covid_case_01 ON #primary_care_covid_case_01.patient_id = Patient.Patient_ID
          LEFT JOIN #covidemergency_01 ON #covidemergency_01.patient_id = Patient.Patient_ID
          LEFT JOIN #covidadmitted_01 ON #covidadmitted_01.patient_id = Patient.Patient_ID
          LEFT JOIN #postest_14 ON #postest_14.patient_id = Patient.Patient_ID
          LEFT JOIN #primary_care_covid_case_14 ON #primary_care_covid_case_14.patient_id = Patient.Patient_ID
          LEFT JOIN #covidemergency_14 ON #covidemergency_14.patient_id = Patient.Patient_ID
          LEFT JOIN #covidadmitted_14 ON #covidadmitted_14.patient_id = Patient.Patient_ID
          LEFT JOIN #postest_ever ON #postest_ever.patient_id = Patient.Patient_ID
          LEFT JOIN #primary_care_covid_case_ever ON #primary_care_covid_case_ever.patient_id = Patient.Patient_ID
          LEFT JOIN #covidemergency_ever ON #covidemergency_ever.patient_id = Patient.Patient_ID
          LEFT JOIN #covidadmitted_ever ON #covidadmitted_ever.patient_id = Patient.Patient_ID
          LEFT JOIN #registered ON #registered.patient_id = Patient.Patient_ID
          LEFT JOIN #has_died ON #has_died.patient_id = Patient.Patient_ID
          LEFT JOIN #care_home_tpp ON #care_home_tpp.patient_id = Patient.Patient_ID
          LEFT JOIN #care_home_code ON #care_home_code.patient_id = Patient.Patient_ID
        WHERE CASE WHEN (( ISNULL(#registered.[value], 0) != 0 ) AND ISNULL(#age.[value], 0) >= 2 AND ISNULL(#age.[value], 0) <= 120 AND ISNULL(#sex.[value], '') = 'M' OR ISNULL(#sex.[value], '') = 'F' AND NOT ( ISNULL(#has_died.[binary_flag], 0) != 0 ) AND NOT ( ( ISNULL(#care_home_tpp.[value], '') = 'care_or_nursing_home' ) OR ( ( ISNULL(#care_home_code.[binary_flag], 0) != 0 ) ) ) AND ( ISNULL(#msoa.[msoa], '') != '' )) THEN 1 ELSE 0 END = 1
        
