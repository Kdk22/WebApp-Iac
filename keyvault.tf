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


resource "azurerm_key_vault_access_policy" "kv_access_policy_01" {
  #This policy adds databaseadmin group with below permissions
  key_vault_id       = azurerm_key_vault.fg-keyvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]

  depends_on = [azurerm_key_vault.fg-keyvault]
}

# resource "azurerm_key_vault_access_policy" "kv_access_policy_02" {
#   #This policy adds databaseadmin group with below permissions
#   key_vault_id       = azurerm_key_vault.fg-keyvault.id
#   tenant_id          = data.azurerm_client_config.current.tenant_id
#   object_id          = "0aa40ef3-115e-4628-826d-ab7f53bd396f"
#   key_permissions    = ["Get", "List"]
#   secret_permissions = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]

#   depends_on = [azurerm_key_vault.fg-keyvault]
# }


# resource "azurerm_key_vault_access_policy" "kv_access_policy_03" {
#   #This policy adds databaseadmin group with below permissions
#   key_vault_id       = azurerm_key_vault.fg-keyvault.id
#   tenant_id          = data.azurerm_client_config.current.tenant_id
#   object_id          = "0aa40ef3-115e-4628-826d-ab7f53bd396f"
#   key_permissions    = ["Get", "List"]
#   secret_permissions = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]

#   depends_on = [azurerm_key_vault.fg-keyvault]
}

/*
need to enable the logging for key vault so 
resource "azurerm_monitor_diagnostic_setting" "kvlogging" {
  name               = "kvlogging-diagonise"
  target_resource_id = azurerm_key_vault.fg-keyvault.id
  storage_account_id = azurerm_storage_account.task1-storage.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.fg-loganalytics.id
  log_analytics_destination_type = Dedicated

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
  depends_on = [ azurerm_storage_account.task1-storage ]
}
*/