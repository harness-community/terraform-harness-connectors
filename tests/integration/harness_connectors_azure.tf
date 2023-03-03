####################
#
# Harness Connectors Azure Validations
#
####################
locals {
  connectors_azure_outputs = flatten([
    {
      minimum                       = module.connector_azure_cloud_minimal.connector_details
      delegate_system               = module.connector_azure_cloud_delegate_system.connector_details
      delegate_user                 = module.connector_azure_cloud_delegate_user.connector_details
      service_principal_secret      = module.connector_azure_cloud_service_principal_secret.connector_details
      service_principal_certificate = module.connector_azure_cloud_service_principal_cert.connector_details
    }
  ])
}

module "connector_azure_cloud_minimal" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/azure/cloud"

  name                = "test-azure-cloud-minimal"
  organization_id     = local.organization_id
  project_id          = local.project_id
  delegate_selectors  = ["account"]
  execute_on_delegate = true
  azure_credentials = {
    type = "delegate"
  }
  global_tags = local.common_tags

}

module "connector_azure_cloud_delegate_system" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/azure/cloud"

  name                = "test-azure-cloud-delegate-system"
  organization_id     = local.organization_id
  project_id          = local.project_id
  delegate_selectors  = ["account"]
  execute_on_delegate = true
  azure_credentials = {
    type          = "delegate"
    delegate_auth = "system"
  }
  global_tags = local.common_tags

}

module "connector_azure_cloud_delegate_user" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/azure/cloud"

  name                = "test-azure-cloud-delegate-user"
  organization_id     = local.organization_id
  project_id          = local.project_id
  delegate_selectors  = ["account"]
  execute_on_delegate = true
  azure_credentials = {
    type          = "delegate"
    delegate_auth = "user"
    client_id     = "00000000-0000-0000-0000-000000000000"
  }
  global_tags = local.common_tags

}

module "connector_azure_cloud_service_principal_secret" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/azure/cloud"

  name            = "test-azure-cloud-service-principal-secret"
  organization_id = local.organization_id
  project_id      = local.project_id
  azure_credentials = {
    type            = "service_principal"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    client_id       = "00000000-0000-0000-0000-000000000000"
    secret_kind     = "secret"
    secret_location = "project"
    secret_name     = local.test_secret_name

  }
  global_tags = local.common_tags

}

module "connector_azure_cloud_service_principal_cert" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/azure/cloud"

  name            = "test-azure-cloud-service-principal-cert"
  organization_id = local.organization_id
  project_id      = local.project_id
  azure_credentials = {
    type            = "service_principal"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    client_id       = "00000000-0000-0000-0000-000000000000"
    secret_kind     = "certificate"
    secret_location = "project"
    secret_name     = local.test_secret_name

  }
  global_tags = local.common_tags

}
