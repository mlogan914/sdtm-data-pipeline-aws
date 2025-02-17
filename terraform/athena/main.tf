# =============================================================
# Athena Configuration
# This provisions Athena resources for querying output data
# =============================================================

# ---------------------------------------
# Create an Athena Workgroup
# ---------------------------------------
resource "aws_athena_workgroup" "athena_workgroup" {
  name = "athena-workgroup-5201201"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.query_results_bucket_name}/athena-results/"
    }
  }
}