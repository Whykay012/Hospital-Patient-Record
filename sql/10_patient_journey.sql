-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 10 - PATIENT JOURNEY ANALYSIS
-- ============================================================


-- ============================================================
-- 1. PATIENT JOURNEY OVERVIEW
-- ============================================================

SELECT
    COUNT(DISTINCT PATIENT) AS total_patients,
    COUNT(*) AS total_encounters,
    ROUND(
        1.0 * COUNT(*) / COUNT(DISTINCT PATIENT),
        2
    ) AS average_encounters_per_patient
FROM encounters;


-- ============================================================
-- 2. FIRST AND LAST ENCOUNTER FOR EACH PATIENT
-- ============================================================

SELECT
    PATIENT AS patient_id,
    MIN(START) AS first_encounter,
    MAX(START) AS last_encounter,
    COUNT(*) AS encounter_count
FROM encounters
GROUP BY PATIENT
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 3. PATIENT JOURNEY DURATION
-- ============================================================

SELECT
    PATIENT AS patient_id,
    MIN(START) AS first_encounter,
    MAX(STOP) AS last_encounter,

    ROUND(
        julianday(MAX(STOP)) -
        julianday(MIN(START)),
        2
    ) AS journey_days,

    COUNT(*) AS encounter_count

FROM encounters

GROUP BY PATIENT

ORDER BY journey_days DESC

LIMIT 20;


-- ============================================================
-- 4. ENCOUNTERS PER PATIENT
-- ============================================================

SELECT
    PATIENT AS patient_id,
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT ENCOUNTERCLASS) AS encounter_types,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost
FROM encounters
GROUP BY PATIENT
ORDER BY total_encounters DESC
LIMIT 20;


-- ============================================================
-- 5. PATIENTS WITH ONLY ONE ENCOUNTER
-- ============================================================

SELECT
    COUNT(*) AS single_encounter_patients
FROM (
    SELECT
        PATIENT
    FROM encounters
    GROUP BY PATIENT
    HAVING COUNT(*) = 1
);


-- ============================================================
-- 6. PATIENTS WITH MULTIPLE ENCOUNTERS
-- ============================================================

SELECT
    COUNT(*) AS returning_patients
FROM (
    SELECT
        PATIENT
    FROM encounters
    GROUP BY PATIENT
    HAVING COUNT(*) > 1
);


-- ============================================================
-- 7. PATIENT ENCOUNTER FREQUENCY DISTRIBUTION
-- ============================================================

SELECT
    encounter_count,
    COUNT(*) AS patient_count
FROM (
    SELECT
        PATIENT,
        COUNT(*) AS encounter_count
    FROM encounters
    GROUP BY PATIENT
)
GROUP BY encounter_count
ORDER BY encounter_count;


-- ============================================================
-- 8. ENCOUNTER CLASS JOURNEY
-- ============================================================

SELECT
    PATIENT AS patient_id,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN ENCOUNTERCLASS = 'ambulatory'
            THEN 1
            ELSE 0
        END
    ) AS ambulatory_encounters,

    SUM(
        CASE
            WHEN ENCOUNTERCLASS = 'outpatient'
            THEN 1
            ELSE 0
        END
    ) AS outpatient_encounters,

    SUM(
        CASE
            WHEN ENCOUNTERCLASS = 'inpatient'
            THEN 1
            ELSE 0
        END
    ) AS inpatient_encounters,

    SUM(
        CASE
            WHEN ENCOUNTERCLASS = 'emergency'
            THEN 1
            ELSE 0
        END
    ) AS emergency_encounters,

    SUM(
        CASE
            WHEN ENCOUNTERCLASS = 'urgentcare'
            THEN 1
            ELSE 0
        END
    ) AS urgentcare_encounters

FROM encounters

GROUP BY PATIENT

ORDER BY total_encounters DESC

LIMIT 20;


-- ============================================================
-- 9. PATIENT JOURNEY BY ENCOUNTER TYPE
-- ============================================================

SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(
        1.0 * COUNT(*) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS encounters_per_patient,
    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost
FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY encounter_count DESC;


-- ============================================================
-- 10. AVERAGE TIME BETWEEN ENCOUNTERS
-- ============================================================

WITH ordered_encounters AS (

    SELECT
        PATIENT,
        START,
        LAG(START) OVER (
            PARTITION BY PATIENT
            ORDER BY START
        ) AS previous_encounter
    FROM encounters
)

SELECT
    COUNT(*) AS repeat_encounter_intervals,

    ROUND(
        AVG(
            julianday(START) -
            julianday(previous_encounter)
        ),
        2
    ) AS average_days_between_encounters,

    ROUND(
        MIN(
            julianday(START) -
            julianday(previous_encounter)
        ),
        2
    ) AS minimum_days_between_encounters,

    ROUND(
        MAX(
            julianday(START) -
            julianday(previous_encounter)
        ),
        2
    ) AS maximum_days_between_encounters

FROM ordered_encounters

WHERE previous_encounter IS NOT NULL;


-- ============================================================
-- 11. PATIENTS WITH VERY FREQUENT ENCOUNTERS
-- ============================================================

SELECT
    PATIENT AS patient_id,
    COUNT(*) AS encounter_count,
    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,
    MIN(START) AS first_encounter,
    MAX(START) AS last_encounter
FROM encounters
GROUP BY PATIENT
HAVING COUNT(*) >= 10
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 12. PATIENT JOURNEY COST
-- ============================================================

SELECT
    PATIENT AS patient_id,
    COUNT(*) AS encounter_count,

    ROUND(
        SUM(BASE_ENCOUNTER_COST),
        2
    ) AS total_base_cost,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        SUM(PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        SUM(TOTAL_CLAIM_COST) -
        SUM(PAYER_COVERAGE),
        2
    ) AS estimated_patient_responsibility

FROM encounters

GROUP BY PATIENT

ORDER BY total_claim_cost DESC

LIMIT 20;


-- ============================================================
-- 13. PATIENT PROCEDURE JOURNEY
-- ============================================================

SELECT
    p.Id AS patient_id,
    COUNT(pr.CODE) AS procedure_count,
    COUNT(DISTINCT pr.CODE) AS procedure_types,
    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost
FROM patients p
JOIN procedures pr
    ON p.Id = pr.PATIENT
GROUP BY p.Id
ORDER BY procedure_count DESC
LIMIT 20;


-- ============================================================
-- 14. PATIENT ENCOUNTERS AND PROCEDURES
-- ============================================================

SELECT
    e.PATIENT AS patient_id,

    COUNT(DISTINCT e.Id)
        AS encounter_count,

    COUNT(pr.CODE)
        AS procedure_count,

    COUNT(DISTINCT pr.CODE)
        AS procedure_types,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost

FROM encounters e

LEFT JOIN procedures pr
    ON e.Id = pr.ENCOUNTER

GROUP BY e.PATIENT

ORDER BY encounter_count DESC

LIMIT 20;


-- ============================================================
-- 15. PATIENT DIAGNOSIS JOURNEY
-- ============================================================

SELECT
    PATIENT AS patient_id,

    COUNT(DISTINCT REASONCODE)
        AS distinct_diagnoses,

    COUNT(*) AS diagnosed_encounters,

    GROUP_CONCAT(
        DISTINCT REASONDESCRIPTION
    ) AS diagnoses

FROM encounters

WHERE REASONCODE IS NOT NULL

GROUP BY PATIENT

ORDER BY distinct_diagnoses DESC

LIMIT 20;


-- ============================================================
-- 16. PATIENT FIRST DIAGNOSIS
-- ============================================================

WITH first_diagnosis AS (

    SELECT
        PATIENT,
        REASONCODE,
        REASONDESCRIPTION,
        START,

        ROW_NUMBER() OVER (
            PARTITION BY PATIENT
            ORDER BY START
        ) AS diagnosis_rank

    FROM encounters

    WHERE REASONCODE IS NOT NULL
)

SELECT
    PATIENT AS patient_id,
    REASONCODE AS first_diagnosis_code,
    REASONDESCRIPTION AS first_diagnosis,
    START AS first_diagnosis_date

FROM first_diagnosis

WHERE diagnosis_rank = 1

ORDER BY first_diagnosis_date

LIMIT 20;


-- ============================================================
-- 17. PATIENT LAST DIAGNOSIS
-- ============================================================

WITH last_diagnosis AS (

    SELECT
        PATIENT,
        REASONCODE,
        REASONDESCRIPTION,
        START,

        ROW_NUMBER() OVER (
            PARTITION BY PATIENT
            ORDER BY START DESC
        ) AS diagnosis_rank

    FROM encounters

    WHERE REASONCODE IS NOT NULL
)

SELECT
    PATIENT AS patient_id,
    REASONCODE AS last_diagnosis_code,
    REASONDESCRIPTION AS last_diagnosis,
    START AS last_diagnosis_date

FROM last_diagnosis

WHERE diagnosis_rank = 1

ORDER BY last_diagnosis_date DESC

LIMIT 20;


-- ============================================================
-- 18. FIRST TO LAST ENCOUNTER TRANSITION
-- ============================================================

SELECT
    PATIENT AS patient_id,

    MIN(START) AS first_encounter,

    MAX(START) AS last_encounter,

    ROUND(
        julianday(MAX(START)) -
        julianday(MIN(START)),
        2
    ) AS journey_days,

    COUNT(*) AS total_encounters

FROM encounters

GROUP BY PATIENT

HAVING COUNT(*) > 1

ORDER BY journey_days DESC

LIMIT 20;


-- ============================================================
-- 19. PATIENT JOURNEY BY YEAR
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,

    COUNT(*) AS encounter_count,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    ROUND(
        1.0 * COUNT(*) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS encounters_per_patient,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost

FROM encounters

GROUP BY year

ORDER BY year;


-- ============================================================
-- 20. RETURNING PATIENT RATE BY YEAR
-- ============================================================

WITH patient_year AS (

    SELECT
        SUBSTR(START, 1, 4) AS year,
        PATIENT,
        COUNT(*) AS encounter_count
    FROM encounters
    GROUP BY
        year,
        PATIENT
)

SELECT
    year,

    COUNT(*) AS total_patients,

    SUM(
        CASE
            WHEN encounter_count > 1
            THEN 1
            ELSE 0
        END
    ) AS returning_patients,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN encounter_count > 1
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS returning_patient_rate

FROM patient_year

GROUP BY year

ORDER BY year;


-- ============================================================
-- 21. PATIENT JOURNEY BY GENDER
-- ============================================================

SELECT
    p.GENDER,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    COUNT(e.Id)
        AS total_encounters,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_patient,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.GENDER

ORDER BY total_encounters DESC;


-- ============================================================
-- 22. PATIENT JOURNEY BY RACE
-- ============================================================

SELECT
    p.RACE,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    COUNT(e.Id)
        AS total_encounters,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_patient,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.RACE

ORDER BY total_encounters DESC;


-- ============================================================
-- 23. HIGH-UTILIZATION PATIENTS
-- ============================================================

SELECT
    p.Id AS patient_id,
    p.GENDER,
    p.RACE,
    p.ETHNICITY,

    COUNT(e.Id)
        AS encounter_count,

    COUNT(DISTINCT e.ENCOUNTERCLASS)
        AS encounter_types,

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
    p.Id,
    p.GENDER,
    p.RACE,
    p.ETHNICITY

HAVING COUNT(e.Id) >= 10

ORDER BY encounter_count DESC

LIMIT 20;


-- ============================================================
-- 24. PATIENT JOURNEY SUMMARY BY UTILIZATION GROUP
-- ============================================================

WITH patient_utilization AS (

    SELECT
        PATIENT,
        COUNT(*) AS encounter_count,
        SUM(TOTAL_CLAIM_COST) AS total_claim_cost
    FROM encounters
    GROUP BY PATIENT
)

SELECT

    CASE
        WHEN encounter_count = 1
            THEN '1 encounter'

        WHEN encounter_count BETWEEN 2 AND 4
            THEN '2-4 encounters'

        WHEN encounter_count BETWEEN 5 AND 9
            THEN '5-9 encounters'

        ELSE '10+ encounters'
    END AS utilization_group,

    COUNT(*) AS patient_count,

    ROUND(
        AVG(encounter_count),
        2
    ) AS average_encounters,

    ROUND(
        AVG(total_claim_cost),
        2
    ) AS average_patient_cost,

    ROUND(
        SUM(total_claim_cost),
        2
    ) AS total_claim_cost

FROM patient_utilization

GROUP BY utilization_group

ORDER BY
    CASE utilization_group
        WHEN '1 encounter' THEN 1
        WHEN '2-4 encounters' THEN 2
        WHEN '5-9 encounters' THEN 3
        WHEN '10+ encounters' THEN 4
    END;


-- ============================================================
-- 25. EXECUTIVE PATIENT JOURNEY SUMMARY
-- ============================================================

SELECT

    COUNT(DISTINCT PATIENT)
        AS total_patients,

    COUNT(*)
        AS total_encounters,

    ROUND(
        1.0 * COUNT(*) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS average_encounters_per_patient,

    COUNT(
        DISTINCT CASE
            WHEN PATIENT IN (
                SELECT PATIENT
                FROM encounters
                GROUP BY PATIENT
                HAVING COUNT(*) > 1
            )
            THEN PATIENT
        END
    ) AS returning_patients,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_encounter_cost

FROM encounters;