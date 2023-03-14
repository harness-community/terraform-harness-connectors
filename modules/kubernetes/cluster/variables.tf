####################
#
# Harness Connector Kubernetes Cluster Variables
#
####################
variable "identifier" {
  type        = string
  description = "[Optional] Provide a custom identifier.  More than 2 but less than 128 characters and can only include alphanumeric or '_'"
  default     = null

  validation {
    condition = (
      var.identifier != null
      ?
      can(regex("^[0-9A-Za-z][0-9A-Za-z_]{2,127}$", var.identifier))
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide a custom identifier.  More than 2 but less than 128 characters and can only include alphanumeric or '_'.
            Note: If not set, Terraform will auto-assign an identifier based on the name of the resource
        EOF
  }
}

variable "name" {
  type        = string
  description = "[Required] (String) Name of the resource."

  validation {
    condition = (
      length(var.name) > 2
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Required] Provide a project name.  Must be two or more characters.
        EOF
  }
}

variable "organization_id" {
  type        = string
  description = "[Optional] Provide an organization reference ID.  Must exist before execution"
  default     = null

  validation {
    condition = (
      var.organization_id != null
      ?
      length(var.organization_id) > 2
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide an organization name.  Must exist before execution.
        EOF
  }
}

variable "project_id" {
  type        = string
  description = "[Optional] Provide an project reference ID.  Must exist before execution"
  default     = null

  validation {
    condition = (
      var.project_id != null
      ?
      can(regex("^([a-zA-Z0-9_]*)", var.project_id))
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide an project name.  Must exist before execution.
        EOF
  }
}

variable "description" {
  type        = string
  description = "[Optional] (String) Description of the resource."
  default     = "Harness Connector created via Terraform"

  validation {
    condition = (
      length(var.description) > 6
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide an resource description.  Must be six or more characters.
        EOF
  }
}

variable "delegate_selectors" {
  type        = list(string)
  description = "[Optional] (Set of String) Tags to filter delegates for connection."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "[Optional] Provide a Map of Tags to associate with the environment"
  default     = {}

  validation {
    condition = (
      length(keys(var.tags)) == length(values(var.tags))
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide a Map of Tags to associate with the project
        EOF
  }
}

variable "global_tags" {
  type        = map(any)
  description = "[Optional] Provide a Map of Tags to associate with the project and resources created"
  default     = {}

  validation {
    condition = (
      length(keys(var.global_tags)) == length(values(var.global_tags))
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide a Map of Tags to associate with the project and resources created
        EOF
  }
}

# Kubernetes Cloud Connector Specifics
variable "delegate_credentials" {
  type        = map(any)
  description = "[Optional] (Map) Delegate Based Authentication Credentials"
  default     = {}

  validation {
    condition = (
      lookup(var.delegate_credentials, "delegates", null) != null
      ?
      length(var.delegate_credentials.delegates) > 0
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed. Organizations must include:
            * Delegate Based Authentication
            * delegates - [Optional] (Set of Strings) Selectors to use for the delegate. Optional if type == delegate.
            *             If not set, then uses the default selectors for the connector.
            *
          EOF
  }
}

variable "service_account_credentials" {
  type        = any
  description = "[Optional] (Map) Service Account Based Authentication Credentials"
  default     = {}

  validation {
    condition = (
      var.service_account_credentials != {} && length(keys(var.service_account_credentials)) > 0
      ?
      alltrue([
        can(regex("^((http|https)://)[-a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)$", lookup(var.service_account_credentials, "master_url", null))),
        can(regex("^(account|org|project)$", lookup(var.service_account_credentials, "secret_location", "project"))),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.service_account_credentials, "secret_name", null)))
      ])
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed. Organizations must include:
            * Service_account Based Authentication
            * master_url      - [Required] (String) The URL of the Kubernetes cluster.
            * secret_location - [Optional] (String) Location within Harness that the secret is stored.
            *                   Supported values are "account", "org", or "project"
            * secret_name     - [Required] (String) Existing Harness Secret containing service_account token.
            *                   NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                   secret_location
            *
          EOF
  }
}

variable "username_credentials" {
  type        = any
  description = "[Optional] (Map) Username Based Authentication Credentials"
  default     = {}

  validation {
    condition = (
      var.username_credentials != {} && length(keys(var.username_credentials)) > 0
      ?
      alltrue([
        can(regex("^((http|https)://)[-a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)$", lookup(var.username_credentials, "master_url", null))),
        can(regex("^(account|org|project)$", lookup(var.username_credentials, "username_location", "project"))),
        contains([true, false], lookup(var.username_credentials, "is_user_secret", false)),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.username_credentials, "username", null))),
        can(regex("^(account|org|project)$", lookup(var.username_credentials, "secret_location", "project"))),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.username_credentials, "secret_name", null)))
      ])
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed. Organizations must include:
            * Username Based Authentication
            * master_url        - [Required] (String) The URL of the Kubernetes cluster.
            * username          - [Required] (String) Can either be username or a harness secret reference if value of is_user_secret == true
            * is_user_secret    - [Optional] (Boolean) Deterimines if the username should be sourced from a Harness Secret
            * username_location - [Optional] (String) Location within Harness that the secret username is stored.
            *                     Supported values are "account", "org", or "project"
            * secret_location   - [Optional] (String) Location within Harness that the secret is stored.
            *                     Supported values are "account", "org", or "project"
            * secret_name       - [Required] (String) Existing Harness Secret containing username token.
            *                     NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                     secret_location
          EOF
  }
}

variable "certificate_credentials" {
  type        = any
  description = "[Optional] (Map) Certificate Based Authentication Credentials"
  default     = {}

  validation {
    condition = (
      var.certificate_credentials != {} && length(keys(var.certificate_credentials)) > 0
      ?
      alltrue([
        can(regex("^((http|https)://)[-a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)$", lookup(var.certificate_credentials, "master_url", null))),
        contains(["RSA", "EC"], upper(lookup(var.certificate_credentials, "client_key_algorithm", "invalid"))),
        can(regex("^(account|org|project)$", lookup(var.certificate_credentials, "client_key_location", "project"))),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.certificate_credentials, "client_key", null))),
        can(regex("^(account|org|project)$", lookup(var.certificate_credentials, "certificate_location", "project"))),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.certificate_credentials, "certificate", null))),
        (
          lookup(var.certificate_credentials, "ca_cert_location", "project") != null
          ?
          can(regex("^(account|org|project)$", lookup(var.certificate_credentials, "ca_cert_location", "project")))
          :
          true
        ),
        (
          lookup(var.certificate_credentials, "ca_cert", null) != null
          ?
          can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.certificate_credentials, "ca_cert", null)))
          :
          true
        ),
        (
          lookup(var.certificate_credentials, "client_key_passphrase_location", "project") != null
          ?
          can(regex("^(account|org|project)$", lookup(var.certificate_credentials, "client_key_passphrase_location", "project")))
          :
          true
        ),
        (
          lookup(var.certificate_credentials, "client_key_passphrase", null) != null
          ?
          can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.certificate_credentials, "client_key_passphrase", null)))
          :
          true
        )
      ])
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed. Organizations must include:
            * Certificate Based Authentication
            * master_url            - [Required] (String) The URL of the Kubernetes cluster.
            * client_key_location   - [Optional] (String) Location within Harness that the secret is stored.
            *                         Supported values are "account", "org", or "project"
            * client_key            - [Required] (String) Existing Harness Secret containing client_key reference id.
            *                         NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                         client_key_location
            * certificate_location  - [Optional] (String) Location within Harness that the secret is stored.
            *                         Supported values are "account", "org", or "project"
            * certificate           - [Required] (String) Existing Harness Secret containing certificate reference id.
            *                         NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                         certificate_location
            * ca_cert_location      - [Optional] (String) Location within Harness that the secret is stored.
            *                         Supported values are "account", "org", or "project"
            * ca_cert               - [Optional] (String) Existing Harness Secret containing certificate reference id.
            *                         NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                         certificate_location
            * passphrase_location   - [Optional] (String) Location within Harness that the secret is stored.
            *                         Supported values are "account", "org", or "project"
            * passphrase            - [Optional] (String) Existing Harness Secret containing client_key passphrase reference id.
            *                         NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                         certificate_location
          EOF
  }
}

variable "openid_connect_credentials" {
  type        = any
  description = "[Optional] (Map) Certificate Based Authentication Credentials"
  default     = {}

  validation {
    condition = (
      var.openid_connect_credentials != {} && length(keys(var.openid_connect_credentials)) > 0
      ?
      alltrue([
        can(regex("^((http|https)://)[-a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)$", lookup(var.openid_connect_credentials, "master_url", null))),
        can(regex("^((http|https)://)[-a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)$", lookup(var.openid_connect_credentials, "issuer_url", null))),
        can(regex("^(account|org|project)$", lookup(var.openid_connect_credentials, "client_id_location", "project"))),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.openid_connect_credentials, "client_id", null))),
        can(regex("^(account|org|project)$", lookup(var.openid_connect_credentials, "password_location", "project"))),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.openid_connect_credentials, "password", null))),
        can(regex("^(account|org|project)$", lookup(var.openid_connect_credentials, "username_location", "project"))),
        contains([true, false], lookup(var.openid_connect_credentials, "is_user_secret", false)),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.openid_connect_credentials, "username", null))),
        can(regex("^(account|org|project)$", lookup(var.openid_connect_credentials, "secret_location", "project"))),
        can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.openid_connect_credentials, "secret_name", null))),
        (
          lookup(var.openid_connect_credentials, "scopes", null) != null
          ?
          length(var.openid_connect_credentials.scopes) > 0
          :
          true
        )
      ])
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed. Organizations must include:
            * Certificate Based Authentication
            * master_url            - [Required] (String) The URL of the Kubernetes cluster.
            * issuer_url            - [Required] (String) The URL of the OpenID Connect issuer.
            * client_id_location    - [Optional] (String) Location within Harness that the secret is stored.
            *                         Supported values are "account", "org", or "project"
            * client_id             - [Required] (String) Existing Harness Secret containing client_id reference id.
            *                         NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                         client_id_location
            * username              - [Required] (String) Can either be username or a harness secret reference if value of is_user_secret == true
            * is_user_secret        - [Optional] (Boolean) Deterimines if the username should be sourced from a Harness Secret
            * username_location     - [Optional] (String) Location within Harness that the secret username is stored.
            *                         Supported values are "account", "org", or "project"
            * secret_location       - [Optional] (String) Location within Harness that the secret is stored.
            *                         Supported values are "account", "org", or "project"
            * secret_name           - [Required] (String) Existing Harness Secret containing username token.
            *                         NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                         secret_location
            * scopes                - [Optional]  (List of String) Scopes to request for the connector.
          EOF
  }
}
