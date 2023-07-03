# Terraform Modules for Harness Connectors - Kubernetes Cluster
Terraform Module for creating and managing the Harness Connector for Kubernetes Cluster

## Summary
This module handle the creation and managment of Connectors by leveraging the Harness Terraform provider

## Supported Terraform Versions
_Note: These modules require a minimum of Terraform Version 1.2.0 to support the Input Validations and Precondition Lifecycle hooks leveraged in the code._

_Note: The list of supported Terraform Versions is based on the most recent of each release which has been tested against this module._

    - v1.2.9
    - v1.3.9
    - v1.4.6
    - v1.5.0
    - v1.5.1
    - v1.5.2

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
| name | [Required] Name of the connector. | string |  | X |
| identifier | [Optional] Provide a custom identifier.  More than 2 but less than 128 characters and can only include alphanumeric or '_' | string | null | |
| organization_id | [Optional] Provide an organization reference ID. Must exist before execution | string | null | |
| project_id | [Optional] Provide an project reference ID. Must exist before execution | string | null | |
| description | [Optional] Description of the resource. | string | Harness Connector created via Terraform | |
| delegate_selectors | [Optional] Tags to filter delegates for connection.| list | [] | |
| delegate_credentials | [Optional] Delegate Based Authentication Credentials | map | | See block definition below |
| service_account_credentials | [Optional] Service Account Based Authentication Credentials | map | | See block definition below |
| username_credentials | [Optional] Username Based Authentication Credentials | map | | See block definition below |
| certificate_credentials | [Optional] Certificate Based Authentication Credentials | map | | See block definition below |
| openid_connect_credentials | [Optional] Certificate Based Authentication Credentials | map | | See block definition below |
| tags | [Optional] Provide a Map of Tags to associate with the project | map(any) | {} | |
| global_tags | [Optional] Provide a Map of Tags to associate with the project and resources created | map(any) | {} | |

### Variables - delegate_credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| delegates | [Required] The URL of the Kubernetes cluster. | string | | X |

### Variables - service_account_credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| master_url | [Required] The URL of the Kubernetes cluster | string | | X |
| secret_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| secret_name | [Required] Existing Harness Secret containing service_account token. | string | | X |

### Variables - username_credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| master_url | [Required] The URL of the Kubernetes cluster | string | | X |
| username |[Required] Can either be username or a harness secret reference if value of is_user_secret == true | string | | X |
| is_user_secret | [Optional] (Boolean) Deterimines if the username should be sourced from a Harness Secret | boolean | false | |
| username_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| secret_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| secret_name | [Required] Existing Harness Secret containing service_account token. | string | | X |

### Variables - certificate_credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| master_url | [Required] The URL of the Kubernetes cluster | string | | X |
| client_key_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| client_key | [Required] Existing Harness Secret containing client_key reference id. | string | | X |
| certificate_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| certificate | [Required] Existing Harness Secret containing certificate reference id. | string | | X |
| ca_cert_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| ca_cert | [Optional] Existing Harness Secret containing certificate reference id. | string | | |
| passphrase_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| passphrase | [Optional] Existing Harness Secret containing client_key passphrase reference id. | string | | |

### Variables - openid_connect_credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| master_url | [Required] The URL of the Kubernetes cluster | string | | X |
| issuer_url | [Required] (String) The URL of the OpenID Connect issuer. | string | | X |
| client_id_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| client_id | [Required] Existing Harness Secret containing client_id reference id. | string | | X |
| username |[Required] Can either be username or a harness secret reference if value of is_user_secret == true | string | | X |
| is_user_secret | [Optional] (Boolean) Deterimines if the username should be sourced from a Harness Secret | boolean | false | |
| username_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| secret_location | [Optional] Location within Harness that the secret is stored. Supported values are "account", "org", or "project" | string | project | |
| secret_name | [Required] Existing Harness Secret containing service_account token. | string | | X |
| scopes | [Optional]  (List of String) Scopes to request for the connector. | list | [] | |

## Outputs
| Name | Description | Value |
| --- | --- | --- |
| details | Details for the created Harness connector | Map containing details of created connector
| connector_details | [Deprecated] Details for the created Harness connector | Map containing details of created connector

## Examples
### Build a single Connector using delegate authentication
```
module "kubernetes_cluster" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/kubernetes/cluster"

  name                = "kubernetes-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  delegate_selectors  = ["account"]
}
```

### Build a single Connector using service-account authentication
```
module "kubernetes_cluster" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/kubernetes/cluster"

  name                = "kubernetes-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  delegate_selectors  = ["account"]
  service_account_credentials = {
    master_url  = "https://k8s.url"
    secret_name = local.test_secret_name
  }
}
```

### Build a single Connector using username authentication
```
module "kubernetes_cluster" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/kubernetes/cluster"

  name                = "kubernetes-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  delegate_selectors  = ["account"]
  username_credentials = {
    master_url  = "https://k8s.url"
    username    = "master"
    secret_name = local.test_secret_name
  }
}
```

### Build a single Connector using basic certificate authentication
```
module "kubernetes_cluster" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/kubernetes/cluster"

  name                = "kubernetes-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  delegate_selectors  = ["account"]
  certificate_credentials = {
    master_url           = "https://k8s.url"
    certificate          = local.test_secret_name
    client_key_algorithm = "rsa"
    client_key           = local.test_secret_name
  }
}
```

### Build a single Connector using openid_connect authentication
```
module "kubernetes_cluster" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/kubernetes/cluster"

  name                = "kubernetes-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  delegate_selectors  = ["account"]
  openid_connect_credentials = {
    master_url  = "https://k8s.url"
    issuer_url  = "https://k8s.url"
    client_id   = local.test_secret_name
    password    = local.test_secret_name
    username    = "main"
    secret_name = local.test_secret_name
    scopes      = ["all"]
  }
}
```

## Contributing
A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors
Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](../LICENSE) for full details.
