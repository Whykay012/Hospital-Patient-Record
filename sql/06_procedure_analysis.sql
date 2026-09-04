-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 06 - PROCEDURE ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL PROCEDURE SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_procedures,

    COUNT(DISTINCT PATIENT)
        AS patients_with_procedures,

    COUNT(DISTINCT ENCOUNTER)
        AS encounters_with_procedures,

    COUNT(DISTINCT CODE)
        AS distinct_procedure_types,

    ROUND(SUM(BASE_COST), 2)
        AS total_procedure_cost,

    ROUND(AVG(BASE_COST), 2)
        AS average_procedure_cost,

    ROUND(MIN(BASE_COST), 2)
        AS minimum_procedure_cost,

    ROUND(MAX(BASE_COST), 2)
        AS maximum_procedure_cost

FROM procedures;


-- ============================================================
-- 2. TOP 20 PROCEDURES BY FREQUENCY
-- ============================================================

SELECT
    CODE AS procedure_code,

    DESCRIPTION AS procedure_description,

    COUNT(*) AS procedure_count,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    COUNT(DISTINCT ENCOUNTER)
        AS unique_encounters

FROM procedures

GROUP BY
    CODE,
    DESCRIPTION

ORDER BY procedure_count DESC

LIMIT 20;


-- ============================================================
-- 3. TOP 20 PROCEDURES BY TOTAL COST
-- ============================================================

SELECT
    CODE AS procedure_code,

    DESCRIPTION AS procedure_description,

    COUNT(*) AS procedure_count,

    ROUND(
        SUM(BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_procedure_cost

FROM procedures

GROUP BY
    CODE,
    DESCRIPTION

ORDER BY total_procedure_cost DESC

LIMIT 20;


-- ============================================================
-- 4. TOP 20 PROCEDURES BY AVERAGE COST
-- ============================================================

SELECT
    CODE AS procedure_code,

    DESCRIPTION AS procedure_description,

    COUNT(*) AS procedure_count,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_procedure_cost,

    ROUND(
        SUM(BASE_COST),
        2
    ) AS total_procedure_cost

FROM procedures

GROUP BY
    CODE,
    DESCRIPTION

HAVING COUNT(*) >= 5

ORDER BY average_procedure_cost DESC

LIMIT 20;


-- ============================================================
-- 5. PROCEDURE COST BANDS
-- ============================================================

SELECT

    CASE
        WHEN BASE_COST < 500
            THEN '< $500'

        WHEN BASE_COST < 1000
            THEN '$500 - $999'

        WHEN BASE_COST < 5000
            THEN '$1,000 - $4,999'

        WHEN BASE_COST < 10000
            THEN '$5,000 - $9,999'

        WHEN BASE_COST < 25000
            THEN '$10,000 - $24,999'

        ELSE '$25,000+'
    END AS cost_band,

    COUNT(*) AS procedure_count,

    ROUND(
        SUM(BASE_COST),
        2
    ) AS total_cost,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_cost,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM procedures),
        2
    ) AS percentage_of_procedures

FROM procedures

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
-- 6. PROCEDURES PER PATIENT
-- ============================================================

SELECT
    p.Id AS patient_id,

    COUNT(pr.CODE) AS procedure_count,

    COUNT(DISTINCT pr.CODE)
        AS distinct_procedure_types,

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

GROUP BY p.Id

ORDER BY procedure_count DESC

LIMIT 20;


-- ============================================================
-- 7. PROCEDURE UTILIZATION BY PATIENT
-- ============================================================

SELECT

    procedure_count,

    COUNT(*) AS patient_count,

    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(DISTINCT PATIENT)
            FROM procedures
        ),
        2
    ) AS percentage_of_procedure_patients

FROM (
    SELECT
        PATIENT,

        COUNT(*) AS procedure_count

    FROM procedures

    GROUP BY PATIENT
)

GROUP BY procedure_count

ORDER BY procedure_count;


-- ============================================================
-- 8. PATIENTS WITH NO PROCEDURES
-- ============================================================

SELECT

    COUNT(*) AS patients_without_procedures,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_without_procedures

FROM patients p

LEFT JOIN procedures pr
    ON p.Id = pr.PATIENT

WHERE pr.PATIENT IS NULL;


-- ============================================================
-- 9. PROCEDURES BY ENCOUNTER CLASS
-- ============================================================

SELECT

    e.ENCOUNTERCLASS,

    COUNT(pr.CODE) AS procedure_count,

    COUNT(DISTINCT pr.PATIENT)
        AS unique_patients,

    COUNT(DISTINCT pr.ENCOUNTER)
        AS encounters_with_procedures,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(pr.BASE_COST),
        2
    ) AS average_procedure_cost

FROM procedures pr

JOIN encounters e
    ON pr.ENCOUNTER = e.Id

GROUP BY e.ENCOUNTERCLASS

ORDER BY procedure_count DESC;


-- ============================================================
-- 10. PROCEDURE COST BY ENCOUNTER CLASS
-- ============================================================

SELECT

    e.ENCOUNTERCLASS,

    COUNT(pr.CODE) AS procedure_count,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(pr.BASE_COST),
        2
    ) AS average_procedure_cost,

    ROUND(
        MAX(pr.BASE_COST),
        2
    ) AS highest_procedure_cost

FROM procedures pr

JOIN encounters e
    ON pr.ENCOUNTER = e.Id

GROUP BY e.ENCOUNTERCLASS

ORDER BY total_procedure_cost DESC;


-- ============================================================
-- 11. PROCEDURES BY YEAR
-- ============================================================

SELECT

    SUBSTR(START, 1, 4) AS year,

    COUNT(*) AS procedure_count,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    COUNT(DISTINCT ENCOUNTER)
        AS unique_encounters,

    ROUND(
        SUM(BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_procedure_cost

FROM procedures

GROUP BY year

ORDER BY year;


-- ============================================================
-- 12. PROCEDURE TREND BY YEAR AND ENCOUNTER CLASS
-- ============================================================

SELECT

    SUBSTR(pr.START, 1, 4) AS year,

    e.ENCOUNTERCLASS,

    COUNT(pr.CODE) AS procedure_count,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost

FROM procedures pr

JOIN encounters e
    ON pr.ENCOUNTER = e.Id

GROUP BY
    year,
    e.ENCOUNTERCLASS

ORDER BY
    year,
    procedure_count DESC;


-- ============================================================
-- 13. TOP PROCEDURES BY UNIQUE PATIENTS
-- ============================================================

SELECT

    CODE AS procedure_code,

    DESCRIPTION AS procedure_description,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    COUNT(*) AS procedure_count,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_cost

FROM procedures

GROUP BY
    CODE,
    DESCRIPTION

ORDER BY unique_patients DESC

LIMIT 20;


-- ============================================================
-- 14. PROCEDURE REPEAT RATE
-- ============================================================

SELECT

    CODE AS procedure_code,

    DESCRIPTION AS procedure_description,

    COUNT(*) AS total_occurrences,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    ROUND(
        1.0 * COUNT(*) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS procedures_per_patient

FROM procedures

GROUP BY
    CODE,
    DESCRIPTION

HAVING COUNT(DISTINCT PATIENT) > 1

ORDER BY procedures_per_patient DESC

LIMIT 20;


-- ============================================================
-- 15. PROCEDURES WITH REPORTED REASONS
-- ============================================================

SELECT

    COUNT(*) AS procedures_with_reason,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM procedures),
        2
    ) AS percentage_with_reason

FROM procedures

WHERE REASONCODE IS NOT NULL;


-- ============================================================
-- 16. TOP PROCEDURE REASONS
-- ============================================================

SELECT

    REASONCODE AS reason_code,

    REASONDESCRIPTION AS reason_description,

    COUNT(*) AS procedure_count,

    COUNT(DISTINCT PATIENT)
        AS unique_patients

FROM procedures

WHERE REASONCODE IS NOT NULL

GROUP BY
    REASONCODE,
    REASONDESCRIPTION

ORDER BY procedure_count DESC

LIMIT 20;


-- ============================================================
-- 17. PROCEDURE COST BY REASON
-- ============================================================

SELECT

    REASONCODE AS reason_code,

    REASONDESCRIPTION AS reason_description,

    COUNT(*) AS procedure_count,

    ROUND(
        SUM(BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_procedure_cost

FROM procedures

WHERE REASONCODE IS NOT NULL

GROUP BY
    REASONCODE,
    REASONDESCRIPTION

ORDER BY total_procedure_cost DESC

LIMIT 20;


-- ============================================================
-- 18. TOP 20 PATIENTS BY PROCEDURE COST
-- ============================================================

SELECT

    p.Id AS patient_id,

    p.GENDER,

    p.RACE,

    p.ETHNICITY,

    COUNT(pr.CODE) AS procedure_count,

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
    p.Id,
    p.GENDER,
    p.RACE,
    p.ETHNICITY

ORDER BY total_procedure_cost DESC

LIMIT 20;


-- ============================================================
-- 19. PROCEDURE DIVERSITY PER PATIENT
-- ============================================================

SELECT

    p.Id AS patient_id,

    COUNT(pr.CODE)
        AS total_procedures,

    COUNT(DISTINCT pr.CODE)
        AS distinct_procedure_types

FROM patients p

JOIN procedures pr
    ON p.Id = pr.PATIENT

GROUP BY p.Id

ORDER BY distinct_procedure_types DESC

LIMIT 20;


-- ============================================================
-- 20. PROCEDURE SUMMARY FOR EXECUTIVE REPORTING
-- ============================================================

SELECT

    COUNT(*) AS total_procedures,

    COUNT(DISTINCT PATIENT)
        AS patients_with_procedures,

    COUNT(DISTINCT ENCOUNTER)
        AS encounters_with_procedures,

    COUNT(DISTINCT CODE)
        AS distinct_procedure_types,

    ROUND(
        SUM(BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_procedure_cost,

    ROUND(
        1.0 * COUNT(*) /
        COUNT(DISTINCT PATIENT),
        2
    ) AS procedures_per_patient

FROM procedures;