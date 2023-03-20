####################
#
# Harness Connector SCM GitHub Outputs
#
####################
output "connector_details" {
  depends_on = [
    time_sleep.connector_setup
  ]
  value       = harness_platform_connector_github.github
  description = "Details for the created Harness Connector"
}

output "details" {
  depends_on = [
    time_sleep.connector_setup
  ]
  value       = harness_platform_connector_github.github
  description = "Details for the created Harness Connector"
}
