/* Configure the AWS Provider
Uncomment and enter your AWS user's access_key and secret_key
below, or set them as environment variables
*/

provider "aws" {
  region = var.aws_region
  //  access_key = "ACCESS KEY HERE"
  //  secret_key = "SECRET KEY HERE"
}

