-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- DATABASE CREATION / VALIDATION SCRIPT
-- ============================================================

PRAGMA foreign_keys = ON;


-- ============================================================
-- VERIFY TABLES
-- ============================================================

SELECT
    name AS table_name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;


-- ============================================================
-- ROW COUNTS
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
-- RELATIONSHIP VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS orphan_encounters
FROM encounters e
LEFT JOIN patients p
    ON e.PATIENT = p.Id
WHERE p.Id IS NULL;


SELECT
    COUNT(*) AS orphan_procedures
FROM procedures pr
LEFT JOIN encounters e
    ON pr.ENCOUNTER = e.Id
WHERE e.Id IS NULL;


SELECT
    COUNT(*) AS orphan_payer_references
FROM encounters e
LEFT JOIN payers p
    ON e.PAYER = p.Id
WHERE e.PAYER IS NOT NULL
  AND p.Id IS NULL;


SELECT
    COUNT(*) AS orphan_organization_references
FROM encounters e
LEFT JOIN organizations o
    ON e.ORGANIZATION = o.Id
WHERE e.ORGANIZATION IS NOT NULL
  AND o.Id IS NULL;