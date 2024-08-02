terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  # here i am storing the state file 
   backend "azurerm" {
    resource_group_name  = "myTFResourceGroup"
    storage_account_name = "statestoragetf"
    container_name       = "statecon"
    key                  = "terraform.tfstate"
  }
}


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Enviroment = "Task 1"
    Team       = "DevOps"
  }

}