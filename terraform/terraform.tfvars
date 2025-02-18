region                             = "us-west-2"
raw_bucket_name                    = "raw-prd-5201201"
scripts_bucket_name                = "scripts-5201201"
oper_bucket_name                   = "oper-5201201"
audit_bucket_name                  = "audit-5201201"
output_bucket_name                 = "output-5201201"
appdata_bucket_name                = "appdata-5201201"
query_results_bucket_name          = "query-results-5201201"
s3_access_point_name               = "s3-access-point-5201201"
s3_object_lambda_access_point_name = "s3-object-lambda-access-point-5201201"
s3_object_lambda_access_point_arn  = "arn:aws:lambda:us-west-2:525425830681:function:serverlessrepo-ComprehendPiiR-PiiRedactionFunction-0JkwowHd0ZnO"

tags = {
  "Project"     = "SDTM-52012-01"
  "Description" = "SDTM Data Pipeline with CI/CD Integration"
}
