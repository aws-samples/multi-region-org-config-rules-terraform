output "config_aggregator_arn" {
    value = aws_config_configuration_aggregator.organization.arn 
    description = "AWS Config Aggregator ARN"
}