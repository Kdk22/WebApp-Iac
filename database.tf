

#Create Random password 
resource "random_password" "randompassword" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#Create Key Vault Secret
# Here key vault is created first , then access policies then oly secretes are pushed to key vault
resource "azurerm_key_vault_secret" "sqladminpassword" {
  # checkov:skip=CKV_AZURE_41:Expiration not needed 
  name         = "sqladmin"
  value        = random_password.randompassword.result
  key_vault_id = azurerm_key_vault.fg-keyvault.id
  content_type = "text/plain"
  depends_on = [
    azurerm_mssql_database.fg-database,
    azurerm_key_vault.fg-keyvault,
    azurerm_key_vault_access_policy.kv_access_policy_sc,
    azurerm_key_vault_access_policy.kv_access_policy_me
  ]
}

#Azure sql database
resource "azurerm_mssql_server" "azuresql" {
  name                         = "fg-sqldb-prod"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "4adminu$er"
  administrator_login_password = random_password.randompassword.result

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = "0aa40ef3-115e-4628-826d-ab7f53bd396f"
  }
}

#add subnet from the backend vnet
#adding a new comment in main branch
resource "azurerm_mssql_virtual_network_rule" "allow-be" {
  name      = "be-sql-vnet-rule"
  server_id = azurerm_mssql_server.azuresql.id
  subnet_id = azurerm_subnet.be-subnet.id
  depends_on = [
    azurerm_mssql_server.azuresql
  ]
}

resource "azurerm_mssql_database" "fg-database" {
  name           = "fg-db"
  server_id      = azurerm_mssql_server.azuresql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false

  tags = {
    Application = "task1"
    Env         = "Prod"
  }
}

#this is python connection string and it's stored in key vault
resource "azurerm_key_vault_secret" "sqldb_cnxn" {
  name         = "fgsqldbconstring"
  value        = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:fg-sqldb-prod.database.windows.net,1433;Database=fg-db;Uid=4adminu$er;Pwd=${random_password.randompassword.result};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.fg-keyvault.id
  depends_on = [
    azurerm_mssql_database.fg-database,
    azurerm_key_vault.fg-keyvault,
    azurerm_key_vault_access_policy.kv_access_policy_sc,
    azurerm_key_vault_access_policy.kv_access_policy_me
  ]
}