import time
from datetime import datetime
from etl_pipeline import extract, transform, load, get_existing_emails

def run_etl():
    print(f"Running ETL at {datetime.now()}")

    existing_emails = get_existing_emails()
    df = extract(existing_emails)
    df_clean = transform(df)
    load(df_clean)


if __name__ == "__main__":
    for i in range(6): 
        run_etl()
        time.sleep(10)