variable "azure-subscription" {
  description = "Azure subscription id"
}

variable "azure-tenant" {
  description = "Azure tenant id"
}

variable "azure-resource-group" {
  description = "Azure resource group name"
}

variable "azure-location" {
  description = "Azure location"
}

variable "azure-net-name" {
  description = "Azure virtual net name"
}

variable "azure-address-space" {
  description = "Azure address space"
  type        = list(string)
}

variable "azure-dns-servers" {
  description = "Azure DNS servers"
  type        = list(string)
}

variable "azure-subnet-name" {
  description = "Azure subnet name"
}

variable "azure-subnet-prefixes" {
  description = "Azure subnet prefixes"
  type        = list(string)
}

variable "azure-nsg-name" {
  description = "Azure network security group name"
}

# Global VM options

variable "azure-admin-username" {
  description = "Admin username"
}

variable "azure-storage-account-type" {
  description = "Storage account type"
  default     = "Standard_LRS"
}

variable "azure-os-publisher" {
  description = "Publisher of the image"
  default     = "Canonical"
}

variable "azure-os-offer" {
  description = "Offer of the image"
  default     = "0001-com-ubuntu-server-noble"
}

variable "azure-os-sku" {
  description = "SKU of the image"
  default     = "24_04-lts"
}

variable "azure-os-version" {
  description = "Version of the image"
  default     = "latest"
}

# Jenkins VM specific options

variable "jenkins-vm-name" {
  description = "Jenkins VM name"
}

variable "jenkins-vm-size" {
  description = "Jenkins VM size"
}

variable "jenkins-privateip-address" {
  description = "Jenkins VM private IP address"
}

# Build node VM specific options

variable "build-vm-name" {
  description = "Build node VM name"
}

variable "build-vm-size" {
  description = "Build node VM size"
}

variable "build-privateip-address" {
  description = "Build node VM private IP address"
}

# Staging (pre) node VM specific options

variable "stage-vm-name" {
  description = "Staging node VM name"
}

variable "stage-vm-size" {
  description = "Staging node VM size"
}

variable "stage-privateip-address" {
  description = "Staging node VM private IP address"
}

# Deployment (prod) node VM specific options

variable "deploy-vm-name" {
  description = "Deployment node VM name"
}

variable "deploy-vm-size" {
  description = "Deployment node VM size"
}

variable "deploy-privateip-address" {
  description = "Deployment node VM private IP address"
}

