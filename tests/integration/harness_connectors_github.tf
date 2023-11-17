####################
#
# Harness Connectors Github Validations
#
####################
locals {
  connectors_github_outputs = flatten([
    {
      connector_github_minimal         = module.connector_github_minimal.details
      connector_github_username_secret = module.connector_github_username_secret.details
      connector_github_ssh             = module.connector_github_ssh.details
      connector_github_api_token       = module.connector_github_api_token.details
      connector_github_api_github_app  = module.connector_github_api_github_app.details
    }
  ])
}

module "connector_github_minimal" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/scms/github"

  name            = "test-github-minimal"
  organization_id = local.organization_id
  project_id      = local.project_id
  url             = "https://github.com"
  github_credentials = {
    type     = "http"
    username = local.organization_id
    password = local.test_secret_name
  }

  global_tags = local.common_tags

}

module "connector_github_username_secret" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/scms/github"

  name            = "test-github-username-secret"
  organization_id = local.organization_id
  project_id      = local.project_id
  url             = "https://github.com"
  github_credentials = {
    type           = "http"
    username       = local.test_secret_name
    is_user_secret = true
    password       = local.test_secret_name
  }

  global_tags = local.common_tags

}

module "connector_github_ssh" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/scms/github"

  name            = "test-github-ssh"
  organization_id = local.organization_id
  project_id      = local.project_id
  url             = "https://github.com"
  github_credentials = {
    type    = "ssh"
    ssh_key = local.test_secret_name
  }

  global_tags = local.common_tags

}

module "connector_github_api_token" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/scms/github"

  name            = "test-github-api-token"
  organization_id = local.organization_id
  project_id      = local.project_id
  url             = "https://github.com"
  github_credentials = {
    type     = "http"
    username = local.organization_id
    password = local.test_secret_name
  }
  api_credentials = {
    type       = "token"
    token_name = local.test_secret_name
  }

  global_tags = local.common_tags

}

module "connector_github_api_github_app" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/scms/github"

  name            = "test-github-api-github-app"
  organization_id = local.organization_id
  project_id      = local.project_id
  url             = "https://github.com"
  github_credentials = {
    type     = "http"
    username = local.organization_id
    password = local.test_secret_name
  }
  api_credentials = {
    type            = "github_app"
    application_id  = "mygithubapp"
    installation_id = "mygithubapp"
    private_key     = local.test_secret_name
  }

  global_tags = local.common_tags

}
