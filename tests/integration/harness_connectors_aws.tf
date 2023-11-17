####################
#
# Harness Connectors AWS Validations
#
####################
locals {
  connectors_aws_outputs = flatten([
    {
      connector_aws_minimal                 = module.connector_aws_minimal.details
      connector_aws_custom_identifier       = module.connector_aws_custom_identifier.details
      connector_aws_minimal_case_sensitive  = module.connector_aws_minimal_case_sensitive.details
      connector_aws_manual_cross_account    = module.connector_aws_manual_cross_account.details
      connector_aws_inhert_no_cross_account = module.connector_aws_inhert_no_cross_account.details
      connector_aws_irsa_minimal            = module.connector_aws_irsa_minimal.details
      connector_aws_irsa_with_cross_account = module.connector_aws_irsa_with_cross_account.details
      connector_aws_equal_jitter            = module.connector_aws_equal_jitter.details
      connector_aws_full_jitter             = module.connector_aws_full_jitter.details
      connector_aws_fixed_delay             = module.connector_aws_fixed_delay.details
    }
  ])
}

module "connector_aws_minimal" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/cloud"

  name            = "test-aws-cloud-minimal"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type           = "manual"
    access_key     = "access_key"
    secret_key_ref = local.test_secret_name
  }
}

module "connector_aws_custom_identifier" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/cloud"

  identifier      = "TestAWSCloudCustomIdentifier"
  name            = "test-aws-cloud-custom-identifier"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type           = "manual"
    access_key     = "access_key"
    secret_key_ref = local.test_secret_name
  }
}

module "connector_aws_minimal_case_sensitive" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/cloud"

  name            = "Test-Aws-Cloud-Case-Sensitive"
  organization_id = local.organization_id
  project_id      = local.project_id
  case_sensitive  = true

  credentials = {
    type           = "manual"
    access_key     = "access_key"
    secret_key_ref = local.test_secret_name
  }
}

module "connector_aws_manual_cross_account" {
  depends_on = [
    time_sleep.load_dependencies
  ]

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
  depends_on = [
    time_sleep.load_dependencies
  ]

  source          = "../../modules/aws/cloud"
  name            = "aws-inherit-credentials-no-cross-account"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type               = "inherit_from_delegate"
    delegate_selectors = ["delegate1", "delegate2"]
  }

}

module "connector_aws_irsa_minimal" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source          = "../../modules/aws/cloud"
  name            = "aws-irsa-minimal"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type               = "irsa"
    delegate_selectors = ["delegate1", "delegate2"]
  }

}

module "connector_aws_irsa_with_cross_account" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source          = "../../modules/aws/cloud"
  name            = "aws-irsa-with-cross-account"
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

module "connector_aws_equal_jitter" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/cloud"

  name            = "test-aws-cloud-equal-jitter"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type           = "manual"
    access_key     = "access_key"
    secret_key_ref = local.test_secret_name
  }

  backoff_strategy = {
    type = "equal_jitter"
  }
}

module "connector_aws_full_jitter" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/cloud"

  name            = "test-aws-cloud-full-jitter"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type           = "manual"
    access_key     = "access_key"
    secret_key_ref = local.test_secret_name
  }

  backoff_strategy = {
    type = "full_jitter"
  }
}

module "connector_aws_fixed_delay" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/aws/cloud"

  name            = "test-aws-cloud-fixed-delay"
  organization_id = local.organization_id
  project_id      = local.project_id

  credentials = {
    type           = "manual"
    access_key     = "access_key"
    secret_key_ref = local.test_secret_name
  }

  backoff_strategy = {
    type = "fixed_delay"
  }
}
