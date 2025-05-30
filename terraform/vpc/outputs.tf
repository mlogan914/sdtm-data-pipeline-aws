# ================================================================
# VPC Module - Outputs
# 
# This file defines outputs from the VPC module.
# ===============================================================

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}