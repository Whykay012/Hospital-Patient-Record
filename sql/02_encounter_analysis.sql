-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 02 - ENCOUNTER ANALYSIS
-- ============================================================


-- ============================================================
-- 1. TOTAL ENCOUNTERS
-- ============================================================

SELECT
    COUNT(*) AS total_encounters
FROM encounters;


-- ============================================================
-- 2. ENCOUNTERS BY ENCOUNTER CLASS
-- ============================================================

SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS encounter_count,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS percentage
FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY encounter_count DESC;


-- ============================================================
-- 3. ENCOUNTERS BY YEAR
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,
    COUNT(*) AS encounter_count
FROM encounters
GROUP BY year
ORDER BY year;


-- ============================================================
-- 4. ENCOUNTERS BY YEAR AND ENCOUNTER CLASS
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,
    ENCOUNTERCLASS,
    COUNT(*) AS encounter_count
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
    COUNT(*) AS encounter_count
FROM encounters
GROUP BY month
ORDER BY month;


-- ============================================================
-- 6. AVERAGE ENCOUNTER DURATION
-- ============================================================

SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS encounter_count,
    ROUND(
        AVG(
            (
                julianday(STOP) -
                julianday(START)
            ) * 24
        ),
        2
    ) AS avg_duration_hours
FROM encounters
WHERE START IS NOT NULL
  AND STOP IS NOT NULL
GROUP BY ENCOUNTERCLASS
ORDER BY avg_duration_hours DESC;


-- ============================================================
-- 7. MINIMUM, MAXIMUM AND AVERAGE DURATION
-- ============================================================

SELECT
    ROUND(
        MIN(
            (
                julianday(STOP) -
                julianday(START)
            ) * 24
        ),
        2
    ) AS min_duration_hours,

    ROUND(
        AVG(
            (
                julianday(STOP) -
                julianday(START)
            ) * 24
        ),
        2
    ) AS avg_duration_hours,

    ROUND(
        MAX(
            (
                julianday(STOP) -
                julianday(START)
            ) * 24
        ),
        2
    ) AS max_duration_hours
FROM encounters
WHERE START IS NOT NULL
  AND STOP IS NOT NULL;


-- ============================================================
-- 8. ENCOUNTERS BY DESCRIPTION
-- ============================================================

SELECT
    DESCRIPTION,
    COUNT(*) AS encounter_count
FROM encounters
GROUP BY DESCRIPTION
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 9. ENCOUNTERS BY REASON
-- ============================================================

SELECT
    REASONDESCRIPTION,
    COUNT(*) AS encounter_count
FROM encounters
WHERE REASONDESCRIPTION IS NOT NULL
GROUP BY REASONDESCRIPTION
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 10. DAILY ENCOUNTER VOLUME
-- ============================================================

SELECT
    SUBSTR(START, 1, 10) AS encounter_date,
    COUNT(*) AS encounter_count
FROM encounters
GROUP BY encounter_date
ORDER BY encounter_date;


-- ============================================================
-- 11. DAY OF WEEK ENCOUNTER VOLUME
-- ============================================================

SELECT
    CASE CAST(
        STRFTIME(
            '%w',
            START
        ) AS INTEGER
    )
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,

    COUNT(*) AS encounter_count
FROM encounters
GROUP BY STRFTIME('%w', START)
ORDER BY
    CAST(STRFTIME('%w', START) AS INTEGER);


-- ============================================================
-- 12. HOUR OF DAY ENCOUNTER VOLUME
-- ============================================================

SELECT
    SUBSTR(START, 12, 2) AS hour,
    COUNT(*) AS encounter_count
FROM encounters
GROUP BY hour
ORDER BY hour;


-- ============================================================
-- 13. ENCOUNTER COST BY ENCOUNTER CLASS
-- ============================================================

SELECT
    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(
        AVG(BASE_ENCOUNTER_COST),
        2
    ) AS avg_base_cost,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS avg_claim_cost,

    ROUND(
        AVG(PAYER_COVERAGE),
        2
    ) AS avg_payer_coverage

FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY avg_claim_cost DESC;


-- ============================================================
-- 14. TOTAL COST BY ENCOUNTER CLASS
-- ============================================================

SELECT
    ENCOUNTERCLASS,

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
    ) AS total_payer_coverage

FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY total_claim_cost DESC;


-- ============================================================
-- 15. TOP PATIENTS BY NUMBER OF ENCOUNTERS
-- ============================================================

SELECT
    PATIENT,
    COUNT(*) AS encounter_count
FROM encounters
GROUP BY PATIENT
ORDER BY encounter_count DESC
LIMIT 20;


-- ============================================================
-- 16. PATIENTS WITH HIGH ENCOUNTER UTILIZATION
-- ============================================================

SELECT
    PATIENT,
    COUNT(*) AS encounter_count
FROM encounters
GROUP BY PATIENT
HAVING COUNT(*) >= 20
ORDER BY encounter_count DESC;


-- ============================================================
-- 17. ENCOUNTER VOLUME BY ORGANIZATION
-- ============================================================

SELECT
    e.ORGANIZATION,
    o.NAME AS organization_name,
    COUNT(*) AS encounter_count
FROM encounters e
LEFT JOIN organizations o
    ON e.ORGANIZATION = o.Id
GROUP BY
    e.ORGANIZATION,
    o.NAME
ORDER BY encounter_count DESC;


-- ============================================================
-- 18. ENCOUNTER VOLUME BY PAYER
-- ============================================================

SELECT
    e.PAYER,
    p.NAME AS payer_name,
    COUNT(*) AS encounter_count
FROM encounters e
LEFT JOIN payers p
    ON e.PAYER = p.Id
GROUP BY
    e.PAYER,
    p.NAME
ORDER BY encounter_count DESC;


-- ============================================================
-- 19. CLAIM COST DISTRIBUTION
-- ============================================================

SELECT
    CASE
        WHEN TOTAL_CLAIM_COST < 500 THEN '< $500'
        WHEN TOTAL_CLAIM_COST < 1000 THEN '$500 - $999'
        WHEN TOTAL_CLAIM_COST < 5000 THEN '$1,000 - $4,999'
        WHEN TOTAL_CLAIM_COST < 10000 THEN '$5,000 - $9,999'
        ELSE '$10,000+'
    END AS cost_band,

    COUNT(*) AS encounter_count,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS percentage

FROM encounters
GROUP BY cost_band
ORDER BY
    CASE cost_band
        WHEN '< $500' THEN 1
        WHEN '$500 - $999' THEN 2
        WHEN '$1,000 - $4,999' THEN 3
        WHEN '$5,000 - $9,999' THEN 4
        WHEN '$10,000+' THEN 5
    END;


-- ============================================================
-- 20. OVERALL ENCOUNTER SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS total_encounters,

    COUNT(DISTINCT PATIENT) AS unique_patients,

    COUNT(DISTINCT PAYER) AS unique_payers,

    COUNT(DISTINCT ENCOUNTERCLASS) AS encounter_classes,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost,

    ROUND(
        SUM(PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        AVG(PAYER_COVERAGE),
        2
    ) AS average_payer_coverage

FROM encounters;