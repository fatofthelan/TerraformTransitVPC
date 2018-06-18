# Configure the AWS Provider
provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region     = "${var.aws_region}"
}

/* Create a keypair to use for our instances */
resource "aws_key_pair" "transit_vpc_key" {
  key_name = "transit_vpc_key"
  public_key = "${file(var.transit_key_pair_public)}"
}

/* This section creates the networks elements of the transit VPC */

/* Create the VPC */
resource "aws_vpc" "transit_vpc" {
  cidr_block = "${var.transit_vpc_cidr_block}"

  tags = {
    "Name"    = "transit-vpc"
    "Network" = "transit"
  }
}

/* Create the first transit VPC untrust subnet */
resource "aws_subnet" "transit_vpc_untrust_subnet_az1" {
  vpc_id            = "${aws_vpc.transit_vpc.id}"
  cidr_block        = "${join("", list("${var.transit_vpc_cidr_prefix}", "1.0/24"))}"
  availability_zone = "${var.availability_zone}"

  tags {
    "Name"    = "transit-untrust-subnet-az1"
    "Network" = "untrust-transit"
  }
}

/* Create the second transit VPC untrust subnet */
resource "aws_subnet" "transit_vpc_untrust_subnet_az2" {
  vpc_id            = "${aws_vpc.transit_vpc.id}"
  cidr_block        = "${join("", list("${var.transit_vpc_cidr_prefix}", "2.0/24"))}"
  availability_zone = "${var.availability_zone}"

  tags {
    "Name"    = "transit-untrust-subnet-az2"
    "Network" = "untrust-transit"
  }
}

/* Create the first transit VPC trust subnet */
resource "aws_subnet" "transit_vpc_trust_subnet_az1" {
  vpc_id            = "${aws_vpc.transit_vpc.id}"
  cidr_block        = "${join("", list("${var.transit_vpc_cidr_prefix}", "10.0/24"))}"
  availability_zone = "${var.availability_zone}"

  tags {
    "Name"    = "transit-trust-subnet-az1"
    "Network" = "trust-transit"
  }
}

/* Create the second transit VPC trust subnet */
resource "aws_subnet" "transit_vpc_trust_subnet_az2" {
  vpc_id            = "${aws_vpc.transit_vpc.id}"
  cidr_block        = "${join("", list("${var.transit_vpc_cidr_prefix}", "20.0/24"))}"
  availability_zone = "${var.availability_zone}"

  tags {
    "Name"    = "transit-trust-subnet-az2"
    "Network" = "trust-transit"
  }
}

/* Create the Internet Gateway for the transit VPC */
resource "aws_internet_gateway" "transit_internet_gateway" {
  vpc_id = "${aws_vpc.transit_vpc.id}"

  tags {
    "Network" = "untrust-transit"
    "Name"    = "transit-igw"
  }
}

/* Create the Elastic IPs for the firewall 1 manage and untrust interfaces */
resource "aws_eip" "firewall_1_management_public_ip" {
  vpc        = true
  depends_on = ["aws_vpc.transit_vpc", "aws_internet_gateway.transit_internet_gateway", "aws_network_interface.firewall_1_management_network_interface"]

  tags {
    "Name" = "firewall_1_managment_ip"
  }
}

resource "aws_eip" "firewall_1_untrust_public_ip" {
  vpc        = true
  depends_on = ["aws_vpc.transit_vpc", "aws_internet_gateway.transit_internet_gateway", "aws_network_interface.firewall_1_untrust_network_interface"]

  tags {
    "Name" = "firewall_1_untrust_ip"
  }
}

/* Create the Elastic IPs for the firewall 2 manage and untrust interfaces */
resource "aws_eip" "firewall_2_management_public_ip" {
  vpc        = true
  depends_on = ["aws_vpc.transit_vpc", "aws_internet_gateway.transit_internet_gateway", "aws_network_interface.firewall_2_management_network_interface"]

  tags {
    "Name" = "firewall_2_managment_ip"
  }
}

resource "aws_eip" "firewall_2_untrust_public_ip" {
  vpc        = true
  depends_on = ["aws_vpc.transit_vpc", "aws_internet_gateway.transit_internet_gateway", "aws_network_interface.firewall_2_untrust_network_interface"]

  tags {
    "Name" = "firewall_2_untrust_ip"
  }
}


/* Associate the Elastic IPs to the internal network interfaces */
resource "aws_eip_association" "firewall_1_management_eip_association" {
  network_interface_id = "${aws_network_interface.firewall_1_management_network_interface.id}"
  allocation_id        = "${aws_eip.firewall_1_management_public_ip.id}"
}

resource "aws_eip_association" "firewall_1_untrust_eip_association" {
  network_interface_id = "${aws_network_interface.firewall_1_untrust_network_interface.id}"
  allocation_id        = "${aws_eip.firewall_1_untrust_public_ip.id}"
}

resource "aws_eip_association" "firewall_2_management_eip_association" {
  network_interface_id = "${aws_network_interface.firewall_2_management_network_interface.id}"
  allocation_id        = "${aws_eip.firewall_2_management_public_ip.id}"
}

resource "aws_eip_association" "firewall_2_untrust_eip_association" {
  network_interface_id = "${aws_network_interface.firewall_2_untrust_network_interface.id}"
  allocation_id        = "${aws_eip.firewall_2_untrust_public_ip.id}"
}

/* Create the transit VPC route table */
resource "aws_route_table" "transit_route_table" {
  vpc_id = "${aws_vpc.transit_vpc.id}"
}

/* Create the default route for the transit VPC, points to the IGW */
resource "aws_route" "transit_default_route" {
  route_table_id         = "${aws_route_table.transit_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.transit_internet_gateway.id}"
}

/* Associate transit subnets with transit routes */
resource "aws_route_table_association" "transit_assc_untrust_subnet_az1" {
  subnet_id      = "${aws_subnet.transit_vpc_untrust_subnet_az1.id}"
  route_table_id = "${aws_route_table.transit_route_table.id}"
}

resource "aws_route_table_association" "transit_assc_untrust_subnet_az2" {
  subnet_id      = "${aws_subnet.transit_vpc_untrust_subnet_az2.id}"
  route_table_id = "${aws_route_table.transit_route_table.id}"
}

resource "aws_route_table_association" "transit_assc_trust_subnet_az1" {
  subnet_id      = "${aws_subnet.transit_vpc_trust_subnet_az1.id}"
  route_table_id = "${aws_route_table.transit_route_table.id}"
}

resource "aws_route_table_association" "transit_assc_trust_subnet_az2" {
  subnet_id      = "${aws_subnet.transit_vpc_trust_subnet_az2.id}"
  route_table_id = "${aws_route_table.transit_route_table.id}"
}

/* Network interfaces for firewall 1 */
resource "aws_network_interface" "firewall_1_management_network_interface" {
  subnet_id         = "${aws_subnet.transit_vpc_untrust_subnet_az1.id}"
  security_groups   = ["${aws_security_group.allow_all_security_group.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["${join("", list("${var.transit_vpc_cidr_prefix}", "1.10"))}"]

  tags {
    "Name" = "firewall_1_mgmt-port"
  }
}

resource "aws_network_interface" "firewall_1_untrust_network_interface" {
  subnet_id         = "${aws_subnet.transit_vpc_untrust_subnet_az1.id}"
  security_groups   = ["${aws_security_group.allow_all_security_group.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["${join("", list("${var.transit_vpc_cidr_prefix}", "1.20"))}"]

  tags {
    "Name" = "firewall_1_eth1/1"
  }
}

resource "aws_network_interface" "firewall_1_trust_network_interface" {
  subnet_id         = "${aws_subnet.transit_vpc_trust_subnet_az1.id}"
  security_groups   = ["${aws_security_group.allow_all_security_group.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["${join("", list("${var.transit_vpc_cidr_prefix}", "10.20"))}"]

  tags {
    "Name" = "firewall_1_eth1/2"
  }
}

/* Network interfaces for firewall 2 */
resource "aws_network_interface" "firewall_2_management_network_interface" {
  subnet_id         = "${aws_subnet.transit_vpc_untrust_subnet_az1.id}"
  security_groups   = ["${aws_security_group.allow_all_security_group.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["${join("", list("${var.transit_vpc_cidr_prefix}", "1.11"))}"]

  tags {
    "Name" = "firewall_2_mgmt-port"
  }
}

resource "aws_network_interface" "firewall_2_untrust_network_interface" {
  subnet_id         = "${aws_subnet.transit_vpc_untrust_subnet_az1.id}"
  security_groups   = ["${aws_security_group.allow_all_security_group.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["${join("", list("${var.transit_vpc_cidr_prefix}", "1.21"))}"]

  tags {
    "Name" = "firewall_2_eth1/1"
  }
}

resource "aws_network_interface" "firewall_2_trust_network_interface" {
  subnet_id         = "${aws_subnet.transit_vpc_trust_subnet_az1.id}"
  security_groups   = ["${aws_security_group.allow_all_security_group.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["${join("", list("${var.transit_vpc_cidr_prefix}", "10.21"))}"]

  tags {
    "Name" = "firewall_2_eth1/2"
  }
}


/* Security group to allow all traffic */
resource "aws_security_group" "allow_all_security_group" {
  name        = "allow_all_security_group"
  description = "Allow all traffic"
  vpc_id      = "${aws_vpc.transit_vpc.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Create S3 bucket for bootstrap files */
resource "aws_s3_bucket" "bootstrap_bucket" {
  bucket = "${var.bootstrap_bucket}"
  acl    = "private"
  force_destroy = true

  tags {
    Name = "Bootstrap Bucket"
  }
}
/* Upload bootstrap files to the S3 Bucket above */
resource "aws_s3_bucket_object" "bootstrap_xml" {
    bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
    acl    = "private"
    key    = "config/bootstrap.xml"
    source = "bootstrap_files/bootstrap.xml"
}

resource "aws_s3_bucket_object" "init-cft_txt" {
    bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
    acl    = "private"
    key    = "config/init-cfg.txt"
    source = "bootstrap_files/init-cfg.txt"
}

resource "aws_s3_bucket_object" "software" {
    bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
    acl    = "private"
    key    = "software/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "license" {
    bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
    acl    = "private"
    key    = "license/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "content" {
    bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
    acl    = "private"
    key    = "content/"
    source = "/dev/null"
}
/* This section creates the compute elements of the transit VPC */

/* Create the first firewall */
resource "aws_instance" "palo_alto_fw_1" {
  disable_api_termination              = false
  iam_instance_profile                 = "${aws_iam_instance_profile.firewall_bootstrap_profile.name}"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = "${var.palo_alto_fw_ami}"
  instance_type                        = "m4.xlarge"

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = "gp2"
    delete_on_termination = true
    volume_size           = 60
  }

  key_name   = "transit_vpc_key"
  monitoring = false

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.firewall_1_management_network_interface.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.firewall_1_untrust_network_interface.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.firewall_1_trust_network_interface.id}"
  }

  user_data = "${base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.bootstrap_bucket)))}"
}


/* Create the second firewall */
resource "aws_instance" "palo_alto_fw_2" {
  disable_api_termination              = false
  iam_instance_profile                 = "${aws_iam_instance_profile.firewall_bootstrap_profile.name}"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = "${var.palo_alto_fw_ami}"
  instance_type                        = "m4.xlarge"

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = "gp2"
    delete_on_termination = true
    volume_size           = 60
  }

  key_name   = "transit_vpc_key"
  monitoring = false

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.firewall_2_management_network_interface.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.firewall_2_untrust_network_interface.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.firewall_2_trust_network_interface.id}"
  }

  user_data = "${base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.bootstrap_bucket)))}"
}

/* Create the roles and policies to permit the firewall to bootstrap */
resource "aws_iam_role" "firewall_bootstrap_role" {
  name = "firewall_bootstrap_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "firewall_bootstrap_policy" {
  name = "firewall_bootstrap_policy"
  role = "${aws_iam_role.firewall_bootstrap_role.id}"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.bootstrap_bucket}"
    },
    {
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.bootstrap_bucket}/*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "firewall_bootstrap_profile" {
  name = "firewall_bootstrap_profile"
  role = "${aws_iam_role.firewall_bootstrap_role.name}"
  path = "/"
}
