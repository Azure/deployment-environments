module "event_hubs_namespace" {
  #source = "github.com/Azure/azure-data-labs-modules/terraform/event-hubs/event-hubs-namespace"
  source = "git::https://github.com/Azure/azure-data-labs-modules.git//terraform/event-hubs/event-hubs-namespace?ref=v1.5.0-beta"

  basename            = local.basename
  resource_group_name = local.resource_group_name
  location            = local.location

  subnet_id            = local.enable_private_endpoints ? module.subnet_default[0].id : null
  private_dns_zone_ids = local.enable_private_endpoints ? [module.private_dns_zones[0].list["privatelink.servicebus.windows.net"].id] : null

  module_enabled      = local.enable_event_hub
  is_private_endpoint = local.enable_private_endpoints

  tags = local.tags
}