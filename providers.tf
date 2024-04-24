# Configure Aviatrix provider


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
  region = var.aliregion
  #region = "cn-hangzhou"
  # region = "cn-beijing"
  #skip_region_validation = "true"
  # Error: Invalid Alibaba Cloud region: acs-cn-beijing. You can skip checking this region by setting provider parameter 'skip_region_validation'
}

provider "alicloud" {
  alias = "global"
  #region = var.ali_global_region
  region = "eu-central-1"
}
