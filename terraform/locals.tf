resource "random_pet" "synapse_name" {
  count = var.synapse_name == null ? 1 : 0
}

locals {
  basename      = "${try(random_pet.synapse_name[0].id, var.synapse_name)}-${var.synapse_environment}"
  safe_basename = replace(local.basename, "-", "")
}