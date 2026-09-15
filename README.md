# Hospital Patient Records Analysis

## Overview

This project analyzes a hospital patient records dataset to understand patient utilization, encounter activity, healthcare costs, payer coverage, procedures, diagnoses, and patient return patterns.

I used Python, SQL, statistics, and data visualization to take the project from data-quality checks through exploratory and advanced analysis.

The main focus was not just to create charts, but to understand the data, validate the relationships between the tables, identify useful patterns, and turn the results into clear analytical findings.

---

## Dataset

The project contains the following main datasets:

| Dataset | Records | Description |
|---|---:|---|
| Patients | 974 | Patient demographic and geographic information |
| Encounters | 27,891 | Patient healthcare encounters |
| Procedures | 47,701 | Procedures linked to patient encounters |
| Payers | 10 | Payer information |
| Organizations | 1 | Healthcare organization information |
| Data Dictionary | 65 fields | Dataset field definitions |

### Key Metrics

| Metric | Value |
|---|---:|
| Total Patients | 974 |
| Total Encounters | 27,891 |
| Total Procedures | 47,701 |
| Total Claim Cost | ~$101.51M |
| Total Payer Coverage | ~$31.10M |
| Total Out-of-Pocket Cost | ~$70.42M |
| Average Claim Cost | ~$3,639.68 |
| Average Recorded Encounter Duration | ~7.27 hours |
| 30-Day Return Rate | ~60.18% |
| Top 20% Patient Cost Contribution | ~83.93% |

These figures describe the records available in this dataset and are not intended to represent a wider healthcare population.

---

## Questions I Explored

### Patient Utilization
- Which patients have the highest number of encounters?
- How is healthcare utilization distributed across patients?
- Which patients have both high utilization and high costs?
- Can patients be grouped based on utilization patterns?

### Cost and Coverage
- How are claim costs distributed?
- Which encounter types generate the highest costs?
- How concentrated is total cost among high-cost patients?
- How much of the cost is covered by payers?
- What is the recorded out-of-pocket cost?

### Payers
- Which payers are associated with the most encounters?
- How much total cost is associated with each payer?
- How does payer coverage vary?

### Operations
- How does encounter activity change over time?
- Which encounter types have the highest recorded duration?
- How do encounter types compare in volume and cost?

### Diagnoses and Procedures
- Which diagnoses/reasons occur most frequently?
- Which diagnoses are associated with higher costs?
- Which procedures are most frequently recorded?

### Patient Returns
- How often do patients have another recorded encounter within 30 days?
- Which utilization patterns are associated with repeated encounters?

---

## Project Structure

```text
Hospital-patient-record-data-analyst-cleaned/
│
├── analysis/
│   └── notebooks/
│       ├── 01_data_quality_audit2.ipynb
│       ├── 02_exploratory_analysis.ipynb
│       ├── 03_statistical_analysis.ipynb
│       ├── 04_advanced_healthcare_analysis.ipynb
│       ├── check_database.py
│       └── inspect_csvs.py
│
├── data/
│   ├── raw/
│   │   ├── patients.csv
│   │   ├── encounters.csv
│   │   ├── procedures.csv
│   │   ├── payers.csv
│   │   ├── organizations.csv
│   │   └── data_dictionary.csv
│   │
│   └── processed/
│       ├── advanced_healthcare_kpis.csv
│       ├── advanced_patient_profile.csv
│       ├── advanced_operational_analysis.csv
│       ├── advanced_diagnosis_analysis.csv
│       ├── advanced_procedure_analysis.csv
│       ├── monthly_healthcare_activity.csv
│       ├── patient_utilization_summary.csv
│       ├── payer_statistical_summary.csv
│       ├── statistical_analysis_results.csv
│       └── top_high_cost_patients.csv
│
├── database/
│   ├── create_hospital_db.sql
│   ├── schema.sql
│   ├── healthcare.db
│   └── hospital_analytics.db
│
├── documentation/
│   ├── data_dictionary.md
│   ├── data_inventory.md
│   └── data_model.md
│
├── images/
│   ├── 01_data_quality_audit/
│   ├── 02_exploratory_analysis/
│   ├── 03_statistical_analysis/
│   └── 04_advanced_healthcare_analysis/
│
├── sql/
│   ├── 01_data_quality_audit.sql
│   ├── 02_encounter_analysis.sql
│   ├── 03_patient_utilization.sql
│   ├── 04_cost_analysis.sql
│   ├── 05_payer_analysis.sql
│   ├── 06_procedure_analysis.sql
│   ├── 07_readmission_analysis.sql
│   ├── 08_demographic_analysis.sql
│   ├── 09_diagnosis_analysis.sql
│   ├── 10_patient_journey.sql
│   ├── 11_operational_analysis.sql
│   └── 12_advanced_analysis.sql
│
├── deep_dataset.ipynb
├── load_database.py
├── run_sql.py
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Analysis

### 1. Data Quality Audit

I started by checking the structure and quality of the datasets before using them for analysis.

The checks include:

- Missing values
- Duplicate records
- Primary-key uniqueness
- Foreign-key relationships
- Date fields
- Financial fields
- Encounter duration
- Patient IDs
- Encounter IDs
- Payer IDs
- Organization IDs
- Procedure relationships
- Other business-rule checks

This helped identify potential data issues before moving into the analysis.

---

### 2. Exploratory Data Analysis

The exploratory analysis looks at:

- Encounter volume
- Encounter types
- Monthly activity
- Claim costs
- Cost by encounter type
- Patient utilization
- Payer activity
- Procedure activity
- Gender
- Race
- Geographic patterns

The aim was to understand the overall structure of the data and identify areas that required deeper analysis.

---

### 3. Statistical Analysis

The statistical analysis goes beyond descriptive summaries and includes:

- Descriptive statistics
- Mean and median comparisons
- Cost comparisons
- Utilization comparisons
- Correlation analysis
- Group comparisons
- Statistical significance testing
- Payer coverage analysis
- 30-day return analysis

Statistical results are interpreted together with the size and practical relevance of the observed differences.

---

### 4. Advanced Analysis

The advanced notebook brings the main findings together at patient and operational levels.

#### Patient Utilization

Each patient is profiled using measures such as:

- Number of encounters
- Total cost
- Average cost
- Payer coverage
- Out-of-pocket cost
- Recorded encounter hours

#### Patient Segmentation

Patients are grouped into utilization segments to compare different levels of healthcare activity.

#### High-Cost Patients

The analysis identifies patients with the highest total recorded costs and compares their:

- Encounter volume
- Total cost
- Average cost
- Payer coverage
- Out-of-pocket cost
- Recorded utilization

#### Cost Concentration

A Pareto-style analysis shows how total cost is distributed across patients.

In this dataset, the top 20% of patients account for approximately **83.93% of total recorded cost**.

This is a descriptive finding from the dataset and does not explain why those patients have higher costs.

#### Outlier Analysis

I also looked for unusual values in:

- Encounter costs
- Encounter duration
- Patient utilization

Outliers are treated as records that may need further investigation rather than automatically being treated as errors.

#### 30-Day Patient Return

The project checks whether a patient has another recorded encounter within 30 days of a previous encounter.

The calculated rate is approximately **60.18%**.

This should be understood as a dataset-based 30-day return measure, not automatically as an official clinical readmission rate.

#### Diagnosis and Procedure Analysis

The analysis covers:

- Most frequent diagnoses/reasons
- Cost by diagnosis/reason
- Average cost by diagnosis/reason
- Most frequently recorded procedures

#### Operational Analysis

Operational measures include:

- Encounter volume
- Average duration
- Median duration
- Total cost
- Average cost
- Payer coverage

---

## SQL Analysis

The project also contains SQL analysis covering the major parts of the dataset:

| SQL File | Analysis |
|---|---|
| `01_data_quality_audit.sql` | Data quality checks |
| `02_encounter_analysis.sql` | Encounter analysis |
| `03_patient_utilization.sql` | Patient utilization |
| `04_cost_analysis.sql` | Cost analysis |
| `05_payer_analysis.sql` | Payer analysis |
| `06_procedure_analysis.sql` | Procedure analysis |
| `07_readmission_analysis.sql` | 30-day return analysis |
| `08_demographic_analysis.sql` | Demographic analysis |
| `09_diagnosis_analysis.sql` | Diagnosis analysis |
| `10_patient_journey.sql` | Patient journey |
| `11_operational_analysis.sql` | Operational analysis |
| `12_advanced_analysis.sql` | Advanced analysis |

The database layer uses SQLite and provides a relational structure for working with the patient, encounter, procedure, payer, and organization data.

---

## Tools Used

### Python
- Pandas
- NumPy
- SciPy
- Matplotlib
- Seaborn
- Jupyter Notebook

### SQL
- SQLite
- SQL joins
- Aggregations
- Window functions
- Patient-level analysis
- Cost analysis
- Payer analysis

### Other
- CSV
- SQLite databases
- Git/GitHub
- Data documentation

---

## How to Run

### 1. Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd Hospital-patient-record-data-analyst-cleaned
```

### 2. Create a virtual environment

Windows:

```bash
python -m venv .venv
.venv\Scripts\activate
```

macOS/Linux:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Install the required packages

```bash
pip install -r requirements.txt
```

### 4. Load the database

```bash
python load_database.py
```

### 5. Run database checks

```bash
python analysis/notebooks/check_database.py
```

### 6. Run the SQL analysis

```bash
python run_sql.py
```

### 7. Open the notebooks

```bash
jupyter notebook
```

Recommended order:

```text
01_data_quality_audit2.ipynb
02_exploratory_analysis.ipynb
03_statistical_analysis.ipynb
04_advanced_healthcare_analysis.ipynb
deep_dataset.ipynb
```

---

## Key Findings

Some of the main findings from the analysis include:

- The dataset contains **974 patients and 27,891 encounters**.
- There are **47,701 recorded procedures**.
- Total recorded claim cost is approximately **$101.51M**.
- Recorded payer coverage is approximately **$31.10M**.
- Recorded out-of-pocket cost is approximately **$70.42M**.
- The average recorded claim cost is approximately **$3,639.68**.
- The calculated 30-day return rate is approximately **60.18%**.
- Healthcare cost is highly concentrated, with the top 20% of patients accounting for approximately **83.93% of total recorded cost**.

These findings provide areas for further investigation around utilization, cost concentration, payer coverage, and repeat patient activity.

### Observational Data

The analysis identifies patterns and relationships in the data. It does not establish causation.

### 30-Day Return Measure

A subsequent encounter within 30 days is used as a return measure. It should not automatically be described as a formal hospital readmission metric.

### Cost and Severity

Higher recorded cost does not necessarily mean higher clinical severity or poorer patient outcomes.

### Encounter Duration

Recorded encounter duration should be interpreted in the context of encounter type and how the source system records healthcare activity.

### Dataset Scope

The findings apply to the available dataset and should not automatically be generalized to other hospitals or patient populations.

### Privacy

Healthcare data should be handled responsibly. Any public version of this project should comply with the applicable data-use and privacy requirements. Identifiable or sensitive patient information should not be published without appropriate authorization.

---

## What This Project Demonstrates

This project demonstrates my ability to work through a complete data analysis workflow:

- Data cleaning and validation
- Exploratory data analysis
- Healthcare utilization analysis
- Cost and payer analysis
- Patient-level analysis
- Statistical analysis
- SQL analysis
- Data visualization
- Outlier analysis
- Patient segmentation
- Patient journey analysis
- Reproducible analytical workflows
- Documentation and communication of findings

---

## Author

**Awoyera Olayinka**

Data Analyst | SQL | Python | Data Visualization | Healthcare Analytics

---
