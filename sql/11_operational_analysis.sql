-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 11 - OPERATIONAL ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL OPERATIONAL SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    COUNT(DISTINCT ENCOUNTERCLASS) AS encounter_types,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost
FROM encounters;


-- ============================================================
-- 2. ENCOUNTERS BY ENCOUNTER CLASS
-- ============================================================

SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS encounter_percentage,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost
FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY encounter_count DESC;


-- ============================================================
-- 3. ENCOUNTERS BY YEAR
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters
GROUP BY year
ORDER BY year;


-- ============================================================
-- 4. ENCOUNTERS BY YEAR AND ENCOUNTER CLASS
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,
    ENCOUNTERCLASS,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters
GROUP BY
    year,
    ENCOUNTERCLASS
ORDER BY
    year,
    encounter_count DESC;


-- ============================================================
-- 5. MONTHLY ENCOUNTER VOLUME
-- ============================================================

SELECT
    SUBSTR(START, 1, 7) AS month,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters
GROUP BY month
ORDER BY month;


-- ============================================================
-- 6. DAY-OF-WEEK ENCOUNTER PATTERN
-- ============================================================

SELECT
    CASE CAST(
        STRFTIME('%w', START) AS INTEGER
    )
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,

    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost

FROM encounters

GROUP BY
    STRFTIME('%w', START)

ORDER BY
    CAST(STRFTIME('%w', START) AS INTEGER);


-- ============================================================
-- 7. HOUR-OF-DAY ENCOUNTER PATTERN
-- ============================================================

SELECT
    SUBSTR(START, 12, 2) AS hour,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost
FROM encounters
GROUP BY hour
ORDER BY hour;


-- ============================================================
-- 8. ENCOUNTER DURATION ANALYSIS
-- ============================================================

SELECT
    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(
        AVG(
            (julianday(STOP) - julianday(START)) * 24
        ),
        2
    ) AS average_duration_hours,

    ROUND(
        MIN(
            (julianday(STOP) - julianday(START)) * 24
        ),
        2
    ) AS minimum_duration_hours,

    ROUND(
        MAX(
            (julianday(STOP) - julianday(START)) * 24
        ),
        2
    ) AS maximum_duration_hours

FROM encounters

GROUP BY ENCOUNTERCLASS

ORDER BY average_duration_hours DESC;


-- ============================================================
-- 9. LONGEST ENCOUNTERS
-- ============================================================

SELECT
    Id AS encounter_id,
    PATIENT AS patient_id,
    ENCOUNTERCLASS,
    START,
    STOP,

    ROUND(
        (julianday(STOP) - julianday(START)) * 24,
        2
    ) AS duration_hours,

    ROUND(TOTAL_CLAIM_COST, 2) AS total_claim_cost

FROM encounters

ORDER BY duration_hours DESC

LIMIT 20;


-- ============================================================
-- 10. SHORTEST ENCOUNTERS
-- ============================================================

SELECT
    Id AS encounter_id,
    PATIENT AS patient_id,
    ENCOUNTERCLASS,
    START,
    STOP,

    ROUND(
        (julianday(STOP) - julianday(START)) * 24,
        2
    ) AS duration_hours,

    ROUND(TOTAL_CLAIM_COST, 2) AS total_claim_cost

FROM encounters

ORDER BY duration_hours ASC

LIMIT 20;


-- ============================================================
-- 11. DAILY ENCOUNTER VOLUME
-- ============================================================

SELECT
    SUBSTR(START, 1, 10) AS encounter_date,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters
GROUP BY encounter_date
ORDER BY encounter_date;


-- ============================================================
-- 12. BUSIEST DAYS
-- ============================================================

SELECT
    SUBSTR(START, 1, 10) AS encounter_date,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost
FROM encounters
GROUP BY encounter_date
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 13. ENCOUNTER DESCRIPTION VOLUME
-- ============================================================

SELECT
    DESCRIPTION AS encounter_description,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost
FROM encounters
GROUP BY DESCRIPTION
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 14. PROCEDURE VOLUME
-- ============================================================

SELECT
    pr.DESCRIPTION AS procedure_description,
    COUNT(*) AS procedure_count,
    COUNT(DISTINCT pr.PATIENT) AS unique_patients,
    ROUND(SUM(pr.BASE_COST), 2) AS total_procedure_cost,
    ROUND(AVG(pr.BASE_COST), 2) AS average_procedure_cost
FROM procedures pr
GROUP BY pr.DESCRIPTION
ORDER BY procedure_count DESC
LIMIT 20;


-- ============================================================
-- 15. PROCEDURE VOLUME BY YEAR
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,
    COUNT(*) AS procedure_count,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    ROUND(SUM(BASE_COST), 2) AS total_procedure_cost
FROM procedures
GROUP BY year
ORDER BY year;


-- ============================================================
-- 16. PROCEDURES PER ENCOUNTER
-- ============================================================

SELECT
    e.ENCOUNTERCLASS,

    COUNT(DISTINCT e.Id)
        AS encounter_count,

    COUNT(pr.CODE)
        AS procedure_count,

    ROUND(
        1.0 * COUNT(pr.CODE) /
        COUNT(DISTINCT e.Id),
        2
    ) AS procedures_per_encounter

FROM encounters e

LEFT JOIN procedures pr
    ON e.Id = pr.ENCOUNTER

GROUP BY e.ENCOUNTERCLASS

ORDER BY procedures_per_encounter DESC;


-- ============================================================
-- 17. ENCOUNTERS WITH PROCEDURES
-- ============================================================

SELECT

    COUNT(DISTINCT e.Id)
        AS total_encounters,

    COUNT(
        DISTINCT CASE
            WHEN pr.ENCOUNTER IS NOT NULL
            THEN e.Id
        END
    ) AS encounters_with_procedures,

    ROUND(
        100.0 *
        COUNT(
            DISTINCT CASE
                WHEN pr.ENCOUNTER IS NOT NULL
                THEN e.Id
            END
        ) / COUNT(DISTINCT e.Id),
        2
    ) AS procedure_utilization_rate

FROM encounters e

LEFT JOIN procedures pr
    ON e.Id = pr.ENCOUNTER;


-- ============================================================
-- 18. HIGH-COST ENCOUNTER CLASSES
-- ============================================================

SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS encounter_count,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_claim_cost,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS average_claim_cost,
    ROUND(MAX(TOTAL_CLAIM_COST), 2) AS maximum_claim_cost
FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY average_claim_cost DESC;


-- ============================================================
-- 19. HIGH-COST INDIVIDUAL ENCOUNTERS
-- ============================================================

SELECT
    Id AS encounter_id,
    PATIENT AS patient_id,
    ENCOUNTERCLASS,
    DESCRIPTION,
    ROUND(BASE_ENCOUNTER_COST, 2) AS base_cost,
    ROUND(TOTAL_CLAIM_COST, 2) AS total_claim_cost,
    ROUND(PAYER_COVERAGE, 2) AS payer_coverage
FROM encounters
ORDER BY TOTAL_CLAIM_COST DESC
LIMIT 20;


-- ============================================================
-- 20. PAYER COVERAGE BY ENCOUNTER CLASS
-- ============================================================

SELECT
    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        SUM(PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        100.0 *
        SUM(PAYER_COVERAGE) /
        NULLIF(SUM(TOTAL_CLAIM_COST), 0),
        2
    ) AS coverage_rate

FROM encounters

GROUP BY ENCOUNTERCLASS

ORDER BY coverage_rate DESC;


-- ============================================================
-- 21. OPERATIONAL VOLUME BY PAYER
-- ============================================================

SELECT
    py.NAME AS payer_name,

    COUNT(e.Id)
        AS encounter_count,

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

FROM encounters e

JOIN payers py
    ON e.PAYER = py.Id

GROUP BY py.NAME

ORDER BY encounter_count DESC;


-- ============================================================
-- 22. OPERATIONAL VOLUME BY DIAGNOSIS
-- ============================================================

SELECT
    REASONDESCRIPTION AS diagnosis,

    COUNT(*) AS encounter_count,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost

FROM encounters

WHERE REASONCODE IS NOT NULL

GROUP BY REASONDESCRIPTION

ORDER BY encounter_count DESC

LIMIT 20;


-- ============================================================
-- 23. DAILY OPERATIONAL PEAKS
-- ============================================================

WITH daily_volume AS (

    SELECT
        SUBSTR(START, 1, 10) AS encounter_date,
        COUNT(*) AS encounter_count
    FROM encounters
    GROUP BY encounter_date
)

SELECT
    ROUND(AVG(encounter_count), 2)
        AS average_daily_encounters,

    MIN(encounter_count)
        AS minimum_daily_encounters,

    MAX(encounter_count)
        AS maximum_daily_encounters

FROM daily_volume;


-- ============================================================
-- 24. ENCOUNTER COST BY DURATION BAND
-- ============================================================

SELECT

    CASE
        WHEN
            (julianday(STOP) - julianday(START)) * 24 < 1
            THEN '< 1 hour'

        WHEN
            (julianday(STOP) - julianday(START)) * 24 < 4
            THEN '1-3 hours'

        WHEN
            (julianday(STOP) - julianday(START)) * 24 < 12
            THEN '4-11 hours'

        WHEN
            (julianday(STOP) - julianday(START)) * 24 < 24
            THEN '12-23 hours'

        ELSE '24+ hours'
    END AS duration_band,

    COUNT(*) AS encounter_count,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost

FROM encounters

GROUP BY duration_band

ORDER BY
    CASE duration_band
        WHEN '< 1 hour' THEN 1
        WHEN '1-3 hours' THEN 2
        WHEN '4-11 hours' THEN 3
        WHEN '12-23 hours' THEN 4
        WHEN '24+ hours' THEN 5
    END;


-- ============================================================
-- 25. OPERATIONAL EFFICIENCY SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS total_encounters,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    ROUND(
        1.0 * COUNT(*) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS encounters_per_patient,

    ROUND(
        AVG(
            (julianday(STOP) - julianday(START)) * 24
        ),
        2
    ) AS average_encounter_duration_hours,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost,

    ROUND(
        100.0 *
        SUM(PAYER_COVERAGE) /
        NULLIF(SUM(TOTAL_CLAIM_COST), 0),
        2
    ) AS overall_coverage_rate

FROM encounters;