# Terraform Modules for Harness Connectors - Aws Cloud
Terraform Module for creating and managing the Harness Connector for Aws Cloud

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

_Note: When the identifier variable is not provided, the module will automatically format the identifier based on the provided resource name and the identifier will be in lowercase format with all spaces and hyphens replaced with '\_'. To override the case lowering, you must set the parameter `case_sensitive: true`_

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| name | [Required] Name of the connector. | string |  | X |
| identifier | [Optional] Provide a custom identifier.  More than 2 but less than 128 characters and can only include alphanumeric or '_' | string | null | |
| organization_id | [Optional] Provide an organization reference ID. Must exist before execution | string | null | |
| project_id | [Optional] Provide an project reference ID. Must exist before execution | string | null | |
| description | [Optional] Description of the resource. | string | Harness Connector created via Terraform | |
| execute_on_delegate | [Optional] Execute on delegate or not. | boolean | true | |
| credentials | [Required] AWS Connector Credentials. | map | | See block definition below |
| case_sensitive | [Optional] Should identifiers be case sensitive by default? (Note: Setting this value to `true` will retain the case sensitivity of the identifier) | bool | false | |
| tags | [Optional] Provide a Map of Tags to associate with the project | map(any) | {} | |
| global_tags | [Optional] Provide a Map of Tags to associate with the project and resources created | map(any) | {} | |
| cross_account_access | [Optional] ARN of the AWS Role to Assume. | map |  | See block definition below |
| backoff_strategy | [Optional] Backoff Strategy | map |  | See block definition below |

### Variables - credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| type | [Required] Type can either be manual, irsa or inherit_from_delegate. | string |  | X |
| secret_key_ref | [Conditionally Required] Harness Secret reference value to be used for the AWS Secret Key.  Required if type == manual | string | | C |
| access_key | [Conditionally Required] AWS Access Key.  Required if type == manual. | string | ||
| access_key_ref | [Conditionally Required] AWS Access Key stored as a harness secret.  Required if type == manual. | string | ||
| delegate_selectors | [Conditionally Required] Tags to filter delegates for connection.  Required if type = "irsa" or "inherit_from_delegate" | list(string) | | |

### Variables - cross_account_access

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| role_arn | [Required] AWS ARN of the role to be assumed | string |  | X |
| external_id | If the administrator of the account to which the role belongs provided you with an external ID, then enter that value. | string | | |

### Variables - backoff_strategy

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| type | [Required] Supported Backoff types - equal_jitter, full_jitter, or fixed_delay | string |  | X |
| base_delay | [Optional] Base delay for the backup | number | | 0 |
| max_backoff_time | [Optional] Maximum Backoff Time | number | | 0 |
| fixed_backoff | [Optional] Fixed Backoff.  Only valid for `fixed_delay` type | number | | 0 |
| retry_count | [Optional] Retry Count | number | | 0 |


## Examples


### Build a single Connector using manual credentails
```
module "aws_cloud" {
  source  = "harness-community/delivery/harness//modules/aws/cloud"

  name                = "aws-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  execute_on_delegate = true
  credentials = {
    type = "manual"
    access_key = "AWS_ACCESS_KEY"
    secret_key_ref = "HARNESS_SECRET REF"
}
```

Note:  For more information on referencing secrests see: https://developer.harness.io/docs/platform/security/add-use-text-secrets/#:~:text=Always%20reference%20a,getValue(%22doc%2Dsecret%22)%3E%27


### Build a single Connector using manual credentials assigned Identity
```
module "aws_cloud" {
  source  = "harness-community/delivery/harness//modules/aws/cloud"

  name                = "aws-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  execute_on_delegate = true
  credentials = {
    type = "inherit_from_delegate"
    delegate_selectors = ["delegate1"]
  }
}
```



### Build a single Connector using delegate irsa Identity
```
module "aws_cloud" {
  source  = "harness-community/delivery/harness//modules/aws/cloud"

  name                = "aws-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  execute_on_delegate = true
  credentials = {
    type = "irsa"
    delegate_selectors =["delegate1"]
  }
}
```

### Build a single Connector using delegate User-Assigned Managed Identity

## Contributing
A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors
Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](../LICENSE) for full details.
