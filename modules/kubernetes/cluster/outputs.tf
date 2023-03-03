####################
#
# Harness Connector Kubernetes Cluster Outputs
#
####################
output "connector_details" {
  depends_on = [
    time_sleep.connector_setup
  ]
  value       = harness_platform_connector_kubernetes.cluster
  description = "Details for the created Harness Connector"
}
