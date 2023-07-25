terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      version = ">= 3.32.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "rg-factored-datathon-mint-magpie"
      storage_account_name = "tfstatem12o6"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}