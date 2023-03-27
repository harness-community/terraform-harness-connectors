####################
#
# Harness Connectors AWS Validations
#
####################
locals {
  connectors_aws_outputs = flatten([
    {
      minimum                           = module.connector_aws_minimal.connector_details
      manual_cross_account              = module.connector_aws_manual_cross_account.connector_details
      inherit_no_cross_account          = module.connector_aws_inhert_no_cross_account.connector_details
      connector_aws_irsa_cross_account  = module.connector_aws_irsa_cross_account.connector_details
    }
  ])
}

module "connector_aws_minimal" {
  source          = "../../modules/aws/cloud"
  name            = "aws-manual-credentials-cross-account"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type               = "manual"
    access_key         = "access_key"
    secret_key_ref     = local.test_secret_name
  }
}


module "connector_aws_manual_cross_account" {
  source          = "../../modules/aws/cloud"
  name            = "aws-manual-credentials-cross-account"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type               = "manual"
    access_key         = "access_key"
    secret_key_ref     = local.test_secret_name
    delegate_selectors = ["delegate1", "delegate2"]
  }

  cross_account_access = {
    role_arn = "role_arn"
  }

}

module "connector_aws_inhert_no_cross_account" {
  source          = "../../modules/aws/cloud"
  name            = "aws-inherit-credentials-no-cross-account"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type               = "inherit_from_delegate"
    delegate_selectors = ["delegate1", "delegate2"]
  }

}

module "connector_aws_irsa_cross_account" {
  source          = "../../modules/aws/cloud"
  name            = "aws-irsa-credentials"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type               = "irsa"
    delegate_selectors = ["delegate1", "delegate2"]
  }

  cross_account_access = {
    role_arn = "role_arn"
  }

}