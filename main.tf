module "web-server" {
  source = "./module"  
  aws_region = var.aws_region
  instance_type = var.instance_type
  ami_id = var.ami_id
}

terraform {
  backend "s3" {
    bucket = "jay.sahu"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}