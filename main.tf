

# STEP1 - ALI CHINA 
module "ali-gateway-nsg" {
  providers = {
    alicloud.china     = alicloud.china               # key = configuration_alias;  value = provider declaration
    azurerm.controller = azurerm.controller
  }
  source                             = "github.com/patelavtx/aviatrix_alicloud_china_gateway_azure_controller_nsg"    # forked from jocortems
  gateway_name                       = var.aligateway_name                                                               # Required. Must exactly match argument gw_name in the module below
  controller_nsg_name                = var.controller_nsg_name                                                        # Required. Name of the NSG associated with the Controller
  controller_nsg_resource_group_name = var.controller_nsg_resource_group_name                                         # Required. Name of the resource group where the NSG associated with the controller is deployed
  controller_nsg_rule_priority       = var.alicontroller_nsg_rule_priority                                               # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Controller
  ha_enabled                         = var.ha_enabled                                                                           # Optional. Defaults to true. Must match HA GW deployment in the module below
}


module "mc-transit-ali" {
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "2.5.3"
  name                = var.aligateway_name
  account             = var.aliaccount
  cloud               = var.alicloud
  region              = var.aliregion
  local_as_number     = var.ali_cn_asn
  allocate_new_eip    = true
  az_support          = false
  enable_segmentation = true
  gw_name             = var.aligateway_name              # ensure matches with the NSG module
  insane_mode         = false
  cidr                = var.alicidr
  ha_gw               = var.ha_enabled
}






# STEP2 - Azure Transit China

module "transit-gateway-nsg" {
  providers = {
    azurerm.gateways   = azurerm.gateways
    azurerm.controller = azurerm.controller
  }
  source                      = "github.com/patelavtx/aviatrix_controller_nsg_management_azure_china"
  gateway_resource_group      = var.gateway_resource_group # Required. The name of the resource group where the Aviatrix Gateways will be deployed
  use_existing_resource_group = false                      # Optional. Defaults to false. Whether to create a new resource group or use an existing one
  gateway_name                = var.gateway_name           # Required. This is used to derive the name for the Public IP addresses that will be used by the Aviatrix Gateway
  gateway_region              = "China East"               # Required. Azure China Region where the Aviatrix Gateways will be deployed
  tags = var.tags
  ha_enabled                         = var.ha_enabled                         # Optional. Defaults to true. If set to false only one Public IP address is created and must disable ha_gw when creating Aviatrix spoke or transit gateways              
  controller_nsg_name                = var.controller_nsg_name                # Required. Name of the NSG associated with the Aviatrix Controller
  controller_nsg_resource_group_name = var.controller_nsg_resource_group_name # Required. Name of the resource group where the NSG associated with the Aviatrix Controller is deployed
  controller_nsg_rule_priority       = var.controller_nsg_rule_priority       # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Aviatrix Controller
}




module "mc-transit" {
  source                           = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version                          = "2.5.3"
  cloud                            = "Azure"
  cidr                             = var.cidr
  region                           = var.region
  az_support                       = false
  account                          = var.account
  resource_group                   = module.transit-gateway-nsg.gateway_resource_group # created from nsg RG
  name                             = var.gateway_name
  allocate_new_eip                 = false
  ha_azure_eip_name_resource_group = format("%s:%s", module.transit-gateway-nsg.gateway_ha_vip.name, module.transit-gateway-nsg.gateway_ha_vip.resource_group_name)
  azure_eip_name_resource_group    = format("%s:%s", module.transit-gateway-nsg.gateway_vip.name, module.transit-gateway-nsg.gateway_vip.resource_group_name)
  enable_advertise_transit_cidr    = "true"
  eip                              = module.transit-gateway-nsg.gateway_vip.ip_address
  ha_eip                           = module.transit-gateway-nsg.gateway_ha_vip.ip_address
  enable_transit_firenet           = "false"
  enable_segmentation              = "false"
  tags                             = var.tags
  ha_gw                            = var.ha_enabled
}




#  gateway peering  to ALI transit if deployed  -  works
resource "aviatrix_transit_gateway_peering" "cn_az_ali_peering" {
  transit_gateway_name1                       = module.mc-transit.transit_gateway.gw_name
  transit_gateway_name2                       = "alitransit4-cn"
  enable_peering_over_private_network         = false
  enable_insane_mode_encryption_over_internet = false
}



#  STEP3 - Azure Spoke China
## deploy spoke china after transit chine
module "spoke-gateway-nsg" {
  providers = {
    azurerm.gateways = azurerm.gateways
    azurerm.controller = azurerm.controller
  }
  source                                      = "github.com/patelavtx/aviatrix_controller_nsg_management_azure_china"
  gateway_resource_group                      = var.spokegateway_rg      # Required. The name of the resource group where the Aviatrix Gateways will be deployed
  use_existing_resource_group                 = false                        # Optional. Defaults to false. Whether to create a new resource group or use an existing one
  gateway_name                                = var.spokegateway_name                     # Required. This is used to derive the name for the Public IP addresses that will be used by the Aviatrix Gateway
  gateway_region                              = var.region                   # Required. Azure China Region where the Aviatrix Gateways will be deployed
  tags                = var.tags
  ha_enabled                                  = var.spokeha_enabled                        # Optional. Defaults to true. If set to false only one Public IP address is created and must disable ha_gw when creating Aviatrix spoke or transit gateways              
  controller_nsg_name                         = var.controller_nsg_name                   # Required. Name of the NSG associated with the Aviatrix Controller
  controller_nsg_resource_group_name          = var.controller_nsg_resource_group_name                # Required. Name of the resource group where the NSG associated with the Aviatrix Controller is deployed
  controller_nsg_rule_priority                = var.spokecontroller_nsg_rule_priority                                # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Aviatrix Controller
}


module "spoke_azure_1" {
  source         = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version        = "1.6.5"
  cloud          = "Azure" # added for new mod
  transit_gw     = module.mc-transit.transit_gateway.gw_name
  az_support = false
  attached       = var.attached
  cidr           = var.spokecidr
  region         = var.region
  ha_gw          = var.spokeha_enabled
  account        = var.account
  insane_mode    = "false"
  resource_group = module.spoke-gateway-nsg.gateway_resource_group
  name = var.spokegateway_name
  subnet_pairs = "2"
  allocate_new_eip                            = false         # remember that NSG module is creating the EIPs; setting this to true causes conflict in NSG rule applied to controller
  #ha_azure_eip_name_resource_group            = format("%s:%s", module.spoke-gateway-nsg.gateway_ha_vip.name, module.spoke-gateway-nsg.gateway_ha_vip.resource_group_name)
  azure_eip_name_resource_group               = format("%s:%s", module.spoke-gateway-nsg.gateway_vip.name, module.spoke-gateway-nsg.gateway_vip.resource_group_name)
  eip                                         = module.spoke-gateway-nsg.gateway_vip.ip_address
  #ha_eip                                      = module.spoke-gateway-nsg.gateway_ha_vip.ip_address
  tags = var.tags 
}


module "azure-linux-vm-spoke85" {
  source = "github.com/patelavtx/azure-linux-passwd.git"
  #public_key_file = var.public_key_file                  # option used with different GH source that supports pubpriv key
  region = var.region
  resource_group_name =  module.spoke_azure_1.vpc.resource_group
  subnet_id =   module.spoke_azure_1.vpc.subnets[1].subnet_id 
  vm_name = "${module.spoke_azure_1.vpc.name}-vm"
}

output "spoke85-vm" {
  value = module.azure-linux-vm-spoke85
}
