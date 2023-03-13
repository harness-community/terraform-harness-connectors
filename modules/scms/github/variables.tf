####################
#
# Harness Connector SCM GitHub Variables
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

# [Optional] (Boolean) Execute on delegate or not.
variable "url" {
  type        = string
  description = "[Required] (String) URL of the Githubhub repository or account."

  validation {
    condition = (
      alltrue([
        can(regex("^((http|https)://)[-a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)$", var.url))
      ])
    )
    error_message = <<EOF
        Validation of an object failed. URL must be in valid format
          EOF
  }
}

variable "type" {
  type        = string
  description = "[Optional] (String) Whether the connection we're making is to a github repository or a github account. Valid values are account or repo."
  default     = "account"

  validation {
    condition = (
      contains(["account", "repo"], lower(var.type))
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Required] (String) Connection Type - One of 'account' or 'repo'
        EOF
  }
}

# [Optional] (Boolean) Execute on delegate or not.
variable "validation_repo" {
  type        = string
  description = "[Optional] (String) Repository to test the connection with. This is only used when connection_type is Account."
  default     = null
}

# [Optional] (Map) GitHub Connector Credentials.
variable "github_credentials" {
  type        = map(any)
  description = "[Required] (Map) GitHub Connector Credentials."

  validation {
    condition = (
      alltrue([
        (
          alltrue([
            for key in keys(var.github_credentials) : (
              contains([
                "type", "username", "is_user_secret", "secret_location", "password", "ssh_key"
              ], key)
            )
          ])
        ),
        contains(["http","ssh"], lower(lookup(var.github_credentials, "type", "invalid"))) &&
        (
          lower(lookup(var.github_credentials, "type", "http")) != "ssh"
          ?
            lookup(var.github_credentials, "username", null) != null &&
            can(regex("^(account|org|project)$", lookup(var.github_credentials, "secret_location", "project"))) &&
            can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.github_credentials, "password", null)))
          :
            true
        ),
        (
          lower(lookup(var.github_credentials, "type", "http")) == "ssh"
          ?
            can(regex("^(account|org|project)$", lookup(var.github_credentials, "secret_location", "project"))) &&
            can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.github_credentials, "ssh_key", null)))
          :
            true
        )
      ])
    )
    error_message = <<EOF
        Validation of an object failed. GitHub Credentials must include:
            * type            - [Required] Type of Credential.  Valid options are 'http' or 'ssh'.
            * HTTP Credentials
            * username        - [Conditionaly Required] If 'type == http' then the github username must be provided.
            * is_user_secret  - [Optional] Deterimines if the username should be sourced from a Harness Secret
            * secret_location - [Optional] Location within Harness that the secret is stored.
            *                   Supported values are "account", "org", or "project"
            * password        - [Conditionaly Required] If 'type == http' then provide an existing Harness Secret
            *                   containing github token.
            *                   NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                   secret_location
            * SSH Credentials
            * secret_location - [Optional] Location within Harness that the secret is stored.
            *                   Supported values are "account", "org", or "project"
            * ssh_key         - [Conditionaly Required] If 'type == ssh' then provide an existing Harness Secret
            *                   containing ssh_key.
            *                   NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                   secret_location
          EOF
  }
}

# Configuration for using the github api. API Access is required for using “Git Experience”, for creation of
# Git based triggers, Webhooks management and updating Git statuses.
variable "api_credentials" {
  type        = map(any)
  description = "[Optional] (Map) GitHub API Credentials."
  default     = {}

  validation {
    condition = (
      alltrue([
        length(keys(var.api_credentials)) > 0
        ?
        (
          alltrue([(
            alltrue([
              for key in keys(var.api_credentials) : (
                contains([
                  "type", "token_location", "token_name", "application_id", "installation_id",
                  "private_key_location", "private_key"
                ], key)
              )
            ])
            ),
            (
              contains(["token", "github_app"], lower(lookup(var.api_credentials, "type", null))) &&
              (
                lower(lookup(var.api_credentials, "type", null)) == "token"
                ?
                  can(regex("^(account|org|project)$", lookup(var.api_credentials, "token_location", "project"))) &&
                  can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.api_credentials, "token_name", null)))
                :
                  true
              ) &&
              (
                lower(lookup(var.api_credentials, "type", null)) == "github_app"
                ?
                  lookup(var.api_credentials, "application_id", null) != null &&
                  lookup(var.api_credentials, "installation_id", null) != null &&
                  can(regex("^(account|org|project)$", lookup(var.api_credentials, "private_key_location", "project"))) &&
                  can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.api_credentials, "private_key", null)))
                :
                  true
              )
            )
          ])
        )
        :
          true
      ])
    )
    error_message = <<EOF
        Validation of an object failed. GitHub API Credentials must include:
            * type            - [Required] Type of API Credential.  Valid options are 'token' or 'github_app'.
            * API Token Authentication
            * token_location - [Optional] Location within Harness that the secret is stored.
            *                   Supported values are "account", "org", or "project"
            * token_name           - [Conditionaly Required] If 'type == token' then provide an existing Harness Secret
            *                        containing token.
            *                        NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                        secret_location
            * API GitHub App Authentication
            * application_id       - [Conditionaly Required] If 'type == github_app' then Enter the GitHub App ID from the GitHub App General tab.
            * installation_id      - [Conditionaly Required] If 'type == github_app' then Enter the Installation ID located in the URL of the installed GitHub App.
            * private_key_location - [Optional] Location within Harness that the secret is stored.
            *                        Supported values are "account", "org", or "project"
            * private_key          - [Conditionaly Required] If 'type == github_app' then provide an existing Harness Secret
            *                        containing private_key.
            *                        NOTE: Secrets stored at the Account or Organization level must include correct value for the
            *                        secret_location
          EOF
  }
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
