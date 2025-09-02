terraform {
  backend "azurerm" {
    resource_group_name  = "project7"
    storage_account_name = "project7storageacc"
    container_name       = "tfstate"
    key                  = "project7/infra.tfstate"
  }
}