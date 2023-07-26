resource "azurerm_key_vault" "key_vault" {
  name                = "kv-factored-datathon"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = var.aad_login.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = var.aad_login.tenant_id
    object_id = var.aad_login.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }

  access_policy {
    tenant_id = var.aad_login.tenant_id
    object_id = azurerm_synapse_workspace.default.identity[0].principal_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "sas_uri" {
  name         = "secret-sas-uri"
  value        = var.sas_uri
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_synapse_linked_service" "linked_service_key_vault" {
  name                 = "kv-linked-service"
  synapse_workspace_id = azurerm_synapse_workspace.default.id
  type                 = "AzureKeyVault"   
  type_properties_json = <<JSON
{
    "baseurl": "${azurerm_key_vault.key_vault.vault_uri}"
}
JSON
}

resource "azurerm_synapse_linked_service" "blob_safactoreddatathon" {
  name                 = "syn-ls-blob-safactoreddatathon"
  synapse_workspace_id = azurerm_synapse_workspace.default.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "sasUri":{
        "type": "AzureKeyVaultSecret",
            "store": {
                "referenceName": "${azurerm_synapse_linked_service.linked_service_key_vault.name}", 
                "type": "LinkedServiceReference"
            },
            "secretName": "${azurerm_key_vault_secret.sas_uri.name}"
    }
}
JSON
}