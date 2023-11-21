# Terraform Modules for Harness Connectors - GitHub
Terraform Module for creating and managing the Harness Connector for GitHub

## Summary
This module handle the creation and managment of Connectors by leveraging the Harness Terraform provider

## Supported Terraform Versions
_Note: These modules require a minimum of Terraform Version 1.2.0 to support the Input Validations and Precondition Lifecycle hooks leveraged in the code._

_Note: The list of supported Terraform Versions is based on the most recent of each release which has been tested against this module._

    - 1.2.9
    - 1.3.9
    - 1.4.6
    - 1.5.7
    - 1.6.0
    - 1.6.1
    - 1.6.2
    - 1.6.3

_Note: Terraform version 1.4.1 will not work due to an issue with the Random provider_

## Providers
This module requires that the calling template has defined the [Harness Provider - Docs](https://registry.terraform.io/providers/harness/harness/latest/docs) authentication.

### Example setup of the Harness Provider Authentication with environment variables
You can also set up authentication with Harness through environment variables. To do this set the following items in your environment:
- HARNESS_ENDPOINT: Harness Platform URL, defaults to Harness SaaS URL: https://app.harness.io/gateway
- HARNESS_ACCOUNT_ID: Harness Platform Account Number
- HARNESS_PLATFORM_API_KEY: Harness Platform API Key for your account

### Example setup of the Harness Provider
```
# Provider Setup Details
variable "harness_platform_url" {
  type        = string
  description = "[Optional] Enter the Harness Platform URL.  Defaults to Harness SaaS URL"
  default     = null # If Not passed, then the ENV HARNESS_ENDPOINT will be used or the default value of "https://app.harness.io/gateway"
}

variable "harness_platform_account" {
  type        = string
  description = "[Required] Enter the Harness Platform Account Number"
  default     = null # If Not passed, then the ENV HARNESS_ACCOUNT_ID will be used
  sensitive   = true
}

variable "harness_platform_key" {
  type        = string
  description = "[Required] Enter the Harness Platform API Key for your account"
  default     = null # If Not passed, then the ENV HARNESS_PLATFORM_API_KEY will be used
  sensitive   = true
}

provider "harness" {
  endpoint         = var.harness_platform_url
  account_id       = var.harness_platform_account
  platform_api_key = var.harness_platform_key
}

```


### Terraform required providers declaration
```
terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.14"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}
```

## Variables

_Note: When the identifier variable is not provided, the module will automatically format the identifier based on the provided resource name_

_Note: Only one of the credential blocks can be provided.  If not chosen, the credential model will default to delegate-based credentials and uses the provided delegate_selectors.)

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| name | [Required] Provide a resourcen name. Must be at least 1 character but but less than 128 characters | string | | X |
| identifier | [Optional] Provide a custom identifier.  Must be at least 1 character but but less than 128 characters and can only include alphanumeric or '_' | string | null | |
| organization_id | [Optional] Provide an organization reference ID. Must exist before execution | string | null | |
| project_id | [Optional] Provide an project reference ID. Must exist before execution | string | null | |
| description | [Optional] Description of the resource. | string | Harness Connector created via Terraform | |
| delegate_selectors | [Optional] Tags to filter delegates for connection.| list | [] | |
| url | [Required] URL of the Githubhub repository or account. | string | | X |
| type | [Optional] Whether the connection we're making is to a github repository or a github account. Valid values are account or repo. | string | account | |
| validation_repo | [Optional] Repository to test the connection with. This is only used when connection_type is Account. | string | null | |
| github_credentials | [Required] GitHub Connector Credentials. | map | | See block definition below |
| api_credentials | [Optional] GitHub API Credentials. | map | | See block definition below |
| case_sensitive | [Optional] Should identifiers be case sensitive by default? (Note: Setting this value to `true` will retain the case sensitivity of the identifier) | bool | false | |
| tags | [Optional] Provide a Map of Tags to associate with the project | map(any) | {} | |
| global_tags | [Optional] Provide a Map of Tags to associate with the project and resources created | map(any) | {} | |

### Variables - github_credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| type | [Required] Type of Credential.  Valid options are 'http' or 'ssh'. | string | | X |
| username | [Optional] The github username must be provided. | string | | If 'type == http' |
| is_user_secret | [Optional] Deterimines if the username should be sourced from a Harness Secret | string | false | |
| secret_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| password | [Optional] Provide an existing Harness Secret containing github token. | string | | If 'type == http' |
| ssh_key | [Optional] Provide an existing Harness Secret containing ssh_key. | string | | If 'type == ssh' |

### Variables - github_credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| type | [Required] Type of API Credential.  Valid options are 'token' or 'github_app' | string | | X |
| token_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| token_name | [Required] Provide an existing Harness Secret containing token. | string | | If 'type == token' |
| application_id | [Required] Enter the GitHub App ID from the GitHub App General tab. | string | | If 'type == github_app' |
| installation_id | [Required] Enter the Installation ID located in the URL of the installed GitHub App. | string | | If 'type == github_app' |
| private_key_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| private_key | [Required] Provide an existing Harness Secret containing private_key | string | | If 'type == github_app' |

## Outputs
| Name | Description | Value |
| --- | --- | --- |
| details | Details for the created Harness connector | Map containing details of created connector
| connector_details | [Deprecated] Details for the created Harness connector | Map containing details of created connector

## Examples
### Build a single Connector using http authentication
```
module "github" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/scms/github"

  name             = "kubernetes-global-connector"
  organization_id  = "myorg"
  project_id       = "myproject"
  url              = "https://github.com"
  github_credentials = {
    type     = "http"
    username = "github_id"
    password = "secretpassword"
  }
}
```

### Build a single Connector using ssh_key authentication
```
module "github" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/scms/github"

  name             = "kubernetes-global-connector"
  organization_id  = "myorg"
  project_id       = "myproject"
  url              = "https://github.com"
  github_credentials = {
    type    = "ssh"
    ssh_key = "ssh_key"
  }
}
```

### Build a single Connector using http authentication with api token
```
module "github" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/scms/github"

  name             = "kubernetes-global-connector"
  organization_id  = "myorg"
  project_id       = "myproject"
  url              = "https://github.com"
  github_credentials = {
    type     = "http"
    username = "github_id"
    password = "secretpassword"
  }
  api_credentials = {
    type       = "token"
    token_name = "secretpassword"
  }
}
```

### Build a single Connector using ssh_key authentication with api github_app
```
module "github" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/scms/github"

  name             = "kubernetes-global-connector"
  organization_id  = "myorg"
  project_id       = "myproject"
  url              = "https://github.com"
  github_credentials = {
    type     = "http"
    username = "github_id"
    password = "secretpassword"
  }
  api_credentials = {
    type            = "github_app"
    application_id  = "mygithubapp"
    installation_id = "mygithubapp"
    private_key     = "github_app_key"
  }
}
```

## Contributing
A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors
Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](../LICENSE) for full details.
