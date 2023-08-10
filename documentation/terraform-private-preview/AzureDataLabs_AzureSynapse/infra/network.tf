# Virtual network

module "virtual_network" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/virtual-network"

  basename            = local.basename
  resource_group_name = local.resource_group_name
  location            = local.location
  address_space       = ["10.0.0.0/16"]

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)

  tags = local.tags
}

# Subnets

module "subnet_default" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/subnet"

  name                                      = "snet-${local.prefix}-${local.postfix}-default"
  resource_group_name                       = local.resource_group_name
  vnet_name                                 = module.virtual_network[0].name
  address_prefixes                          = ["10.0.1.0/24"]
  private_endpoint_network_policies_enabled = true

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

module "subnet_bastion" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/subnet"

  name                = "AzureBastionSubnet"
  resource_group_name = local.resource_group_name
  vnet_name           = module.virtual_network[0].name
  address_prefixes    = ["10.0.10.0/27"]

  count = local.enable_jumphost ? 1 : 0
}