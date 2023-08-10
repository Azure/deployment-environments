# Appplication insights

module "application_insights" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/application-insights"

  basename            = local.basename
  resource_group_name = local.resource_group_name
  location            = local.location
  application_type    = "web"

  tags = local.tags
}