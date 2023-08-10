locals {
  tags = {
    Owner       = "Azure Data Labs"
    Project     = "Azure Data Labs"
    Environment = "dev"
    Toolkit     = "Terraform"
    Template    = "data-science-aml"
    Name        = "${var.prefix}"
  }

  dns_zones = [
    "privatelink.sql.azuresynapse.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.azuresynapse.net",
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.azurecr.io",
    "privatelink.servicebus.windows.net",
    "privatelink.api.azureml.ms",
    "privatelink.notebooks.azure.net"
  ]

  safe_prefix  = replace(local.prefix, "-", "")
  safe_postfix = replace(local.postfix, "-", "")

  basename      = "${local.prefix}-${local.postfix}"
  safe_basename = "${local.safe_prefix}${local.safe_postfix}"

  # Configuration

  config = yamldecode(file("config-lab.yml"))

  resource_group_name = local.config.variables.enable_ade_deployment == "true" ? var.resource_group_name : length(module.resource_group) > 0 ? module.resource_group[0].name : ""
  location            = local.config.variables.location != null ? local.config.variables.location : var.location
  prefix              = local.config.variables.prefix != null ? local.config.variables.prefix : var.prefix
  postfix             = local.config.variables.postfix != null ? local.config.variables.postfix : var.postfix

  enable_private_endpoints                = local.config.variables.enable_private_endpoints != null ? local.config.variables.enable_private_endpoints : var.enable_private_endpoints
  enable_jumphost                         = local.config.variables.enable_jumphost != null ? local.config.variables.enable_jumphost : var.enable_jumphost
  enable_synapse_workspace                = local.config.variables.enable_synapse_workspace != null ? local.config.variables.enable_synapse_workspace : var.enable_synapse_workspace
  enable_machine_learning_compute_cluster = local.config.variables.enable_machine_learning_compute_cluster != null ? local.config.variables.enable_machine_learning_compute_cluster : var.enable_machine_learning_compute_cluster
  enable_machine_learning_synapse_spark   = local.config.variables.enable_machine_learning_synapse_spark != null ? local.config.variables.enable_machine_learning_synapse_spark : var.enable_machine_learning_synapse_spark

  enable_ade_deployment = local.config.variables.enable_ade_deployment
}
