# =============================================================
# AWS Glue Configuration
# This provisions Glue resources for the pipeline.
# =============================================================

# ---------------------------------------
# Create Database
# ---------------------------------------
resource "aws_glue_catalog_database" "glue_database" {
  name = "metadata_repository"
}
# ---------------------------------------
# Create Crawler
# ---------------------------------------

# Raw/Landing bucket crawler
# TODO: Rename this to raw_crawler
resource "aws_glue_crawler" "glue_crawler" {
  name          = "crawler-5201201"
  role          = aws_iam_role.glue_service_role.arn
  database_name = aws_glue_catalog_database.glue_database.name

  # Define Datata Sources
  s3_target {
    path = "s3://${var.raw_bucket_name}"
  }
}

# Output bucket crawler
resource "aws_glue_crawler" "output_crawler" {
  name          = "output-crawler-5201201"
  role          = aws_iam_role.glue_service_role.arn
  database_name = aws_glue_catalog_database.glue_database.name

  # Define Datata Sources
  s3_target {
    path = "s3://${var.output_bucket_name}"
  }
}

# ---------------------------------------
# Glue Job Script
# ---------------------------------------
resource "aws_s3_object" "glue_script" {
  bucket = var.scripts_bucket_name
  key    = "glue_data_quality.py"
  source = "./glue/glue_data_quality.py"
}

# ---------------------------------------
# Create Data Quality Job
# ---------------------------------------
resource "aws_glue_job" "data_quality_job" {
  name              = "data-quality-job-5201201"
  role_arn          = aws_iam_role.glue_service_role.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    script_location = "s3://${var.scripts_bucket_name}/glue_data_quality.py"
  }
}

