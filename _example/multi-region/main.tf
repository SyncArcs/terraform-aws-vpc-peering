provider "aws" {
  region = "us-east-1"
}

##-----------------------------------------------------------------------------
## multi region vpc-peering module call.
##-----------------------------------------------------------------------------

module "vpc-peering" {
  source           = "../../."
  name             = "test"
  environment      = "test"
  managedby        = "SyncArcs"
  requestor_vpc_id = "vpc-0538338eb28a72da0"
  acceptor_vpc_id  = "vpc-0504aa6182ab77a71"
  accept_region    = "us-east-2"
  auto_accept      = false
}


