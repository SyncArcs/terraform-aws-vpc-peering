data "aws_region" "default" {}

data "aws_caller_identity" "current" {}

locals {
  accept_region = var.auto_accept == false ? var.accept_region : data.aws_region.default.id
}

module "labels" {
  source      = "git::https://github.com/opsstation/terraform-aws-labels.git?ref=v1.0.0"
  name        = var.name
  environment = var.environment
  repository  = var.repository
  managedby   = var.managedby
  label_order = var.label_order

}

##-----------------------------------------------------------------------------
## Provides a resource to manage a VPC peering connection.
##-----------------------------------------------------------------------------
resource "aws_vpc_peering_connection" "default" {
  count = var.enable_peering && var.auto_accept ? 1 : 0

  vpc_id      = var.requestor_vpc_id
  peer_vpc_id = var.acceptor_vpc_id
  auto_accept = var.auto_accept
  accepter {
    allow_remote_vpc_dns_resolution = var.acceptor_allow_remote_vpc_dns_resolution
  }
  requester {
    allow_remote_vpc_dns_resolution = var.requestor_allow_remote_vpc_dns_resolution
  }
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-peering", module.labels.id)
    }
  )
}

##-----------------------------------------------------------------------------
##provides details about a requestor VPC.
##-----------------------------------------------------------------------------
data "aws_vpc" "requestor" {
  count = var.enable_peering ? 1 : 0
  id    = var.requestor_vpc_id
}

##-----------------------------------------------------------------------------
## provides details about a acceptor VPC.
##-----------------------------------------------------------------------------
data "aws_vpc" "acceptor" {
  provider = aws.peer
  count    = var.enable_peering ? 1 : 0
  id       = var.acceptor_vpc_id
}

##-----------------------------------------------------------------------------
## This resource can be useful for getting back a list of acceptor route table ids to be referenced elsewhere.
##-----------------------------------------------------------------------------
data "aws_route_tables" "acceptor" {
  provider = aws.peer
  count    = var.enable_peering ? 1 : 0
  vpc_id   = join("", data.aws_vpc.acceptor[*].id)
}

##-----------------------------------------------------------------------------
## This resource can be useful for getting back a list of requestor route table ids to be referenced elsewhere.
##-----------------------------------------------------------------------------
data "aws_route_tables" "requestor" {
  count  = var.enable_peering ? 1 : 0
  vpc_id = join("", data.aws_vpc.requestor[*].id)
}

##-----------------------------------------------------------------------------
## Provides a resource to manage the accepter's side of a VPC Peering Connection.
##-----------------------------------------------------------------------------
resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = var.enable_peering && var.auto_accept == false ? 1 : 0
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.region[0].id
  auto_accept               = true
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-peering", module.labels.environment)
    }
  )
}

##-----------------------------------------------------------------------------
## provides details about a requestor Route.
##-----------------------------------------------------------------------------
resource "aws_route" "requestor" {
  count                     = var.enable_peering && var.auto_accept ? length(distinct(sort(data.aws_route_tables.requestor[0].ids))) * length(data.aws_vpc.acceptor[0].cidr_block_associations) : 0
  route_table_id            = element(distinct(sort(data.aws_route_tables.requestor[0].ids)), ceil(count.index / length(data.aws_vpc.acceptor[0].cidr_block_associations)))
  destination_cidr_block    = data.aws_vpc.acceptor[0].cidr_block_associations[count.index % length(data.aws_vpc.acceptor[0].cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = join("", aws_vpc_peering_connection.default[*].id)
  depends_on                = [data.aws_route_tables.requestor, aws_vpc_peering_connection.default]
}

##-----------------------------------------------------------------------------
## provides details about a requestor-region Route.
##-----------------------------------------------------------------------------
resource "aws_route" "requestor-region" {
  count = var.enable_peering && var.auto_accept == false ? length(
    distinct(sort(data.aws_route_tables.requestor[*].ids[0])),
  ) * length(data.aws_vpc.acceptor[0].cidr_block_associations) : 0
  route_table_id = element(
    distinct(sort(data.aws_route_tables.requestor[*].ids[0])),
    ceil(
      count.index / length(data.aws_vpc.acceptor[0].cidr_block_associations),
    ),
  )
  destination_cidr_block    = data.aws_vpc.acceptor[0].cidr_block_associations[count.index % length(data.aws_vpc.acceptor[0].cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = aws_vpc_peering_connection.region[0].id
  depends_on = [
    data.aws_route_tables.requestor,
    aws_vpc_peering_connection.region,
  ]
}

##-----------------------------------------------------------------------------
## provides details about a acceptor Route.
##-----------------------------------------------------------------------------
resource "aws_route" "acceptor" {
  count                     = var.enable_peering && var.auto_accept ? length(distinct(sort(data.aws_route_tables.acceptor[0].ids))) * length(data.aws_vpc.requestor[0].cidr_block_associations) : 0
  route_table_id            = element(distinct(sort(data.aws_route_tables.acceptor[0].ids)), ceil(count.index / length(data.aws_vpc.requestor[0].cidr_block_associations)))
  destination_cidr_block    = data.aws_vpc.requestor[0].cidr_block_associations[count.index % length(data.aws_vpc.requestor[0].cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = join("", aws_vpc_peering_connection.default[*].id)
  depends_on                = [data.aws_route_tables.acceptor, aws_vpc_peering_connection.default]
}

##-----------------------------------------------------------------------------
## provides details about a acceptor-region Route.
##-----------------------------------------------------------------------------
resource "aws_route" "acceptor-region" {
  count = var.enable_peering && var.auto_accept == false ? length(
    distinct(sort(data.aws_route_tables.acceptor[*].ids[0])),
  ) * length(data.aws_vpc.requestor[0].cidr_block_associations) : 0
  route_table_id = element(
    distinct(sort(data.aws_route_tables.acceptor[*].ids[0])),
    ceil(
      count.index / length(data.aws_vpc.requestor[0].cidr_block_associations),
    ),
  )
  provider                  = aws.peer
  destination_cidr_block    = data.aws_vpc.requestor[0].cidr_block_associations[count.index % length(data.aws_vpc.requestor[0].cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = aws_vpc_peering_connection.region[0].id
  depends_on = [
    data.aws_route_tables.acceptor,
    aws_vpc_peering_connection.region,
  ]
}

provider "aws" {
  alias  = "peer"
  region = local.accept_region
}
##-----------------------------------------------------------------------------
## Provides a resource to manage a VPC peering connection.
##-----------------------------------------------------------------------------
resource "aws_vpc_peering_connection" "region" {
  count = var.enable_peering && var.auto_accept == false ? 1 : 0

  vpc_id        = var.requestor_vpc_id
  peer_vpc_id   = var.acceptor_vpc_id
  auto_accept   = var.auto_accept
  peer_region   = local.accept_region
  peer_owner_id = data.aws_caller_identity.current.account_id
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-peering", module.labels.environment)
    }
  )
}