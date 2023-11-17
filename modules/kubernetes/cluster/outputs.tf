####################
#
# Harness Connector Kubernetes Cluster Outputs
#
####################
# 2023-11-16
# This output is now deprecated and replaced by the output
# labeled `details`
# output "connector_details" {
#   depends_on = [
#     time_sleep.connector_setup
#   ]
#   value       = harness_platform_connector_kubernetes.cluster
#   description = "Details for the created Harness Connector"
# }

output "details" {
  depends_on = [
    time_sleep.connector_setup
  ]
  value       = harness_platform_connector_kubernetes.cluster
  description = "Details for the created Harness Connector"
}
