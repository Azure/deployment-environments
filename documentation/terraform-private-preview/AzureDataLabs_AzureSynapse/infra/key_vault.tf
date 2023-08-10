# Key Vault

module "key_vault" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/key-vault"

  basename                 = local.basename
  resource_group_name      = local.resource_group_name
  location                 = local.location
  sku_name                 = "premium"
  purge_protection_enabled = false

  subnet_id            = local.enable_private_endpoints ? module.subnet_default[0].id : null
  private_dns_zone_ids = local.enable_private_endpoints ? [module.private_dns_zones[0].list["privatelink.vaultcore.azure.net"].id] : null

  is_private_endpoint = local.enable_private_endpoints

  tags = local.tags
}