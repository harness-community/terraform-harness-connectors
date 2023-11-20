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
| credentials | [Required] AWS Connector Credentials. | map | | See block definition below |
| case_sensitive | [Optional] Should identifiers be case sensitive by default? (Note: Setting this value to `true` will retain the case sensitivity of the identifier) | bool | false | |
| tags | [Optional] Provide a Map of Tags to associate with the project | map(any) | {} | |
| global_tags | [Optional] Provide a Map of Tags to associate with the project and resources created | map(any) | {} | |

### Variables - credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| type | [Required] Type can either be manual, assume_role or inherit_from_delegate. | string |  | X |
| delegate_selectors | [Conditionally Required] For Type 'assume_role' or 'inherit_from_delegate', you must supply a list of 'delegate_selectors' for the connection | list |  | |
| secret_key_ref | [Conditionally Required] Harness Secret reference value to be used for the AWS Secret Key.  Required if type == manual | string | | |
| access_key_ref | [Conditionally Required] AWS Access Key stored as a harness secret.  Required if type == manual. | string | ||
| role_arn | [Conditionally Required] AWS ARN of the role to be assumed.  Required if type == assume_role | string |  | X |
| external_id | [Optional] If the administrator of the account to which the role belongs provided you with an external ID, then enter that value.  Required if type == assume_role | string | | |
| duration | [Conditionally Required] (Number) The duration, in seconds, of the role session. The value can range from 900 seconds (15 minutes) to 3600 seconds (1 hour). By default, the value is set to 3600 seconds. An expiration can also be specified in the client request body. The minimum value is 1 hour.  Required if type == assume_role | number | 3600 ||


## Examples
Note:  For more information on referencing secrets see: https://developer.harness.io/docs/platform/secrets/add-use-text-secrets/#reference-the-secret-by-identifier

### Build a single Connector using manual credentials
```
module "aws_secrets" {
  source  = "harness-community/delivery/harness//modules/aws/secrets"

  name                = "aws-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"

  credentials = {
    type = "manual"
    access_key_ref = "AWS_ACCESS_KEY REF"
    secret_key_ref = "HARNESS_SECRET REF"
}
```

### Build a single Connector using credentials on delegate
```
module "aws_secrets" {
  source  = "harness-community/delivery/harness//modules/aws/secrets"

  name                = "aws-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"

  credentials = {
    type               = "inherit_from_delegate"
    delegate_selectors = ["delegate1"]
  }
}
```



### Build a single Connector assuming Role Using STS on Delegate
```
module "aws_secrets" {
  source  = "harness-community/delivery/harness//modules/aws/secrets"

  name                = "aws-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"

  credentials = {
    type        = "assume_role"
    role_arn    = "somerolearn"
    external_id = "externalid"
    duration    = 900
    delegate_selectors = ["delegate1"]
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
