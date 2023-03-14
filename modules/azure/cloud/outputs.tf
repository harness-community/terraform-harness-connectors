####################
#
# Harness Connector Azure Cloud Outputs
#
####################
output "connector_details" {
  depends_on = [
    time_sleep.connector_setup
  ]
  value       = harness_platform_connector_azure_cloud_provider.azure
  description = "Details for the created Harness Connector"
}
