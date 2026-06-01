import requests
import pandas as pd
import sqlite3
import logging
import traceback
from logging.handlers import RotatingFileHandler
from datetime import datetime, UTC

print("FILE RUNNING")

logger = logging.getLogger()
logger.setLevel(logging.INFO)

handler = RotatingFileHandler(
    "etl_pipeline.log",
    maxBytes=1_000_000,
    backupCount=3
)

formatter = logging.Formatter(
    "%(asctime)s - %(levelname)s - %(message)s"
)

handler.setFormatter(formatter)

if logger.hasHandlers():
    logger.handlers.clear()

logger.addHandler(handler)

def extract(existing_emails=None):
    url = "https://randomuser.me/api/?results=20"
    
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    
    data = response.json()
    users = data['results']
    
    df = pd.json_normalize(users)

    if existing_emails:
        df = df[~df['email'].isin(existing_emails)]

    logger.info(f"Extracted {len(df)} new rows")

    return df

def transform(df):

    if df is None or df.empty:
        return pd.DataFrame()

    df_transformed = pd.DataFrame()

    df_transformed['email'] = df['email']
    df_transformed['gender'] = df['gender']
    df_transformed['first_name'] = df['name.first']
    df_transformed['last_name'] = df['name.last']
    df_transformed['nationality'] = df['nat']
    df_transformed['age'] = df['dob.age']
    df_transformed['dob_date'] = df['dob.date']

    df_transformed['age_group'] = pd.cut(
        df_transformed['age'],
        bins=[0, 18, 30, 60, 100],
        labels=['Child', 'Young Adult', 'Adult', 'Senior']
    )

    df_transformed['email_domain'] = df_transformed['email'].str.split('@').str[1]

    df_transformed['loaded_at'] = datetime.now(UTC).isoformat()

    df_transformed = df_transformed.dropna(subset=['email'])

    df_transformed = df_transformed.drop_duplicates(subset=['email'])

    logger.info(f"Transformed {len(df_transformed)} rows")

    return df_transformed


def load(df, db_path='users.db'):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        email TEXT PRIMARY KEY,
        gender TEXT,
        first_name TEXT,
        last_name TEXT,
        nationality TEXT,
        age INTEGER,
        age_group TEXT,
        email_domain TEXT,
        dob_date TEXT,
        loaded_at TEXT
    )
    """)

    rows = df[[
        'email',
        'gender',
        'first_name',
        'last_name',
        'nat' if 'nat' in df.columns else 'nationality',
        'age',
        'age_group',
        'email_domain',
        'dob_date',
        'loaded_at'
    ]].values.tolist()

    cursor.executemany("""
    INSERT OR IGNORE INTO users (
        email, gender, first_name, last_name,
        nationality, age, age_group,
        email_domain, dob_date, loaded_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, rows)

    conn.commit()
    conn.close()

    logger.info(f"Loaded {len(rows)} rows into DB")


def get_existing_emails(db_path='users.db'):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT email FROM users")
        rows = cursor.fetchall()
        return set(row[0] for row in rows)

    except sqlite3.OperationalError:
        # если таблицы ещё нет
        return set()

    finally:
        conn.close()


if __name__ == "__main__":
    try:
        logger.info("ETL started")

        existing_emails = get_existing_emails()
        df = extract(existing_emails)
        df_clean = transform(df)
        load(df_clean)

        logger.info("ETL finished successfully")

    except Exception as e:
        error_message = traceback.format_exc()

        with open("alert.log", "a") as f:
            f.write(error_message + "\n")

        logger.error("ETL failed")
        raise