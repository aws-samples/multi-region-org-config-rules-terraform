# Get current region of Terraform stack
data "aws_region" "current" {}

# Get current account number
data "aws_caller_identity" "current" {}

# Retrieves the partition that it resides in
data "aws_partition" "current" {}

data "aws_iam_policy_document" "config-role-document" {
  statement {
    sid         = var.config-sid
    effect      = var.config-effect
    actions     = var.config-actions
    principals {
      type = var.config-principal-type
      identifiers = var.config-principal-identifier
    }
  }
}

data "aws_iam_policy_document" "s3-config-document" {
  statement {
    sid         = var.s3-permcheck-logging-sid
    effect      = var.s3-permcheck-logging-effect
    actions     = var.s3-permcheck-logging-actions
    resources   = ["arn:${data.aws_partition.current.partition}:s3:::${var.config_bucket}",]
    principals {
      type = var.s3-logging-principal-type
      identifiers = var.s3-logging-identifier
    }
  }

  statement {
    sid         = var.s3-delivery-logging-sid
    effect      = var.s3-deliver-logging-effect
    actions     = var.s3-delivery-logging-actions
    resources   = ["arn:${data.aws_partition.current.partition}:s3:::${var.config_bucket}/AWSLogs/*/*",]
    principals {
      type = var.s3-logging-principal-type
      identifiers = var.s3-logging-identifier
    }
  }
}