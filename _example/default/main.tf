provider "aws" {
  region = "us-east-1"
}


module "vpc-peering" {
  source = "../../."
  name             = "dev"
  environment      = "test"
  managedby        = "SyncArcs"
  requestor_vpc_id = "vpc-03a4e6b96315a8cb2"
  acceptor_vpc_id  = "vpc-07e6faf30b2a9774f"
}