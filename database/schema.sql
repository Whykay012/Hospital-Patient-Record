-- ============================================================
-- HOSPITAL HEALTHCARE ANALYTICS
-- DATABASE SCHEMA
-- ============================================================

-- ============================================================
-- PATIENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS patients (
    Id TEXT PRIMARY KEY,
    BIRTHDATE TEXT,
    DEATHDATE TEXT,
    PREFIX TEXT,
    FIRST TEXT,
    LAST TEXT,
    SUFFIX TEXT,
    MAIDEN TEXT,
    MARITAL TEXT,
    RACE TEXT,
    ETHNICITY TEXT,
    GENDER TEXT,
    BIRTHPLACE TEXT,
    ADDRESS TEXT,
    CITY TEXT,
    STATE TEXT,
    COUNTY TEXT,
    ZIP REAL,
    LAT REAL,
    LON REAL
);


-- ============================================================
-- PAYERS
-- ============================================================

CREATE TABLE IF NOT EXISTS payers (
    Id TEXT PRIMARY KEY,
    NAME TEXT,
    ADDRESS TEXT,
    CITY TEXT,
    STATE_HEADQUARTERED TEXT,
    ZIP REAL,
    PHONE TEXT
);


-- ============================================================
-- ORGANIZATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS organizations (
    Id TEXT PRIMARY KEY,
    NAME TEXT,
    ADDRESS TEXT,
    CITY TEXT,
    STATE TEXT,
    ZIP INTEGER,
    LAT REAL,
    LON REAL
);


-- ============================================================
-- ENCOUNTERS
-- ============================================================

CREATE TABLE IF NOT EXISTS encounters (
    Id TEXT PRIMARY KEY,
    START TEXT,
    STOP TEXT,
    PATIENT TEXT,
    ORGANIZATION TEXT,
    PAYER TEXT,
    ENCOUNTERCLASS TEXT,
    CODE INTEGER,
    DESCRIPTION TEXT,
    BASE_ENCOUNTER_COST REAL,
    TOTAL_CLAIM_COST REAL,
    PAYER_COVERAGE REAL,
    REASONCODE REAL,
    REASONDESCRIPTION TEXT,

    FOREIGN KEY (PATIENT)
        REFERENCES patients(Id),

    FOREIGN KEY (ORGANIZATION)
        REFERENCES organizations(Id),

    FOREIGN KEY (PAYER)
        REFERENCES payers(Id)
);


-- ============================================================
-- PROCEDURES
-- ============================================================

CREATE TABLE IF NOT EXISTS procedures (
    START TEXT,
    STOP TEXT,
    PATIENT TEXT,
    ENCOUNTER TEXT,
    CODE INTEGER,
    DESCRIPTION TEXT,
    BASE_COST INTEGER,
    REASONCODE REAL,
    REASONDESCRIPTION TEXT,

    FOREIGN KEY (PATIENT)
        REFERENCES patients(Id),

    FOREIGN KEY (ENCOUNTER)
        REFERENCES encounters(Id)
);


-- ============================================================
-- DATA DICTIONARY
-- ============================================================

CREATE TABLE IF NOT EXISTS data_dictionary (
    Table_name TEXT,
    Field TEXT,
    Description TEXT
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_patients_id
ON patients(Id);

CREATE INDEX IF NOT EXISTS idx_encounters_id
ON encounters(Id);

CREATE INDEX IF NOT EXISTS idx_encounters_patient
ON encounters(PATIENT);

CREATE INDEX IF NOT EXISTS idx_encounters_payer
ON encounters(PAYER);

CREATE INDEX IF NOT EXISTS idx_encounters_organization
ON encounters(ORGANIZATION);

CREATE INDEX IF NOT EXISTS idx_procedures_patient
ON procedures(PATIENT);

CREATE INDEX IF NOT EXISTS idx_procedures_encounter
ON procedures(ENCOUNTER);

CREATE INDEX IF NOT EXISTS idx_procedures_code
ON procedures(CODE);

CREATE INDEX IF NOT EXISTS idx_encounters_start
ON encounters(START);

CREATE INDEX IF NOT EXISTS idx_procedures_start
ON procedures(START);