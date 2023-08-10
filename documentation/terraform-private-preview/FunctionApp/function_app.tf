# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This file is hosted @ https://fidalgocli.blob.core.windows.net/cli/function_app.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.75"
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

variable "os_type" {
  default = "linux"
}

variable "runtime" {
  default = "python"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_application_insights" "main" {
  name                = replace(var.resource_name, " ", "-")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  application_type    = "web"
  tags                = {}
}

resource "azurerm_storage_account" "main" {
  name                      = lower(replace(replace(var.resource_name, " ", ""), "-", ""))
  resource_group_name       = data.azurerm_resource_group.rg.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "RAGRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true
  tags                      = {}
}

resource "azurerm_app_service_plan" "main" {
  name                = replace(var.resource_name, " ", "-")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  kind                = "FunctionApp"
  tags                = {}

  reserved = var.os_type == "linux" ? true : false

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "main" {
  name                       = replace(var.resource_name, " ", "-")
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.main.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  https_only                 = true
  version                    = "~3"
  tags                       = {}

  os_type                    = var.os_type
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.main.instrumentation_key
    FUNCTIONS_WORKER_RUNTIME       = var.runtime
  }

  identity {
    type = "SystemAssigned"
  }
}
