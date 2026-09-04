-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 04 - COST ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL COST SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_encounters,

    ROUND(SUM(BASE_ENCOUNTER_COST), 2)
        AS total_base_encounter_cost,

    ROUND(SUM(TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(SUM(PAYER_COVERAGE), 2)
        AS total_payer_coverage,

    ROUND(
        SUM(TOTAL_CLAIM_COST) -
        SUM(PAYER_COVERAGE),
        2
    ) AS total_estimated_patient_responsibility,

    ROUND(AVG(BASE_ENCOUNTER_COST), 2)
        AS average_base_cost,

    ROUND(AVG(TOTAL_CLAIM_COST), 2)
        AS average_claim_cost,

    ROUND(AVG(PAYER_COVERAGE), 2)
        AS average_payer_coverage

FROM encounters;


-- ============================================================
-- 2. COST BY ENCOUNTER CLASS
-- ============================================================

SELECT
    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(SUM(BASE_ENCOUNTER_COST), 2)
        AS total_base_cost,

    ROUND(SUM(TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(SUM(PAYER_COVERAGE), 2)
        AS total_payer_coverage,

    ROUND(
        SUM(TOTAL_CLAIM_COST) -
        SUM(PAYER_COVERAGE),
        2
    ) AS estimated_patient_responsibility,

    ROUND(AVG(TOTAL_CLAIM_COST), 2)
        AS average_claim_cost

FROM encounters

GROUP BY ENCOUNTERCLASS

ORDER BY total_claim_cost DESC;


-- ============================================================
-- 3. COST BY YEAR
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,

    COUNT(*) AS encounter_count,

    ROUND(SUM(TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(SUM(PAYER_COVERAGE), 2)
        AS total_payer_coverage,

    ROUND(
        SUM(TOTAL_CLAIM_COST) -
        SUM(PAYER_COVERAGE),
        2
    ) AS estimated_patient_responsibility,

    ROUND(AVG(TOTAL_CLAIM_COST), 2)
        AS average_claim_cost

FROM encounters

GROUP BY year

ORDER BY year;


-- ============================================================
-- 4. COST BY YEAR AND ENCOUNTER CLASS
-- ============================================================

SELECT
    SUBSTR(START, 1, 4) AS year,

    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(SUM(TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(AVG(TOTAL_CLAIM_COST), 2)
        AS average_claim_cost

FROM encounters

GROUP BY
    year,
    ENCOUNTERCLASS

ORDER BY
    year,
    total_claim_cost DESC;


-- ============================================================
-- 5. COST BY PAYER
-- ============================================================

SELECT
    e.PAYER,

    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(SUM(e.TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(SUM(e.PAYER_COVERAGE), 2)
        AS total_payer_coverage,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST) -
        SUM(e.PAYER_COVERAGE),
        2
    ) AS estimated_patient_responsibility,

    ROUND(AVG(e.TOTAL_CLAIM_COST), 2)
        AS average_claim_cost

FROM encounters e

LEFT JOIN payers p
    ON e.PAYER = p.Id

GROUP BY
    e.PAYER,
    p.NAME

ORDER BY total_claim_cost DESC;


-- ============================================================
-- 6. PAYER COVERAGE RATE
-- ============================================================

SELECT
    p.NAME AS payer_name,

    COUNT(e.Id) AS encounter_count,

    ROUND(SUM(e.TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(SUM(e.PAYER_COVERAGE), 2)
        AS total_payer_coverage,

    ROUND(
        100.0 * SUM(e.PAYER_COVERAGE) /
        NULLIF(SUM(e.TOTAL_CLAIM_COST), 0),
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
-- 7. PATIENT RESPONSIBILITY BY ENCOUNTER
-- ============================================================

SELECT
    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(
        SUM(TOTAL_CLAIM_COST - PAYER_COVERAGE),
        2
    ) AS estimated_patient_responsibility,

    ROUND(
        AVG(TOTAL_CLAIM_COST - PAYER_COVERAGE),
        2
    ) AS average_patient_responsibility

FROM encounters

GROUP BY ENCOUNTERCLASS

ORDER BY estimated_patient_responsibility DESC;


-- ============================================================
-- 8. TOP 20 MOST EXPENSIVE ENCOUNTERS
-- ============================================================

SELECT
    e.Id AS encounter_id,

    e.PATIENT AS patient_id,

    e.ENCOUNTERCLASS,

    e.DESCRIPTION,

    ROUND(e.BASE_ENCOUNTER_COST, 2)
        AS base_encounter_cost,

    ROUND(e.TOTAL_CLAIM_COST, 2)
        AS total_claim_cost,

    ROUND(e.PAYER_COVERAGE, 2)
        AS payer_coverage,

    ROUND(
        e.TOTAL_CLAIM_COST -
        e.PAYER_COVERAGE,
        2
    ) AS patient_responsibility

FROM encounters e

ORDER BY e.TOTAL_CLAIM_COST DESC

LIMIT 20;


-- ============================================================
-- 9. COST BANDS
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

    COUNT(*) AS encounter_count,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS percentage_of_encounters

FROM encounters

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
-- 10. MONTHLY COST TREND
-- ============================================================

SELECT
    SUBSTR(START, 1, 7) AS month,

    COUNT(*) AS encounter_count,

    ROUND(SUM(TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(AVG(TOTAL_CLAIM_COST), 2)
        AS average_claim_cost

FROM encounters

GROUP BY month

ORDER BY month;


-- ============================================================
-- 11. TOP 20 PATIENTS BY TOTAL HEALTHCARE COST
-- ============================================================

SELECT
    p.Id AS patient_id,

    p.GENDER,

    p.RACE,

    p.ETHNICITY,

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
        SUM(e.TOTAL_CLAIM_COST) -
        SUM(e.PAYER_COVERAGE),
        2
    ) AS estimated_patient_responsibility

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY
    p.Id,
    p.GENDER,
    p.RACE,
    p.ETHNICITY

ORDER BY total_claim_cost DESC

LIMIT 20;


-- ============================================================
-- 12. COST PER ACTIVE PATIENT
-- ============================================================

SELECT

    ROUND(
        SUM(TOTAL_CLAIM_COST) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS average_total_claim_cost_per_active_patient,

    ROUND(
        SUM(PAYER_COVERAGE) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS average_payer_coverage_per_active_patient,

    ROUND(
        (
            SUM(TOTAL_CLAIM_COST) -
            SUM(PAYER_COVERAGE)
        ) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS average_patient_responsibility_per_active_patient

FROM encounters;


-- ============================================================
-- 13. BASE COST VS CLAIM COST
-- ============================================================

SELECT

    ENCOUNTERCLASS,

    ROUND(
        AVG(BASE_ENCOUNTER_COST),
        2
    ) AS average_base_cost,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost,

    ROUND(
        AVG(TOTAL_CLAIM_COST) -
        AVG(BASE_ENCOUNTER_COST),
        2
    ) AS average_claim_cost_difference

FROM encounters

GROUP BY ENCOUNTERCLASS

ORDER BY average_claim_cost_difference DESC;


-- ============================================================
-- 14. COST BY PROCEDURE
-- ============================================================

SELECT

    pr.CODE AS procedure_code,

    pr.DESCRIPTION AS procedure_description,

    COUNT(*) AS procedure_count,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(pr.BASE_COST),
        2
    ) AS average_procedure_cost

FROM procedures pr

GROUP BY
    pr.CODE,
    pr.DESCRIPTION

ORDER BY total_procedure_cost DESC

LIMIT 20;


-- ============================================================
-- 15. PROCEDURE COST SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS total_procedures,

    COUNT(DISTINCT PATIENT)
        AS patients_with_procedures,

    COUNT(DISTINCT CODE)
        AS distinct_procedure_types,

    ROUND(
        SUM(BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_procedure_cost

FROM procedures;


-- ============================================================
-- 16. COST CONCENTRATION
-- ============================================================

SELECT

    ROUND(
        SUM(
            CASE
                WHEN TOTAL_CLAIM_COST >= 10000
                THEN TOTAL_CLAIM_COST
                ELSE 0
            END
        ),
        2
    ) AS cost_from_high_cost_encounters,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN TOTAL_CLAIM_COST >= 10000
                THEN TOTAL_CLAIM_COST
                ELSE 0
            END
        ) /
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS percentage_of_total_claim_cost

FROM encounters;


-- ============================================================
-- 17. HIGH-COST ENCOUNTER RATE
-- ============================================================

SELECT

    COUNT(*) AS high_cost_encounters,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS percentage_of_encounters

FROM encounters

WHERE TOTAL_CLAIM_COST >= 10000;


-- ============================================================
-- 18. PATIENT RESPONSIBILITY RATE BY PAYER
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
-- 19. TOP 20 ENCOUNTER TYPES BY TOTAL COST
-- ============================================================

SELECT

    DESCRIPTION,

    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost

FROM encounters

GROUP BY
    DESCRIPTION,
    ENCOUNTERCLASS

ORDER BY total_claim_cost DESC

LIMIT 20;


-- ============================================================
-- 20. EXECUTIVE COST SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS total_encounters,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

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
    ) AS estimated_patient_responsibility,

    ROUND(
        100.0 *
        SUM(PAYER_COVERAGE) /
        NULLIF(
            SUM(TOTAL_CLAIM_COST),
            0
        ),
        2
    ) AS overall_coverage_rate,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_claim_cost,

    ROUND(
        MAX(TOTAL_CLAIM_COST),
        2
    ) AS highest_claim_cost

FROM encounters;