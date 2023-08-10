# Onboarding Process

If you didn't sign-up for Terraform early access yet and want to sign-up now, please [sign-up by filling out the form](https://aka.ms/ade-terraform-signup) or [email us](mailto:adesupport@microsoft.com).

We will need following information to onboard you onto the private preview of the Terraform support:
 - Subscription(s) in which Dev Center(s) are or would be created
 - Region(s) in which the Dev Center(s) are created

Once we receive the information, we will onboard your subscriptions and will directly share instructions on how you can try out the private preview. 

# Instructions to leverage Terraform support in Azure Deployment Environments(ADE)

ADE's support for Terraform templates enables enterprises to configure the app infrastructure using Terraform IaC, securely provide them to dev teams through Catalog and empower dev teams to leverage those Terraform templates when spinning up deployment environments.

The end-to-end workflows largely remain the same and are detailed out in [official ADE documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/).

The only difference is how an Environment Definition needs to be configured when using Terraform IaC and is detailed out in the below section - 

We are also providing a [sample catalog](https://github.com/Azure/deployment-environments/tree/main/documentation/terraform-private-preview/sample-catalog) that contains 5 sample environment definitions that were built using Terraform IaC. You may directly leverage these templates to quickly experiment with the end to end workflows. Official documentation details out the step-by-step process to [attach a repo as a catalog](https://learn.microsoft.com/en-us/azure/deployment-environments/how-to-configure-catalog).


## How to Configure Terraform Environment Definitions

Official documentation details out the step by step process that needs to be followed when [configuring an environment definition using ARM](https://learn.microsoft.com/en-us/azure/deployment-environments/configure-environment-definition) and below are a few instructions that needs to be followed when configuring an environment definition using Terraform IaC.

* Create a Terraform Environment Definition
  * Similar to ARM files, you need to point to an entrypoint file with the "templatePath" property. In [this](https://github.com/Azure/deployment-environments/blob/main/documentation/terraform-private-preview/sample-catalog/web-app/manifest.yaml#L5) example, we use web_app.tf.

  * Ensure the "runner" property is set to "Terraform".
  
  * When configuring your "AzureRM" Terraform provider block, ensure you set the "skip_provider_registration" to true. If you don't do this, Terraform will attempt to register tons of providers, which our PET identity usually doesn't have permissions to do.

```
provider "azurerm" {
  features {}

  skip_provider_registration = true
}
```

* If you are adding Terraform based environment definitons to an existing Catalog, sync the Catalog before attempting to create an environment using the specific environment definition. You will now be able to create an environment directly in the [developer portal](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments#create-an-environment) or [through CLI](https://learn.microsoft.com/en-us/azure/deployment-environments/how-to-create-access-environments#create-an-environment) using the Terraform based environment definitions

# Getting help or providing feedback

If you are facing any issues or have feedback to share on Terraform support, please create a new issues in [GitHub Issues](https://github.com/Azure/deployment-environments/issues). 

If you have general feedback about the product, please submit the feedback on the [Developer Community](https://developercommunity.visualstudio.com/deploymentenvironments) or by [emailing us directly](mailto:adesupport@microsoft.com).
