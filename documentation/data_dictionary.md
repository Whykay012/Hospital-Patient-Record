# Healthcare Dataset Data Dictionary

## 1. Patients

| Column | Data Type | Description | Business Meaning | Nullable? | Primary Key? | Foreign Key? |
|---|---|---|---|---|---|---|
| Id | String | Unique patient identifier | Identifies a patient | No | Yes | No |
| BIRTHDATE | Date | Patient's date of birth | Used for demographic and age analysis | No | No | No |
| DEATHDATE | Date | Patient's date of death | Used to identify deceased patients | Yes | No | No |
| ... | ... | ... | ... | ... | ... | ... |

## 2. Encounters

| Column | Data Type | Description | Business Meaning | Nullable? | Primary Key? | Foreign Key? |
|---|---|---|---|---|---|---|
| Id | String | Unique encounter identifier | Identifies healthcare encounter | No | Yes | No |
| PATIENT | String | Patient identifier | Links encounter to patient | No | No | Yes → patients.Id |
| ORGANIZATION | String | Organization identifier | Links encounter to healthcare organization | No | No | Yes → organizations.Id |
| PAYER | String | Payer identifier | Links encounter to payer | No | No | Yes → payers.Id |
| ... | ... | ... | ... | ... | ... | ... |