# Onboarding Process

If you haven't already signed-up for Terraform early access and want to sign-up now, please [sign-up by filling out the form](https://aka.ms/ade-terraform-signup) or [email us](mailto:adesupport@microsoft.com).

We will need following information to onboard you onto the private preview of the Terraform support:
 - Subscription(s) in which Dev Center(s) are or would be created
 - Region(s) in which the Dev Center(s) are created

Once we receive the information, we will onboard your subscriptions and will directly share instructions on how you can try out the private preview. 

# Instructions on trying out Terraform templates in Azure Deployment Environments(ADE)

ADE's support for Terraform templates enables enterprise customers to configure the app infrastructure using Terraform IaC, securely provide them to dev teams through Catalog and empower dev teams to use those Terraform templates to spin up deployment environments.

The end-to-end workflows largely remain the same and are detailed out in [official ADE documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/). Official documentation details out the step-by-step process to [attach a repo as a catalog](https://learn.microsoft.com/en-us/azure/deployment-environments/how-to-configure-catalog).

The only difference is how an Environment Defintion needs to be configured when using Terraform IaC and is detailed out in the below section

## How to Configure Terraform Environment Definitions

Official documentation details out the step by step process that needs to be followed when [configuring an environment definition using ARM](https://learn.microsoft.com/en-us/azure/deployment-environments/configure-environment-definition) and below are a few instructions that needs to be followed when configuring an environment defintion using Terraform IaC.

We are also providing a [sample catalog](./SampleCatalog) that contains 5 sample environment definitions that were built using Terraform IaC. You may directly leverage these templates to quickly experiment with the end to end workflows.

* Create a Terraform Environment Definition
  * Similar to ARM files, you need to point to an entrypoint file with the "templatePath" property. In [this](https://github.com/Azure/deployment-environments/blob/main/documentation/terraform-private-preview/WebApp/manifest.yaml#L5) example, we use web_app.tf.

  * Ensure the "runner" property is set to "Terraform".
  
  * When configuring your "AzureRM" Terraform provider block, ensure you set the "skip_provider_registration" to true. If you don't do this, Terraform will attempt to register tons of providers, which our PET identity usually doesn't have permissions to do.

```
provider "azurerm" {
  features {}

  skip_provider_registration = true
}
```

* If you are adding Terraform based environment definitons to an existing Catalog, sync the Catalog before attempting to create an environment using the specific environment definition.

* Create your environment

You will now be able to create an environment directly in the [developer portal](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments#create-an-environment) or [through CLI](https://learn.microsoft.com/en-us/azure/deployment-environments/how-to-create-access-environments#create-an-environment) using the Terraform based environment defintions

# Getting help or providing feedback

If you are facing any issues or have feedback to share on Terraform support, In general, our team uses either Azure support or the [Developer Community](https://developercommunity.visualstudio.com/deploymentenvironments). Please submit issues to the developer community.
