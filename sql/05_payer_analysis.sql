-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 05 - PAYER ANALYSIS
-- ============================================================


-- ============================================================
-- 1. PAYER OVERVIEW
-- ============================================================

SELECT
    COUNT(*) AS total_payers,

    COUNT(DISTINCT e.PAYER) AS payers_used_by_encounters,

    (SELECT COUNT(*) FROM encounters)
        AS total_encounters

FROM payers p

LEFT JOIN encounters e
    ON p.Id = e.PAYER;


-- ============================================================
-- 2. ENCOUNTERS BY PAYER
-- ============================================================

SELECT
    p.Id AS payer_id,

    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        100.0 * COUNT(e.Id) /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS encounter_percentage

FROM payers p

LEFT JOIN encounters e
    ON p.Id = e.PAYER

GROUP BY
    p.Id,
    p.NAME

ORDER BY encounter_count DESC;


-- ============================================================
-- 3. CLAIM COST BY PAYER
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(e.TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost,

    ROUND(
        MIN(e.TOTAL_CLAIM_COST),
        2
    ) AS minimum_claim_cost,

    ROUND(
        MAX(e.TOTAL_CLAIM_COST),
        2
    ) AS maximum_claim_cost

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY total_claim_cost DESC;


-- ============================================================
-- 4. PAYER COVERAGE BY PAYER
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        SUM(e.PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        100.0 *
        SUM(e.PAYER_COVERAGE) /
        NULLIF(
            SUM(e.TOTAL_CLAIM_COST),
            0
        ),
        2
    ) AS coverage_rate_percentage

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY coverage_rate_percentage DESC;


-- ============================================================
-- 5. ESTIMATED PATIENT RESPONSIBILITY BY PAYER
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        SUM(
            e.TOTAL_CLAIM_COST -
            e.PAYER_COVERAGE
        ),
        2
    ) AS estimated_patient_responsibility,

    ROUND(
        AVG(
            e.TOTAL_CLAIM_COST -
            e.PAYER_COVERAGE
        ),
        2
    ) AS average_patient_responsibility

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY estimated_patient_responsibility DESC;


-- ============================================================
-- 6. PATIENT RESPONSIBILITY RATE BY PAYER
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        100.0 *
        SUM(
            e.TOTAL_CLAIM_COST -
            e.PAYER_COVERAGE
        ) /
        NULLIF(
            SUM(e.TOTAL_CLAIM_COST),
            0
        ),
        2
    ) AS patient_responsibility_rate

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY patient_responsibility_rate DESC;


-- ============================================================
-- 7. PAYER MIX BY ENCOUNTER CLASS
-- ============================================================

SELECT
    p.NAME AS payer_name,

    e.ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY p.NAME
        ),
        2
    ) AS percentage_of_payer_encounters

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    p.NAME,
    e.ENCOUNTERCLASS

ORDER BY
    p.NAME,
    encounter_count DESC;


-- ============================================================
-- 8. ENCOUNTER CLASS BY PAYER
-- ============================================================

SELECT
    e.ENCOUNTERCLASS,

    p.NAME AS payer_name,

    COUNT(*) AS encounter_count,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY e.ENCOUNTERCLASS
        ),
        2
    ) AS percentage_of_encounter_class

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.ENCOUNTERCLASS,
    p.NAME

ORDER BY
    e.ENCOUNTERCLASS,
    encounter_count DESC;


-- ============================================================
-- 9. PAYER PERFORMANCE BY YEAR
-- ============================================================

SELECT
    SUBSTR(e.START, 1, 4) AS year,

    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        SUM(e.PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        100.0 *
        SUM(e.PAYER_COVERAGE) /
        NULLIF(
            SUM(e.TOTAL_CLAIM_COST),
            0
        ),
        2
    ) AS coverage_rate_percentage

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    year,
    p.NAME

ORDER BY
    year,
    total_claim_cost DESC;


-- ============================================================
-- 10. PAYER UTILIZATION BY YEAR
-- ============================================================

SELECT
    SUBSTR(e.START, 1, 4) AS year,

    p.NAME AS payer_name,

    COUNT(DISTINCT e.PATIENT) AS unique_patients,

    COUNT(e.Id) AS encounter_count

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    year,
    p.NAME

ORDER BY
    year,
    encounter_count DESC;


-- ============================================================
-- 11. AVERAGE CLAIM COST BY PAYER AND ENCOUNTER CLASS
-- ============================================================

SELECT
    p.NAME AS payer_name,

    e.ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(
        AVG(e.TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost,

    ROUND(
        AVG(e.PAYER_COVERAGE),
        2
    ) AS average_payer_coverage,

    ROUND(
        AVG(
            e.TOTAL_CLAIM_COST -
            e.PAYER_COVERAGE
        ),
        2
    ) AS average_patient_responsibility

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    p.NAME,
    e.ENCOUNTERCLASS

ORDER BY average_claim_cost DESC;


-- ============================================================
-- 12. HIGH-COST ENCOUNTERS BY PAYER
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(*) AS high_cost_encounters,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS high_cost_claim_value,

    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM encounters
            WHERE TOTAL_CLAIM_COST >= 10000
        ),
        2
    ) AS percentage_of_high_cost_encounters

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

WHERE e.TOTAL_CLAIM_COST >= 10000

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY high_cost_claim_value DESC;


-- ============================================================
-- 13. PAYER COST DISTRIBUTION
-- ============================================================

SELECT
    p.NAME AS payer_name,

    CASE
        WHEN e.TOTAL_CLAIM_COST < 500
            THEN '< $500'

        WHEN e.TOTAL_CLAIM_COST < 1000
            THEN '$500 - $999'

        WHEN e.TOTAL_CLAIM_COST < 5000
            THEN '$1,000 - $4,999'

        WHEN e.TOTAL_CLAIM_COST < 10000
            THEN '$5,000 - $9,999'

        WHEN e.TOTAL_CLAIM_COST < 25000
            THEN '$10,000 - $24,999'

        ELSE '$25,000+'
    END AS cost_band,

    COUNT(*) AS encounter_count

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    p.NAME,
    cost_band

ORDER BY
    p.NAME,
    encounter_count DESC;


-- ============================================================
-- 14. TOP PAYERS BY TOTAL COVERAGE
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        SUM(e.PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        AVG(e.PAYER_COVERAGE),
        2
    ) AS average_payer_coverage

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY total_payer_coverage DESC;


-- ============================================================
-- 15. PAYER SHARE OF TOTAL CLAIM COST
-- ============================================================

SELECT
    p.NAME AS payer_name,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        100.0 *
        SUM(e.TOTAL_CLAIM_COST) /
        (
            SELECT SUM(TOTAL_CLAIM_COST)
            FROM encounters
        ),
        2
    ) AS percentage_of_total_claim_cost

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY total_claim_cost DESC;


-- ============================================================
-- 16. PAYER SHARE OF TOTAL COVERAGE
-- ============================================================

SELECT
    p.NAME AS payer_name,

    ROUND(
        SUM(e.PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        100.0 *
        SUM(e.PAYER_COVERAGE) /
        (
            SELECT SUM(PAYER_COVERAGE)
            FROM encounters
        ),
        2
    ) AS percentage_of_total_coverage

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY total_payer_coverage DESC;


-- ============================================================
-- 17. PATIENTS PER PAYER
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    COUNT(e.Id)
        AS total_encounters,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_patient

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY unique_patients DESC;


-- ============================================================
-- 18. PAYER ENCOUNTER CONCENTRATION
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(*) AS encounter_count,

    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM encounters
        ),
        2
    ) AS encounter_share_percentage

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY encounter_count DESC;


-- ============================================================
-- 19. PAYER DATA COMPLETENESS
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(e.Id) AS total_encounters,

    SUM(
        CASE
            WHEN e.PAYER IS NULL
            THEN 1
            ELSE 0
        END
    ) AS missing_payer_reference,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN e.PAYER IS NULL
                THEN 1
                ELSE 0
            END
        ) /
        COUNT(e.Id),
        2
    ) AS missing_payer_percentage

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    p.NAME;


-- ============================================================
-- 20. EXECUTIVE PAYER SUMMARY
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    COUNT(DISTINCT e.PATIENT)
        AS unique_patients,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        SUM(e.PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST) -
        SUM(e.PAYER_COVERAGE),
        2
    ) AS estimated_patient_responsibility,

    ROUND(
        100.0 *
        SUM(e.PAYER_COVERAGE) /
        NULLIF(
            SUM(e.TOTAL_CLAIM_COST),
            0
        ),
        2
    ) AS coverage_rate_percentage,

    ROUND(
        AVG(e.TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY total_claim_cost DESC;