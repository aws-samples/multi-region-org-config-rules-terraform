resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_channel]
}

# Delivery channel resource and bucket location to specify configuration history location.
resource "aws_config_delivery_channel" "config_channel" {
  name           = "${data.aws_region.current.name}-channel"
  s3_bucket_name = var.config_bucket
  depends_on = [aws_config_configuration_recorder.config_recorder]
}


# -----------------------------------------------------------
# set up the  Config Recorder
# -----------------------------------------------------------
resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "${data.aws_region.current.name}-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# -----------------------------------------------------------
# set up the  Config Authorization for Aggregation
# -----------------------------------------------------------
resource "aws_config_aggregate_authorization" "security_authorization" {
  account_id = var.security_account_number
  region     = var.region
}

# -----------------------------------------------------------
# set up the  Config Rules
# -----------------------------------------------------------

# Config Rule is set up on a count based on the number of managed rules that exist within the 
# rules variable list. The input_parameters field looks for the input_parameters variable
# and looks for the corresponding managed rule name.
resource "aws_config_config_rule" "config_rule" {
  count             = length(var.rules)
  depends_on        = [
    aws_config_configuration_recorder.config_recorder
  ]

  input_parameters = lookup(var.input_parameters, element(var.rules, count.index), "")
  name              = element(var.rules, count.index)

  source {
    owner             = "AWS"
    source_identifier = lookup(var.source_identifiers, element(var.rules, count.index))
  }
}