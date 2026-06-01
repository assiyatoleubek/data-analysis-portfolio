import boto3

bucket_name = "assiya-lab13-datastorage"
s3 = boto3.client('s3')

# создаем файл
with open("report.csv", "w") as f:
    f.write("id,value\n1,100\n2,200")

# загрузка
s3.upload_file(
    "report.csv",
    bucket_name,
    "uploads/report.csv",
    ExtraArgs={
        "Metadata": {
            "department": "analytics",
            "owner": "asiya"
        }
    }
)

print("Uploaded")

# скачивание
s3.download_file(
    bucket_name,
    "uploads/report.csv",
    "downloaded_report.csv"
)

# список файлов
paginator = s3.get_paginator('list_objects_v2')
for page in paginator.paginate(Bucket=bucket_name, Prefix="uploads/"):
    for obj in page.get("Contents", []):
        print(obj["Key"], obj["Size"], obj["LastModified"])

# presigned URL
url = s3.generate_presigned_url(
    "get_object",
    Params={"Bucket": bucket_name, "Key": "uploads/report.csv"},
    ExpiresIn=7200
)

print("URL:", url)

# удаление
s3.delete_object(Bucket=bucket_name, Key="uploads/report.csv")
print("Deleted")