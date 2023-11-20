####################
#
# Harness Connectors AWS Secrets Manager Validations
#
####################
locals {
  connectors_aws_sm_outputs = flatten([
    {
      connector_aws_sm_minimal     = module.connector_aws_sm_minimal.details
      connector_aws_sm_inherit     = module.connector_aws_sm_inherit.details
      connector_aws_sm_assume_role = module.connector_aws_sm_assume_role.details
    }
  ])
}

module "connector_aws_sm_minimal" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/secrets"

  name            = "test-aws-sm-minimal"
  organization_id = local.organization_id
  project_id      = local.project_id

  region = "us-east-1"

  credentials = {
    type           = "manual"
    access_key_ref = local.test_secret_name
    secret_key_ref = local.test_secret_name
  }
}


module "connector_aws_sm_inherit" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/secrets"

  name            = "test-aws-sm-inherit"
  organization_id = local.organization_id
  project_id      = local.project_id

  region = "us-east-1"

  credentials = {
    type               = "inherit_from_delegate"
    delegate_selectors = ["harness"]
  }
}

module "connector_aws_sm_assume_role" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/secrets"

  name            = "test-aws-sm-assume-role"
  organization_id = local.organization_id
  project_id      = local.project_id

  region = "us-east-1"

  credentials = {
    type               = "assume_role"
    delegate_selectors = ["harness"]
    role_arn           = "somerolearn"
    external_id        = "externalid"
    duration           = 900
  }
}
