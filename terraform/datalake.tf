resource "random_pet" "storage_account_gen2_name" {
  prefix = var.storage_account_gen2_name_prefix
  length = 1
  separator = ""
}

resource "azurerm_storage_account" "lake" {
  name                     = random_pet.storage_account_gen2_name.id
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
}

resource "azurerm_role_assignment" "sbdc_current_user" {
  scope                = azurerm_storage_account.lake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.aad_login.object_id
}

resource "azurerm_role_assignment" "sbdc_syn_ws" {
  scope                = azurerm_storage_account.lake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.default.identity[0].principal_id
}

resource "azurerm_role_assignment" "c_syn_ws" {
  scope                = azurerm_storage_account.lake.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_synapse_workspace.default.identity[0].principal_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "lake_filesystem" {
  name               = "default"
  storage_account_id = azurerm_storage_account.lake.id

  depends_on = [
    azurerm_role_assignment.sbdc_current_user
  ]
}