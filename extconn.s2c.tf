
/*
# Opt1 Setup  s2C ALI CN -> ALI GBL
resource "aviatrix_transit_external_device_conn" "to_aliglobal" {
  vpc_id                    = module.mc-transit-ali.vpc.vpc_id
  connection_name           = "2aliglobal"
  gw_name                   = module.mc-transit-ali.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = var.ali_cn_asn
  bgp_remote_as_num         = var.ali_global_asn
  remote_gateway_ip         = ""
  phase1_local_identifier    = "public_ip"
  pre_shared_key            = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "${local.ali_cn_apipa1}/30, ${local.ali_cn_apipa2}/30"
  remote_tunnel_cidr        = "${local.ali_gbl_apipa1}/30, ${local.ali_gbl_apipa2}/30"
  #ha_enabled                = "true"
  #backup_remote_gateway_ip  = "20.31.84.218"
  #backup_bgp_remote_as_num  = "65515"
  #backup_pre_shared_key     = "Aviatrix123#"
  #backup_local_tunnel_cidr  = "169.254.21.206/30, 169.254.22.206/30"
  #backup_remote_tunnel_cidr = "169.254.21.205/30, 169.254.22.205/30"
}
*/

/*
# Opt2 - Test with remote gateway configured
resource "aviatrix_transit_external_device_conn" "to_aliglobal" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output
 vpc_id                    = module.mc-transit-ali.vpc.vpc_id
  connection_name           = "2aliglobal"
  gw_name                   = module.mc-transit-ali.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = var.ali_cn_asn
  bgp_remote_as_num         = var.ali_global_asn
  remote_gateway_ip         = "8.211.33.239,8.209.105.152"
  phase1_local_identifier    = "public_ip"
  pre_shared_key            = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "${local.ali_cn_apipa1}/30, ${local.ali_cn_apipa2}/30"
  remote_tunnel_cidr        = "${local.ali_gbl_apipa1}/30, ${local.ali_gbl_apipa2}/30"
  #ha_enabled                = "true"
  #backup_remote_gateway_ip  = "20.31.84.218"
  #backup_bgp_remote_as_num  = "65515"
  #backup_pre_shared_key     = "Aviatrix123#"
  #backup_local_tunnel_cidr  = "169.254.21.206/30, 169.254.22.206/30"
  #backup_remote_tunnel_cidr = "169.254.21.205/30, 169.254.22.205/30"
}
*/


# Opt3a - Test with vpc peering using private ips
#Note/.  Issue with accessing vpc peering on ALI, need to chase G.Lam.
resource "aviatrix_transit_external_device_conn" "to_aliglobal" {
  vpc_id                    = module.mc-transit-ali.vpc.vpc_id
  connection_name           = "2aliglobal"
  gw_name                   = module.mc-transit-ali.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = var.ali_cn_asn
  bgp_remote_as_num         = var.ali_global_asn
  remote_gateway_ip         = "10.40.28.26, 10.40.28.27"
  phase1_local_identifier    = "private_ip"
  pre_shared_key            = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "${local.ali_cn_apipa1}/30, ${local.ali_cn_apipa2}/30"
  remote_tunnel_cidr        = "${local.ali_gbl_apipa1}/30, ${local.ali_gbl_apipa2}/30"
}




