# Get current region of Terraform stack
data "aws_region" "current" {}

# Get current account number
data "aws_caller_identity" "current" {}

# Retrieves the partition that it resides in
data "aws_partition" "current" {}