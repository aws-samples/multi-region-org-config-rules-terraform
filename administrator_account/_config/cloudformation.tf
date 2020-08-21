resource "aws_cloudformation_stack" "conformance_stack" {
  depends_on = [ aws_sns_topic.config_updates, aws_config_delivery_channel.config_channel ]
  name       = "CompliancePack-Stack-${data.aws_region.current.name}"

  parameters = {
    SnsTopicForPublishNotificationArn = aws_sns_topic.config_updates.arn
  }

  template_body = file("${path.module}/templates/dynamodb-rules.yml")
}

resource "aws_sns_topic" "config_updates" {
  name              = "config-updates-topic"
  kms_master_key_id = "alias/aws/sns"
}