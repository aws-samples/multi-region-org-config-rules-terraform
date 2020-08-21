resource "aws_config_aggregate_authorization" "config_aggregation" {
  account_id = var.source_account_number
  region = data.aws_region.current.name
}