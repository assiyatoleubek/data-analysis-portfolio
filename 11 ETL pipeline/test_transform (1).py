import pandas as pd
from etl_pipeline import transform


def test_normal_input():
    df = pd.DataFrame({
        "email": ["test@gmail.com"],
        "gender": ["male"],
        "name.first": ["John"],
        "name.last": ["Doe"],
        "nat": ["US"],
        "dob.age": [25],
        "dob.date": ["2000-01-01"]
    })

    result = transform(df)

    assert result["email_domain"].iloc[0] == "gmail.com"
    assert result["age_group"].iloc[0] == "Young Adult"


def test_duplicates():
    df = pd.DataFrame({
        "email": ["a@test.com", "a@test.com"],
        "gender": ["male", "male"],
        "name.first": ["John", "John"],
        "name.last": ["Doe", "Doe"],
        "nat": ["US", "US"],
        "dob.age": [25, 25],
        "dob.date": ["2000-01-01", "2000-01-01"]
    })

    result = transform(df)

    assert len(result) == 1


def test_missing_email():
    df = pd.DataFrame({
        "email": [None],
        "gender": ["male"],
        "name.first": ["John"],
        "name.last": ["Doe"],
        "nat": ["US"],
        "dob.age": [25],
        "dob.date": ["2000-01-01"]
    })

    result = transform(df)

    assert result.empty


def test_empty_df():
    df = pd.DataFrame()

    result = transform(df)

    assert result.empty