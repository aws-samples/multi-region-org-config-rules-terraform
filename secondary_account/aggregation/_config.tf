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
# set up the  Config Recorder
# -----------------------------------------------------------
resource "aws_config_configuration_recorder" "config_recorder" {
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ConfigRecorderRole"
}