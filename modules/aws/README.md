# Terraform Modules for Harness Platform Core Connectors - Azure
A collection of Terraform resources used to support the Azure connectors for the Harness Platform

## Goal
The goal of this repository is to provide simple to consume versions of the Harness Terraform resources in such a way to make the management of Harness via Terraform easy to adopt.

## Summary
This collection of Terraform modules focuses on the initial setup of Harness Platform configurations and base functionality.

## Providers

```
terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }
}
```

## Variables

_Note: When the identifier variable is not provided, the module will automatically format the identifier based on the provided resource name_

| Name | Description | Type | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| harness_platform_url | [Optional] Enter the Harness Platform URL.  Defaults to Harness SaaS URL | string | https://app.harness.io/gateway | |
| harness_platform_account | [Required] Enter the Harness Platform Account Number | string | | X |
| harness_platform_key | [Required] Enter the Harness Platform API Key for your account | string | | X |
| organization_name | Provide an organization name.  Must exist before execution | string | default | |
| project_name | Provide an project name in the chosen organization.  Must exist before execution | string | Default Project | |

## Examples
### Retrieve default module outputs
```
module "harness_connectors" {
  source = "git@github.com:harness-community/terraform-harness-connectors.git"

  harness_platform_account = "myaccount_id"
  harness_platform_key = "myplatform_key"
  organization_name = "default"
  project_name = "Default Project"
}
```

## Additional Module Details
_This module is really designed to be driven by leveraging the submodules.  For more information on each of these, you can review the associated README file_

### Azure
Create and manage new Harness Platform Azure Connectors.  Read more about this module in the [README](modules/azure/README.md)

### SCM
Create and manage new Harness Platform GitHub Connectors.  Read more about this module in the [README](modules/scm/README.md)

### Artifacts
Create and manage new Harness Platform GitHub Connectors.  Read more about this module in the [README](modules/artifacts/README.md)

## Contributing
A complete [Contributors Guide](CONTRIBUTING.md) can be found in this repository

## Authors
Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](LICENSE) for full details.
