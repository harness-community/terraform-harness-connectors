# Depends on
# - harness_connectors_azure.tf
# - harness_connectors_kubernetes.tf

# Create Testing infrastructure
resource "harness_platform_organization" "test" {
  identifier  = "${local.fmt_prefix}_terraform_harness_connectors"
  name        = "${local.fmt_prefix}-terraform-harness-connectors"
  description = "Testing Organization for Terraform Harness Connectors"
  tags        = ["purpose:terraform-testing"]
}

resource "harness_platform_project" "test" {
  identifier = "terraform_harness_connectors"
  name       = "terraform-harness-connectors"
  org_id     = harness_platform_organization.test.id
  color      = "#0063F7"
  tags       = ["purpose:terraform-testing"]
}
resource "time_sleep" "pre_load_dependencies" {
  depends_on = [
    harness_platform_organization.test,
    harness_platform_project.test
  ]

  create_duration  = "15s"
  destroy_duration = "15s"
}


resource "harness_platform_secret_text" "test" {
  depends_on = [
    time_sleep.pre_load_dependencies
  ]
  identifier  = "test_secret"
  name        = "test-secret"
  description = "Harness Test Secret"
  org_id      = harness_platform_organization.test.id
  project_id  = harness_platform_project.test.id
  tags        = ["purpose:terraform-testing"]

  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = "secret"
}

# When creating a new Environment, there is a potential race-condition
# as the environment comes up.  This resource will introduce
# a slight delay in further execution to wait for the resources to
# complete.
resource "time_sleep" "load_dependencies" {
  depends_on = [
    harness_platform_organization.test,
    harness_platform_project.test,
    harness_platform_secret_text.test
  ]

  create_duration  = "15s"
  destroy_duration = "15s"
}
