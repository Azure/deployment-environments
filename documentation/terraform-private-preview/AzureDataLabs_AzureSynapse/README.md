# Azure Data Labs - Azure Synapse Analytics

This template repository contains all templates to deploy a (secure) **Azure Synapse Analytics environment**. This template offers some optional modules which can be enabled/disabled to support some of architectures below. This template was developed by Azure Data Labs and utilized its' modules, and was tweaked to provide support for ADE.

### What will be deployed?

By navigating through the deployment steps, you will deploy the following resources in an Azure subscription:

| Module | Default? | Comment |
| - | - | - |
| [Storage Account](./infra/storage_account.tf) | Yes | ADLS Gen2. Includes `blob` and `dfs` private endpoints (PEs) if  `enable_private_endpoints`
| [Key Vault](./infra/key_vault.tf) | Yes | Includes `vault` PE if `enable_private_endpoints`
| [Virtual Network](./infra/network.tf) | Yes | 10.0.0.0/16 by default
| [Subnet](./infra/network.tf) | Yes | Includes two subnets `default` (10.0.1.0/24) and `bastion` (10.0.10.0/27)
| [Synapse Workspace](./infra//synapse.tf) | Yes | Includes `sql` and `dev` PEs + Private Link Hub if `enable_private_endpoints`
| [Synapse Spark Pool](./infra/synapse.tf) | No | Enable by `enable_synapse_spark_pool`
| [Synapse SQL Pool](./infra/synapse.tf) | No | Enable by `enable_synapse_sql_pool`
| [Data Factory](./infra/data_factory.tf) | No | Enable by `enable_data_factory`. Includes `df` and `portal` PEs if `enable_private_endpoints`
| [Event Hub](./infra/event_hub.tf) | No | Enable by `enable_event_hub`. Includes `namespace` PE if `enable_private_endpoints`
| [Analysis Services Server](./infra/analysis_services_server.tf) | No | Enable by `enable_analysis_services_server`
| [Jumphost (Windows)](./infra/jumphost.tf) | No | Includes Bastion, enable by `enable_jumphost`

### Deployment

- **Enabling / disabling secure deployment**: to enable/disable secure deployment, change `enable_private_endpoints` in config-lab.yml.
- **Enabling / disabling resources**: to enable/disable optional modules, change `enable_{optional-module}` flag in config-lab.yml. 
- **Deploying the template**: to deploy this template, see [Deploy an Environment](https://learn.microsoft.com/en-us/azure/deployment-environments/quickstart-create-access-environments).

### Related Architectures

- 📘 [Enterprise business intelligence](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/analytics/enterprise-bi-synapse)
- 📘 [Near real-time lakehouse data processing](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/data/real-time-lakehouse-data-processing)
