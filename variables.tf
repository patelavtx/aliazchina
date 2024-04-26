variable "controller_ip" {
  description = "Set controller ip"
  type        = string
}

variable "ctrl_password" {
    type = string
}

variable "account" {
    type = string
    default = "AzCN-proj"
}

variable "cloud" {
  description = "Cloud type"
  type        = string

  validation {
    condition     = contains(["aws", "azure", "oci", "ali", "gcp"], lower(var.cloud))
    error_message = "Invalid cloud type. Choose AWS, Azure, GCP, ALI or OCI."
  }
  default = "Azure"
}

variable "cidr" {
  description = "Set vpc cidr"
  type        = string
  default = "10.84.28.0/23"
}
/*
variable "instance_size" {
  description = "Set vpc cidr"
  type        = string
}
*/
variable "region" {
  description = "Set regions"
  type        = string
  default = "China East"
}


variable "localasn" {
  description = "Set internal BGP ASN"
  type        = string
  default = "65084"
}

variable "bgp_advertise_cidrs" {
  description = "Define a list of CIDRs that should be advertised via BGP."
  type        = string
  default     = ""
}



#  nsg_management module

variable "use_existing_resource_group" {
    type = bool
    description = "Whether to deploy a resource group in the Azure Subscription where the gateways will be deployed or create a new resource group"
    default = false
}

variable "gateway_name" {
    type = string
    description = "Name of the Aviatrix Gateway"
}

variable "gateway_resource_group" {
     type = string
     default = "atulrg-tx84"
}



variable "tags" {
    type = map(string)
    description = "Tags to be applied to the public IP addresses created for the gateways. Make sure to use the correct format depending on the cloud you are deploying"
    default = {
      ProjectName        = "CN test"
      BusinessOwnerEmail = "nobody@test.com"
    }
}


variable "controller_nsg_name" {
    type = string
    description = "Name of the Network Security Group attached to the Aviatrix Controller Network Interface"  
}

variable "controller_nsg_resource_group_name" {
    type = string
    description = "Name of the Resource Group where the Network Security Group attached to the Aviatrix Controller Network Interface is deployed"  
}

variable "controller_nsg_rule_priority" {
    type = number
    description = "Priority of the rule that will be created in the existing Network Security Group attached to the Aviatrix Controller Network Interface. This number must be unique. Valid values are 100-4096"
    
    validation {
      condition = var.controller_nsg_rule_priority >= 100 && var.controller_nsg_rule_priority <= 4096
      error_message = "Priority must be a number between 100 and 4096"
    }
    default = "100"
}

variable "ha_enabled" {
    type = bool
    description = "Whether HAGW will be deployed. Defaults to true"
    default = true
}



# spoke vars


variable "transit_gw" {
    type = string
}

variable "nat_attached" {
  default     = "false"
}

variable "attached" {
  default     = "true"
}

variable "spokegateway_name" {
  default     = "spoketest"
}

variable "spokecidr" {
  description = " "
  default = "10.85.1.0/24"
}

variable "spokegateway_rg" {
  description = ""
  default = "atulrg-cnspoke83"
}


variable "spokeha_enabled" {
  description = "Required when spoke is HA pair."
  default     = false
}

variable "spokecontroller_nsg_rule_priority" {
    type = number
    description = "Priority of the rule that will be created in the existing Network Security Group attached to the Aviatrix Controller Network Interface. This number must be unique. Valid values are 100-4096"
    
    validation {
      condition = var.spokecontroller_nsg_rule_priority >= 100 && var.spokecontroller_nsg_rule_priority <= 4096
      error_message = "Priority must be a number between 100 and 4096"
    }
    default = "110"
}



# ALI Transit China

variable "aliaccount" {
    type = string
    default = "ALI-proj"
}

variable "alicloud" {
  description = "Cloud type"
  type        = string
  default = "ALI"

  validation {
    condition     = contains(["aws", "azure", "oci", "ali", "gcp"], lower(var.alicloud))
    error_message = "Invalid cloud type. Choose AWS, Azure, GCP, ALI or OCI."
  }
}

variable "alicidr" {
  description = "Set vpc cidr"
  type        = string
  default = "10.4.28.0/23"
}

/*
variable "instance_size" {
  description = "Set vpc cidr"
  type        = string
}
*/

variable "aliregion" {
  description = "Set regions"
  type        = string
  default = "acs-cn-beijing (Beijing)" 
}


variable "ali_cn_asn" {
  description = "Set internal BGP ASN"
  type        = string
  default = "65004"
}


#  ALI nsg_management module
variable "aligateway_name" {
    type = string
    description = "Name of the Aviatrix Gateway"
    default = "alitransit4-cn"
}


variable "alicontroller_nsg_rule_priority" {
    type = number
    description = "Priority of the rule that will be created in the existing Network Security Group attached to the Aviatrix Controller Network Interface. This number must be unique. Valid values are 100-4096"
    
    validation {
      condition = var.alicontroller_nsg_rule_priority >= 100 && var.alicontroller_nsg_rule_priority <= 4096
      error_message = "Priority must be a number between 100 and 4096"
    }
    default = "301"
}


# ali
variable "ali_global_region" {
    type = string
    description = "Alibaba Global Cloud Region Name"
    default = "acs-eu-central-1"
}

variable "ali_global_asn" {
    type = string
    description = "Alibaba Global Cloud Region Name"
    default = "65040"
}

variable "apipa1" {
  description = "Provide CSR vNet address space"
  default = "169.254.31.201/30"
}


variable "apipa2" {
  description = "Provide CSR vNet address space"
  default = "169.254.32.202/30"
}

locals {
  ali_gbl_apipa1 = cidrhost(var.apipa1,1)
  ali_gbl_apipa2 = cidrhost(var.apipa2,1)
  ali_cn_apipa1 = cidrhost(var.apipa1,2)
  ali_cn_apipa2 = cidrhost(var.apipa2,2)
 }