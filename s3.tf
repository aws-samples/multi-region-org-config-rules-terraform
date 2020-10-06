resource "aws_s3_bucket" "new_config_bucket" {
  bucket = var.config_bucket
  acl    = "private"

  dynamic "server_side_encryption_configuration" {
    for_each = var.encryption_enabled ? ["true"] : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "config_logging_policy" {
  bucket = aws_s3_bucket.new_config_bucket.id

  policy = data.aws_iam_policy_document.s3-config-document.json
}