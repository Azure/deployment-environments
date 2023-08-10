# Azure Deployment Environments Community

The goal of this repository is to provide sample infrastructure-as-code(IaC) templates that could be used to get started with the [Azure Deployment Environments](https://aka.ms/deploymentenvironments) service. This repository will also be used to provide documentation on capabilities that are in private preview(gated) and engage with customers who are experimenting with the capabilities in private preview.

Azure Deployment Environments(ADE) empowers development teams to quickly and easily spin-up app infrastructure with project-based templates that establish consistency and best practices while maximizing security, compliance, and cost efficiency. This on-demand access to secure environments accelerates the different stages of the software development lifecycle in a compliant and cost-efficient manner.

An Environment is a collection of Azure resources on which your application is deployed. For example, to deploy a web application, you might create an environment consisting of an App Service, Key Vault, Cosmos DB and a Storage account. An environment could consist of both Azure PaaS and IaaS resources such as AKS Cluster, App Service, VMs, databases, etc.

[Environments](https://github.com/Azure/deployment-environments/tree/main/Environments) folder consists of sample templates that you can use to quickly get started with the service.

[Documentation](https://github.com/Azure/deployment-environments/tree/main/documentation) folder details out capabilities that are currently in private preview and instructions on how to try them out.

> Note - ADE currently supports [ARM templates](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/overview) publicly and Terraform support is in private preview. In the near future, will support other IaC tools such as Bicep, Pulumi, etc.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
