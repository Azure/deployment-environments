# Resource group

module "resource_group" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/resource-group"

  basename = local.basename
  location = local.location

  count = local.enable_ade_deployment ? 0 : 1

  tags = local.tags
}

module "resource_group_global_dns" {
  source = "github.com/Azure/azure-data-labs-modules/terraform/resource-group"

  basename = "${local.basename}-global-dns"
  location = local.location

  count = local.enable_private_endpoints ? 1 : 0

  tags = local.tags
}