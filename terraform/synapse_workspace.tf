resource "azurerm_synapse_workspace" "default" {
  name                                 = "syn-${local.basename}"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.lake_filesystem.id

  sql_administrator_login          = var.synadmin_username
  sql_administrator_login_password = var.synadmin_password

  managed_resource_group_name = "${azurerm_resource_group.rg.name}-syn-managed"

  dynamic "aad_admin" {
    for_each = var.aad_login == null ? [] : ["aad_admin"]

    content {
      login     = var.aad_login.name
      object_id = var.aad_login.object_id
      tenant_id = var.aad_login.tenant_id
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_synapse_firewall_rule" "allow_my_ip" {
  name                 = "AllowMyPublicIp"
  synapse_workspace_id = azurerm_synapse_workspace.default.id
  start_ip_address     = data.http.ip.response_body
  end_ip_address       = data.http.ip.response_body
}