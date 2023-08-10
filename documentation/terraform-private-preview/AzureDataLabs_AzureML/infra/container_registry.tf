# Container registry

module "container_registry" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/container-registry"

  basename            = local.safe_basename
  resource_group_name = local.resource_group_name
  location            = local.location
  sku                 = "Premium"
  admin_enabled       = true

  subnet_id            = local.enable_private_endpoints ? module.subnet_default[0].id : null
  private_dns_zone_ids = local.enable_private_endpoints ? [module.private_dns_zones[0].list["privatelink.azurecr.io"].id] : null

  is_private_endpoint = local.enable_private_endpoints

  tags = local.tags
}