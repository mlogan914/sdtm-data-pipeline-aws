# Automated SDTM Data Pipeline on AWS (Custom Script-Based)- Serverless

## Overview

This project presents a minimally viable concept pipeline that automates SDTM-compliant data transformation in clinical trial industries. It is designed to ingest raw clinical data from various sources, including Electronic Data Capture (EDC), labs, wearables, manual uploads, and APIs, converting it into CDISC SDTM datasets.

> **Context:** SDTM (Study Data Tabulation Model) is a standardized format for organizing human clinical trial data. Developed by CDISC (Clinical Data Interchange Standards Consortium), it's used to structure and submit trial data to regulatory agencies like the FDA (Food & Drug Administration) and PMDA (Pharmaceuticals and Medical Devices Agency). SDTM improves data consistency, traceability, and interoperability across studies.

---

## Tools & Technologies Used:
<div align="center">
  <img src="https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black" />
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white" />
  <img src="https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazon-aws&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Datadog-632CA6?style=flat&logo=datadog&logoColor=white" />
  <img src="https://img.shields.io/badge/VS_Code-0078d7?style=flat&logo=visual-studio-code&logoColor=white" />
  <img src="https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white" />
</div>


---

## Business Scenario:

### Evaluation of Pelvinexinol in Endometriosis (VEXIN-03) - Phase III Clinical Trial
**Objective:**
The VEXIN-03 clinical trial is designed to assess the efficacy and safety of Pelvinexinol, a pain medication for women with endometriosis in the United States. This study evaluates the medication’s impact on pain relief using clinical and Patient-Reported Outcomes (PRO) data. In addition to data collected at study sites, patients will also track key health metrics through external health apps.

### External Application Data Sources  

### 1. Patient-Reported Outcomes (PROs) from External Health Apps (Clue, Flo, MyPainDiary)
#### **Types of Data Collected**
- **Daily pain scores** (1-10 scale, different body areas)  
- **Menstrual cycle tracking** (flow, symptoms, duration)  
- **Mood and fatigue levels**  
- **Medication intake** (NSAIDs, hormonal treatments)  

#### **Privacy Considerations**
- Personally Identifiable Information (PII) risks include:  
  - **Names**  
  - **Emails**  
  - **Timestamps**  
  - **Location data** (if GPS tracking is enabled)

### 2. Wearable Device Data (Fitbit, Apple Health, Oura Ring)  
#### **Types of Data Collected**
- **Resting heart rate** (increases during pain episodes)  
- **Sleep disturbances** (insomnia, frequent awakenings)  
- **Step count & activity levels** (reduced during flare-ups)  

#### **Privacy Considerations**
- Personally Identifiable Information (PII) risks include: 
  - **Device ID**  
  - **User profiles**  
  - **Timestamps**  
  - **GPS coordinates**
  
**Requirements:**
1. **Data Ingestion & Integration** – The pipeline must unify disparate datasets into a single pipeline.
2. **Privacy & De-identification** – Some wearable device data will be excluded from SDTM tables but will need to be accessible to end users (e.g., medical monitors). PII must be masked while preserving raw device data for in-place querying, with granular access controls for different users.
3. **Standardization & Validation** – Site-collected patient data must be standardized across study sites and time points to generate SDTM datasets for clinical analysis using custom scripts.
4. **Data Access & Aggregation** – Statistical programmers and statisticians must be able to easily query and transform trial data to generate ad hoc reports.
5. **Automated Data Processing** – The pipeline should automate data collection, de-identification, transformation, and aggregation while handling updates from multiple study sites.
---
## Architecture Diagram
This pipeline is a fully serverless data processing framework built using AWS services to automate data transformation, integration, and data validation, eliminating infrastructure management while optimizing performance.

![diagram](architechture.png)
---
## Key Features

### Serverless AWS-Based Architecture
- **S3** – Stores raw, staged, final SDTM datasets, complicance reports, and logs.
- **Step Functions** – Orchestrates ingestion & processing, validation, and transformation workflows.
- **Glue** – Manages metadata, enforces data quality checks, and updates centralized metadata repositories.
- **ECS (Fargate)** – Runs SDTM transformation and validation scripts.
- **Lambda** – Handles event-driven workflows, metadata updates, and auxiliary tasks.
- **S3 Object Lambda** – Filters and redacts PII from patient-reported outcomes.
- **CloudWatch** – Provides real-time monitoring, logging, and alerts to track pipeline performance.
- **Athena** – Enables serverless SQL-based querying for end users.

### Infrastructure as Code (IaC)
- Terraform – Used for provisioning scalable, reusable, and automated pipeline infrastructure.

### Observability with Datadog
To ensure high observability, proactive issue detection, and streamlined debugging across this serverless architecture, Datadog was integrated into the pipeline.

- **AWS Integration** – Datadog receives logs, metrics, and traces from AWS services such as Lambda, ECS, Step Functions, and CloudWatch.
- **Log Forwarding** – Enables quick drill-down from metrics to raw logs for root cause analysis.
- **Alerting** – Custom monitors and thresholds trigger alerts.
- **Tagging & Tracing** – ECS and Lambda components include environment and pipeline-stage tags, allowing granular filtering and performance tracing.

📄[Datadog Integration Steps Document](docs/datadog_integration.md)

#### Directory Structure
```
├── data                                # Sample raw data
├── docker                              # Docker files + scripts for transform and validate
│   ├── transform                       # Transformation scripts
│   │   ├── dm.py                       # Sample SDTM transformation script for Demographics (DM)
│   │   ├── dockerfile                  # Transform task dockerfile
│   │   └── requirements.txt            # Transform dependencies
│   └── validate                        # Validation scripts
│       ├── dockerfile                  # Validate task dockerfile
│       └── run_p21.py                  # Sample P21 validation script
└── terraform                           # Terraform main folder
	├── athena                          # Athena module
	│   ├── main.tf                     # Athena configuration
	│   └── variables.tf                # Athena-related variables
	├── ecs                             # ECS module
	│   ├── main.tf                     # ECS configuration
	│   ├── outputs.tf                  # ECS outputs
	│   ├── roles.tf                    # IAM roles for ECS
	│   └── variables.tf                # ECS-related variables
	├── glue                            # AWS Glue module + scripts
	│   ├── glue_data_quality.py        # Data quality check script for Glue
	│   ├── main.tf                     # Glue configuration
	│   ├── outputs.tf                  # Glue outputs
	│   ├── roles.tf                    # IAM roles for Glue
	│   └── variables.tf                # Glue-related variables
	├── lambda                          # Lambda module + scripts
	│   ├── lambda_function.py          # Lambda function code
	│   ├── lambda_function.zip         # Zipped Lambda function for deployment
	│   ├── main.tf                     # Lambda configuration
	│   ├── outputs.tf                  # Lambda outputs
	│   └── roles.tf                    # IAM roles for Lambda
	├── main.tf                         # Terraform root module
	├── providers.tf                    # AWS provider configurations for Terraform
	├── s3                              # S3 module
	│   ├── main.tf                     # S3 configuration
	│   ├── outputs.tf                  # S3 outputs
	│   └── variables.tf                # S3-related variables
	├── sns                             # SNS module
	│   ├── main.tf                     # SNS configuration
	│   └── outputs.tf                  # SNS outputs
	├── step_functions                  # AWS Step Functions module
	│   ├── main.tf                     # Step Functions configuration
	│   ├── roles.tf                    # IAM roles for Step Functions
	│   └── variables.tf                # Step Functions-related variables
	├── terraform.tfstate               # Terraform state file (tracked remotely in production) [REDACTED]
	├── terraform.tfstate.backup        # Terraform state file backup [REDACTED]
	├── terraform.tfvars                # Terraform variables file
	├── variables.tf                    # Global Terraform variables
	└── vpc                             # VPC module
		├── main.tf                     # VPC configuration
		└── outputs.tf                  # VPC outputs
```
### Compliance Validation  
- Pinnacle21 (previously known as OpenCDISC) – is a widely used validation tool in the clinical research that provides automated SDTM compliance verification. 
- Pinnacle21 CLI – is integrated for CDISC compliance checks, to ensue SDTM datasets meet regulatory standards for submission.  

#### Platform Limitations & Workarounds  
> ⚠ **Note:** Pinnacle21 CLI **only supports Windows and macOS**, making it incompatible with Linux-based environments. Provisioning a Windows-based VM for validation is an alternative, but it undermines the fully serverless architecture design. A more efficient approach is to run Pinnacle21 on datasets externally from the pipeline.

To bypass this limitation, a placeholder script has been added to simulate a P21 validation run. This can be replaced with a custom validation solution in the future.  

### PII Redaction
When storing clinical datasets in Amazon S3 for use across multiple applications, it’s required to redact sensitive information.

How It Works

S3 Object Lambda Integration – When raw data is requested from S3, an S3 Object Lambda function intercepts the request and applies PII redaction exposing data to the requestor.

![diagram](object_lambda.png)

You can use the prebuilt Lambda function for PII redaction by attaching it to an S3 Object Lambda Access Point. When an application makes a standard S3 GET request, the access point triggers the Lambda function to detect and redact PII from the data. The redacted data is then returned to the application/requester.

### Metadata Management
**Centralized Data Catalog**

AWS Glue serves as a centralized metadata store, maintaining table schemas, dataset locations, and partitions for optimized queries. It detects and updates schemas dynamically to align with SDTM structures while enforcing schema integrity through validation checks. Glue metadata tables act as checkpoints for tracking pipeline progress and guiding downstream processes. Cataloged data is also queryable in Athena enabling quick validation.

### Error Handling & Data Quality
Errors are logged in CloudWatch, with SNS alerts for critical failures. Data quality checks might include duplicate detection, missing value validation, and range checks, with customization options. Outputs support CSV, Parquet, and XPT for compatibility.

### CI/CD

GitHub Actions automates deployment of transformation scripts to AWS ECS, enabling continuous integration and delivery.

---

## Pipeline Execution Flow

### 1. Initial Development Stage
#### Development Workflow
- Developers use UAT data to create and version base transformation scripts in GitHub.
- CI/CD pipelines ensure code updates are deployed to AWS ECS.

#### Code Deployment
- AWS ECS retrieves the latest transformation scripts from GitHub upon deployment.
---
### 2. Pipeline Trigger
#### Raw Data Arrival
- Raw production data is uploaded to a staging S3 bucket.
- An **S3 event notification** triggers an **AWS Lambda** function, which initiates **AWS Step Functions** to start the pipeline.
---
### 3. Data Quality Checks
#### AWS Glue Crawler
- Step Functions trigger an AWS Glue Crawler to crawl raw data and update the centralized metadata repository.

#### Quality Assurance
- AWS Glue Data Quality checks are executed on the raw data:
- **If checks fail**:
  - Notifications are sent via AWS SNS.
  - Processing stops until issues are resolved.
- **If checks pass**:
  - The pipeline proceeds to the next stage.
---
### 4. Data Transformation
#### Processing
- Step Functions trigger AWS ECS to execute transformation scripts on the raw data using custom code.

#### Version Control
- ECS tasks pull the latest version of scripts from GitHub for processing.
---
### 5. Pinnacle21 Compliance Checks
#### Validation
- Step Functions trigger AWS ECS to run Pinnacle21 CLI for CDISC compliance checks on the transformed datasets.

#### Outcome
- **If checks fail**:
  - Notifications are sent via AWS SNS.
  - Logs and reports are stored in the Audit S3 bucket for review.
- **If checks pass**:
  - Compliance reports and logs are saved in the Audit S3 bucket.
  - The pipeline proceeds to the output stage.
---
### 6. Output
#### Final Output
- Step Functions orchestrate the upload of transformed, SDTM-compliant datasets to the output S3 bucket in multiple formats:
  - CSV
  - Parquet
  - XPT
---
### 7. Metadata Updates
#### Destination Metadata
- Step Functions trigger an AWS Lambda function to update the metadata repository for the transformed datasets.
---
### 8. Data Analysis & Validation
#### Querying with Athena
- Amazon Athena is used to perform serverless SQL-based queries on the transformed SDTM datasets.
- End users (e.g., biostatisticians, statistical programmers etc.,) can validate data integrity, check compliance, and generate reports.
---
### 9. Data Access & PII Redaction (External to Step Functions Workflow)
#### S3 Object Lambda
- Wearable application data is ingested into an S3 bucket via custom scripts.
- When a requester accesses the data, S3 Object Lambda is invoked to dynamically filter and redact PII from patient-reported data.

---

## Pipeline Deployment
![diagram](deploy_pipeline.png)
---

## Step Functions Workflow
![diagram](stepfunctions_graph.png)

---

## Outcome
This design concept lays the foundation for automating data processing and compliance workflows in the pharma and medical device industries. It simplifies operations while ensuring high-quality, compliant datasets that meet CDISC standards.