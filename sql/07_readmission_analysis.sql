-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 07 - READMISSION ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL READMISSION SUMMARY
-- ============================================================

WITH encounter_dates AS (
    SELECT
        Id AS encounter_id,
        PATIENT AS patient_id,
        datetime(START) AS start_datetime,
        datetime(STOP) AS stop_datetime
    FROM encounters
),

next_encounter AS (
    SELECT
        e1.patient_id,
        e1.encounter_id,
        e1.start_datetime,
        e1.stop_datetime,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN encounter_dates e2
        ON e1.patient_id = e2.patient_id
        AND e2.start_datetime > e1.stop_datetime

    GROUP BY
        e1.patient_id,
        e1.encounter_id,
        e1.start_datetime,
        e1.stop_datetime
)

SELECT

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS encounters_followed_by_another_encounter,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NULL
            THEN 1
            ELSE 0
        END
    ) AS encounters_without_follow_up,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS follow_up_percentage

FROM next_encounter;


-- ============================================================
-- 2. 30-DAY READMISSION RATE
-- ============================================================

WITH encounter_dates AS (
    SELECT
        Id AS encounter_id,
        PATIENT AS patient_id,
        datetime(START) AS start_datetime,
        datetime(STOP) AS stop_datetime
    FROM encounters
),

readmission_check AS (
    SELECT
        e1.encounter_id,
        e1.patient_id,
        e1.stop_datetime,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN encounter_dates e2
        ON e1.patient_id = e2.patient_id
        AND e2.start_datetime > e1.stop_datetime
        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.patient_id,
        e1.stop_datetime
)

SELECT

    COUNT(*) AS eligible_encounters,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmitted_within_30_days,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NULL
            THEN 1
            ELSE 0
        END
    ) AS not_readmitted_within_30_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_30_day

FROM readmission_check;


-- ============================================================
-- 3. 7-DAY READMISSION RATE
-- ============================================================

WITH encounter_dates AS (
    SELECT
        Id AS encounter_id,
        PATIENT AS patient_id,
        datetime(STOP) AS stop_datetime
    FROM encounters
),

readmission_check AS (
    SELECT
        e1.encounter_id,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            Id AS encounter_id,
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+7 days'
        )

    GROUP BY e1.encounter_id
)

SELECT

    COUNT(*) AS eligible_encounters,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmitted_within_7_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_7_day

FROM readmission_check;


-- ============================================================
-- 4. 90-DAY READMISSION RATE
-- ============================================================

WITH encounter_dates AS (
    SELECT
        Id AS encounter_id,
        PATIENT AS patient_id,
        datetime(STOP) AS stop_datetime
    FROM encounters
),

readmission_check AS (
    SELECT
        e1.encounter_id,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            Id AS encounter_id,
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+90 days'
        )

    GROUP BY e1.encounter_id
)

SELECT

    COUNT(*) AS eligible_encounters,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmitted_within_90_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_90_day

FROM readmission_check;


-- ============================================================
-- 5. READMISSION BY ENCOUNTER CLASS
-- ============================================================

WITH encounter_dates AS (
    SELECT
        Id AS encounter_id,
        PATIENT AS patient_id,
        ENCOUNTERCLASS,
        datetime(STOP) AS stop_datetime
    FROM encounters
),

readmission_check AS (
    SELECT
        e1.encounter_id,
        e1.ENCOUNTERCLASS,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            Id AS encounter_id,
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.ENCOUNTERCLASS
)

SELECT

    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmitted_within_30_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_30_day

FROM readmission_check

GROUP BY ENCOUNTERCLASS

ORDER BY readmission_rate_30_day DESC;


-- ============================================================
-- 6. READMISSION BY YEAR
-- ============================================================

WITH encounter_dates AS (
    SELECT
        Id AS encounter_id,
        PATIENT AS patient_id,
        SUBSTR(START, 1, 4) AS year,
        datetime(STOP) AS stop_datetime
    FROM encounters
),

readmission_check AS (
    SELECT
        e1.encounter_id,
        e1.year,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            Id AS encounter_id,
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.year
)

SELECT

    year,

    COUNT(*) AS encounter_count,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmitted_within_30_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_30_day

FROM readmission_check

GROUP BY year

ORDER BY year;


-- ============================================================
-- 7. PATIENTS WITH MULTIPLE ENCOUNTERS
-- ============================================================

SELECT

    PATIENT AS patient_id,

    COUNT(*) AS total_encounters,

    MIN(datetime(START)) AS first_encounter,

    MAX(datetime(START)) AS most_recent_encounter

FROM encounters

GROUP BY PATIENT

HAVING COUNT(*) > 1

ORDER BY total_encounters DESC;


-- ============================================================
-- 8. TOP 20 MOST FREQUENTLY READMITTED PATIENTS
-- ============================================================

SELECT

    PATIENT AS patient_id,

    COUNT(*) AS total_encounters

FROM encounters

GROUP BY PATIENT

HAVING COUNT(*) >= 3

ORDER BY total_encounters DESC

LIMIT 20;


-- ============================================================
-- 9. TIME BETWEEN CONSECUTIVE ENCOUNTERS
-- ============================================================

WITH ordered_encounters AS (

    SELECT

        PATIENT AS patient_id,

        Id AS encounter_id,

        datetime(START) AS start_datetime,

        LAG(
            datetime(START)
        ) OVER (
            PARTITION BY PATIENT
            ORDER BY datetime(START)
        ) AS previous_encounter_datetime

    FROM encounters
)

SELECT

    ROUND(
        AVG(
            julianday(start_datetime) -
            julianday(previous_encounter_datetime)
        ),
        2
    ) AS average_days_between_encounters,

    ROUND(
        MIN(
            julianday(start_datetime) -
            julianday(previous_encounter_datetime)
        ),
        2
    ) AS minimum_days_between_encounters,

    ROUND(
        MAX(
            julianday(start_datetime) -
            julianday(previous_encounter_datetime)
        ),
        2
    ) AS maximum_days_between_encounters

FROM ordered_encounters

WHERE previous_encounter_datetime IS NOT NULL;


-- ============================================================
-- 10. ENCOUNTERS FOLLOWED BY ANOTHER ENCOUNTER WITHIN 30 DAYS
-- ============================================================

WITH ordered_encounters AS (

    SELECT

        PATIENT AS patient_id,

        Id AS encounter_id,

        datetime(START) AS start_datetime,

        LAG(
            datetime(START)
        ) OVER (
            PARTITION BY PATIENT
            ORDER BY datetime(START)
        ) AS previous_encounter_datetime

    FROM encounters
)

SELECT

    COUNT(*) AS subsequent_encounters,

    SUM(
        CASE
            WHEN julianday(start_datetime) -
                 julianday(previous_encounter_datetime) <= 30
            THEN 1
            ELSE 0
        END
    ) AS encounters_within_30_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN julianday(start_datetime) -
                     julianday(previous_encounter_datetime) <= 30
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS percentage_within_30_days

FROM ordered_encounters

WHERE previous_encounter_datetime IS NOT NULL;


-- ============================================================
-- 11. READMISSION BY GENDER
-- ============================================================

WITH encounter_dates AS (
    SELECT
        e.Id AS encounter_id,
        e.PATIENT AS patient_id,
        p.GENDER,
        datetime(e.STOP) AS stop_datetime
    FROM encounters e
    JOIN patients p
        ON e.PATIENT = p.Id
),

readmission_check AS (
    SELECT

        e1.encounter_id,

        e1.GENDER,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            Id AS encounter_id,
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.GENDER
)

SELECT

    GENDER,

    COUNT(*) AS encounter_count,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate

FROM readmission_check

GROUP BY GENDER

ORDER BY readmission_rate DESC;


-- ============================================================
-- 12. READMISSION BY RACE
-- ============================================================

WITH encounter_dates AS (
    SELECT
        e.Id AS encounter_id,
        e.PATIENT AS patient_id,
        p.RACE,
        datetime(e.STOP) AS stop_datetime
    FROM encounters e
    JOIN patients p
        ON e.PATIENT = p.Id
),

readmission_check AS (
    SELECT

        e1.encounter_id,

        e1.RACE,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            Id AS encounter_id,
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.RACE
)

SELECT

    RACE,

    COUNT(*) AS encounter_count,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate

FROM readmission_check

GROUP BY RACE

ORDER BY readmission_rate DESC;


-- ============================================================
-- 13. READMISSION BY ETHNICITY
-- ============================================================

WITH encounter_dates AS (
    SELECT
        e.Id AS encounter_id,
        e.PATIENT AS patient_id,
        p.ETHNICITY,
        datetime(e.STOP) AS stop_datetime
    FROM encounters e
    JOIN patients p
        ON e.PATIENT = p.Id
),

readmission_check AS (
    SELECT

        e1.encounter_id,

        e1.ETHNICITY,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            Id AS encounter_id,
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.ETHNICITY
)

SELECT

    ETHNICITY,

    COUNT(*) AS encounter_count,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate

FROM readmission_check

GROUP BY ETHNICITY

ORDER BY readmission_rate DESC;


-- ============================================================
-- 14. READMISSION COST IMPACT
-- ============================================================

WITH encounter_dates AS (
    SELECT
        Id AS encounter_id,
        PATIENT AS patient_id,
        TOTAL_CLAIM_COST,
        PAYER_COVERAGE,
        datetime(STOP) AS stop_datetime
    FROM encounters
),

readmission_check AS (
    SELECT

        e1.encounter_id,

        e1.TOTAL_CLAIM_COST,

        e1.PAYER_COVERAGE,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.TOTAL_CLAIM_COST,
        e1.PAYER_COVERAGE
)

SELECT

    CASE
        WHEN next_encounter_datetime IS NOT NULL
            THEN 'Readmitted within 30 days'
        ELSE 'Not readmitted within 30 days'
    END AS readmission_status,

    COUNT(*) AS encounter_count,

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
    ) AS total_payer_coverage

FROM readmission_check

GROUP BY readmission_status;


-- ============================================================
-- 15. READMISSION BY PAYER
-- ============================================================

WITH encounter_dates AS (
    SELECT
        e.Id AS encounter_id,
        e.PATIENT AS patient_id,
        e.PAYER,
        datetime(e.STOP) AS stop_datetime
    FROM encounters e
),

readmission_check AS (
    SELECT

        e1.encounter_id,

        e1.PAYER,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.PAYER
)

SELECT

    p.NAME AS payer_name,

    COUNT(*) AS encounter_count,

    SUM(
        CASE
            WHEN r.next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate

FROM readmission_check r

LEFT JOIN payers p
    ON r.PAYER = p.Id

GROUP BY
    r.PAYER,
    p.NAME

ORDER BY readmission_rate DESC;


-- ============================================================
-- 16. READMISSION BY PROCEDURE EXPOSURE
-- ============================================================

WITH encounter_procedures AS (

    SELECT DISTINCT
        ENCOUNTER
    FROM procedures
),

encounter_dates AS (

    SELECT

        e.Id AS encounter_id,

        e.PATIENT AS patient_id,

        CASE
            WHEN ep.ENCOUNTER IS NOT NULL
                THEN 'With procedure'
            ELSE 'Without procedure'
        END AS procedure_status,

        datetime(e.STOP) AS stop_datetime

    FROM encounters e

    LEFT JOIN encounter_procedures ep
        ON e.Id = ep.ENCOUNTER
),

readmission_check AS (

    SELECT

        e1.encounter_id,

        e1.procedure_status,

        MIN(e2.start_datetime) AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (
        SELECT
            PATIENT AS patient_id,
            datetime(START) AS start_datetime
        FROM encounters
    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY
        e1.encounter_id,
        e1.procedure_status
)

SELECT

    procedure_status,

    COUNT(*) AS encounter_count,

    SUM(
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate

FROM readmission_check

GROUP BY procedure_status;


-- ============================================================
-- 17. PATIENTS WITH 3 OR MORE ENCOUNTERS
-- ============================================================

SELECT

    PATIENT AS patient_id,

    COUNT(*) AS encounter_count,

    COUNT(
        DISTINCT ENCOUNTERCLASS
    ) AS encounter_class_count,

    ROUND(
        SUM(TOTAL_CLAIM_COST),
        2
    ) AS total_claim_cost

FROM encounters

GROUP BY PATIENT

HAVING COUNT(*) >= 3

ORDER BY encounter_count DESC;


-- ============================================================
-- 18. REPEATED ENCOUNTER CLASSES
-- ============================================================

SELECT

    PATIENT AS patient_id,

    ENCOUNTERCLASS,

    COUNT(*) AS encounter_count

FROM encounters

GROUP BY
    PATIENT,
    ENCOUNTERCLASS

HAVING COUNT(*) > 1

ORDER BY encounter_count DESC;


-- ============================================================
-- 19. SAME-DAY REPEAT ENCOUNTERS
-- ============================================================

WITH daily_encounters AS (

    SELECT

        PATIENT AS patient_id,

        DATE(START) AS encounter_date,

        COUNT(*) AS daily_encounter_count

    FROM encounters

    GROUP BY
        PATIENT,
        DATE(START)
)

SELECT

    COUNT(*) AS patient_days_with_multiple_encounters,

    SUM(daily_encounter_count)
        AS total_encounters_on_those_days,

    ROUND(
        AVG(daily_encounter_count),
        2
    ) AS average_encounters_per_repeat_day

FROM daily_encounters

WHERE daily_encounter_count > 1;


-- ============================================================
-- 20. EXECUTIVE READMISSION SUMMARY
-- ============================================================

WITH encounter_dates AS (

    SELECT

        Id AS encounter_id,

        PATIENT AS patient_id,

        ENCOUNTERCLASS,

        TOTAL_CLAIM_COST,

        datetime(STOP) AS stop_datetime

    FROM encounters
),

readmission_check AS (

    SELECT

        e1.encounter_id,

        e1.ENCOUNTERCLASS,

        e1.TOTAL_CLAIM_COST,

        MIN(e2.start_datetime)
            AS next_encounter_datetime

    FROM encounter_dates e1

    LEFT JOIN (

        SELECT

            Id AS encounter_id,

            PATIENT AS patient_id,

            datetime(START) AS start_datetime

        FROM encounters

    ) e2

        ON e1.patient_id = e2.patient_id

        AND e2.start_datetime > e1.stop_datetime

        AND e2.start_datetime <= datetime(
            e1.stop_datetime,
            '+30 days'
        )

    GROUP BY

        e1.encounter_id,

        e1.ENCOUNTERCLASS,

        e1.TOTAL_CLAIM_COST
)

SELECT

    COUNT(*) AS total_encounters,

    COUNT(DISTINCT (
        CASE
            WHEN next_encounter_datetime IS NOT NULL
            THEN encounter_id
        END
    )) AS readmitted_encounters,

    ROUND(
        100.0 *
        COUNT(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN 1
            END
        ) / COUNT(*),
        2
    ) AS overall_30_day_readmission_rate,

    ROUND(
        AVG(
            CASE
                WHEN next_encounter_datetime IS NOT NULL
                THEN TOTAL_CLAIM_COST
            END
        ),
        2
    ) AS average_cost_of_readmitted_encounters

FROM readmission_check;