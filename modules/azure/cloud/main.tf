####################
#
# Harness Connector Azure Cloud Setup
#
####################
resource "harness_platform_connector_azure_cloud_provider" "azure" {

  # [Required] (String) Unique identifier of the resource.
  identifier = local.fmt_identifier
  # [Required] (String) Name of the resource.
  name = var.name

  # [Optional] (String) Specifies the Azure Environment type, which is AZURE by default. Can either be AZURE or AZURE_US_GOVERNMENT
  azure_environment_type = local.azure_environment_type
  # [Optional] (Set of String) Tags to filter delegates for connection.
  delegate_selectors = var.delegate_selectors
  # [Optional] (String) Description of the resource.
  description = var.description
  # [Optional] (Boolean) Execute on delegate or not.
  execute_on_delegate = var.execute_on_delegate
  # [Optional] (String) Unique identifier of the organization.
  org_id = var.organization_id
  # [Optional] (String) Unique identifier of the project.
  project_id = var.project_id
  # [Optional] (Set of String) Tags to associate with the resource.
  tags = local.common_tags_tuple

  # [Required] (Block List, Min: 1, Max: 1) Contains Azure connector credentials.
  dynamic "credentials" {
    for_each = (
      var.azure_credentials != {}
      ?
      length(keys(var.azure_credentials)) > 0
      ?
      [var.azure_credentials]
      :
      []
      :
      []
    )

    # compact(flatten([var.azure_credentials]))
    content {
      type = (
        credentials.value.type == "delegate"
        ?
        "InheritFromDelegate"
        :
        "ManualConfig"
      )
      # Manual Azure connection block
      # Conditionally executed when the credential.type == "service_principal"
      dynamic "azure_manual_details" {
        for_each = lookup(credentials.value, "type", "delegate") == "service_principal" ? [1] : []
        content {
          # [Required] (String) The Azure Active Directory (AAD) directory ID where you created your application.
          tenant_id = credentials.value.tenant_id
          # [Required] (String) Application ID of the Azure App.
          application_id = credentials.value.client_id
          auth {
            # [Required] (String) Type can either be Certificate or Secret.
            type = title(credentials.value.secret_kind)
            dynamic "azure_client_key_cert" {
              for_each = lower(credentials.value.secret_kind) == "certificate" ? [credentials.value.secret_kind] : []
              content {
                # (String) Reference of the secret for the certificate.
                # To reference a secret at the organization scope:
                #  - prefix 'org' to the expression: org.{identifier}.
                # To reference a secret at the account scope:
                # - prefix 'account` to the expression: account.{identifier}.
                certificate_ref = (
                  lookup(credentials.value, "secret_location", "project") != "project"
                  ?
                  "${credentials.value.secret_location}.${lower(replace(credentials.value.secret_name, " ", ""))}"
                  :
                  lower(replace(credentials.value.secret_name, " ", ""))
                )
              }
            }
            dynamic "azure_client_secret_key" {
              for_each = lower(credentials.value.secret_kind) == "secret" ? [credentials.value.secret_kind] : []
              content {
                # (String) Reference of the secret for the secret key.
                # To reference a secret at the organization scope:
                #  - prefix 'org' to the expression: org.{identifier}.
                # To reference a secret at the account scope:
                #  - prefix 'account` to the expression: account.{identifier}.
                secret_ref = (
                  lookup(credentials.value, "secret_location", "project") != "project"
                  ?
                  "${credentials.value.secret_location}.${lower(replace(credentials.value.secret_name, " ", ""))}"
                  :
                  lower(replace(credentials.value.secret_name, " ", ""))
                )
              }
            }
          }
        }
      }
      # Delegate based Azure connection block
      # Conditionally executed when the credential.type == "delegate"
      dynamic "azure_inherit_from_delegate_details" {
        for_each = lookup(credentials.value, "type", "manual") == "delegate" ? [1] : []
        content {
          auth {
            # [Required] (String) Type can either be SystemAssignedManagedIdentity or UserAssignedManagedIdentity.
            type = (
              lookup(credentials.value, "delegate_auth", null) != null
              ?
              lookup({ system = "SystemAssignedManagedIdentity", user = "UserAssignedManagedIdentity" }, credentials.value.delegate_auth, "INVALID")
              :
              "SystemAssignedManagedIdentity"
            )
            dynamic "azure_msi_auth_ua" {
              for_each = compact(flatten([lookup(credentials.value, "client_id", "")]))
              content {
                # (String) Client Id of the ManagedIdentity resource.
                client_id = credentials.value.client_id
              }
            }
          }
        }
      }
    }
  }

}

# When creating a new Connector, there is a potential race-condition
# as the connector comes up.  This resource will introduce
# a slight delay in further execution to wait for the resources to
# complete.
resource "time_sleep" "connector_setup" {
  depends_on = [
    harness_platform_connector_azure_cloud_provider.azure
  ]

  create_duration  = "15s"
  destroy_duration = "15s"
}
