# Bastion

module "bastion" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/bastion-host"

  basename            = local.basename
  resource_group_name = local.resource_group_name
  location            = local.location
  subnet_id           = local.enable_jumphost ? module.subnet_bastion[0].id : null

  module_enabled = local.enable_jumphost

  tags = local.tags
}

# Virtual machine

module "virtual_machine_jumphost" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/virtual-machine"

  basename            = local.basename
  resource_group_name = local.resource_group_name
  location            = local.location
  subnet_id           = local.enable_jumphost ? module.subnet_default[0].id : null
  jumphost_username   = var.jumphost_username
  jumphost_password   = var.jumphost_password

  module_enabled = local.enable_jumphost

  tags = local.tags
}