data "azurerm_client_config" "current" {}



resource "azurerm_key_vault" "fg-keyvault" {
  name                        = "fgkeyvault2024"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"


}

# this permission is for service connection from app registration, this is given to store database secrets to key vault
resource "azurerm_key_vault_access_policy" "kv_access_policy_01" {

  key_vault_id = azurerm_key_vault.fg-keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = "54b84d5e-84a5-49fc-8c76-f8d0604cc8c1"
  key_permissions = [
    "Get", "List"
  ]
  secret_permissions = [
    "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"
  ]

  depends_on = [azurerm_key_vault.fg-keyvault]
}

# permission to my self
resource "azurerm_key_vault_access_policy" "kv_access_policy_02" {
  key_vault_id       = azurerm_key_vault.fg-keyvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = "ab35c899-90de-4dcc-9d4f-ebae7a569976"
  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]

  depends_on = [azurerm_key_vault.fg-keyvault]
}



# need to enable the logging for key vault
# here i used the same storge accout created for function app: azurerm_linux_function_app
# if you use   log_analytics_destination_type = Dedicated then your cost would be higher

resource "azurerm_monitor_diagnostic_setting" "kvlogging" {
  name                       = "kvlogging-diagonise"
  target_resource_id         = azurerm_key_vault.fg-keyvault.id
  storage_account_id         = azurerm_storage_account.fn-storageaccount.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.fg-loganalytics.id


  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }

  }
  depends_on = [
    azurerm_storage_account.fn-storageaccount
  ]
}
