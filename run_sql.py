from pathlib import Path
import sqlite3
import sys

PROJECT_ROOT = Path(__file__).resolve().parent
DATABASE = PROJECT_ROOT / "database" / "healthcare.db"


if len(sys.argv) != 2:
    print("Usage: python run_sql.py sql/filename.sql")
    sys.exit(1)


sql_file = PROJECT_ROOT / sys.argv[1]

if not sql_file.exists():
    print(f"SQL file not found: {sql_file}")
    sys.exit(1)


conn = sqlite3.connect(DATABASE)

sql = sql_file.read_text(encoding="utf-8")

statements = [
    statement.strip()
    for statement in sql.split(";")
    if statement.strip()
]


print("=" * 80)
print(f"RUNNING: {sql_file.relative_to(PROJECT_ROOT)}")
print("=" * 80)


for number, statement in enumerate(statements, start=1):

    # Skip pure comments
    executable = "\n".join(
        line
        for line in statement.splitlines()
        if not line.strip().startswith("--")
    ).strip()

    if not executable:
        continue

    try:
        cursor = conn.execute(executable)

        rows = cursor.fetchall()

        print(f"\nRESULT {number}")
        print("-" * 80)

        if cursor.description:
            columns = [
                description[0]
                for description in cursor.description
            ]

            print(" | ".join(columns))

            for row in rows:
                print(" | ".join(str(value) for value in row))

        else:
            print("Statement executed successfully.")

    except Exception as error:
        print(f"\nERROR in statement {number}:")
        print(error)


conn.close()

print("\n" + "=" * 80)
print("SQL EXECUTION COMPLETE")
print("=" * 80)