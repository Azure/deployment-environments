# Azure Data Labs - Azure Machine Learning

This template repository contains all templates to deploy a (secure) Azure Machine Learning environment. This template offers some optional modules which can be enabled/disabled to support some of architectures below. This template was provided by Azure Data Labs and utilized their modules, and was tweaked to provide ADE support.

### What will be deployed?

By navigating through the deployment steps, you will deploy the following resources in an Azure subscription:

| Module | Default? | Comment |
| - | - | - |
| [Storage Account](./infra/storage_account.tf) | Yes | ADLS Gen2. Includes `blob` and `file` private endpoints (PEs) if  `enable_private_endpoints`
| [Key Vault](./infra/key_vault.tf) | Yes | Includes `vault` PE if `enable_private_endpoints`
| [Container Registry](./infra/container_registry.tf) | Yes | Includes `registry` PE if `enable_private_endpoints`
| [Application Insights](./infra/application_insights.tf) | Yes | n/a
| [Virtual Network](./infra/network.tf) | Yes | 10.0.0.0/16 by default
| [Subnet](./infra/network.tf) | Yes | Includes three subnets `default` (10.0.1.0/24), `compute` (10.0.2.0/24) and `bastion` (10.0.10.0/27)
| [Synapse Workspace](./infra/synapse.tf) | No | Enable by `enable_synapse_workspace`
| [Synapse Spark Pool](./infra/synapse.tf) | No | Enable by `enable_synapse_spark_pool`
| [Jumphost (Windows)](./infra/jumphost.tf) | No | Includes Bastion, enable by `enable_jumphost`

### Deployment

- **Enabling / disabling secure deployment**: to enable/disable secure deployment, change `enable_private_endpoints` in config-lab.yml.
- **Enabling / disabling resources**: to enable/disable optional modules, change `enable_{optional-module}` flag in config-lab.yml. 
- **Deploying the template**: to deploy this template, see [Create an Environment](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments).

### Related Architectures

- 📘 [Secure Azure Machine Learning Service (AzureML) Environment](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/secure-azure-machine-learning-service-azureml-environment/ba-p/3162297)
- 📘 [Azure Machine Learning Architecture](https://docs.microsoft.com/en-us/azure/architecture/solution-ideas/articles/azure-machine-learning-solution-architecture)
- 📘 [Enterprise Security and Compliance for Azure Machine Learning](https://techcommunity.microsoft.com/t5/ai-machine-learning-blog/enterprise-security-and-compliance-for-azure-machine-learning/ba-p/3484858)
