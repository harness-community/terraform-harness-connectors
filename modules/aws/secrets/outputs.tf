####################
#
# Harness Connector AWS Secrets Manager Outputs
#
####################
output "details" {
  depends_on = [
    time_sleep.connector_setup
  ]
  value       = harness_platform_connector_aws_secret_manager.aws
  description = "Details for the created Harness AWS Secrets Manager Connector"
}
