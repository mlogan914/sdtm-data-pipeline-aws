# =============================================================
# AWS S3 Configuration
# This file provisions S3 buckets for data storage and logging.
# =============================================================

# ----------------------------------------
# Landing Bucket
# ----------------------------------------
resource "aws_s3_bucket" "raw-prd-bucket" {
  bucket = var.raw_bucket_name

  tags = var.tags
}

# Landing Bucket Policy
resource "aws_s3_bucket_policy" "raw-prd-bucket-policy" {
  bucket = aws_s3_bucket.raw-prd-bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "glue.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.raw-prd-bucket.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : "${aws_s3_bucket.raw-prd-bucket.arn}/*"
      }
    ]
  })
}

# Allow S3 to invoke Lambda function
resource "aws_lambda_permission" "allow_s3_invocation" {
  statement_id  = "AllowS3Invocation"
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  function_name = var.lambda_function_name
  source_arn    = aws_s3_bucket.raw-prd-bucket.arn
}

# Landing Bucket S3 Event Notification
resource "aws_s3_bucket_notification" "landing_bucket_notification" {
  bucket = aws_s3_bucket.raw-prd-bucket.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invocation # Ensure permission is applied before the notification
  ]
}
# ----------------------------------------
# Scripts Bucket
# ----------------------------------------
resource "aws_s3_bucket" "scripts-bucket" {
  bucket = var.scripts_bucket_name

  tags = var.tags
}

# Scripts Bucket Policy
resource "aws_s3_bucket_policy" "scripts-bucket-policy" {
  bucket = aws_s3_bucket.scripts-bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "glue.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.scripts-bucket.arn}/*"
      },

    ]
  })
}
# ----------------------------------------
# Output Bucket
# ----------------------------------------