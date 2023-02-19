variable "prefix" {
    description = "The prefix which should be used for all resources in this example"
  }
  
  variable "location" {
    description = "The Azure Region in which all resources in this example should be created."
    default = "eastus"
  }

  variable "packer_image_name" {
    description = "Name of the Packer image"
    default = "myPackerImage"
  }

  variable "platform_fault_domain_count" {
    default = "2"
    
  }
  variable "vm_count" {
    default = "2"
    type = string
  }

  variable "platform_update_domain_count" {
    default = "3"
  }

  variable "admin_username" {
    default = "azureadmin"
  }
  variable "admin_password" {
    default = "P@ssw0rd123"
  }
