This is my first draft on creating the AWS Transit VPC/Subscribing VPC terraform templates.

This Terraform template will:
- Create the Transit VPC and Subscribing (Spokes) VPCs.
- Create and populate the S3 Bucket used for bootstrapping the VM-Series firewalls.
- Spin up 2 Palo Alto Networks VM-Series Firewalls in the Transit VPC, one per AZ.
- Configure VPNs between the Spoke VPC and the VM-Series Firewalls.
- Configure BGP to add routes for the Spoke VPCs.

To use this terraform template, you will need to do the following:
- Download and install terraform
- Change any variables in the vars.tf file to suit your needs.
- Define a unique name for the "bootstrap_bucket" variable in the vars.tf file.
- Create a keypair using "ssh-keygen -f transit-vpc-key" in the "keys" directory.
- Duplicate the spoke.tf file for each desired spoke VPC you wish to create.(Automated VPNs/Configs only
  work for the first Spoke VPC at this point. This will be addressed in v2.)
- Change the name of the "spoke_name" and "spoke_vpc_cidr_prefix" variables in each spoke.tf file
  you created in the previous step.
- Run "terraform init" then "terraform apply"
- After the template runs, you will see each of the firewall's IPs as well as the PSKs for the VPNs.
- Log in to each firewall and import/load each firewall's configuration files from the templates
  directory. DO NOT COMMIT YET. Go to the Network tab, IKE Gateways, and open each entry and enter
  the PSKs from the Terraform output. (I'll automate this in v2.)
- Commit and you should all of the VPN tunnels become active as well as their BGP entries.

NOTES:
- The username and password from the bootstrap.xml is paloalto / in*4ksh8JN2kdh (be sure to change this once your FWs come up!)
- The AMI used by default is for the Pay As You Go instance of PANOS 8.1. Change the "palo_alto_fw_ami" variable to suit your needs.
