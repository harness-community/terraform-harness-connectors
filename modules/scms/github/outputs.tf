####################
#
# Harness Connector SCM GitHub Outputs
#
####################
# 2023-03-16
# This output is being deprecated and replaced by the output
# labeled `details`
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
