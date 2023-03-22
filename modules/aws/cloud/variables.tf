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


# [Optional] (Boolean) Execute on delegate or not.
variable "execute_on_delegate" {
  type        = bool
  description = "[Optional] (Boolean) Execute on delegate or not."
  default     = true
}

# [Required] (Map) AWS Connector Credentials.
variable "credentials" {
  type = any
  description = "[Required] (Map) AWS Connector Credentials."
    validation {
      condition = contains(["manual","irsa","inherit_from_delegate"],var.credentials["type"])
      error_message = "Allowed values are manual, irsa and inherit_from_delegate"
    }

    validation {
     condition = var.credentials.type == "irsa" ? contains(keys(var.credentials), "delegate_selectors") : true 
     error_message = "For Type 'irsa' you must supply 'delegate_selectors'"
    }

    validation {
     condition = var.credentials.type == "inherit_from_delegate" ? contains(keys(var.credentials), "delegate_selectors") : true 
     error_message = "For Type 'inherit_from_delegate' you must supply 'delegate_selectors'"
    }

    validation {
     condition = var.credentials.type == "manual" ? contains(keys(var.credentials), "secret_key_ref") : true 
     error_message = "For Type 'manual' you must supply 'secret_key_ref'"
    }

    validation {
     condition = var.credentials.type == "manual" ? contains(keys(var.credentials), "access_key_ref") || contains(keys(var.credentials), "access_key") : true 
     error_message = "For Type 'manual' you must supply 'access_key' OR access_key_ref"
    }


    
  }


# [Required] (Map) AWS Connector Credentials.
variable "cross_account_access" {
  type        = map(any)
  description = "[Required] (Map) AWS Cross Account Assumption"
  default = null
}

