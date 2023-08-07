variable "aws_region" {
  type        = string
  description = "AWS Region"
  default = "us-east-2"
}

variable "instance_count" {
  default = "1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instances."
  type        = string
  default     = "ami-024e6efaf93d85776"  # Replace this with the default AMI ID you want to use.
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.10.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
  default     = ["10.10.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}





