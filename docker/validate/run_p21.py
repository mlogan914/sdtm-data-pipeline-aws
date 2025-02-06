import os
import time
import boto3
from botocore.exceptions import NoCredentialsError

# Function to simulate the Pinnacle 21 validation
def simulate_p21_validation(input_file):
    print(f"Running Pinnacle 21 Validation on {input_file}...")
    time.sleep(3)

    # Placeholder result
    validation_report = f"Validation report for {input_file}\n\n"
    validation_report += "----------------------------------\n"
    validation_report += "Pinnacle 21 Validation Result (Placeholder)\n"
    validation_report += "----------------------------------\n"
    validation_report += "Status: PASS\n"
    validation_report += f"Comments: Validation simulated for {input_file}\n"
    
    return validation_report

# Upload report to S3
def upload_report_to_s3(report, bucket_name, object_key):
    # Initialize the S3 client
    s3_client = boto3.client('s3')
    
    try:
        # Upload the report to the S3 bucket
        s3_client.put_object(Bucket=bucket_name, Key=object_key, Body=report)
        print(f"Validation report successfully uploaded to S3: {bucket_name}/{object_key}")
    except NoCredentialsError:
        print("Credentials not available for AWS S3.")
    except Exception as e:
        print(f"Error uploading report to S3: {str(e)}")

# Function to copy a file from oper bucket to output bucket
def copy_file_between_buckets(source_bucket, source_key, destination_bucket, destination_key):
    # Initialize the S3 client
    s3_client = boto3.client('s3')

    try:
        # Copy files
        copy_source = {'Bucket': source_bucket, 'Key': source_key}
        s3_client.copy_object(CopySource=copy_source, Bucket=destination_bucket, Key=destination_key)
        print(f"File successfully copied from {source_bucket}/{source_key} to {destination_bucket}/{destination_key}")
    except NoCredentialsError:
        print("Credentials not available for AWS S3.")
    except Exception as e:
        print(f"Error copying file between S3 buckets: {str(e)}")

# Function to list and copy files with specific extensions
def copy_files_with_extensions(source_bucket, destination_bucket, extensions):
    s3_client = boto3.client('s3')
    
    try:
        # List all objects in the oper bucket
        response = s3_client.list_objects_v2(Bucket=source_bucket)
        
        if 'Contents' in response:
            for obj in response['Contents']:
                source_key = obj['Key']
                # Check if the file has one of the specified extensions
                if any(source_key.endswith(ext) for ext in extensions):
                    # Define the destination key (could be the same or different)
                    destination_key = source_key  # You can modify this path if needed
                    
                    # Copy the file to the output bucket
                    copy_file_between_buckets(source_bucket, source_key, destination_bucket, destination_key)
                else:
                    print(f"Skipping file (invalid extension): {source_key}")
        else:
            print(f"No files found in {source_bucket}.")
    
    except Exception as e:
        print(f"Error listing files in the source bucket: {str(e)}")

def main():
    # Sample input file (placeholder for actual input file like dm.csv)
    input_file = "/data/dm.xpt" 

    # Simulate the P21 validation check
    report = simulate_p21_validation(input_file)

    # Define the S3 bucket and object key (S3 file path) for the report
    report_bucket_name = 'audit-5201201'
    report_object_key = 'p21_reports/p21_validation_report.txt'

    # Upload the report to S3
    upload_report_to_s3(report, report_bucket_name, report_object_key)

    # Define the source and destination buckets for file copy
    source_bucket = 'oper-5201201'
    destination_bucket = 'output-5201201'
    
    # Define the extensions to filter files (CSV, Parquet, XPT)
    extensions = ['.csv', '.parquet', '.xpt']

    # Copy files with specified extensions
    copy_files_with_extensions(source_bucket, destination_bucket, extensions)

if __name__ == "__main__":
    main()