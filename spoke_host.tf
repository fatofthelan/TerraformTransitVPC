/* Create a bastion host for testing */

resource "aws_instance" "spoke_host" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.spoke_host_sg.id}"]
  key_name                    = "transit_vpc_key"
  subnet_id                   = "${aws_subnet.spoke_vpc_subnet_az1.id}"
  associate_public_ip_address = true

  tags {
    Name = "Spoke Host"
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
EOF
}

/* Allow SSH only to the Bastion Host */
resource "aws_security_group" "spoke_host_sg" {
  name        = "spoke_host_sg"
  description = "Allows all to Spoke Host"
  vpc_id      = "${aws_vpc.spoke_vpc.id}"

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
