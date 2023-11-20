####################
#
# Harness Connector AWS Cloud Variables
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

variable "case_sensitive" {
  type        = bool
  description = "[Optional] Should identifiers be case sensitive by default? (Note: Setting this value to `true` will retain the case sensitivity of the identifier)"
  default     = false
}

# [Required] The AWS region where the AWS Secret Manager is.
variable "region" {
  type = string
  description = "[Required] The AWS region where the AWS Secret Manager is."
}

# [Required] A prefix to be added to all secrets.
variable "secret_name_prefix" {
  type = string
  description = "[Optional] A prefix to be added to all secrets."
  default = null
}

# [Required] Use as Default Secrets Manager.
variable "is_default" {
  type = string
  description = "[Optional] Use as Default Secrets Manager."
  default = false
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

# [Required] (Map) AWS Connector Credentials.
variable "credentials" {
  type        = any
  description = "[Required] (Map) AWS Connector Credentials."
  validation {
    condition     = contains(["manual", "assume_role", "inherit_from_delegate"], var.credentials["type"])
    error_message = "Allowed values are manual, assume_role and inherit_from_delegate"
  }

  validation {
    condition     = var.credentials.type != "manual" ? contains(keys(var.credentials), "delegate_selectors") : true
    error_message = "For Type 'assume_role' or 'inherit_from_delegate', you must supply a list of 'delegate_selectors' for the connection"
  }

  validation {
    condition     = var.credentials.type == "assume_role" ? contains(keys(var.credentials), "role_arn") : true
    error_message = "For Type 'assume_role' you must supply 'role_arn'"
  }

  validation {
    condition     = var.credentials.type == "assume_role" ? contains(keys(var.credentials), "duration") : true
    error_message = "For Type 'assume_role' you must supply 'duration'.  The duration, in seconds, of the role session. The value can range from 900 seconds (15 minutes) to 3600 seconds (1 hour). By default, the value is set to 3600 seconds. An expiration can also be specified in the client request body. The minimum value is 1 hour."
  }

  validation {
    condition     = var.credentials.type == "assume_role" ? contains(keys(var.credentials), "external_id") : true
    error_message = "For Type 'assume_role' you must supply 'external_id'. If the administrator of the account to which the role belongs provided you with an external ID, then enter that value."
  }

  validation {
    condition     = var.credentials.type == "manual" ? contains(keys(var.credentials), "access_key_ref") : true
    error_message = "For Type 'manual' you must supply 'access_key_ref'. The reference to the Harness secret containing the AWS access key. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}. "
  }

  validation {
    condition     = var.credentials.type == "manual" ? contains(keys(var.credentials), "secret_key_ref") : true
    error_message = "For Type 'manual' you must supply 'secret_key_ref'. The reference to the Harness secret containing the AWS secret key. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}."
  }




}
