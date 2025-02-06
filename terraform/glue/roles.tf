# Glue Service Role
resource "aws_iam_role" "glue_service_role" {
  name = "glue_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_policy" "glue_s3_policy" {
  name        = "GlueS3AccessPolicy"
  description = "Custom policy for S3 access for Glue crawlers"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": [
          "${var.raw_bucket_arn}/*",
          "${var.scripts_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Attach Custom Policy
resource "aws_iam_role_policy_attachment" "glue_role_attachment" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

# Attach Glue AWS Managed Policy
resource "aws_iam_role_policy_attachment" "glue_managed_policy_attachment" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}