terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}

variable "resource_group_name" {}

variable "resource_name" {}

variable "location" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_service_plan" "service_plan" {
  name                = replace(var.resource_name, " ", "-")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku_name            = "P1v2"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "example" {
  name                = replace(var.resource_name, " ", "-")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.service_plan.id

  site_config {}
}
