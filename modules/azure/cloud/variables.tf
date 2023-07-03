####################
#
# Harness Connector Azure Cloud Variables
#
####################
variable "identifier" {
  type        = string
  description = "[Optional] Provide a custom identifier.  Must be at least 1 character but less than 128 characters and can only include alphanumeric or '_'"
  default     = null

  validation {
    condition = (
      var.identifier != null
      ?
      can(regex("^[0-9A-Za-z][0-9A-Za-z_]{0,127}$", var.identifier))
      :
      true
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide a custom identifier.  Must be at least 1 character but less than 128 characters and can only include alphanumeric or '_'.
            Note: If not set, Terraform will auto-assign an identifier based on the name of the resource
        EOF
  }
}
variable "name" {
  type        = string
  description = "[Required] Provide a resource name. Must be at least 1 character but but less than 128 characters"

  validation {
    condition = (
      length(var.name) > 1
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Required] Provide a resource name. Must be at least 1 character but but less than 128 characters.
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

variable "case_sensitive" {
  type        = bool
  description = "[Optional] Should identifiers be case sensitive by default? (Note: Setting this value to `true` will retain the case sensitivity of the identifier)"
  default     = false
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

# Azure Cloud Configuration Specifics
variable "type" {
  type        = string
  description = "[Optional] Specifies the Connector Azure Cloud type. Supported values are azure or us_government"
  default     = "azure"

  validation {
    condition = (
      contains(["azure", "us_government"], lower(var.type))
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Required] (String) Connector Azure Cloud Type - One of 'azure' or 'us_government'
        EOF
  }
}

# [Optional] (Boolean) Execute on delegate or not.
variable "execute_on_delegate" {
  type        = bool
  description = "[Optional] (Boolean) Execute on delegate or not."
  default     = true
}

# [Required] (Map) Azure Connector Credentials.
variable "azure_credentials" {
  type        = map(any)
  description = "[Required] (Map) Azure Connector Credentials."

  validation {
    condition = (
      alltrue([
        (
          alltrue([
            for key in keys(var.azure_credentials) : (
              contains([
                "type", "delegate_auth", "tenant_id", "client_id",
                "secret_kind", "secret_location", "secret_name"
              ], key)
            )
          ])
        ),
        contains(["delegate", "service_principal"], lookup(var.azure_credentials, "type", "invalid")),
        (
          lookup(var.azure_credentials, "type", "invalid") == "delegate"
          ?
          lookup(var.azure_credentials, "delegate_auth", null) != null
          ?
          alltrue([
            contains(["system", "user"], lower(var.azure_credentials.delegate_auth)),
            (
              lower(var.azure_credentials.delegate_auth) == "user"
              ?
              can(regex("^([a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12})$", lookup(var.azure_credentials, "client_id", null)))
              :
              true
            )
          ])
          :
          true
          :
          true
        ),
        (
          lookup(var.azure_credentials, "type", "invalid") == "service_principal"
          ?
          alltrue([
            can(regex("^([a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12})$", lookup(var.azure_credentials, "tenant_id", null))),
            can(regex("^([a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12})$", lookup(var.azure_credentials, "client_id", null))),
            contains(["secret", "certificate"], lower(lookup(var.azure_credentials, "secret_kind", "invalid"))),
            can(regex("^(account|org|project)$", lookup(var.azure_credentials, "secret_location", "project"))),
            can(regex("^([a-zA-Z0-9 _-])+$", lookup(var.azure_credentials, "secret_name", null)))
          ])
          :
          true
        )
      ])
    )
    error_message = <<EOF
        Validation of an object failed. Organizations must include:
            * type - [Required] (String) Type can either be delegate or service_principal.
            * delegate_auth - [Conditionally Required] (String) Type can either be system or user. Mandatory if type == delegate
            * tenant_id - [Conditionally Required] (String) Azure Tenant ID. Mandatory if type == service_principal
            * client_id - [Conditionally Required] (String) Azure Service Principal or Managed Identity ID. Mandatory if type == delegate && delegate_auth == user OR type == service_principal
            * secret_kind - [Conditionally Required] (String) Azure Client Authentication model can be either secret or certifiate. Mandatory if type == service_principal
            * secret_location - [Optional] (String) Location within Harness that the secret is stored.  Supported values are "account", "org", or "project"
            * secret_name - [Conditionally Required] (String) Existing Harness Secret containing Azure Client Authentication details. Mandatory if type == service_principal
              - NOTE: Secrets stored at the Account or Organization level must include correct value for the secret_location
        EOF
  }
}
