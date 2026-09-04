from pathlib import Path
import sqlite3

# This file is inside:
# Hospital-patient-record/analysis/notebooks/
#
# Therefore, we go up two folders to reach:
# Hospital-patient-record/

PROJECT_ROOT = Path(__file__).resolve().parents[2]

DATABASE_PATH = PROJECT_ROOT / "database" / "healthcare.db"

print("=" * 70)
print("HOSPITAL HEALTHCARE ANALYTICS - DATABASE INSPECTION")
print("=" * 70)

print(f"\nProject root:")
print(PROJECT_ROOT)

print(f"\nDatabase path:")
print(DATABASE_PATH)

print(f"\nDatabase exists: {DATABASE_PATH.exists()}")

if not DATABASE_PATH.exists():
    raise FileNotFoundError(
        f"\nDatabase not found:\n{DATABASE_PATH}"
    )

conn = sqlite3.connect(DATABASE_PATH)

tables = conn.execute(
    """
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
    ORDER BY name
    """
).fetchall()

print("\n" + "=" * 70)
print("TABLES FOUND")
print("=" * 70)

if not tables:
    print("NO TABLES FOUND")

else:
    for table in tables:
        print(f"- {table[0]}")

print("\n" + "=" * 70)
print("TABLE DETAILS")
print("=" * 70)

for (table_name,) in tables:

    print(f"\n--- {table_name} ---")

    row_count = conn.execute(
        f'SELECT COUNT(*) FROM "{table_name}"'
    ).fetchone()[0]

    print(f"Rows: {row_count:,}")

    columns = conn.execute(
        f'PRAGMA table_info("{table_name}")'
    ).fetchall()

    print("Columns:")

    for column in columns:

        column_id = column[0]
        column_name = column[1]
        data_type = column[2]
        not_null = column[3]
        primary_key = column[5]

        print(
            f"  {column_id}: "
            f"{column_name} | "
            f"type={data_type} | "
            f"NOT NULL={bool(not_null)} | "
            f"PK={bool(primary_key)}"
        )

conn.close()

print("\n" + "=" * 70)
print("INSPECTION COMPLETE")
print("=" * 70)