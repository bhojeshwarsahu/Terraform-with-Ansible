data "aws_secretsmanager_secret_version" "provider_keys" {
  secret_id     = "IAC"

}

locals {
  provider_keys = jsondecode(data.aws_secretsmanager_secret_version.provider_keys.secret_string)
}

provider "aws" {
  alias = "deployer"
  region = "us-east-1"
  access_key = local.provider_keys["access_key"]
  secret_key = local.provider_keys["secret_key"]
}
