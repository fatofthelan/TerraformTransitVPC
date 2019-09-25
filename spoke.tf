/* This template creates a spoke VPC that will connect to the transit VPC
via VPN. To use or create multiple spokes, simply duplicate this file for
each desired spoke and change the "spoke_name" variable to the name of
the new spoke you want to create and find/replace "spoke" with with the
name of the new spoke, "prod" for example. */

variable "spoke_name" {
  default = "spoke"
}

variable "spoke_vpc_cidr_prefix" {
  default = "10.11."
}

/* This first section creates the network elements of the spoke VPC */

/* Create the VPC */
resource "aws_vpc" "spoke_vpc" {
  cidr_block = join("", [var.spoke_vpc_cidr_prefix, "0.0/16"])

  tags = {
    "Name"    = "${var.spoke_name}-vpc"
    "Network" = var.spoke_name
  }
}

/* Create the first AZ spoke VPC subnet */
resource "aws_subnet" "spoke_vpc_subnet_az1" {
  vpc_id            = aws_vpc.spoke_vpc.id
  cidr_block        = join("", [var.spoke_vpc_cidr_prefix, "1.0/24"])
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    "Name"    = "${var.spoke_name}-subnet-az1"
    "Network" = var.spoke_name
  }
}

/* Create the spoke VPC route table */
resource "aws_route_table" "spoke_route_table" {
  vpc_id = aws_vpc.spoke_vpc.id

  tags = {
    "Name" = "Spoke"
  }
}

/* Associate spoke subnet with spoke routes */
resource "aws_route_table_association" "spoke_assc_subnet_az1" {
  subnet_id      = aws_subnet.spoke_vpc_subnet_az1.id
  route_table_id = aws_route_table.spoke_route_table.id
}

/* VPN Section */

/* Create Customer Gateways for the spoke */
resource "aws_customer_gateway" "spoke_customer_gateway_fw1" {
  bgp_asn    = 65000
  ip_address = aws_eip.firewall_1_untrust_public_ip.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.spoke_name}_customer_gateway_fw1"
  }
}

resource "aws_customer_gateway" "spoke_customer_gateway_fw2" {
  bgp_asn    = 65000
  ip_address = aws_eip.firewall_2_untrust_public_ip.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.spoke_name}_customer_gateway_fw2"
  }
}

/* Create the Virtual Private Gateway and VPN to the Transit VPC */
resource "aws_vpn_gateway" "spoke_vpn_gateway" {
  vpc_id            = aws_vpc.spoke_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.spoke_name}_vpn_gateway"
  }
}

/* Create the VPN Connections to the Transit VPC Customer Gateways */
resource "aws_vpn_connection" "spoke_to_transit_fw1" {
  vpn_gateway_id      = aws_vpn_gateway.spoke_vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.spoke_customer_gateway_fw1.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name = "${var.spoke_name}_to_transit_fw1"
  }
}

resource "aws_vpn_connection" "spoke_to_transit_fw2" {
  vpn_gateway_id      = aws_vpn_gateway.spoke_vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.spoke_customer_gateway_fw2.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name = "${var.spoke_name}_to_transit_fw2"
  }
}

/* Propagate our VGW route to the route table */
resource "aws_vpn_gateway_route_propagation" "spoke_route_propagation" {
  vpn_gateway_id = aws_vpn_gateway.spoke_vpn_gateway.id
  route_table_id = aws_route_table.spoke_route_table.id
}

