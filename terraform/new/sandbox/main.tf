module "aws" {
  source = "../modules/aws"

  deployment_name = "spack-sandbox"
  region          = "us-east-2"
}
