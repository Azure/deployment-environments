# Onboarding

To join the Terraform private preview, please submit a support request in the Azure portal on "Azure Deployment Environments". Be sure to include these in the support request:
 - the Dev Center name
 - the subscription the Dev Center is in
 - the region the dev center is in

We will whitelist Terraform environments in your subscription.

# How to Configure Terraform Environment Definitions

Creating environment definitions for Terraform is similar to our current ARM definitions. There are a few Terraform-specific things to worry about though.

This folder contains 5 functioning environment definitions of varying complexity. Feel free to add this folder as a catalog to your dev center.

## Guide

* Create a Terraform Environment Definition
  * Much like with our ARM files, we need to point to an entrypoint file with the "templatePath" property. In [this](https://github.com/Azure/deployment-environments/blob/main/documentation/terraform-private-preview/WebApp/manifest.yaml#L5) example, we use web_app.tf.

  * Ensure the "runner" property is set to "Terraform".
  
  * Optionally, your Terraform variables file ([example](https://github.com/Azure/deployment-environments/blob/main/documentation/terraform-private-preview/WebApp/web_app.tf#L18C1-L18C34)) can contain the variable "resource_group_name". This will be provided by the system, so you don't need this as a parameter in the manifest.yml file.
  
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
# Issues

In general, our team uses either Azure support or the [Developer Community](https://developercommunity.visualstudio.com/deploymentenvironments). Please submit issues to the developer community.
