-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 12 - ADVANCED ANALYSIS
-- ============================================================


-- ============================================================
-- 1. PATIENT UTILIZATION SEGMENTATION
-- ============================================================

WITH patient_stats AS (
    SELECT
        PATIENT,
        COUNT(*) AS encounter_count,
        SUM(TOTAL_CLAIM_COST) AS total_cost,
        COUNT(DISTINCT ENCOUNTERCLASS) AS encounter_types
    FROM encounters
    GROUP BY PATIENT
)

SELECT
    CASE
        WHEN encounter_count = 1 THEN 'Low Utilization'
        WHEN encounter_count BETWEEN 2 AND 4 THEN 'Moderate Utilization'
        WHEN encounter_count BETWEEN 5 AND 9 THEN 'High Utilization'
        ELSE 'Very High Utilization'
    END AS utilization_segment,

    COUNT(*) AS patient_count,

    ROUND(AVG(encounter_count), 2)
        AS avg_encounters,

    ROUND(AVG(total_cost), 2)
        AS avg_patient_cost,

    ROUND(SUM(total_cost), 2)
        AS total_segment_cost

FROM patient_stats

GROUP BY utilization_segment

ORDER BY
    CASE utilization_segment
        WHEN 'Low Utilization' THEN 1
        WHEN 'Moderate Utilization' THEN 2
        WHEN 'High Utilization' THEN 3
        WHEN 'Very High Utilization' THEN 4
    END;


-- ============================================================
-- 2. TOP 20 HIGH-COST PATIENTS
-- ============================================================

SELECT
    PATIENT AS patient_id,

    COUNT(*) AS encounter_count,

    COUNT(DISTINCT ENCOUNTERCLASS)
        AS encounter_types,

    ROUND(SUM(TOTAL_CLAIM_COST), 2)
        AS total_claim_cost,

    ROUND(AVG(TOTAL_CLAIM_COST), 2)
        AS average_claim_cost,

    ROUND(SUM(PAYER_COVERAGE), 2)
        AS total_payer_coverage

FROM encounters

GROUP BY PATIENT

ORDER BY total_claim_cost DESC

LIMIT 20;


-- ============================================================
-- 3. COST PERCENTILE / RANKING
-- ============================================================

WITH patient_costs AS (
    SELECT
        PATIENT,
        SUM(TOTAL_CLAIM_COST) AS total_cost
    FROM encounters
    GROUP BY PATIENT
)

SELECT
    PATIENT AS patient_id,

    ROUND(total_cost, 2)
        AS total_cost,

    RANK() OVER (
        ORDER BY total_cost DESC
    ) AS cost_rank,

    ROUND(
        100.0 *
        PERCENT_RANK() OVER (
            ORDER BY total_cost
        ),
        2
    ) AS cost_percentile

FROM patient_costs

ORDER BY total_cost DESC

LIMIT 20;


-- ============================================================
-- 4. PARETO ANALYSIS OF PATIENT COST
-- ============================================================

WITH patient_costs AS (
    SELECT
        PATIENT,
        SUM(TOTAL_CLAIM_COST) AS total_cost
    FROM encounters
    GROUP BY PATIENT
),

ranked AS (
    SELECT
        PATIENT,
        total_cost,

        SUM(total_cost) OVER (
            ORDER BY total_cost DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_cost,

        SUM(total_cost) OVER ()
            AS overall_cost

    FROM patient_costs
)

SELECT
    PATIENT AS patient_id,

    ROUND(total_cost, 2)
        AS total_cost,

    ROUND(
        100.0 * cumulative_cost / overall_cost,
        2
    ) AS cumulative_cost_percentage

FROM ranked

ORDER BY total_cost DESC

LIMIT 50;


-- ============================================================
-- 5. TOP 20% PATIENT COST CONTRIBUTION
-- ============================================================

WITH patient_costs AS (
    SELECT
        PATIENT,
        SUM(TOTAL_CLAIM_COST) AS total_cost
    FROM encounters
    GROUP BY PATIENT
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY total_cost DESC
        ) AS patient_rank,

        COUNT(*) OVER ()
            AS total_patients,

        SUM(total_cost) OVER ()
            AS overall_cost

    FROM patient_costs
)

SELECT

    COUNT(
        CASE
            WHEN patient_rank <= total_patients * 0.20
            THEN 1
        END
    ) AS top_20_percent_patients,

    ROUND(
        SUM(
            CASE
                WHEN patient_rank <= total_patients * 0.20
                THEN total_cost
                ELSE 0
            END
        ),
        2
    ) AS top_20_percent_cost,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN patient_rank <= total_patients * 0.20
                THEN total_cost
                ELSE 0
            END
        ) / overall_cost,
        2
    ) AS cost_contribution_percentage

FROM ranked;


-- ============================================================
-- 6. ENCOUNTER COST OUTLIERS
-- ============================================================

WITH cost_stats AS (
    SELECT
        AVG(TOTAL_CLAIM_COST) AS avg_cost,
        AVG(TOTAL_CLAIM_COST * TOTAL_CLAIM_COST)
            AS avg_squared_cost
    FROM encounters
),

stats AS (
    SELECT
        avg_cost,
        SQRT(
            avg_squared_cost -
            (avg_cost * avg_cost)
        ) AS stddev_cost
    FROM cost_stats
)

SELECT
    e.Id AS encounter_id,
    e.PATIENT AS patient_id,
    e.ENCOUNTERCLASS,
    ROUND(e.TOTAL_CLAIM_COST, 2) AS total_claim_cost,

    ROUND(
        (e.TOTAL_CLAIM_COST - s.avg_cost)
        / NULLIF(s.stddev_cost, 0),
        2
    ) AS cost_z_score

FROM encounters e

CROSS JOIN stats s

WHERE e.TOTAL_CLAIM_COST >
      s.avg_cost + (2 * s.stddev_cost)

ORDER BY e.TOTAL_CLAIM_COST DESC

LIMIT 20;


-- ============================================================
-- 7. LENGTH-OF-STAY OUTLIERS
-- ============================================================

WITH encounter_duration AS (
    SELECT
        Id,
        PATIENT,
        ENCOUNTERCLASS,
        START,
        STOP,

        (julianday(STOP) -
         julianday(START)) * 24
         AS duration_hours

    FROM encounters
),

duration_stats AS (
    SELECT
        AVG(duration_hours) AS avg_duration,

        AVG(
            duration_hours * duration_hours
        ) AS avg_squared_duration

    FROM encounter_duration
),

stats AS (
    SELECT
        avg_duration,

        SQRT(
            avg_squared_duration -
            (avg_duration * avg_duration)
        ) AS stddev_duration

    FROM duration_stats
)

SELECT
    e.Id AS encounter_id,
    e.PATIENT AS patient_id,
    e.ENCOUNTERCLASS,

    ROUND(
        e.duration_hours,
        2
    ) AS duration_hours,

    ROUND(
        (
            e.duration_hours -
            s.avg_duration
        ) / NULLIF(s.stddev_duration, 0),
        2
    ) AS duration_z_score

FROM encounter_duration e

CROSS JOIN stats s

WHERE e.duration_hours >
      s.avg_duration +
      (2 * s.stddev_duration)

ORDER BY duration_hours DESC

LIMIT 20;


-- ============================================================
-- 8. YEAR-OVER-YEAR ENCOUNTER GROWTH
-- ============================================================

WITH yearly AS (
    SELECT
        SUBSTR(START, 1, 4) AS year,
        COUNT(*) AS encounter_count,
        SUM(TOTAL_CLAIM_COST) AS total_cost
    FROM encounters
    GROUP BY year
),

growth AS (
    SELECT
        year,
        encounter_count,
        total_cost,

        LAG(encounter_count) OVER (
            ORDER BY year
        ) AS previous_encounters,

        LAG(total_cost) OVER (
            ORDER BY year
        ) AS previous_cost

    FROM yearly
)

SELECT
    year,

    encounter_count,

    ROUND(total_cost, 2)
        AS total_cost,

    previous_encounters,

    ROUND(
        100.0 *
        (encounter_count - previous_encounters)
        / NULLIF(previous_encounters, 0),
        2
    ) AS encounter_growth_percentage,

    ROUND(
        100.0 *
        (total_cost - previous_cost)
        / NULLIF(previous_cost, 0),
        2
    ) AS cost_growth_percentage

FROM growth

ORDER BY year;


-- ============================================================
-- 9. MONTH-OVER-MONTH ENCOUNTER GROWTH
-- ============================================================

WITH monthly AS (
    SELECT
        SUBSTR(START, 1, 7) AS month,
        COUNT(*) AS encounter_count,
        SUM(TOTAL_CLAIM_COST) AS total_cost
    FROM encounters
    GROUP BY month
),

growth AS (
    SELECT
        month,
        encounter_count,
        total_cost,

        LAG(encounter_count) OVER (
            ORDER BY month
        ) AS previous_encounters,

        LAG(total_cost) OVER (
            ORDER BY month
        ) AS previous_cost

    FROM monthly
)

SELECT
    month,

    encounter_count,

    ROUND(total_cost, 2)
        AS total_cost,

    ROUND(
        100.0 *
        (encounter_count - previous_encounters)
        / NULLIF(previous_encounters, 0),
        2
    ) AS encounter_growth_percentage,

    ROUND(
        100.0 *
        (total_cost - previous_cost)
        / NULLIF(previous_cost, 0),
        2
    ) AS cost_growth_percentage

FROM growth

ORDER BY month;


-- ============================================================
-- 10. MOVING AVERAGE OF MONTHLY ENCOUNTERS
-- ============================================================

WITH monthly AS (
    SELECT
        SUBSTR(START, 1, 7) AS month,
        COUNT(*) AS encounter_count
    FROM encounters
    GROUP BY month
)

SELECT
    month,
    encounter_count,

    ROUND(
        AVG(encounter_count) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average

FROM monthly

ORDER BY month;


-- ============================================================
-- 11. PAYER COVERAGE PERFORMANCE
-- ============================================================

SELECT
    py.NAME AS payer_name,

    COUNT(e.Id)
        AS encounter_count,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    ROUND(
        SUM(e.PAYER_COVERAGE),
        2
    ) AS total_payer_coverage,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST)
        - SUM(e.PAYER_COVERAGE),
        2
    ) AS estimated_patient_responsibility,

    ROUND(
        100.0 *
        SUM(e.PAYER_COVERAGE)
        / NULLIF(
            SUM(e.TOTAL_CLAIM_COST),
            0
        ),
        2
    ) AS coverage_rate

FROM encounters e

JOIN payers py
    ON e.PAYER = py.Id

GROUP BY py.NAME

ORDER BY coverage_rate DESC;


-- ============================================================
-- 12. DIAGNOSIS COST EFFICIENCY
-- ============================================================

SELECT
    REASONCODE AS diagnosis_code,

    REASONDESCRIPTION AS diagnosis,

    COUNT(*) AS encounter_count,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_cost,

    ROUND(
        AVG(TOTAL_CLAIM_COST),
        2
    ) AS average_cost,

    ROUND(
        SUM(TOTAL_CLAIM_COST)
        / COUNT(DISTINCT PATIENT),
        2
    ) AS cost_per_patient

FROM encounters

WHERE REASONCODE IS NOT NULL

GROUP BY
    REASONCODE,
    REASONDESCRIPTION

HAVING COUNT(DISTINCT PATIENT) >= 5

ORDER BY cost_per_patient DESC

LIMIT 20;


-- ============================================================
-- 13. PROCEDURE COST EFFICIENCY
-- ============================================================

SELECT
    CODE AS procedure_code,

    DESCRIPTION AS procedure_description,

    COUNT(*) AS procedure_count,

    COUNT(DISTINCT PATIENT)
        AS unique_patients,

    ROUND(
        SUM(BASE_COST),
        2
    ) AS total_procedure_cost,

    ROUND(
        AVG(BASE_COST),
        2
    ) AS average_procedure_cost,

    ROUND(
        SUM(BASE_COST)
        / COUNT(DISTINCT PATIENT),
        2
    ) AS cost_per_patient

FROM procedures

GROUP BY
    CODE,
    DESCRIPTION

HAVING COUNT(DISTINCT PATIENT) >= 5

ORDER BY cost_per_patient DESC

LIMIT 20;


-- ============================================================
-- 14. PATIENT RISK / UTILIZATION PROFILE
-- ============================================================

SELECT
    p.Id AS patient_id,

    p.GENDER,
    p.RACE,
    p.ETHNICITY,

    COUNT(e.Id)
        AS encounter_count,

    COUNT(DISTINCT e.REASONCODE)
        AS diagnosis_count,

    COUNT(DISTINCT e.ENCOUNTERCLASS)
        AS encounter_type_count,

    ROUND(
        SUM(e.TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost,

    CASE

        WHEN COUNT(e.Id) >= 10
             AND SUM(e.TOTAL_CLAIM_COST) >= 50000
            THEN 'Very High Utilization / Cost'

        WHEN COUNT(e.Id) >= 10
            THEN 'High Utilization'

        WHEN SUM(e.TOTAL_CLAIM_COST) >= 50000
            THEN 'High Cost'

        WHEN COUNT(e.Id) >= 5
            THEN 'Moderate Utilization'

        ELSE 'Lower Utilization'

    END AS patient_profile

FROM patients p

JOIN encounters e
    ON p.Id = e.PATIENT

GROUP BY
    p.Id,
    p.GENDER,
    p.RACE,
    p.ETHNICITY

ORDER BY total_claim_cost DESC

LIMIT 50;


-- ============================================================
-- 15. PATIENT JOURNEY TRANSITIONS
-- ============================================================

WITH ordered AS (
    SELECT
        PATIENT,

        ENCOUNTERCLASS,

        START,

        LAG(ENCOUNTERCLASS) OVER (
            PARTITION BY PATIENT
            ORDER BY START
        ) AS previous_encounter_class

    FROM encounters
)

SELECT

    previous_encounter_class,

    ENCOUNTERCLASS AS current_encounter_class,

    COUNT(*) AS transition_count

FROM ordered

WHERE previous_encounter_class IS NOT NULL

GROUP BY
    previous_encounter_class,
    ENCOUNTERCLASS

ORDER BY transition_count DESC;


-- ============================================================
-- 16. READMISSION-LIKE RETURN WITHIN 30 DAYS
-- ============================================================

WITH ordered AS (
    SELECT
        PATIENT,
        START,
        ENCOUNTERCLASS,

        LAG(START) OVER (
            PARTITION BY PATIENT
            ORDER BY START
        ) AS previous_start

    FROM encounters
)

SELECT

    COUNT(*) AS qualifying_return_encounters,

    COUNT(DISTINCT PATIENT)
        AS patients_with_return,

    ROUND(
        100.0 *
        COUNT(*) /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS percentage_of_all_encounters

FROM ordered

WHERE previous_start IS NOT NULL

AND (
    julianday(START) -
    julianday(previous_start)
) <= 30

AND (
    julianday(START) -
    julianday(previous_start)
) >= 0;


-- ============================================================
-- 17. TOP DIAGNOSIS-PROCEDURE COMBINATIONS
-- ============================================================

SELECT
    e.REASONCODE AS diagnosis_code,

    e.REASONDESCRIPTION AS diagnosis,

    pr.CODE AS procedure_code,

    pr.DESCRIPTION AS procedure,

    COUNT(*) AS occurrence_count,

    ROUND(
        SUM(pr.BASE_COST),
        2
    ) AS total_procedure_cost

FROM encounters e

JOIN procedures pr
    ON e.Id = pr.ENCOUNTER

WHERE e.REASONCODE IS NOT NULL

GROUP BY
    e.REASONCODE,
    e.REASONDESCRIPTION,
    pr.CODE,
    pr.DESCRIPTION

ORDER BY occurrence_count DESC

LIMIT 30;


-- ============================================================
-- 18. COST VS UTILIZATION SUMMARY
-- ============================================================

WITH patient_stats AS (
    SELECT
        PATIENT,

        COUNT(*) AS encounter_count,

        SUM(TOTAL_CLAIM_COST) AS total_cost

    FROM encounters

    GROUP BY PATIENT
)

SELECT

    CASE
        WHEN encounter_count >= 10
            THEN '10+ Encounters'

        WHEN encounter_count >= 5
            THEN '5-9 Encounters'

        WHEN encounter_count >= 2
            THEN '2-4 Encounters'

        ELSE '1 Encounter'
    END AS utilization_group,

    COUNT(*) AS patient_count,

    ROUND(
        AVG(total_cost),
        2
    ) AS average_cost,

    ROUND(
        SUM(total_cost),
        2
    ) AS total_cost

FROM patient_stats

GROUP BY utilization_group

ORDER BY
    CASE utilization_group
        WHEN '1 Encounter' THEN 1
        WHEN '2-4 Encounters' THEN 2
        WHEN '5-9 Encounters' THEN 3
        WHEN '10+ Encounters' THEN 4
    END;


-- ============================================================
-- 19. DATA-DRIVEN EXECUTIVE KPI SUMMARY
-- ============================================================

SELECT

    COUNT(DISTINCT PATIENT)
        AS total_patients,

    COUNT(*)
        AS total_encounters,

    COUNT(DISTINCT REASONCODE)
        AS distinct_diagnoses,

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
        100.0 *
        SUM(PAYER_COVERAGE)
        / NULLIF(
            SUM(TOTAL_CLAIM_COST),
            0
        ),
        2
    ) AS overall_coverage_rate,

    ROUND(
        AVG(
            (julianday(STOP) -
             julianday(START)) * 24
        ),
        2
    ) AS average_encounter_duration_hours

FROM encounters;


-- ============================================================
-- 20. FINAL PROJECT KPI SUMMARY
-- ============================================================

SELECT
    'Patients' AS metric,
    CAST(
        COUNT(DISTINCT PATIENT)
        AS TEXT
    ) AS value
FROM encounters

UNION ALL

SELECT
    'Encounters',
    CAST(COUNT(*) AS TEXT)
FROM encounters

UNION ALL

SELECT
    'Procedures',
    CAST(
        (SELECT COUNT(*) FROM procedures)
        AS TEXT
    )
FROM encounters

UNION ALL

SELECT
    'Distinct Diagnoses',
    CAST(
        COUNT(DISTINCT REASONCODE)
        AS TEXT
    )
FROM encounters

UNION ALL

SELECT
    'Total Claim Cost',
    printf(
        '%.2f',
        SUM(TOTAL_CLAIM_COST)
    )
FROM encounters

UNION ALL

SELECT
    'Payer Coverage',
    printf(
        '%.2f',
        SUM(PAYER_COVERAGE)
    )
FROM encounters

UNION ALL

SELECT
    'Average Claim Cost',
    printf(
        '%.2f',
        AVG(TOTAL_CLAIM_COST)
    )
FROM encounters;