####################
#
# Harness Connector SCM GitHub Setup
#
####################
resource "harness_platform_connector_github" "github" {

  # [Required] (String) Unique identifier of the resource.
  identifier = local.fmt_identifier
  # [Required] (String) Name of the resource.
  name = var.name
  # [Optional] (String) Description of the resource.
  description = var.description
  # [Optional] (String) Unique identifier of the organization.
  org_id = var.organization_id
  # [Optional] (String) Unique identifier of the project.
  project_id = var.project_id
  # [Optional] (Set of String) Tags to filter delegates for connection.
  delegate_selectors = var.delegate_selectors

  # (String) URL of the Githubhub repository or account.
  url = var.url

  # [Required] (String) Whether the connection we're making is to a github repository or a github account. Valid values are Account, Repo.
  connection_type = title(var.type)

  # [Optional] (String) Repository to test the connection with. This is only used when connection_type is Account.
  validation_repo = var.validation_repo

  # [Required] (Block List, Min: 1, Max: 1) Credentials to use for the connection.
  dynamic "credentials" {
    for_each = [var.github_credentials]
    content {
      # Github connection block
      # Conditionally executed when the credential.type == "http"
      dynamic "http" {
        for_each = lower(lookup(credentials.value, "type", "http")) == "http" ? [1] : []
        content {
          # [Required] (String) Username to use for authentication.
          username = (
            lookup(credentials.value, "is_user_secret", false)
            ?
              null
            :
              lookup(credentials.value, "username", null)
          )
          # [Required] (String) Reference to a secret containing the personal access to use for authentication.
          token_ref = (
            lookup(credentials.value, "secret_location", "project") != "project"
            ?
              "${credentials.value.secret_location}.${lower(replace(credentials.value.password, " ", ""))}"
            :
              lower(replace(credentials.value.password, " ", ""))
          )

          # [Optional] (String) Reference to a secret containing the username to use for authentication.
          username_ref = (
            lookup(credentials.value, "is_user_secret", false)
            ?
              lookup(credentials.value, "secret_location", "project") != "project"
              ?
                "${credentials.value.secret_location}.${lower(replace(credentials.value.username, " ", ""))}"
              :
                lower(replace(credentials.value.username, " ", ""))
            :
              null
          )

        }
      }
      dynamic "ssh" {
        for_each = lower(lookup(credentials.value, "type", "http")) == "ssh" ? [1] : []
        content {
          # [Required] (String) Application ID of the Azure App.
          ssh_key_ref = (
              lookup(credentials.value, "secret_location", "project") != "project"
              ?
                "${credentials.value.secret_location}.${lower(replace(credentials.value.ssh_key, " ", ""))}"
              :
                lower(replace(credentials.value.ssh_key, " ", ""))
          )
        }
      }
    }
  }

  # [Optional] (Block List, Max: 1) Configuration for using the github api. API Access is required for using “Git Experience”, for creation of Git based triggers, Webhooks management and updating Git statuses.
  dynamic "api_authentication" {
    for_each = (
      lookup(var.api_credentials, "type", null) == "token"
      ?
      [var.api_credentials]
      :
      []
    )
    content {
      token_ref = (
        lookup(api_authentication.value, "token_location", "project") != "project"
        ?
          "${api_authentication.value.token_location}.${lower(replace(api_authentication.value.token_name, " ", ""))}"
        :
          lower(replace(api_authentication.value.token_name, " ", ""))
      )
    }
  }
  dynamic "api_authentication" {
    for_each = (
      lookup(var.api_credentials, "type", null) == "github_app"
      ?
      [var.api_credentials]
      :
      []
    )
    content {
      github_app {
        # [Required] (String) Enter the GitHub App ID from the GitHub App General tab.
        application_id = api_authentication.value.application_id
        # [Required] (String) Enter the Installation ID located in the URL of the installed GitHub App.
        installation_id = api_authentication.value.installation_id
        # [Required] (String) Reference to the secret containing the private key. To reference a secret at the organization scope,
        # prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
        private_key_ref = (
          lookup(api_authentication.value, "private_key_location", "project") != "project"
          ?
            "${api_authentication.value.private_key_location}.${lower(replace(api_authentication.value.private_key, " ", ""))}"
          :
            lower(replace(api_authentication.value.private_key, " ", ""))
        )
      }
    }
  }

  # [Optional] (Set of String) Tags to associate with the resource.
  tags = local.common_tags

}

# When creating a new Connector, there is a potential race-condition
# as the connector comes up.  This resource will introduce
# a slight delay in further execution to wait for the resources to
# complete.
resource "time_sleep" "connector_setup" {
  depends_on = [
    harness_platform_connector_github.github
  ]

  create_duration  = "15s"
  destroy_duration = "15s"
}
