# Déclaration des variables
variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
  default     = "my-test-terraform-rg"
}

variable "location" {
  description = "Emplacement des ressources"
  type        = string
  default     = "westeurope"
}

variable "vm_count" {
  description = "Nombre de machines virtuelles à déployer"
  type        = number
  default     = 1
}
