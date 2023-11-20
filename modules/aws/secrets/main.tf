####################
#
# Harness Connector AWS Secrets Setup
#
####################
resource "harness_platform_connector_aws_secret_manager" "aws" {
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

  # (String) The AWS region where the AWS Secret Manager is.
  region = var.region

  # For Type 'assume_role' or 'inherit_from_delegate', you must supply a list of 'delegate_selectors' for the connection
  delegate_selectors = lookup(var.credentials, "delegate_selectors", [])

  # (String) A prefix to be added to all secrets.
  secret_name_prefix = var.secret_name_prefix

  # (Boolean) Use as Default Secrets Manager.
  default = var.is_default
  # [Optional] (Set of String) Tags to associate with the resource.
  tags = local.common_tags_tuple

  # (Block List, Min: 1, Max: 1) Credentials to connect to AWS. (see below for nested schema)
  credentials {
    inherit_from_delegate = var.credentials.type == "inherit_from_delegate" ? true : null
    # [Required] (Block List, Min: 1, Max: 1) Contains AWS connector credentials.
    dynamic "manual" {
      for_each = var.credentials.type == "manual" ? [1] : []
      content {
        # The reference to the Harness secret containing the AWS access key. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
        access_key_ref     = var.credentials.access_key_ref
        # The reference to the Harness secret containing the AWS secret key. To reference a secret at the organization scope, prefix 'org' to the expression: org.{identifier}. To reference a secret at the account scope, prefix 'account` to the expression: account.{identifier}.
        secret_key_ref     = var.credentials.secret_key_ref
      }
    }
    # [Required] (Block List, Min: 1, Max: 1) Contains AWS connector credentials.
    dynamic "assume_role" {
      for_each = var.credentials.type == "assume_role" ? [1] : []
      content {
        # The ARN of the role to assume.
        role_arn     = var.credentials.role_arn
        # If the administrator of the account to which the role belongs provided you with an external ID, then enter that value.
        external_id  = lookup(var.credentials, "external_id", null)
        # The duration, in seconds, of the role session. The value can range from 900 seconds (15 minutes) to 3600 seconds (1 hour). By default, the value is set to 3600 seconds. An expiration can also be specified in the client request body. The minimum value is 1 hour.
        duration     = var.credentials.duration
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
    harness_platform_connector_aws_secret_manager.aws
  ]

  create_duration  = "15s"
  destroy_duration = "15s"
}
