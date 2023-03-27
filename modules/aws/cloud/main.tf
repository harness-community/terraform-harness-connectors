####################
#
# Harness Connector AWS Cloud Setup
#
####################
resource "harness_platform_connector_aws" "aws" {
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
  # [Optional] (Set of String) Tags to associate with the resource.
  tags = local.common_tags

  # [Required] (Block List, Min: 1, Max: 1) Contains AWS connector credentials.
  dynamic "manual" {
    for_each = var.credentials.type == "manual" ? [1] : []
    content {
      secret_key_ref = var.credentials.secret_key_ref
      access_key = lookup(var.credentials,"access_key",null)
      access_key_ref = lookup(var.credentials,"access_key_ref",null)
      delegate_selectors = lookup(var.credentials,"delegate_selectors",null)
      }
  }

    # [Required] (Block List, Min: 1, Max: 1) Contains AWS connector credentials.
  dynamic "irsa" {
    for_each = var.credentials.type == "irsa" ? [1] : []
    content {
      delegate_selectors = var.credentials.delegate_selectors
    }
  }

    dynamic "inherit_from_delegate" {
    for_each = var.credentials.type == "inherit_from_delegate" ? [1] : []
    content {
      delegate_selectors = var.credentials.delegate_selectors
    }
  }

  # [Optional] (Block List, Min: 0, Max: 1) Contains AWS connector cross account details credentials.
  dynamic "cross_account_access" {
    for_each = (var.cross_account_access == null ? [] : [1])
    content {
      role_arn = var.cross_account_access.role_arn
      external_id = lookup(var.cross_account_access,"external_id",null)
    }
  }
}

# When creating a new Connector, there is a potential race-condition
# as the connector comes up.  This resource will introduce
# a slight delay in further execution to wait for the resources to
# complete.
resource "time_sleep" "connector_setup" {
  depends_on = [
    harness_platform_connector_aws.aws
  ]

  create_duration  = "15s"
  destroy_duration = "15s"
}
