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

module "subnet_compute" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/subnet"

  name                                      = "snet-${local.prefix}-${local.postfix}-compute"
  resource_group_name                       = local.resource_group_name
  vnet_name                                 = module.virtual_network[0].name
  address_prefixes                          = ["10.0.2.0/24"]
  private_endpoint_network_policies_enabled = true

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

# Network security groups

module "network_security_group_training" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/network-security-group"

  basename            = "nsg-${local.basename}-01"
  resource_group_name = local.resource_group_name
  location            = local.location

  tags = local.tags

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

# Network security rules

module "network_security_rule_training_batchnodemanagement" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/network-security-rule"

  name                       = "BatchNodeManagement"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "29876-29877"
  source_address_prefix      = "BatchNodeManagement"
  destination_address_prefix = "*"

  resource_group_name         = local.resource_group_name
  network_security_group_name = module.network_security_group_training[0].name

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

module "network_security_rule_training_azuremachinelearning" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/network-security-rule"

  name                       = "AzureMachineLearning"
  priority                   = 110
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "44224"
  source_address_prefix      = "AzureMachineLearning"
  destination_address_prefix = "*"

  resource_group_name         = local.resource_group_name
  network_security_group_name = module.network_security_group_training[0].name

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

# NSG associations

module "subnet_network_security_group_association_training" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/subnet-network-security-group-association"

  subnet_id                 = module.subnet_compute[0].id
  network_security_group_id = module.network_security_group_training[0].id

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

# User Defined Routes

module "route_table_training" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/route-table"

  basename            = local.basename
  location            = local.location
  resource_group_name = local.resource_group_name

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

module "route_training_internet" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/route"

  name                = "Internet"
  resource_group_name = local.resource_group_name
  route_table_name    = module.route_table_training[0].name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

module "route_training_azureml" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/route"

  name                = "AzureMLRoute"
  resource_group_name = local.resource_group_name
  route_table_name    = module.route_table_training[0].name
  address_prefix      = "AzureMachineLearning"
  next_hop_type       = "Internet"

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

module "route_training_batch" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/route"

  name                = "BatchRoute"
  resource_group_name = local.resource_group_name
  route_table_name    = module.route_table_training[0].name
  address_prefix      = "BatchNodeManagement"
  next_hop_type       = "Internet"

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}

# UDR associations

module "subnet_route_table_association_training" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/subnet-route-table-association"

  subnet_id      = module.subnet_compute[0].id
  route_table_id = module.route_table_training[0].id

  count = local.enable_private_endpoints ? 1 : (local.enable_jumphost ? 1 : 0)
}