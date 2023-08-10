# Machine learning workspace

module "machine_learning_workspace" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/machine-learning/machine-learning-workspace"

  basename                = local.basename
  resource_group_name     = local.resource_group_name
  location                = local.location
  storage_account_id      = module.storage_account_mlw.id
  key_vault_id            = module.key_vault.id
  application_insights_id = module.application_insights.id
  container_registry_id   = module.container_registry.id

  subnet_id = local.enable_private_endpoints ? module.subnet_default[0].id : null
  private_dns_zone_ids = local.enable_private_endpoints ? [
    module.private_dns_zones[0].list["privatelink.api.azureml.ms"].id,
    module.private_dns_zones[0].list["privatelink.notebooks.azure.net"].id
  ] : null

  public_network_access_enabled = true
  image_build_compute_name      = "image-builder"

  is_private_endpoint = local.enable_private_endpoints

  tags = local.tags
}

# Machine learning Synapse Spark

module "machine_learning_synapse_spark" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/machine-learning/machine-learning-synapse-spark"

  basename                      = local.postfix
  location                      = local.location
  machine_learning_workspace_id = module.machine_learning_workspace.id
  synapse_spark_pool_id         = module.synapse_spark_pool.id

  module_enabled = local.enable_machine_learning_synapse_spark
}

# Machine learning compute clusters

module "machine_learning_compute_cluster_image-builder" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/machine-learning/machine-learning-compute-cluster"

  basename                      = "image-builder"
  location                      = local.location
  subnet_id                     = local.enable_private_endpoints ? module.subnet_compute[0].id : null
  machine_learning_workspace_id = module.machine_learning_workspace.id

  module_enabled = false
}

module "machine_learning_compute_cluster_cpu_cluster" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/machine-learning/machine-learning-compute-cluster"

  basename                      = "cpu-cluster"
  location                      = local.location
  subnet_id                     = local.enable_private_endpoints ? module.subnet_compute[0].id : null
  machine_learning_workspace_id = module.machine_learning_workspace.id

  module_enabled = local.enable_machine_learning_compute_cluster
}