-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- 01 - DATA QUALITY AUDIT
-- ============================================================

-- ============================================================
-- 1. TABLE ROW COUNTS
-- ============================================================

SELECT 'patients' AS table_name, COUNT(*) AS row_count
FROM patients

UNION ALL

SELECT 'encounters', COUNT(*)
FROM encounters

UNION ALL

SELECT 'procedures', COUNT(*)
FROM procedures

UNION ALL

SELECT 'payers', COUNT(*)
FROM payers

UNION ALL

SELECT 'organizations', COUNT(*)
FROM organizations

UNION ALL

SELECT 'data_dictionary', COUNT(*)
FROM data_dictionary;


-- ============================================================
-- 2. DUPLICATE PATIENT IDS
-- ============================================================

SELECT
    Id AS patient_id,
    COUNT(*) AS record_count
FROM patients
GROUP BY Id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. DUPLICATE ENCOUNTER IDS
-- ============================================================

SELECT
    Id AS encounter_id,
    COUNT(*) AS record_count
FROM encounters
GROUP BY Id
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. DUPLICATE PROCEDURE RECORDS
-- ============================================================

SELECT
    PATIENT,
    ENCOUNTER,
    START,
    STOP,
    CODE,
    COUNT(*) AS record_count
FROM procedures
GROUP BY
    PATIENT,
    ENCOUNTER,
    START,
    STOP,
    CODE
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. MISSING PATIENT IDS
-- ============================================================

SELECT COUNT(*) AS missing_patient_ids
FROM patients
WHERE Id IS NULL;


-- ============================================================
-- 6. MISSING ENCOUNTER IDS
-- ============================================================

SELECT COUNT(*) AS missing_encounter_ids
FROM encounters
WHERE Id IS NULL;


-- ============================================================
-- 7. ORPHAN ENCOUNTERS
-- ============================================================

SELECT COUNT(*) AS orphan_encounters
FROM encounters e
LEFT JOIN patients p
    ON e.PATIENT = p.Id
WHERE p.Id IS NULL;


-- ============================================================
-- 8. ORPHAN PROCEDURES
-- ============================================================

SELECT COUNT(*) AS orphan_procedures
FROM procedures pr
LEFT JOIN encounters e
    ON pr.ENCOUNTER = e.Id
WHERE e.Id IS NULL;


-- ============================================================
-- 9. ORPHAN PAYER REFERENCES
-- ============================================================

SELECT COUNT(*) AS orphan_payer_references
FROM encounters e
LEFT JOIN payers p
    ON e.PAYER = p.Id
WHERE e.PAYER IS NOT NULL
  AND p.Id IS NULL;


-- ============================================================
-- 10. ORPHAN ORGANIZATION REFERENCES
-- ============================================================

SELECT COUNT(*) AS orphan_organization_references
FROM encounters e
LEFT JOIN organizations o
    ON e.ORGANIZATION = o.Id
WHERE e.ORGANIZATION IS NOT NULL
  AND o.Id IS NULL;


-- ============================================================
-- 11. MISSING ENCOUNTER REASONS
-- ============================================================

SELECT
    COUNT(*) AS missing_reason,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS percentage
FROM encounters
WHERE REASONCODE IS NULL
  AND REASONDESCRIPTION IS NULL;


-- ============================================================
-- 12. MISSING PROCEDURE REASONS
-- ============================================================

SELECT
    COUNT(*) AS missing_reason,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM procedures),
        2
    ) AS percentage
FROM procedures
WHERE REASONCODE IS NULL
  AND REASONDESCRIPTION IS NULL;


-- ============================================================
-- 13. MISSING PATIENT DEATH DATE
-- ============================================================

SELECT
    COUNT(*) AS missing_death_date,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage
FROM patients
WHERE DEATHDATE IS NULL;


-- ============================================================
-- 14. MISSING ZIP CODE
-- ============================================================

SELECT
    COUNT(*) AS missing_zip,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage
FROM patients
WHERE ZIP IS NULL;


-- ============================================================
-- 15. INVALID ENCOUNTER DATE ORDER
-- ============================================================

SELECT COUNT(*) AS invalid_encounter_dates
FROM encounters
WHERE START > STOP;


-- ============================================================
-- 16. INVALID PROCEDURE DATE ORDER
-- ============================================================

SELECT COUNT(*) AS invalid_procedure_dates
FROM procedures
WHERE START > STOP;


-- ============================================================
-- 17. NEGATIVE CLAIM COST
-- ============================================================

SELECT COUNT(*) AS negative_claim_cost
FROM encounters
WHERE TOTAL_CLAIM_COST < 0;


-- ============================================================
-- 18. NEGATIVE PAYER COVERAGE
-- ============================================================

SELECT COUNT(*) AS negative_payer_coverage
FROM encounters
WHERE PAYER_COVERAGE < 0;


-- ============================================================
-- 19. PAYER COVERAGE ABOVE CLAIM COST
-- ============================================================

SELECT COUNT(*) AS coverage_above_claim_cost
FROM encounters
WHERE PAYER_COVERAGE > TOTAL_CLAIM_COST;