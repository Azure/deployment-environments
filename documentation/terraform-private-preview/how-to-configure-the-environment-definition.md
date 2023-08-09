# How to Configure Terraform Environment Definitions

Creating environment definitions for Terraform is similar to our current ARM definitions. There are a few Terraform-specific things to worry about though.

## Guide

* Create a Terraform Environment Definition
  * Much like with our ARM files, we need to point to an entrypoint file with the "templatePath" property. In [this](https://github.com/j-rewerts/Project-Fidalgo-PrivatePreview/tree/main/TerraformCatalog/VNET) example, we use main.tf.

  * Ensure the "runner" property is set to "Terraform".
  
  * Optionally, your Terraform variables file ([example](https://github.com/j-rewerts/Project-Fidalgo-PrivatePreview/blob/main/TerraformCatalog/VNET/variables.tf)) can contain the variable "resource_group_name". This will be provided by the system, so you don't need this as a parameter in the manifest.yml file.
  
  * When configuring your azurerm Terraform provider block, ensure you set the "skip_provider_registration" to true. If you don't do this, Terraform will attempt to register tons of providers, which our PET identity usually doesn't have permissions to do.

```
provider "azurerm" {
  features {}

  skip_provider_registration = true
}
```

* Sync the Catalog

* Create your environment

``` bash
az devcenter dev environment create --dev-center my-devcenter --project my-project --name environment-001 --environment-type Prod --environment-definition-name VNET --catalog-name terraform-catalog --parameters "{ 'restrictedNetwork': 'true' }" --user-id me
```

* Try re-deploying

``` bash
az devcenter dev environment update --dev-center my-devcenter --project my-project --name environment-001 --parameters "{ 'restrictedNetwork': 'false' }" --user-id me
```
