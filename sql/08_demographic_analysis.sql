-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 08 - DEMOGRAPHIC ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL PATIENT DEMOGRAPHIC SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_patients,
    COUNT(DISTINCT GENDER) AS gender_categories,
    COUNT(DISTINCT RACE) AS race_categories,
    COUNT(DISTINCT ETHNICITY) AS ethnicity_categories,
    COUNT(DISTINCT MARITAL) AS marital_status_categories,
    COUNT(DISTINCT STATE) AS states_represented
FROM patients;


-- ============================================================
-- 2. PATIENTS BY GENDER
-- ============================================================

SELECT
    GENDER,
    COUNT(*) AS patient_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients
FROM patients
GROUP BY GENDER
ORDER BY patient_count DESC;


-- ============================================================
-- 3. PATIENTS BY RACE
-- ============================================================

SELECT
    RACE,
    COUNT(*) AS patient_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients
FROM patients
GROUP BY RACE
ORDER BY patient_count DESC;


-- ============================================================
-- 4. PATIENTS BY ETHNICITY
-- ============================================================

SELECT
    ETHNICITY,
    COUNT(*) AS patient_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients
FROM patients
GROUP BY ETHNICITY
ORDER BY patient_count DESC;


-- ============================================================
-- 5. PATIENTS BY MARITAL STATUS
-- ============================================================

SELECT
    MARITAL,
    COUNT(*) AS patient_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients
FROM patients
GROUP BY MARITAL
ORDER BY patient_count DESC;


-- ============================================================
-- 6. PATIENTS BY STATE
-- ============================================================

SELECT
    STATE,
    COUNT(*) AS patient_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients
FROM patients
GROUP BY STATE
ORDER BY patient_count DESC;


-- ============================================================
-- 7. PATIENTS BY COUNTY
-- ============================================================

SELECT
    COUNTY,
    COUNT(*) AS patient_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients
FROM patients
GROUP BY COUNTY
ORDER BY patient_count DESC
LIMIT 20;


-- ============================================================
-- 8. PATIENTS BY CITY
-- ============================================================

SELECT
    CITY,
    COUNT(*) AS patient_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients
FROM patients
GROUP BY CITY
ORDER BY patient_count DESC
LIMIT 20;


-- ============================================================
-- 9. AGE DISTRIBUTION
-- ============================================================

SELECT

    CASE
        WHEN (
            julianday('now') -
            julianday(BIRTHDATE)
        ) / 365.25 < 18
            THEN 'Under 18'

        WHEN (
            julianday('now') -
            julianday(BIRTHDATE)
        ) / 365.25 < 30
            THEN '18-29'

        WHEN (
            julianday('now') -
            julianday(BIRTHDATE)
        ) / 365.25 < 40
            THEN '30-39'

        WHEN (
            julianday('now') -
            julianday(BIRTHDATE)
        ) / 365.25 < 50
            THEN '40-49'

        WHEN (
            julianday('now') -
            julianday(BIRTHDATE)
        ) / 365.25 < 60
            THEN '50-59'

        WHEN (
            julianday('now') -
            julianday(BIRTHDATE)
        ) / 365.25 < 70
            THEN '60-69'

        WHEN (
            julianday('now') -
            julianday(BIRTHDATE)
        ) / 365.25 < 80
            THEN '70-79'

        ELSE '80+'
    END AS age_group,

    COUNT(*) AS patient_count,

    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients

FROM patients

WHERE BIRTHDATE IS NOT NULL

GROUP BY age_group

ORDER BY
    CASE age_group
        WHEN 'Under 18' THEN 1
        WHEN '18-29' THEN 2
        WHEN '30-39' THEN 3
        WHEN '40-49' THEN 4
        WHEN '50-59' THEN 5
        WHEN '60-69' THEN 6
        WHEN '70-79' THEN 7
        WHEN '80+' THEN 8
    END;


-- ============================================================
-- 10. GENDER BY RACE
-- ============================================================

SELECT
    GENDER,
    RACE,
    COUNT(*) AS patient_count
FROM patients
GROUP BY
    GENDER,
    RACE
ORDER BY
    GENDER,
    patient_count DESC;


-- ============================================================
-- 11. GENDER BY ETHNICITY
-- ============================================================

SELECT
    GENDER,
    ETHNICITY,
    COUNT(*) AS patient_count
FROM patients
GROUP BY
    GENDER,
    ETHNICITY
ORDER BY
    GENDER,
    patient_count DESC;


-- ============================================================
-- 12. RACE BY ETHNICITY
-- ============================================================

SELECT
    RACE,
    ETHNICITY,
    COUNT(*) AS patient_count
FROM patients
GROUP BY
    RACE,
    ETHNICITY
ORDER BY
    RACE,
    patient_count DESC;


-- ============================================================
-- 13. GENDER BY MARITAL STATUS
-- ============================================================

SELECT
    GENDER,
    MARITAL,
    COUNT(*) AS patient_count
FROM patients
GROUP BY
    GENDER,
    MARITAL
ORDER BY
    GENDER,
    patient_count DESC;


-- ============================================================
-- 14. AGE GROUP BY GENDER
-- ============================================================

WITH patient_age AS (

    SELECT

        GENDER,

        CASE
            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 18
                THEN 'Under 18'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 30
                THEN '18-29'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 40
                THEN '30-39'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 50
                THEN '40-49'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 60
                THEN '50-59'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 70
                THEN '60-69'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 80
                THEN '70-79'

            ELSE '80+'
        END AS age_group

    FROM patients

    WHERE BIRTHDATE IS NOT NULL
)

SELECT
    age_group,
    GENDER,
    COUNT(*) AS patient_count
FROM patient_age
GROUP BY
    age_group,
    GENDER
ORDER BY
    age_group,
    patient_count DESC;


-- ============================================================
-- 15. ENCOUNTER UTILIZATION BY GENDER
-- ============================================================

SELECT

    p.GENDER,

    COUNT(e.Id) AS total_encounters,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_patient,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(e.TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.GENDER

ORDER BY total_encounters DESC;


-- ============================================================
-- 16. ENCOUNTER UTILIZATION BY RACE
-- ============================================================

SELECT

    p.RACE,

    COUNT(e.Id) AS total_encounters,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_patient,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(e.TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.RACE

ORDER BY total_encounters DESC;


-- ============================================================
-- 17. ENCOUNTER UTILIZATION BY ETHNICITY
-- ============================================================

SELECT

    p.ETHNICITY,

    COUNT(e.Id) AS total_encounters,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_patient,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(e.TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.ETHNICITY

ORDER BY total_encounters DESC;


-- ============================================================
-- 18. PROCEDURE UTILIZATION BY GENDER
-- ============================================================

SELECT

    p.GENDER,

    COUNT(pr.PATIENT) AS total_procedures,

    COUNT(DISTINCT pr.PATIENT)
        AS patients_with_procedures,

    COUNT(DISTINCT pr.CODE)
        AS distinct_procedure_types,

    ROUND(
        1.0 * COUNT(pr.PATIENT) /
        COUNT(DISTINCT pr.PATIENT),
        2
    ) AS procedures_per_patient,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost

FROM patients p

JOIN procedures pr
    ON p.Id = pr.PATIENT

GROUP BY p.GENDER

ORDER BY total_procedures DESC;


-- ============================================================
-- 19. PROCEDURE UTILIZATION BY AGE GROUP
-- ============================================================

WITH patient_age AS (

    SELECT

        Id AS patient_id,

        CASE
            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 18
                THEN 'Under 18'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 30
                THEN '18-29'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 40
                THEN '30-39'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 50
                THEN '40-49'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 60
                THEN '50-59'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 70
                THEN '60-69'

            WHEN (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25 < 80
                THEN '70-79'

            ELSE '80+'
        END AS age_group

    FROM patients

    WHERE BIRTHDATE IS NOT NULL
)

SELECT

    pa.age_group,

    COUNT(pr.PATIENT) AS total_procedures,

    COUNT(DISTINCT pr.PATIENT)
        AS patients_with_procedures,

    ROUND(
        1.0 * COUNT(pr.PATIENT) /
        COUNT(DISTINCT pr.PATIENT),
        2
    ) AS procedures_per_patient,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost

FROM patient_age pa

JOIN procedures pr
    ON pa.patient_id = pr.PATIENT

GROUP BY pa.age_group

ORDER BY
    CASE pa.age_group
        WHEN 'Under 18' THEN 1
        WHEN '18-29' THEN 2
        WHEN '30-39' THEN 3
        WHEN '40-49' THEN 4
        WHEN '50-59' THEN 5
        WHEN '60-69' THEN 6
        WHEN '70-79' THEN 7
        WHEN '80+' THEN 8
    END;


-- ============================================================
-- 20. MORTALITY BY DEMOGRAPHIC GROUP
-- ============================================================

SELECT

    GENDER,

    COUNT(*) AS total_patients,

    SUM(
        CASE
            WHEN DEATHDATE IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS patients_with_death_date,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN DEATHDATE IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS death_date_percentage

FROM patients

GROUP BY GENDER

ORDER BY death_date_percentage DESC;


-- ============================================================
-- 21. DEMOGRAPHIC GROUP WITH HIGHEST HEALTHCARE UTILIZATION
-- ============================================================

SELECT

    p.RACE,

    COUNT(e.Id) AS total_encounters,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_patient

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.RACE

ORDER BY encounters_per_patient DESC

LIMIT 10;


-- ============================================================
-- 22. DEMOGRAPHIC COST ANALYSIS
-- ============================================================

SELECT

    p.GENDER,

    p.RACE,

    COUNT(e.Id) AS encounter_count,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(e.TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY
    p.GENDER,
    p.RACE

ORDER BY total_claim_cost DESC;


-- ============================================================
-- 23. TOP DEMOGRAPHIC GROUPS BY PROCEDURE COST
-- ============================================================

SELECT

    p.GENDER,

    p.RACE,

    COUNT(pr.CODE) AS procedure_count,

    COUNT(DISTINCT pr.PATIENT)
        AS unique_patients,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(pr.BASE_COST),
        2
    ) AS average_procedure_cost

FROM patients p

JOIN procedures pr
    ON p.Id = pr.PATIENT

GROUP BY
    p.GENDER,
    p.RACE

ORDER BY total_procedure_cost DESC

LIMIT 20;


-- ============================================================
-- 24. PATIENT AGE SUMMARY
-- ============================================================

SELECT

    ROUND(
        AVG(
            (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25
        ),
        2
    ) AS average_patient_age,

    ROUND(
        MIN(
            (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25
        ),
        2
    ) AS minimum_patient_age,

    ROUND(
        MAX(
            (
                julianday('now') -
                julianday(BIRTHDATE)
            ) / 365.25
        ),
        2
    ) AS maximum_patient_age

FROM patients

WHERE BIRTHDATE IS NOT NULL;


-- ============================================================
-- 25. EXECUTIVE DEMOGRAPHIC SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS total_patients,

    SUM(
        CASE
            WHEN GENDER = 'F'
            THEN 1
            ELSE 0
        END
    ) AS female_patients,

    SUM(
        CASE
            WHEN GENDER = 'M'
            THEN 1
            ELSE 0
        END
    ) AS male_patients,

    SUM(
        CASE
            WHEN DEATHDATE IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS patients_with_death_date,

    COUNT(DISTINCT RACE)
        AS race_categories,

    COUNT(DISTINCT ETHNICITY)
        AS ethnicity_categories,

    COUNT(DISTINCT MARITAL)
        AS marital_status_categories

FROM patients;
