from pathlib import Path
import pandas as pd


# ============================================================
# HOSPITAL HEALTHCARE ANALYTICS
# CSV DATASET INSPECTION
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"


print("=" * 80)
print("HOSPITAL HEALTHCARE ANALYTICS - CSV INSPECTION")
print("=" * 80)

print(f"\nProject root:")
print(PROJECT_ROOT)

print(f"\nRaw data directory:")
print(RAW_DATA_DIR)

print(f"\nRaw data directory exists: {RAW_DATA_DIR.exists()}")


if not RAW_DATA_DIR.exists():
    raise FileNotFoundError(
        f"Raw data directory not found:\n{RAW_DATA_DIR}"
    )


csv_files = sorted(RAW_DATA_DIR.glob("*.csv"))


print("\n" + "=" * 80)
print("CSV FILES FOUND")
print("=" * 80)

for file in csv_files:
    print(f"- {file.name}")


print("\n" + "=" * 80)
print("DATASET DETAILS")
print("=" * 80)


for file in csv_files:

    print("\n" + "-" * 80)
    print(f"FILE: {file.name}")
    print("-" * 80)

    try:
        df = pd.read_csv(file)

    except Exception as error:
        print(f"ERROR READING FILE: {error}")
        continue

    print(f"Rows: {len(df):,}")
    print(f"Columns: {len(df.columns):,}")

    print("\nColumns:")
    for column in df.columns:
        print(f"  - {column}")

    print("\nData types:")
    for column, dtype in df.dtypes.items():
        print(f"  - {column}: {dtype}")

    print("\nMissing values:")
    missing = df.isna().sum()

    missing_found = False

    for column, count in missing.items():
        if count > 0:
            missing_found = True
            percentage = (count / len(df)) * 100

            print(
                f"  - {column}: "
                f"{count:,} "
                f"({percentage:.2f}%)"
            )

    if not missing_found:
        print("  None")

    print("\nDuplicate rows:")
    print(f"  {df.duplicated().sum():,}")

    print("\nFirst 3 rows:")
    print(df.head(3).to_string(index=False))


print("\n" + "=" * 80)
print("CSV INSPECTION COMPLETE")
print("=" * 80)