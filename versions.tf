terraform {
  required_version = "~> 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }

  backend "remote" {
    organization = "andrzej"

    workspaces {
      name = "learn-terraform-sentinel"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {}
