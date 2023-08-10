# Log Analytics workspace

module "log_analytics_workspace" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/log-analytics/log-analytics-workspace"

  basename            = local.basename
  resource_group_name = local.resource_group_name
  location            = local.location

  tags = local.tags
}