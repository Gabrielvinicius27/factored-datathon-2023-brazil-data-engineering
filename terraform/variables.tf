variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg-factored-datathon"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "storage_account_gen2_name_prefix" {
  default     = "stdatalake"
  description = "Prefix of the storage account name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "synapse_name" {
  type        = string
  description = "Name of the deployment"
  default     = null
}

variable "synapse_environment" {
  type        = string
  description = "Name of the environment"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Location of the resources"
  default     = "East US"
}

variable "aad_login" {
  description = "AAD login"
  type        = object({
    name      = string
    object_id = string
    tenant_id = string
  })
  default = null
}

variable "synadmin_username" {
  type        = string
  description = "Specifies The login name of the SQL administrator"
  default     = "synapseadmin"
}

variable "synadmin_password" {
  type        = string
  description = "The Password associated with the sql_administrator_login for the SQL administrator"
  default     = null
}

variable "enable_syn_sparkpool" {
  type        = bool
  description = "Variable to enable or disable Synapse Spark pool deployment"
  default     = false
}

variable "enable_syn_sqlpool" {
  type        = bool
  description = "Variable to enable or disable Synapse Dedicated SQL pool deployment"
  default     = false
}

variable "sas_uri" {
  type    = string
  description = "Value of the Key Vault Secret SAS URI"
  default = null
}

