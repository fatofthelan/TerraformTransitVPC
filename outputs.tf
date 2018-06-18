output "Firewall 1 Management URL" {
  value = "${join("", list("https://", "${aws_eip.firewall_1_management_public_ip.public_ip}"))}"
}

output "Firewall 2 Management URL" {
  value = "${join("", list("https://", "${aws_eip.firewall_2_management_public_ip.public_ip}"))}"
}

output "Firewall 1 Management EIP" {
  value = "${aws_eip.firewall_1_management_public_ip.public_ip}"
}

output "Firewall 2 Management EIP" {
  value = "${aws_eip.firewall_2_management_public_ip.public_ip}"
}

output "Firewall 1 Untrust EIP" {
  value = "${aws_eip.firewall_1_untrust_public_ip.public_ip}"
}

output "Firewall 2 Untrust EIP" {
  value = "${aws_eip.firewall_2_untrust_public_ip.public_ip}"
}
