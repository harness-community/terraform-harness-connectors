####################
#
# Harness Connector Azure Cloud Variables
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

variable "type" {
  type        = string
  description = "[Optional] Specifies the Connector type, which is AZURE by default. Can either be azure or us_government"
  default     = "azure"

  validation {
    condition = (
      contains(["azure", "us_government"], lower(var.type))
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Required] (String) Secret Type - One of 'azure' or 'us_government'
        EOF
  }
}

variable "color" {
  type        = string
  description = "[Optional] (String) Color of the Environment."
  default     = null

  validation {
    condition = (
      anytrue([
        can(regex("^#([A-Fa-f0-9]{6})", var.color)),
        var.color == null
      ])
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide Pipeline Color Identifier.  Must be a valid Hex Color code.
        EOF
  }
}

variable "description" {
  type        = string
  description = "[Optional] (String) Description of the resource."
  default     = "Harness Environment created via Terraform"

  validation {
    condition = (
      length(var.description) > 6
    )
    error_message = <<EOF
        Validation of an object failed.
            * [Optional] Provide an Pipeline description.  Must be six or more characters.
        EOF
  }
}

# [Optional] (Set of String) Tags to filter delegates for connection.
variable "delegate_selectors" {
  type        = list(string)
  description = "[Optional] (Set of String) Tags to filter delegates for connection."
  default     = []

}

# [Optional] (Boolean) Execute on delegate or not.
variable "execute_on_delegate" {
  type        = bool
  description = "[Optional] (Boolean) Execute on delegate or not."
  default     = true
}

# [Optional] (Map) Azure Connector Credentials.
variable "azure_credentials" {
  type        = map(any)
  description = "[Optional] (Map) Azure Connector Credentials."
  default     = {}

  validation {
    condition = (
      anytrue([
        length(var.azure_credentials) == 0,
        alltrue([
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