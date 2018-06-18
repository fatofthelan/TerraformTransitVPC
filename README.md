This is my first draft on creating the AWS Transit VPC/Subscribing VPC terraform templates.

This will create the Transit VPC and Subscribing (Spokes) VPCs as well as create and populate the S3 Bucket used for bootstrapping the VM-Series firewalls.

To use this terraform template, you will need to do the following:
- Download and install terraform
- Change any variables in the vars.tf file to suit your needs.
- Define a unique name for the "bootstrap_bucket" variable in the vars.tf file.
- Create a keypair using "ssh-keygen -f transit-vpc-key" in the "keys" directory.
- Duplicate the spoke.tf file for each desired spoke VPC you wish to create.
- Change the name of the "spoke_name" variable in each spoke.tf file you created in the previous step.
- Run "terraform init" then "terraform apply"

NOTES:
- The example AMI used is for a Pay As You Go instance of PANOS 8.1. Change the "palo_alto_fw_ami" variable to suit your needs.
- You will have to run this in the us-west-2 region until I build the region:ami map.
- I've hard coded a few things that will become variables later. I'm just getting it going now.
- I'll add the SNAT rules and BGP config later.
- The username and password from the bootstrap.xml is paloalto / in*4ksh8JN2kdh (be sure to change this once your FWs come up!)
- To bring up the VPN between the spoke VPC and the transit VPC, go to the AWS Console, VPCs, VPN Connections, and Download
  the configuration of the spoke to FW1. Most of the setting are already setup from the boostrap config, but some items
  will need to be changed such as the tunnel/peep/local IPs and the shared secret. I'll work on automating this later.
