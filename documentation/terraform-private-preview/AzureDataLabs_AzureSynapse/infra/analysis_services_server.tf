# Analysis Services

module "analysis_services" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/analysis-services-server"

  basename            = local.safe_basename
  resource_group_name = local.resource_group_name
  location            = local.location

  module_enabled = local.enable_analysis_services_server

  tags = local.tags
}