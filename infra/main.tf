terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "e5590ea2-6632-45ad-b793-2a856f1c41a8"
}


data "azurerm_resource_group" "project7" {
  name = "project7"
}

resource "azurerm_service_plan" "plan" {
  name                = "project7-service-plan"
  resource_group_name = data.azurerm_resource_group.project7.name
  location            = data.azurerm_resource_group.project7.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "web" {
  name                = "project7-web-app-ajs"
  resource_group_name = data.azurerm_resource_group.project7.name
  location            = data.azurerm_resource_group.project7.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      java_server         = "JAVA"
      java_version        = "17"
      java_server_version = "17"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "8080"
  }
}