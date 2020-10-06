resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_channel]
}

# Delivery channel resource and bucket location to specify configuration history location.
resource "aws_config_delivery_channel" "config_channel" {
  s3_bucket_name = aws_s3_bucket.new_config_bucket.id
  depends_on = [aws_config_configuration_recorder.config_recorder]
}


# -----------------------------------------------------------
# set up the Config Recorder
# -----------------------------------------------------------
resource "aws_config_configuration_recorder" "config_recorder" {
  role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.config_role_name}"

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# -----------------------------------------------------------
# Set up Organization Config Rules
# -----------------------------------------------------------

# AWS Config Rule that manages IAM Password Policy
resource "aws_config_organization_managed_rule" "iam_policy_organization_config_rule" {
  count = data.aws_region.current.name == var.primary_region ? 1 : 0
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  input_parameters  = lookup(var.password_parameters, "iam-password-policy", "")
  name              = "iam-password-policy"
  rule_identifier   = "IAM_PASSWORD_POLICY"
}

# AWS Config Rule that manages IAM Root Access Keys to see if they exist
resource "aws_config_organization_managed_rule" "iam_root_access_key_organization_config_rule" {
  count = data.aws_region.current.name == var.primary_region ? 1 : 0
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  name              = "iam-root-access-key-check"
  rule_identifier   = "IAM_ROOT_ACCESS_KEY_CHECK"
}

# AWS Config Rule that checks whether your AWS account is enabled to use multi-factor authentication (MFA) 
# hardware device to sign in with root credentials.
resource "aws_config_organization_managed_rule" "root_hardware_mfa_organization_config_rule" {
  count = data.aws_region.current.name == var.primary_region ? 1 : 0
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  name              = "root-hardware-mfa"
  rule_identifier   = "ROOT_ACCOUNT_HARDWARE_MFA_ENABLED"
}

# AWS Config Rule that checks whether users of your AWS account require a multi-factor authentication (MFA) 
# device to sign in with root credentials.
resource "aws_config_organization_managed_rule" "root_account_mfa_organization_config_rules" {
  count = data.aws_region.current.name == var.primary_region ? 1 : 0
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  name              = "root-account-mfa-enabled"
  rule_identifier   = "ROOT_ACCOUNT_MFA_ENABLED"
}


# AWS Config Rule that checks whether the required public access block settings are configured from account level. 
# The rule is only NON_COMPLIANT when the fields set below do not match the corresponding fields in the configuration 
# item.
resource "aws_config_organization_managed_rule" "s3_public_access_organization_config_rules" {
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  name              = "s3-account-level-public-access-blocks"
  rule_identifier   = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
}

# AWS Config Rule that checks whether logging is enabled for your S3 buckets.
resource "aws_config_organization_managed_rule" "s3_bucket_logging_organization_config_rules" {
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  name              = "s3-bucket-logging-enabled"
  rule_identifier   = "S3_BUCKET_LOGGING_ENABLED"
}

# AWS Config Rule that checks whether logging is enabled for your S3 buckets.
resource "aws_config_organization_managed_rule" "s3_bucket_encryption_organization_config_rules" {
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  name              = "s3-bucket-server-side-encryption-enabled"
  rule_identifier   = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
}
