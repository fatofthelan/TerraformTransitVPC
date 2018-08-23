/* Create a bastion host for testing */

resource "aws_instance" "bastion_host" {
  ami             = "${data.aws_ami.amazon-linux-2.id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.bastion_host_sg.id}"]
  key_name        = "transit_vpc_key"
  subnet_id       = "${aws_subnet.transit_vpc_trust_subnet_az1.id}"

  //associate_public_ip_address = true
  private_ip = "${join("", list("${var.transit_vpc_cidr_prefix}", "10.40"))}"

  tags {
    Name = "Bastion Host"
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
EOF
}

/* Allow SSH only to the Bastion Host */
resource "aws_security_group" "bastion_host_sg" {
  name        = "bastion_host_sg"
  description = "Allows ssh to Bastion Host"
  vpc_id      = "${aws_vpc.transit_vpc.id}"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
