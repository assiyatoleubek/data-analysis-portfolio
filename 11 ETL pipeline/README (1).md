# ETL Pipeline Project

## Overview
This project implements a complete ETL pipeline in Python using data from the Random User Generator API.

## Features
- Extract data from API
- Transform and clean data
- Load into SQLite database
- Incremental loading (no duplicates)
- Logging
- Error handling
- Scheduling
- Unit testing

## How to Run

Install dependencies:
pip install -r requirements.txt

Run ETL:
python etl_pipeline.py

Run scheduler:
python scheduler.py

Run tests:
pytest -v

## Output
- users.db (database)
- etl_pipeline.log (logs)
- alert.log (errors)