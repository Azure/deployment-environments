# Sample Catalog

The sample Catalog consists of a few catalog items (ARM Template + associated manifest) to help you get started with the service. You can fork the sample catalog and create your catalog to use with DevCenter.

## Catalog Items

- [Function App](FunctionApp): Deploys an Azure Function App, Storage Account, and Application Insights
- [Sandbox](Sandbox): Deploys an empty "sandbox" environment
- [Web App](WebApp): Deploys an Azure Web App without a data store

## ARM and Bicep

Each catalog item has _main.bicep_ file in addition to the ARM template (_azuredeploy.json_). This is because the ARM templates in this repository are written in [bicep](https://github.com/Azure/bicep) and transpiled to ARM using the [build-arm.py](/tools/build-arm.py) script in the [tools](/tools/) folder. The script simply walks the Environments folder and runs the [`az bicep build`](https://learn.microsoft.com/en-us/cli/azure/bicep?view=azure-cli-latest#az-bicep-build) command on each folder's main.bicep file, and is automatically run via the [build_arm.yml](/.github/workflows/build_arm.yml) workflow any time a bicep file changes.

**Please note: This is not a requirement for creating catalog item templates. It is done in this repo to make it easier to understand what is being deployed in each template.**

### What is Bicep?

Bicep is a Domain Specific Language (DSL) for deploying Azure resources declaratively. It aims to drastically simplify the authoring experience with a cleaner syntax, improved type safety, and better support for modularity and code re-use. Bicep is a transparent abstraction over ARM and ARM templates, which means anything that can be done in an ARM Template can be done in Bicep (outside of temporary [known limitations](https://github.com/Azure/bicep#known-limitations)). All resource types, apiVersions, and properties that are valid in an ARM template are equally valid in Bicep on day one (Note: even if Bicep warns that type information is not available for a resource, it can still be deployed).

Bicep code is transpiled to standard ARM Template JSON files, which effectively treats the ARM Template as an Intermediate Language (IL).
