import pandas as pd
from datetime import datetime
import pyarrow as pa
import pyarrow.parquet as pq
import pyreadstat
import boto3
from datetime import datetime

# Test write permissions to /tmp
try:
    test_file = '/tmp/test.txt'
    with open(test_file, 'w') as f:
        f.write('This is a test file.')

    print(f"Test file successfully written to {test_file}")
except Exception as e:
    print(f"Failed to write to /tmp: {e}")


# Initialize S3 client
s3 = boto3.client('s3')

# Set S3 bucket name
bucket_name = 'oper-5201201'

# Read the raw CSV data, ensuring all columns are read as strings
df = pd.read_csv('raw_dm.csv', dtype=str)

# Function to transform the data
def transform_data(df):
    # Define the study constants
    study = "VEXIN - Evaluation of Pelvinexinol in Endometriosis"
    studyid = "VEXIN-03"
    datapagename = "Demographics"
    location = "USA"
    
    # Map races
    race_map = {
        'Black/African American': 'BLACK OR AFRICAN AMERICAN',
        'Native American/Alaskan Native': 'AMERICAN INDIAN OR ALASKA NATIVE',
        'Native Hawaiian/Pacific Islander': 'NATIVE HAWAIIAN OR PACIFIC ISLANDER',
        'Other': lambda x: f'OTHER: {x}',  # if race is "Other", map the "race_other" field
        'Multi-racial': 'MULTIPLE',
        'White/Caucasian': 'WHITE'
    }

    # Ensure siteid has leading zeros and create USUBJID
    df['siteid'] = df['siteid'].apply(lambda x: f"{int(x):02d}")  # Ensure siteid is 2 digits with leading zeros

    # Create USUBJID
    df['USUBJID'] = df.apply(lambda row: f"{row['siteid']}-{row['subject']}" if pd.isna(row['prevsubj']) or row['prevsubj'] == '' else f"{row['siteid']}-{row['prevsubj']}", axis=1)

    # Map SEX to "M" or "F"
    df['SEX'] = df['sex'].apply(lambda x: 'M' if x == 'Male' else 'F' if x == 'Female' else 'U')

    # Apply race mapping, handle 'Other' case
    df['RACE'] = df.apply(lambda row: race_map[row['race']] if row['race'] != 'Other' else race_map['Other'](row['race_other']), axis=1)

    # Upcase ETHNIC
    df['ETHNIC'] = df['ethnic'].str.upper()

    # Convert date columns to ISO8601 format and string type
    df['BRTHDT'] = pd.to_datetime(df['brthdat']).dt.strftime('%Y-%m-%d')
    df['DMDTC'] = pd.to_datetime(df['recorddate']).dt.strftime('%Y-%m-%d')
    df['RFICDTC'] = pd.to_datetime(df['icdat']).dt.strftime('%Y-%m-%d')
    df['RFSTDTC'] = pd.to_datetime(df['startdat']).dt.strftime('%Y-%m-%d')
    df['RFENDTC'] = pd.to_datetime(df['enddat']).dt.strftime('%Y-%m-%d')
    df['RFXSTDTC'] = pd.to_datetime(df['startdat']).dt.strftime('%Y-%m-%d')
    df['RFXENDTC'] = pd.to_datetime(df['enddat']).dt.strftime('%Y-%m-%d')
    df['RFPENDTC'] = pd.to_datetime(df['rfpendtc']).dt.strftime('%Y-%m-%d')

    # Create DM data in CDISC format
    transformed_df = pd.DataFrame({
        'STUDYID': [studyid] * len(df),
        'DOMAIN': ['DM'] * len(df),
        'USUBJID': df['USUBJID'],
        'RFSTDTC': df['RFSTDTC'],
        'RFENDTC': df['RFENDTC'],
        'RFXSTDTC': df['RFXSTDTC'],
        'RFXENDTC': df['RFXENDTC'],
        'RFICDTC': df['RFICDTC'],
        'RFPENDTC': df['RFPENDTC'],
        'DTHDTC': df['dthdat'],
        'DTHFL': df['dthfl'],
        'SITEID': df['siteid'],
        'BRTHDTC': df['BRTHDT'],
        'AGE': df['age'],
        'AGEU': df['ageu'],
        'SEX': df['SEX'],
        'RACE': df['RACE'],
        'ETHNIC': df['ETHNIC'],
        'ARMCD': df['armcd'],
        'ARM': df['arm'],
        'ACTARMCD': df['actarmcd'],
        'ACTARM': df['actarm'],
        'ARMNRS': df['armnrs'],
        'COUNTRY': [location] * len(df),
        'DMDTC': df['DMDTC']
    })

    return transformed_df

# Transform the data
transformed_df = transform_data(df)

# Output the transformed data to CSV
transformed_df.to_csv('/tmp/dm.csv', index=False)

# Output the transformed data to Parquet
table = pa.Table.from_pandas(transformed_df)
pq.write_table(table, '/tmp/dm.parquet')

# Output the transformed data to XPT format
pyreadstat.write_xport(transformed_df, '/tmp/dm.xpt')

# Upload files to S3
s3.upload_file('/tmp/dm.csv', bucket_name, 'dm.csv')
s3.upload_file('/tmp/dm.parquet', bucket_name, 'dm.parquet')
s3.upload_file('/tmp/dm.xpt', bucket_name, 'dm.xpt')

print("Data transformation complete and saved in CSV, Parquet, and XPT formats.")

### -- End of Program Code -- ###