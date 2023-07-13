terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.62.1"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.15.1"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = "c56aea2c-50de-4adc-9673-6a8008892c21"
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}