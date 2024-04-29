# ALIAZCHINA

Example of Aviatrix China deployment  



- ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `'inter ALICloud region leveraging vpc peering' with S2C (BGPoIPSEc) overlay (note/ BGPoLAN not supported by ALI)`

- ![#c5f015](https://placehold.co/15x15/c5f015/c5f015.png) `Works well with better throughput due to vpc peering`



There are a few options on connecting to China:

- OPT1:- Europe Azure Transit >  S2C < China Azure Transit
- OPT2:- Europe Azure Transit >  Europe Ali Transit > S2C < China Ali Transit < China Azure Transit
- OPT3:- As above but with   Europe Ali Transit > S2C/VPC Peering < China Ali Transit   


## Architecture
![Architecture](https://github.com/patelavtx/LabShare/blob/main/AviatrixChina-cn.PNG)




## Terraform code description

Summary of the *tf files, the code itself has some additional comments


**TF files**


 ![#c5f015](https://placehold.co/15x15/c5f015/c5f015.png) `'main.tf' `             
 
- Step1
  - ALI CN Aviatrix Transit + NSG rule entries for EIPs in Controller SG

- Step2
  - Azure CN Aviatrix transit + NSG rule entries for EIPs in Controller SG
  - Aviatrix Transit peering (Az transit + ALI Transit)

- Step3
  - Azure CN Spoke + NSG rule entries for EIPs in Controller SG
  - Azure Test Linux VM


 ![#c5f015](https://placehold.co/15x15/c5f015/c5f015.png) `'extconn.s2c.tf' `        

 - Provides opt1-opt3, setup for opt3
 - Since 'ALi Transit Global transit' private ips are not known, will need to update and re-apply Terraform after initial run
 
 

## Validated environment
```
Terraform v1.8.2  
on linux_amd64 (WSL) and TFC workspace
+ provider aviatrixsystems/aviatrix v3.1.0

```

## providers.tf
```

# AZ
provider azurerm {
    environment = "china"
    skip_provider_registration = "true"

    features {}
}

provider azurerm {
    alias = "gateways"
    environment = "china"
    skip_provider_registration = "true"
    features {}
}


#AVTX
provider azurerm {
    alias = "controller"
    environment = "china"
    skip_provider_registration = "true"
    features {}
}


provider "aviatrix" {
  controller_ip           = var.controller_ip
  username                = "admin"
  password                = var.ctrl_password

}

# ALI
provider "alicloud" {
  alias = "china"
  region = "cn-hangzhou"
  # region = "cn-beijing"
  #skip_region_validation = "true"
}

provider "alicloud" {
  alias = "global"
  #region = var.ali_global_region
  region = "eu-central-1"
}
```