####################
#
# Harness Connector Kubernetes Cluster Setup
#
####################
resource "harness_platform_connector_kubernetes" "cluster" {
  lifecycle {
    precondition {
      condition     = length(local.validate_credential_models) == 1
      error_message = <<EOF
      [Invalid] Only one of the following must be defined for the Connector - ${var.name}:
      - delegate_credentials: ${jsonencode(var.delegate_credentials)}
      - service_account_credentials: ${jsonencode(var.service_account_credentials)}
      - username_credentials: ${jsonencode(var.username_credentials)}
      - client_key_cert_credentials
      - openid_connect_credentials
      EOF
    }
  }
  # [Required] (String) Unique identifier of the resource.
  identifier = local.fmt_identifier
  # [Required] (String) Name of the resource.
  name = var.name
  # [Optional] (Set of String) Tags to filter delegates for connection.
  delegate_selectors = contains(local.validate_credential_models, "delegate") ? null : var.delegate_selectors

  # [Optional] (String) Description of the resource.
  description = var.description
  # [Optional] (String) Unique identifier of the organization.
  org_id = var.organization_id
  # [Optional] (String) Unique identifier of the project.
  project_id = var.project_id
  # [Optional] (Set of String) Tags to associate with the resource.
  tags = local.common_tags

  # [Optional] (Block List, Max: 1) Credentials are inherited from the delegate. (see below for nested schema)
  dynamic "inherit_from_delegate" {
    for_each = contains(local.validate_credential_models, "delegate") ? [var.delegate_credentials] : []
    content {
      # [Required] (Set of String) Selectors to use for the delegate.
      delegate_selectors = (
        lookup(inherit_from_delegate.value, "delegates", null) != null
        ?
        inherit_from_delegate.value.delegates
        :
        var.delegate_selectors
      )
    }
  }

  # [Optional] (Block List, Max: 1) Service account for the connector. (see below for nested schema)
  dynamic "service_account" {
    for_each = contains(local.validate_credential_models, "service_account") ? [var.service_account_credentials] : []
    content {
      # [Required]  (String) The URL of the Kubernetes cluster.
      master_url = lookup(service_account.value, "master_url", null)
      # [Required]  (String) Reference to the secret containing the service account token for the connector. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      service_account_token_ref = (
        lookup(service_account.value, "secret_location", "project") != "project"
        ?
        "${service_account.value.secret_location}.${lower(replace(service_account.value.secret_name, " ", ""))}"
        :
        lower(replace(service_account.value.secret_name, " ", ""))
      )
    }
  }

  # [Optional] (Block List, Max: 1) Username and password for the connector. (see below for nested schema)
  dynamic "username_password" {
    for_each = contains(local.validate_credential_models, "username") ? [var.username_credentials] : []
    content {
      # [Required] (String) The URL of the Kubernetes cluster.
      master_url = lookup(username_password.value, "master_url", null)
      # [Required] (String) Reference to the secret containing the password for the connector. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      password_ref = (
        lookup(username_password.value, "secret_location", "project") != "project"
        ?
        "${username_password.value.secret_location}.${lower(replace(username_password.value.secret_name, " ", ""))}"
        :
        lower(replace(username_password.value.secret_name, " ", ""))
      )

      # [Optional] (String) Username for the connector.
      username = (
        lookup(username_password.value, "is_user_secret", false)
        ?
        null
        :
        lookup(username_password.value, "username", null)
      )
      # [Optional] (String) Reference to the secret containing the username for the connector. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      username_ref = (
        lookup(username_password.value, "is_user_secret", false)
        ?
        lookup(username_password.value, "secret_location", "project") != "project"
        ?
        "${username_password.value.secret_location}.${lower(replace(username_password.value.username, " ", ""))}"
        :
        lower(replace(username_password.value.username, " ", ""))
        :
        null
      )
    }
  }

  # [Optional] (Block List, Max: 1) Client key and certificate config for the connector. (see below for nested schema)
  dynamic "client_key_cert" {
    for_each = contains(local.validate_credential_models, "certificate") ? [var.certificate_credentials] : []
    content {
      # [Required] (String) The URL of the Kubernetes cluster.
      master_url = lookup(client_key_cert.value, "master_url", null)
      # [Required] (String) Reference to the secret containing the client certificate for the connector.
      # To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}.
      # To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      client_cert_ref = (
        lookup(client_key_cert.value, "certificate_location", "project") != "project"
        ?
        "${client_key_cert.value.certificate_location}.${lower(replace(client_key_cert.value.certificate, " ", ""))}"
        :
        lower(replace(client_key_cert.value.certificate, " ", ""))
      )
      # [Required] (String) The algorithm used to generate the client key for the connector. Valid values are RSA, EC
      client_key_algorithm = upper(lookup(client_key_cert.value, "client_key_algorithm", null))
      # [Required] (String) Reference to the secret containing the client key for the connector.
      # To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}.
      # To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      client_key_ref = (
        lookup(client_key_cert.value, "client_key_location", "project") != "project"
        ?
        "${client_key_cert.value.client_key_location}.${lower(replace(client_key_cert.value.client_key, " ", ""))}"
        :
        lower(replace(client_key_cert.value.client_key, " ", ""))
      )

      # [Optional] (String) Reference to the secret containing the CA certificate for the connector.
      # To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}.
      # To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      ca_cert_ref = (
        lookup(client_key_cert.value, "ca_cert", null) != null
        ?
        lookup(client_key_cert.value, "ca_cert_location", "project") != "project"
        ?
        "${client_key_cert.value.ca_cert_location}.${lower(replace(client_key_cert.value.ca_cert, " ", ""))}"
        :
        lower(replace(client_key_cert.value.ca_cert, " ", ""))
        :
        null
      )
      # [Optional] (String) Reference to the secret containing the client key passphrase for the connector.
      # To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}.
      # To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      client_key_passphrase_ref = (
        lookup(client_key_cert.value, "passphrase", null) != null
        ?
        lookup(client_key_cert.value, "passphrase_location", "project") != "project"
        ?
        "${client_key_cert.value.passphrase_location}.${lower(replace(client_key_cert.value.passphrase, " ", ""))}"
        :
        lower(replace(client_key_cert.value.passphrase, " ", ""))
        :
        null
      )
    }

  }

  # [Optional] (Block List, Max: 1) OpenID configuration for the connector. (see below for nested schema)
  dynamic "openid_connect" {
    for_each = contains(local.validate_credential_models, "openid_connect") ? [var.openid_connect_credentials] : []
    content {
      # [Required]  (String) The URL of the Kubernetes cluster.
      master_url = lookup(openid_connect.value, "master_url", null)
      # [Required]  (String) The URL of the OpenID Connect issuer.
      issuer_url = lookup(openid_connect.value, "issuer_url", null)
      # [Required]  (String) Reference to the secret containing the client ID for the connector. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      client_id_ref = (
        lookup(openid_connect.value, "client_id_location", "project") != "project"
        ?
        "${openid_connect.value.client_id_location}.${lower(replace(openid_connect.value.client_id, " ", ""))}"
        :
        lower(replace(openid_connect.value.client_id, " ", ""))
      )
      # [Required]  (String) Reference to the secret containing the password for the connector. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      password_ref = (
        lookup(openid_connect.value, "password_location", "project") != "project"
        ?
        "${openid_connect.value.password_location}.${lower(replace(openid_connect.value.password, " ", ""))}"
        :
        lower(replace(openid_connect.value.password, " ", ""))
      )

      # [Optional]  (List of String) Scopes to request for the connector.
      scopes = lookup(openid_connect.value, "scopes", null)
      # [Optional]  (String) Reference to the secret containing the client secret for the connector. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      secret_ref = (
        lookup(openid_connect.value, "secret_location", "project") != "project"
        ?
        "${openid_connect.value.secret_location}.${lower(replace(openid_connect.value.secret_name, " ", ""))}"
        :
        lower(replace(openid_connect.value.secret_name, " ", ""))
      )
      # [Optional]  (String) Username for the connector.
      username = (
        lookup(openid_connect.value, "is_user_secret", false)
        ?
        null
        :
        lookup(openid_connect.value, "secret_location", "project") != "project"
        ?
        "${openid_connect.value.secret_location}.${lower(replace(openid_connect.value.username, " ", ""))}"
        :
        lower(replace(openid_connect.value.username, " ", ""))
      )
      # [Optional]  (String) Reference to the secret containing the username for the connector. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
      username_ref = (
        lookup(openid_connect.value, "is_user_secret", false)
        ?
        lookup(openid_connect.value, "secret_location", "project") != "project"
        ?
        "${openid_connect.value.secret_location}.${lower(replace(openid_connect.value.username, " ", ""))}"
        :
        lower(replace(openid_connect.value.username, " ", ""))
        :
        null
      )
    }
  }

}


# When creating a new Connector, there is a potential race-condition
# as the connector comes up.  This resource will introduce
# a slight delay in further execution to wait for the resources to
# complete.
resource "time_sleep" "connector_setup" {
  depends_on = [
    harness_platform_connector_kubernetes.cluster
  ]

  create_duration  = "15s"
  destroy_duration = "15s"
}
