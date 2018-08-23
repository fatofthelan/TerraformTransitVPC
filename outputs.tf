output "FW1_Tunnel_1_Pre_Shared_Key" {
  value = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_preshared_key}"
}

output "FW1_Tunnel_2_Pre_Shared_Key" {
  value = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_preshared_key}"
}

output "Firewall 1 Management URL" {
  value = "${join("", list("https://", "${aws_eip.firewall_1_management_public_ip.public_ip}"))}"
}

output "FW2_Tunnel_1_Pre_Shared_Key" {
  value = "${aws_vpn_connection.spoke_to_transit_fw2.tunnel1_preshared_key}"
}

output "FW2_Tunnel_2_Pre_Shared_Key" {
  value = "${aws_vpn_connection.spoke_to_transit_fw2.tunnel2_preshared_key}"
}

output "Firewall 2 Management URL" {
  value = "${join("", list("https://", "${aws_eip.firewall_2_management_public_ip.public_ip}"))}"
}

output "Command to connect to Bastion Host" {
  value = "${join("", list("ssh -i keys/transit-vpc-key -p 221 ec2-user@", "${aws_eip.firewall_1_untrust_public_ip.public_ip}"))}"
}

/* Debugging Outputs - Uncomment if needed.

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

output "Tunnel 1 Customer Gateway Inside IP (FW1-local-address)" {
  value = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_cgw_inside_address}"
}

output "Tunnel 2 Customer Gateway Inside IP (FW2-local-address)" {
  value = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_cgw_inside_address}"
}

output "Tunnel 1 Virtual Gateway Inside IP (FW1-tunnel.1-peer-address)" {
  value = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_vgw_inside_address}"
}

output "Tunnel 2 Virtual Gateway Inside IP (FW1-tunel.2-peer-address)" {
  value = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_vgw_inside_address}"
}

output "Tunnel 1 Virtual Gateway Outside IP (FW1-ike-gw1-peer-address)" {
  value = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_address}"
}

output "Tunnel 2 Virtual Gateway Outside IP (FW1-ike-gw2-peer-address)" {
  value = "${aws_vpn_connection.spoke_to_transit_fw2.tunnel2_address}"
}
*/

