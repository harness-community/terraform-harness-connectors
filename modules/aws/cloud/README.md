# Terraform Modules for Harness Connectors - Azure Cloud
Terraform Module for creating and managing the Harness Connector for Azure Cloud

## Summary
This module handle the creation and managment of Connectors by leveraging the Harness Terraform provider

## Supported Terraform Versions
    - v1.3.7
    - v1.3.8
    - v1.3.9
    - v1.4.0

## Providers

```
terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "~> 0.14.0"
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

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| name | [Required] Name of the connector. | string |  | X |
| identifier | [Optional] Provide a custom identifier.  More than 2 but less than 128 characters and can only include alphanumeric or '_' | string | null | |
| organization_id | [Optional] Provide an organization reference ID. Must exist before execution | string | null | |
| project_id | [Optional] Provide an project reference ID. Must exist before execution | string | null | |
| description | [Optional] Description of the resource. | string | Harness Connector created via Terraform | |
| delegate_selectors | [Optional] Tags to filter delegates for connection.| list | [] | |
| type | [Required] Specifies the Connector Azure Cloud type. Supported values are azure or us_government| string | azure | |
| execute_on_delegate | [Optional] Execute on delegate or not. | boolean | true | |
| azure_credentials | [Required] Azure Connector Credentials. | map | | See block definition below |
| tags | [Optional] Provide a Map of Tags to associate with the project | map(any) | {} | |
| global_tags | [Optional] Provide a Map of Tags to associate with the project and resources created | map(any) | {} | |

### Variables - azure_credentials

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| type | [Required] Type can either be delegate or service_principal. | string |  | X |
| delegate_auth | [Optional] Type can either be system or user. Valid if type == delegate | string | system | |
| tenant_id | [Conditionally Required] Azure Tenant ID. Mandatory if type == service_principal | string | | X |
| client_id | [Conditionally Required] Azure Service Principal or Managed Identity ID. Mandatory if type == delegate && delegate_auth == user OR type == service_principal | string | | X|
| secret_kind | [Conditionally Required] Azure Client Authentication model can be either secret or certifiate. Mandatory if type == service_principal | string | | X |
| secret_location | [Optional] Location within Harness that the secret is stored.  Supported values are "account", "org", or "project" | string | project | |
| secret_name | [Conditionally Required] Existing Harness Secret containing Azure Client Authentication details. Mandatory if type == service_principal | string | | X|

## Examples
### Build a single Connector using delegate System-Assigned Managed Identity
```
module "azure_cloud" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/azure/cloud"

  name                = "azure-global-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  delegate_selectors  = ["account"]
  execute_on_delegate = true
  azure_credentials = {
    type = "delegate"
  }
}
```

### Build a single Connector using delegate User-Assigned Managed Identity
```
module "azure_cloud" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/azure/cloud"

  name                = "azure-lob-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  delegate_selectors  = ["account"]
  execute_on_delegate = true
  azure_credentials = {
    type          = "delegate"
    delegate_auth = "user"
    client_id     = "00000000-0000-0000-0000-000000000000"
  }
}
```

### Build a single Connector using Azure Service Principal with ClientSecret
```
module "azure_cloud" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/azure/cloud"

  name                = "azure-lob-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  azure_credentials = {
    type            = "service_principal"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    client_id       = "00000000-0000-0000-0000-000000000000"
    secret_kind     = "secret"
    secret_location = "project"
    secret_name     = "azure-lob-credentials"
  }
}
```

### Build a single Connector using Azure Service Principal with ClientCertificate
```
module "azure_cloud" {
  source = "git@github.com:harness-community/terraform-harness-delivery.git//modules/azure/cloud"

  name                = "azure-lob-connector"
  organization_id     = "myorg"
  project_id          = "myproject"
  azure_credentials = {
    type            = "service_principal"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    client_id       = "00000000-0000-0000-0000-000000000000"
    secret_kind     = "certificate"
    secret_location = "project"
    secret_name     = "azure-lob-certificate"
  }
}
```

## Contributing
A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors
Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](../LICENSE) for full details.
