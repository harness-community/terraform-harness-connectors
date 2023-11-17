####################
#
# Harness Connector AWS Cloud Outputs
#
####################
output "details" {
  depends_on = [
    time_sleep.connector_setup
  ]
  value       = harness_platform_connector_aws.aws
  description = "Details for the created Harness AWS Connector"
}
