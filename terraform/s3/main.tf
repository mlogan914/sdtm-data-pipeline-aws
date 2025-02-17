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
# Operational Bucket
# ----------------------------------------
resource "aws_s3_bucket" "oper-bucket" {
  bucket = var.oper_bucket_name

  tags = var.tags
}

# Operational Bucket policy (Grant ECS Task Role access)
resource "aws_s3_bucket_policy" "oper-bucket-policy" {
  bucket = aws_s3_bucket.oper-bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.oper-bucket.arn}/*"
        Principal = {
          "AWS" = "${var.ecs_task_execution_role_arn}"
        }
      },
      {
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = "${aws_s3_bucket.oper-bucket.arn}"
        Principal = {
          "AWS" = "${var.ecs_task_execution_role_arn}"
        }
      }
    ]
  })
}

# ----------------------------------------
# Audit Bucket
# ----------------------------------------
resource "aws_s3_bucket" "audit-bucket" {
  bucket = var.audit_bucket_name

  tags = var.tags
}

# Audit Bucket policy
resource "aws_s3_bucket_policy" "audit-bucket-policy" {
  bucket = aws_s3_bucket.audit-bucket.id

  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Effect"    = "Allow"
        "Action"    = "s3:PutObject"
        "Resource"  = "${aws_s3_bucket.audit-bucket.arn}/*"
        "Principal" = {
          "Service" = "ecs-tasks.amazonaws.com"
        }
        "Condition" = {
          "StringEquals" = {
            "aws:RequestedRegion" = "${var.region}"
          }
        }
      }
    ]
  })
}

# ----------------------------------------
# Output Bucket
# ----------------------------------------
resource "aws_s3_bucket" "output-bucket" {
  bucket = var.output_bucket_name

  tags = var.tags
}

# Output Bucket policy
resource "aws_s3_bucket_policy" "output-bucket-policy" {
  bucket = aws_s3_bucket.output-bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.output-bucket.arn}/*", # Allow write to output s3
        "Principal": {
          "AWS": "${var.ecs_task_execution_role_arn}"  
        },
        "Condition": {
          "StringEquals": {
            "aws:RequestedRegion": "${var.region}" 
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.output-bucket.arn}/*"
      }
    ]
  })
}

# ----------------------------------------
# Appdata Bucket
# ----------------------------------------
resource "aws_s3_bucket" "appdata-bucket" {
  bucket = var.appdata_bucket_name

  tags = var.tags
}

# ----------------------------------------
# Athena Query Results Bucket
# ----------------------------------------
resource "aws_s3_bucket" "query-results-bucket" {
  bucket = var.query_results_bucket_name

  tags = var.tags
}

# Athena Query Bucket policy
resource "aws_s3_bucket_policy" "athena_results_policy" {
  bucket = aws_s3_bucket.query-results-bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "athena.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.query-results-bucket.arn}/*"
      },
      {
        Effect    = "Allow",
        Principal = {
          Service = "athena.amazonaws.com"
        },
        Action   = "s3:ListBucket",
        Resource = "${aws_s3_bucket.query-results-bucket.arn}"
      }
    ]
  })
}

# ----------------------------------------
# S3 Access Point
# ----------------------------------------
resource "aws_s3_access_point" "s3_access_point" {
  bucket = aws_s3_bucket.appdata-bucket.id
  name   = var.s3_access_point_name
}

# ==================================================
#   S3 Object Lambda Access Point
# ==================================================
#
#   NOTE: If using prebuilt Lambda functions, deploy them first, 
#         then provide the function ARN in root module.
#
#   Documentation:
#   - S3 Object Lambda: https://docs.aws.amazon.com/AmazonS3/latest/userguide/olap-examples.html
#   - PII Entity Types: https://docs.aws.amazon.com/comprehend/latest/dg/how-pii.html
#   - Amazon Comprehend Regions: https://docs.aws.amazon.com/general/latest/gr/comprehend.html
# ==================================================
resource "aws_s3control_object_lambda_access_point" "s3_object_lambda_access_point" {
  name = var. s3_object_lambda_access_point_name

  configuration {
    supporting_access_point = aws_s3_access_point.s3_access_point.arn

    transformation_configuration {
      actions = ["GetObject"]

      content_transformation {
        aws_lambda {
          function_arn = "${var.s3_object_lambda_access_point_arn}" # Using prebuilt function
        }
      }
    }
  }
}

