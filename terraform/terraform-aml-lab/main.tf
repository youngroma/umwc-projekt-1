############################
# Azure Machine Learning – pełny zestaw zależności
# Region: francecentral
############################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Dane o kliencie/subskrypcji – potrzebne do Key Vault i wygodnych outputów (URL)
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# ---- Lokalne nazwy zasobów ----
locals {
  student_id    = "50539" # <<< WPISZ SWÓJ NUMER INDEKSU
  location      = "norwayeast"
  rg_name       = "rg-aml-${local.student_id}"
  sa_name       = "stor${local.student_id}"
  kv_name       = "kv${local.student_id}"
  la_name       = "la${local.student_id}"
  ai_name       = "ai${local.student_id}"
  acr_name      = "acr${local.student_id}"
  aml_ws_name   = "amlws-${local.student_id}"
}

# Generator losowego suffiksu do Storage Account (unikalność DNS)
resource "random_string" "sa_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_resource_group" "aml" {
  name     = local.rg_name
  location = local.location
}

# ---- Storage Account dla AML ----
resource "azurerm_storage_account" "aml" {
  name                               = local.sa_name
  resource_group_name                = azurerm_resource_group.aml.name
  location                           = local.location
  account_tier                       = "Standard"
  account_replication_type           = "LRS"
  allow_nested_items_to_be_public    = false
  min_tls_version                    = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}

# ---- Log Analytics Workspace (monitoring) ----
resource "azurerm_log_analytics_workspace" "aml" {
  name                = local.la_name
  location            = local.location
  resource_group_name = azurerm_resource_group.aml.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---- Application Insights (workspace-based) ----
resource "azurerm_application_insights" "aml" {
  name                = local.ai_name
  location            = local.location
  resource_group_name = azurerm_resource_group.aml.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.aml.id
}

# ---- Key Vault (sekrety AML) ----
resource "azurerm_key_vault" "aml" {
  name                              = local.kv_name
  resource_group_name               = azurerm_resource_group.aml.name
  location                          = local.location
  tenant_id                         = data.azurerm_client_config.current.tenant_id
  sku_name                          = "standard"
  purge_protection_enabled          = false
  soft_delete_retention_days        = 7
  enabled_for_deployment            = true
  enabled_for_template_deployment   = true
  public_network_access_enabled     = true
}

# Dostęp do Key Vault dla aktualnego użytkownika
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.aml.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Backup","Restore"]
}

# ---- Azure Container Registry ----
resource "azurerm_container_registry" "aml" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.aml.name
  location            = local.location
  sku                 = "Basic"
  admin_enabled       = true
}

# ---- Azure Machine Learning Workspace (v2) ----
resource "azurerm_machine_learning_workspace" "aml" {
  name                    = local.aml_ws_name
  location                = local.location
  resource_group_name     = azurerm_resource_group.aml.name

  application_insights_id = azurerm_application_insights.aml.id
  key_vault_id            = azurerm_key_vault.aml.id
  storage_account_id      = azurerm_storage_account.aml.id
  container_registry_id   = azurerm_container_registry.aml.id

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = true
  description                   = "AML workspace for lab (francecentral)"
}

# ---- Outputs ----
locals {
  aml_ws_resource_id = azurerm_machine_learning_workspace.aml.id
  aml_portal_url     = "https://ml.azure.com/?wsid=${local.aml_ws_resource_id}"
}

output "aml_workspace_name" {
  value       = azurerm_machine_learning_workspace.aml.name
  description = "Nazwa AML Workspace"
}

output "aml_workspace_id" {
  value       = local.aml_ws_resource_id
  description = "Resource ID AML Workspace"
}

output "aml_portal_url" {
  value       = "Link do AML w przeglądarce: ${local.aml_portal_url}"
  description = "Szybkie przejście do AML w przeglądarce"
}