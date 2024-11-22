# terraform-aws-vpc-peering

# AWS Infrastructure Provisioning with Terraform-aws-vpc-Peering module

## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [Examples](#examples)
- [License](#license)


## Introduction

This module is designed for peering two Amazon Virtual Private Clouds (VPCs) using AWS infrastructure. It provides a streamlined way to create a VPC peering connection between two VPCs in the `eu-west-1` region. The module is customizable and can be easily integrated into your Terraform infrastructure.

## Usage

To use this module, you should have Terraform installed and configured for AWS. This module provides the necessary Terraform configuration for creating AWS resources, and you can customize the inputs as needed. Below is an example of how to use this module## examples

# Example: default
```hcl
module "vpc-peering" {
  source           = "git::https://github.com/SyncArcs/terraform-aws-vpc-peering.git?ref=v1.0.0"
  name             = "dev"
  environment      = "test"
  managedby        = "SyncArcs"
  requestor_vpc_id = "vpc-03a4e6b96315a8cb2"
  acceptor_vpc_id  = "vpc-07e6faf30b2a9774f"
}
```

# Example: multi-region

```hcl
module "vpc-peering" {
  source           = "git::https://github.com/SyncArcs/terraform-aws-vpc-peering.git?ref=v1.0.0"
  name             = "test"
  environment      = "test"
  managedby        = "SyncArcs"
  requestor_vpc_id = "vpc-0538338eb28a72da0"
  acceptor_vpc_id  = "vpc-0504aa6182ab77a71"
  accept_region    = "us-east-2"
  auto_accept      = false
}
```


## Examples
For detailed examples on how to use this module, please refer to the [examples](https://github.com/SyncArcs/terraform-aws-vpc-peering/tree/master/_example) directory within this repository.

## License
This Terraform module is provided under the '[License Name]' License. Please see the [LICENSE](https://github.com/SyncArcs/terraform-aws-vpc-peering/blob/master/LICENSE) file for more details.

## Author
Your Name
Replace '[License Name]' and '[Your Name]' with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.21.0 |
| <a name="provider_aws.peer"></a> [aws.peer](#provider\_aws.peer) | >= 5.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | git::https://github.com/opsstation/terraform-aws-labels.git | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route.acceptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.acceptor-region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.requestor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.requestor-region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpc_peering_connection.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection.region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route_tables.acceptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_route_tables.requestor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_vpc.acceptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.requestor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accept_region"></a> [accept\_region](#input\_accept\_region) | The region of the accepter VPC of the VPC Peering Connection. | `string` | `""` | no |
| <a name="input_acceptor_allow_remote_vpc_dns_resolution"></a> [acceptor\_allow\_remote\_vpc\_dns\_resolution](#input\_acceptor\_allow\_remote\_vpc\_dns\_resolution) | Allow acceptor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requestor VPC. | `bool` | `true` | no |
| <a name="input_acceptor_vpc_id"></a> [acceptor\_vpc\_id](#input\_acceptor\_vpc\_id) | Acceptor VPC ID. | `string` | `""` | no |
| <a name="input_auto_accept"></a> [auto\_accept](#input\_auto\_accept) | Automatically accept the peering (both VPCs need to be in the same AWS account). | `bool` | `true` | no |
| <a name="input_enable_peering"></a> [enable\_peering](#input\_enable\_peering) | Set to false to prevent the module from creating or accessing any resources. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`Environment`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'SyncArcs'. | `string` | `"SyncArcs"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `"https://github.com:SyncArcs/terraform-aws-vpc-peering"` | no |
| <a name="input_requestor_allow_remote_vpc_dns_resolution"></a> [requestor\_allow\_remote\_vpc\_dns\_resolution](#input\_requestor\_allow\_remote\_vpc\_dns\_resolution) | Allow requestor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the acceptor VPC. | `bool` | `true` | no |
| <a name="input_requestor_vpc_id"></a> [requestor\_vpc\_id](#input\_requestor\_vpc\_id) | Requestor VPC ID. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_accept_status"></a> [accept\_status](#output\_accept\_status) | The status of the VPC peering connection request. |
| <a name="output_connection_id"></a> [connection\_id](#output\_connection\_id) | VPC peering connection ID. |
| <a name="output_tags"></a> [tags](#output\_tags) | A mapping of tags to assign to the resource. |
<!-- END_TF_DOCS -->