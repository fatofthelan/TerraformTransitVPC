variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "aws_region" {
  default = "us-west-2"
}

variable "availability_zone" {
  default = "us-west-2a"
}

variable "transit_key_pair" {
  default = "transit-vpc-key"
}

variable "transit_key_pair_public" {
  default = "keys/transit-vpc-key.pub"
}

/* Using the AMI for us-west-2
https://www.paloaltonetworks.com/documentation/global/compatibility-matrix/vm-series-firewalls/aws-cft-amazon-machine-images-ami-list/images-for-pan-os-8-1#id1849DL00W6W
*/
variable "palo_alto_fw_ami" {
  default = "ami-9a29b8e2"
}

/* The S3 Bucket name MUST be globally unique. */
variable "bootstrap_bucket" {
  default = "us-west-2-bootstrap-bucket"
}

variable "transit_vpc_cidr_block" {
  default = "10.10.0.0/16"
}

variable "transit_vpc_cidr_prefix" {
  default = "10.10."
}

/* Discover and create a list of the Availability Zones for our region. */
data "aws_availability_zones" "available" {}
