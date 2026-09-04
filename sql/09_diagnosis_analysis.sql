-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 09 - DIAGNOSIS ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL DIAGNOSIS SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_encounters,
    COUNT(REASONCODE) AS encounters_with_diagnosis,
    COUNT(DISTINCT REASONCODE) AS distinct_diagnoses,
    ROUND(
        100.0 * COUNT(REASONCODE) / COUNT(*),
        2
    ) AS diagnosis_documentation_rate
FROM encounters;


-- ============================================================
-- 2. TOP 20 DIAGNOSES BY FREQUENCY
-- ============================================================

SELECT
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY
    REASONCODE,
    REASONDESCRIPTION
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 3. TOP 20 DIAGNOSES BY UNIQUE PATIENTS
-- ============================================================

SELECT
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    COUNT(*) AS encounter_count
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY
    REASONCODE,
    REASONDESCRIPTION
ORDER BY unique_patients DESC
LIMIT 20;


-- ============================================================
-- 4. DIAGNOSIS BY ENCOUNTER CLASS
-- ============================================================

SELECT
    ENCOUNTERCLASS,
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY
    ENCOUNTERCLASS,
    REASONCODE,
    REASONDESCRIPTION
ORDER BY
    ENCOUNTERCLASS,
    encounter_count DESC;


-- ============================================================
-- 5. TOP DIAGNOSES BY TOTAL CLAIM COST
-- ============================================================

SELECT
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY
    REASONCODE,
    REASONDESCRIPTION
ORDER BY total_claim_cost DESC
LIMIT 20;


-- ============================================================
-- 6. TOP DIAGNOSES BY AVERAGE CLAIM COST
-- ============================================================

SELECT
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY
    REASONCODE,
    REASONDESCRIPTION
HAVING COUNT(*) >= 5
ORDER BY average_claim_cost DESC
LIMIT 20;


-- ============================================================
-- 7. DIAGNOSIS BY YEAR
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY
    year,
    REASONCODE,
    REASONDESCRIPTION
ORDER BY
    year,
    encounter_count DESC;


-- ============================================================
-- 8. YEARLY DIAGNOSIS SUMMARY
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,
    COUNT(*) AS diagnosed_encounters,
    COUNT(DISTINCT REASONCODE) AS distinct_diagnoses,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY year
ORDER BY year;


-- ============================================================
-- 9. DIAGNOSIS UTILIZATION BY GENDER
-- ============================================================

SELECT
    p.GENDER,
    e.REASONCODE AS diagnosis_code,
    e.REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT e.PATIENT) AS unique_patients
FROM encounters e
JOIN patients p
    ON e.PATIENT = p.Id
WHERE e.REASONCODE IS NOT NULL
GROUP BY
    p.GENDER,
    e.REASONCODE,
    e.REASONDESCRIPTION
ORDER BY
    p.GENDER,
    encounter_count DESC;


-- ============================================================
-- 10. TOP DIAGNOSES BY GENDER
-- ============================================================

SELECT
    p.GENDER,
    e.REASONDESCRIPTION AS diagnosis,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT e.PATIENT) AS unique_patients,
    ROUND(SUM(e.TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters e
JOIN patients p
    ON e.PATIENT = p.Id
WHERE e.REASONCODE IS NOT NULL
GROUP BY
    p.GENDER,
    e.REASONDESCRIPTION
ORDER BY
    p.GENDER,
    encounter_count DESC;


-- ============================================================
-- 11. DIAGNOSIS UTILIZATION BY RACE
-- ============================================================

SELECT
    p.RACE,
    e.REASONCODE AS diagnosis_code,
    e.REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT e.PATIENT) AS unique_patients
FROM encounters e
JOIN patients p
    ON e.PATIENT = p.Id
WHERE e.REASONCODE IS NOT NULL
GROUP BY
    p.RACE,
    e.REASONCODE,
    e.REASONDESCRIPTION
ORDER BY
    p.RACE,
    encounter_count DESC;


-- ============================================================
-- 12. DIAGNOSIS UTILIZATION BY ETHNICITY
-- ============================================================

SELECT
    p.ETHNICITY,
    e.REASONCODE AS diagnosis_code,
    e.REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT e.PATIENT) AS unique_patients
FROM encounters e
JOIN patients p
    ON e.PATIENT = p.Id
WHERE e.REASONCODE IS NOT NULL
GROUP BY
    p.ETHNICITY,
    e.REASONCODE,
    e.REASONDESCRIPTION
ORDER BY
    p.ETHNICITY,
    encounter_count DESC;


-- ============================================================
-- 13. DIAGNOSIS AND PROCEDURE RELATIONSHIP
-- ============================================================

SELECT
    e.REASONCODE AS diagnosis_code,
    e.REASONDESCRIPTION AS diagnosis_description,
    COUNT(DISTINCT e.Id) AS diagnosed_encounters,
    COUNT(pr.CODE) AS procedure_count,
    COUNT(DISTINCT pr.CODE) AS procedure_types,
    ROUND(SUM(pr.BASE_COST), 2) AS total_procedure_cost
FROM encounters e
LEFT JOIN procedures pr
    ON e.Id = pr.ENCOUNTER
WHERE e.REASONCODE IS NOT NULL
GROUP BY
    e.REASONCODE,
    e.REASONDESCRIPTION
ORDER BY total_procedure_cost DESC
LIMIT 20;


-- ============================================================
-- 14. TOP PROCEDURES ASSOCIATED WITH DIAGNOSES
-- ============================================================

SELECT
    e.REASONCODE AS diagnosis_code,
    e.REASONDESCRIPTION AS diagnosis_description,
    pr.CODE AS procedure_code,
    pr.DESCRIPTION AS procedure_description,
    COUNT(*) AS procedure_count,
    ROUND(SUM(pr.BASE_COST), 2) AS total_procedure_cost
FROM encounters e
JOIN procedures pr
    ON e.Id = pr.ENCOUNTER
WHERE e.REASONCODE IS NOT NULL
GROUP BY
    e.REASONCODE,
    e.REASONDESCRIPTION,
    pr.CODE,
    pr.DESCRIPTION
ORDER BY procedure_count DESC
LIMIT 30;


-- ============================================================
-- 15. DIAGNOSIS COST BANDS
-- ============================================================

SELECT
    CASE
        WHEN TOTAL_CLAIM_COST < 500
            THEN '< $500'
        WHEN TOTAL_CLAIM_COST < 1000
            THEN '$500 - $999'
        WHEN TOTAL_CLAIM_COST < 5000
            THEN '$1,000 - $4,999'
        WHEN TOTAL_CLAIM_COST < 10000
            THEN '$5,000 - $9,999'
        WHEN TOTAL_CLAIM_COST < 25000
            THEN '$10,000 - $24,999'
        ELSE '$25,000+'
    END AS cost_band,

    COUNT(*) AS diagnosed_encounters,

    COUNT(DISTINCT REASONCODE)
        AS distinct_diagnoses,

    ROUND(SUM(TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(AVG(TOTAL_CLAIM_COST), 2)
        AS average_claim_cost

FROM encounters

WHERE REASONCODE IS NOT NULL

GROUP BY cost_band

ORDER BY
    CASE cost_band
        WHEN '< $500' THEN 1
        WHEN '$500 - $999' THEN 2
        WHEN '$1,000 - $4,999' THEN 3
        WHEN '$5,000 - $9,999' THEN 4
        WHEN '$10,000 - $24,999' THEN 5
        WHEN '$25,000+' THEN 6
    END;


-- ============================================================
-- 16. PATIENTS WITH MULTIPLE DIAGNOSES
-- ============================================================

SELECT
    PATIENT AS patient_id,
    COUNT(*) AS diagnosed_encounters,
    COUNT(DISTINCT REASONCODE) AS distinct_diagnoses,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY PATIENT
HAVING COUNT(DISTINCT REASONCODE) > 1
ORDER BY distinct_diagnoses DESC
LIMIT 20;


-- ============================================================
-- 17. MOST COMMON DIAGNOSIS PER PATIENT
-- ============================================================

WITH diagnosis_counts AS (

    SELECT
        PATIENT AS patient_id,
        REASONCODE AS diagnosis_code,
        REASONDESCRIPTION AS diagnosis_description,
        COUNT(*) AS diagnosis_count,

        ROW_NUMBER() OVER (
            PARTITION BY PATIENT
            ORDER BY COUNT(*) DESC
        ) AS diagnosis_rank

    FROM encounters

    WHERE REASONCODE IS NOT NULL

    GROUP BY
        PATIENT,
        REASONCODE,
        REASONDESCRIPTION
)

SELECT
    patient_id,
    diagnosis_code,
    diagnosis_description,
    diagnosis_count
FROM diagnosis_counts
WHERE diagnosis_rank = 1
ORDER BY diagnosis_count DESC
LIMIT 20;


-- ============================================================
-- 18. DIAGNOSIS BY PAYER
-- ============================================================

SELECT
    py.NAME AS payer_name,
    e.REASONCODE AS diagnosis_code,
    e.REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT e.PATIENT) AS unique_patients,
    ROUND(SUM(e.TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters e
JOIN payers py
    ON e.PAYER = py.Id
WHERE e.REASONCODE IS NOT NULL
GROUP BY
    py.NAME,
    e.REASONCODE,
    e.REASONDESCRIPTION
ORDER BY
    py.NAME,
    encounter_count DESC;


-- ============================================================
-- 19. TOP DIAGNOSES BY PAYER
-- ============================================================

SELECT
    py.NAME AS payer_name,
    e.REASONDESCRIPTION AS diagnosis,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT e.PATIENT) AS unique_patients,
    ROUND(SUM(e.TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters e
JOIN payers py
    ON e.PAYER = py.Id
WHERE e.REASONCODE IS NOT NULL
GROUP BY
    py.NAME,
    e.REASONDESCRIPTION
ORDER BY total_claim_cost DESC
LIMIT 30;


-- ============================================================
-- 20. DIAGNOSIS CONCENTRATION
-- ============================================================

WITH diagnosis_counts AS (

    SELECT
        REASONCODE,
        REASONDESCRIPTION,
        COUNT(*) AS encounter_count
    FROM encounters
    WHERE REASONCODE IS NOT NULL
    GROUP BY
        REASONCODE,
        REASONDESCRIPTION
),

ranked AS (

    SELECT
        *,
        SUM(encounter_count) OVER ()
            AS total_diagnosed_encounters,

        SUM(encounter_count) OVER (
            ORDER BY encounter_count DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_encounters

    FROM diagnosis_counts
)

SELECT
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,
    encounter_count,
    total_diagnosed_encounters,
    ROUND(
        100.0 * encounter_count /
        total_diagnosed_encounters,
        2
    ) AS diagnosis_percentage,
    ROUND(
        100.0 * cumulative_encounters /
        total_diagnosed_encounters,
        2
    ) AS cumulative_percentage
FROM ranked
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 21. DIAGNOSIS FREQUENCY AND COST
-- ============================================================

SELECT
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,
    COUNT(*) AS encounter_count,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost,
    ROUND(
        SUM(PAYER_COVERAGE),
        2
    ) AS total_payer_coverage
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY
    REASONCODE,
    REASONDESCRIPTION
ORDER BY total_claim_cost DESC
LIMIT 20;


-- ============================================================
-- 22. DIAGNOSES WITH HIGHEST PATIENT BURDEN
-- ============================================================

SELECT
    REASONCODE AS diagnosis_code,
    REASONDESCRIPTION AS diagnosis_description,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    COUNT(*)
        AS total_encounters,

    ROUND(
        1.0 * COUNT(*) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS encounters_per_patient

FROM encounters

WHERE REASONCODE IS NOT NULL

GROUP BY
    REASONCODE,
    REASONDESCRIPTION

HAVING COUNT(DISTINCT PATIENT) >= 5

ORDER BY encounters_per_patient DESC

LIMIT 20;


-- ============================================================
-- 23. DIAGNOSIS BY ENCOUNTER YEAR AND CLASS
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,
    ENCOUNTERCLASS,
    REASONDESCRIPTION AS diagnosis,
    COUNT(*) AS encounter_count,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters
WHERE REASONCODE IS NOT NULL
GROUP BY
    year,
    ENCOUNTERCLASS,
    REASONDESCRIPTION
ORDER BY
    year,
    encounter_count DESC;


-- ============================================================
-- 24. DIAGNOSIS DATA QUALITY
-- ============================================================

SELECT
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN REASONCODE IS NULL
            THEN 1
            ELSE 0
        END
    ) AS missing_diagnosis_code,

    SUM(
        CASE
            WHEN REASONDESCRIPTION IS NULL
            THEN 1
            ELSE 0
        END
    ) AS missing_diagnosis_description,

    SUM(
        CASE
            WHEN REASONCODE IS NOT NULL
             AND REASONDESCRIPTION IS NULL
            THEN 1
            ELSE 0
        END
    ) AS code_without_description,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN REASONCODE IS NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS missing_diagnosis_percentage

FROM encounters;


-- ============================================================
-- 25. EXECUTIVE DIAGNOSIS SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS total_encounters,

    COUNT(REASONCODE)
        AS encounters_with_diagnosis,

    COUNT(DISTINCT REASONCODE)
        AS distinct_diagnoses,

    COUNT(DISTINCT PATIENT)
        AS patients_with_diagnosis,

    ROUND(
        SUM(
            CASE
                WHEN REASONCODE IS NOT NULL
                THEN TOTAL_CLAIM_COST
                ELSE 0
            END
        ),
        2
    ) AS total_claim_cost_for_diagnosed_encounters,

    ROUND(
        AVG(
            CASE
                WHEN REASONCODE IS NOT NULL
                THEN TOTAL_CLAIM_COST
            END
        ),
        2
    ) AS average_claim_cost_for_diagnosed_encounters

FROM encounters;