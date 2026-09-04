from pathlib import Path
import sqlite3
import pandas as pd


# ============================================================
# HOSPITAL HEALTHCARE ANALYTICS
# DATABASE BUILD SCRIPT
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parent

RAW_DATA = PROJECT_ROOT / "data" / "raw"
DATABASE = PROJECT_ROOT / "database" / "healthcare.db"


print("=" * 80)
print("HOSPITAL HEALTHCARE ANALYTICS - DATABASE BUILD")
print("=" * 80)

print(f"\nProject root:")
print(PROJECT_ROOT)

print(f"\nRaw data:")
print(RAW_DATA)

print(f"\nDatabase:")
print(DATABASE)


# ------------------------------------------------------------
# CHECK SOURCE FILES
# ------------------------------------------------------------

required_files = [
    "patients.csv",
    "encounters.csv",
    "procedures.csv",
    "payers.csv",
    "organizations.csv",
    "data_dictionary.csv",
]

print("\n" + "=" * 80)
print("CHECKING SOURCE FILES")
print("=" * 80)

for filename in required_files:

    path = RAW_DATA / filename

    if not path.exists():
        raise FileNotFoundError(
            f"Required file not found: {path}"
        )

    print(f"OK: {filename}")


# ------------------------------------------------------------
# CREATE DATABASE DIRECTORY
# ------------------------------------------------------------

DATABASE.parent.mkdir(
    parents=True,
    exist_ok=True
)


# ------------------------------------------------------------
# CONNECT TO DATABASE
# ------------------------------------------------------------

print("\n" + "=" * 80)
print("CREATING DATABASE")
print("=" * 80)

conn = sqlite3.connect(DATABASE)


# ------------------------------------------------------------
# REMOVE EXISTING TABLES
# ------------------------------------------------------------

tables_to_drop = [
    "procedures",
    "encounters",
    "patients",
    "payers",
    "organizations",
    "data_dictionary",
]

for table in tables_to_drop:

    conn.execute(
        f'DROP TABLE IF EXISTS "{table}"'
    )


# ------------------------------------------------------------
# LOAD CSV FILES
# ------------------------------------------------------------

datasets = {
    "patients": "patients.csv",
    "encounters": "encounters.csv",
    "procedures": "procedures.csv",
    "payers": "payers.csv",
    "organizations": "organizations.csv",
    "data_dictionary": "data_dictionary.csv",
}


print("\n" + "=" * 80)
print("LOADING DATA")
print("=" * 80)

for table_name, filename in datasets.items():

    path = RAW_DATA / filename

    print(f"\nLoading {filename}...")

    df = pd.read_csv(path)

    df.to_sql(
        table_name,
        conn,
        if_exists="replace",
        index=False
    )

    print(
        f"Loaded {len(df):,} rows "
        f"into {table_name}"
    )


# ------------------------------------------------------------
# CREATE INDEXES
# ------------------------------------------------------------

print("\n" + "=" * 80)
print("CREATING INDEXES")
print("=" * 80)


indexes = [

    """
    CREATE INDEX IF NOT EXISTS idx_patients_id
    ON patients(Id)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_encounters_id
    ON encounters(Id)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_encounters_patient
    ON encounters(PATIENT)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_encounters_payer
    ON encounters(PAYER)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_encounters_organization
    ON encounters(ORGANIZATION)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_procedures_patient
    ON procedures(PATIENT)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_procedures_encounter
    ON procedures(ENCOUNTER)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_procedures_code
    ON procedures(CODE)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_encounters_start
    ON encounters(START)
    """,

    """
    CREATE INDEX IF NOT EXISTS idx_procedures_start
    ON procedures(START)
    """,
]


for index_sql in indexes:

    conn.execute(index_sql)

    print("Index created.")


# ------------------------------------------------------------
# CREATE PRIMARY KEY / RELATIONSHIP CHECKS
# ------------------------------------------------------------

print("\n" + "=" * 80)
print("VERIFYING DATABASE")
print("=" * 80)


for table_name in datasets:

    count = conn.execute(
        f'SELECT COUNT(*) FROM "{table_name}"'
    ).fetchone()[0]

    print(
        f"{table_name}: "
        f"{count:,} rows"
    )


# ------------------------------------------------------------
# FOREIGN KEY-STYLE RELATIONSHIP CHECKS
# ------------------------------------------------------------

print("\n" + "=" * 80)
print("CHECKING RELATIONSHIPS")
print("=" * 80)


orphan_encounters = conn.execute(
    """
    SELECT COUNT(*)
    FROM encounters e
    LEFT JOIN patients p
        ON e.PATIENT = p.Id
    WHERE p.Id IS NULL
    """
).fetchone()[0]

print(
    f"Encounters without matching patient: "
    f"{orphan_encounters:,}"
)


orphan_procedures = conn.execute(
    """
    SELECT COUNT(*)
    FROM procedures pr
    LEFT JOIN encounters e
        ON pr.ENCOUNTER = e.Id
    WHERE e.Id IS NULL
    """
).fetchone()[0]

print(
    f"Procedures without matching encounter: "
    f"{orphan_procedures:,}"
)


orphan_payers = conn.execute(
    """
    SELECT COUNT(*)
    FROM encounters e
    LEFT JOIN payers p
        ON e.PAYER = p.Id
    WHERE e.PAYER IS NOT NULL
      AND p.Id IS NULL
    """
).fetchone()[0]

print(
    f"Encounters without matching payer: "
    f"{orphan_payers:,}"
)


orphan_organizations = conn.execute(
    """
    SELECT COUNT(*)
    FROM encounters e
    LEFT JOIN organizations o
        ON e.ORGANIZATION = o.Id
    WHERE e.ORGANIZATION IS NOT NULL
      AND o.Id IS NULL
    """
).fetchone()[0]

print(
    f"Encounters without matching organization: "
    f"{orphan_organizations:,}"
)


# ------------------------------------------------------------
# COMMIT
# ------------------------------------------------------------

conn.commit()
conn.close()


print("\n" + "=" * 80)
print("DATABASE BUILD COMPLETE")
print("=" * 80)

print(f"\nDatabase created:")
print(DATABASE)

print("\nYou can now proceed to SQL analysis.")