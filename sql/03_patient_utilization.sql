-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 03 - PATIENT UTILIZATION ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL PATIENT UTILIZATION SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_patients,

    COUNT(DISTINCT e.PATIENT) AS patients_with_encounters,

    COUNT(*) -
    COUNT(DISTINCT e.PATIENT) AS patients_without_encounters,

    ROUND(
        100.0 * COUNT(DISTINCT e.PATIENT) /
        COUNT(*),
        2
    ) AS percentage_with_encounters

FROM patients p
LEFT JOIN encounters e
    ON p.Id = e.PATIENT;


-- ============================================================
-- 2. ENCOUNTERS PER PATIENT
-- ============================================================

SELECT
    p.Id AS patient_id,

    COUNT(e.Id) AS encounter_count

FROM patients p

LEFT JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.Id

ORDER BY encounter_count DESC;


-- ============================================================
-- 3. AVERAGE ENCOUNTERS PER PATIENT
-- ============================================================

SELECT
    ROUND(
        AVG(encounter_count),
        2
    ) AS average_encounters_per_patient

FROM (
    SELECT
        p.Id,
        COUNT(e.Id) AS encounter_count

    FROM patients p

    LEFT JOIN encounters e
        ON p.Id = e.PATIENT

    GROUP BY p.Id
);


-- ============================================================
-- 4. PATIENT UTILIZATION BANDS
-- ============================================================

SELECT

    CASE
        WHEN encounter_count = 0
            THEN '0 encounters'

        WHEN encounter_count BETWEEN 1 AND 2
            THEN '1-2 encounters'

        WHEN encounter_count BETWEEN 3 AND 5
            THEN '3-5 encounters'

        WHEN encounter_count BETWEEN 6 AND 10
            THEN '6-10 encounters'

        WHEN encounter_count BETWEEN 11 AND 20
            THEN '11-20 encounters'

        ELSE '21+ encounters'
    END AS utilization_band,

    COUNT(*) AS patient_count,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage_of_patients

FROM (
    SELECT
        p.Id,
        COUNT(e.Id) AS encounter_count

    FROM patients p

    LEFT JOIN encounters e
        ON p.Id = e.PATIENT

    GROUP BY p.Id
)

GROUP BY utilization_band

ORDER BY
    CASE utilization_band
        WHEN '0 encounters' THEN 1
        WHEN '1-2 encounters' THEN 2
        WHEN '3-5 encounters' THEN 3
        WHEN '6-10 encounters' THEN 4
        WHEN '11-20 encounters' THEN 5
        WHEN '21+ encounters' THEN 6
    END;


-- ============================================================
-- 5. TOP 20 HIGHEST-UTILIZATION PATIENTS
-- ============================================================

SELECT

    p.Id AS patient_id,

    p.GENDER,

    p.RACE,

    p.ETHNICITY,

    p.MARITAL,

    COUNT(e.Id) AS encounter_count

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY
    p.Id,
    p.GENDER,
    p.RACE,
    p.ETHNICITY,
    p.MARITAL

ORDER BY encounter_count DESC

LIMIT 20;


-- ============================================================
-- 6. PATIENTS WITH 10 OR MORE ENCOUNTERS
-- ============================================================

SELECT

    p.Id AS patient_id,

    COUNT(e.Id) AS encounter_count

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.Id

HAVING COUNT(e.Id) >= 10

ORDER BY encounter_count DESC;


-- ============================================================
-- 7. PATIENT ENCOUNTER CLASS MIX
-- ============================================================

SELECT

    e.ENCOUNTERCLASS,

    COUNT(DISTINCT e.PATIENT) AS unique_patients,

    COUNT(e.Id) AS total_encounters,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_patient

FROM encounters e

GROUP BY e.ENCOUNTERCLASS

ORDER BY total_encounters DESC;


-- ============================================================
-- 8. PATIENTS BY NUMBER OF DISTINCT ENCOUNTER CLASSES
-- ============================================================

SELECT

    encounter_class_count,

    COUNT(*) AS patient_count

FROM (
    SELECT

        PATIENT,

        COUNT(DISTINCT ENCOUNTERCLASS)
            AS encounter_class_count

    FROM encounters

    GROUP BY PATIENT
)

GROUP BY encounter_class_count

ORDER BY encounter_class_count;


-- ============================================================
-- 9. PATIENTS USING MULTIPLE ENCOUNTER TYPES
-- ============================================================

SELECT

    COUNT(*) AS patients_with_multiple_encounter_types

FROM (
    SELECT

        PATIENT,

        COUNT(DISTINCT ENCOUNTERCLASS)
            AS encounter_class_count

    FROM encounters

    GROUP BY PATIENT

    HAVING COUNT(DISTINCT ENCOUNTERCLASS) > 1
);


-- ============================================================
-- 10. PATIENT UTILIZATION BY GENDER
-- ============================================================

SELECT

    p.GENDER,

    COUNT(DISTINCT p.Id) AS patient_count,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT p.Id),
        2
    ) AS encounters_per_patient

FROM patients p

LEFT JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.GENDER

ORDER BY encounter_count DESC;


-- ============================================================
-- 11. PATIENT UTILIZATION BY RACE
-- ============================================================

SELECT

    p.RACE,

    COUNT(DISTINCT p.Id) AS patient_count,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT p.Id),
        2
    ) AS encounters_per_patient

FROM patients p

LEFT JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.RACE

ORDER BY encounter_count DESC;


-- ============================================================
-- 12. PATIENT UTILIZATION BY ETHNICITY
-- ============================================================

SELECT

    p.ETHNICITY,

    COUNT(DISTINCT p.Id) AS patient_count,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT p.Id),
        2
    ) AS encounters_per_patient

FROM patients p

LEFT JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.ETHNICITY

ORDER BY encounter_count DESC;


-- ============================================================
-- 13. PATIENT UTILIZATION BY MARITAL STATUS
-- ============================================================

SELECT

    p.MARITAL,

    COUNT(DISTINCT p.Id) AS patient_count,

    COUNT(e.Id) AS encounter_count,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT p.Id),
        2
    ) AS encounters_per_patient

FROM patients p

LEFT JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY p.MARITAL

ORDER BY encounter_count DESC;


-- ============================================================
-- 14. PATIENT COST UTILIZATION
-- ============================================================

SELECT

    p.Id AS patient_id,

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

GROUP BY p.Id

ORDER BY total_claim_cost DESC;


-- ============================================================
-- 15. TOP 20 PATIENTS BY TOTAL CLAIM COST
-- ============================================================

SELECT

    p.Id AS patient_id,

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

GROUP BY p.Id

ORDER BY total_claim_cost DESC

LIMIT 20;


-- ============================================================
-- 16. HIGH-UTILIZATION PATIENTS AND COST
-- ============================================================

SELECT

    p.Id AS patient_id,

    COUNT(e.Id) AS encounter_count,

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

GROUP BY p.Id

HAVING COUNT(e.Id) >= 10

ORDER BY total_claim_cost DESC;


-- ============================================================
-- 17. PATIENTS WITH THE MOST PROCEDURES
-- ============================================================

SELECT

    p.Id AS patient_id,

    COUNT(pr.CODE) AS procedure_count,

    COUNT(DISTINCT pr.CODE) AS distinct_procedure_types

FROM patients p

JOIN procedures pr
    ON p.Id = pr.PATIENT

GROUP BY p.Id

ORDER BY procedure_count DESC

LIMIT 20;


-- ============================================================
-- 18. PROCEDURES PER PATIENT
-- ============================================================

SELECT

    ROUND(
        AVG(procedure_count),
        2
    ) AS average_procedures_per_patient

FROM (
    SELECT

        p.Id,

        COUNT(pr.CODE) AS procedure_count

    FROM patients p

    LEFT JOIN procedures pr
        ON p.Id = pr.PATIENT

    GROUP BY p.Id
);


-- ============================================================
-- 19. PATIENTS WITH NO PROCEDURES
-- ============================================================

SELECT

    COUNT(*) AS patients_without_procedures

FROM patients p

LEFT JOIN procedures pr
    ON p.Id = pr.PATIENT

WHERE pr.PATIENT IS NULL;


-- ============================================================
-- 20. PATIENT UTILIZATION SUMMARY
-- ============================================================

SELECT

    COUNT(DISTINCT e.PATIENT)
        AS patients_with_encounters,

    COUNT(e.Id)
        AS total_encounters,

    ROUND(
        1.0 * COUNT(e.Id) /
        COUNT(DISTINCT e.PATIENT),
        2
    ) AS encounters_per_active_patient,

    COUNT(DISTINCT pr.PATIENT)
        AS patients_with_procedures,

    COUNT(pr.CODE)
        AS total_procedures,

    ROUND(
        1.0 * COUNT(pr.CODE) /
        COUNT(DISTINCT pr.PATIENT),
        2
    ) AS procedures_per_procedural_patient

FROM encounters e

LEFT JOIN procedures pr
    ON e.Id = pr.ENCOUNTER;