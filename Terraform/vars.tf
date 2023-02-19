variable "prefix" {
    description = "The prefix which should be used for all resources in this example"
    default = "azurelabs-nd082"
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
    description = "Please input number of VM (from 2 to 5)"
    default = "2"
    type = number

    validation {
      condition = var.vm_count >= 2 && var.vm_count <= 5 
      error_message = "Accepted values: 2-5."
    }
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
