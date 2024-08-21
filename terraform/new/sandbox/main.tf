module "aws" {
  source = "../modules/aws"

  deployment_name = "spack-sandbox"
  region          = "us-east-2"
}

module "k8s" {
  source = "../modules/k8s"

  eks_cluster_name                       = module.aws.cluster_name
  eks_cluster_endpoint                   = module.aws.cluster_endpoint
  eks_cluster_certificate_authority_data = module.aws.cluster_certificate_authority_data
  karpenter_queue_name                   = module.aws.karpenter_queue_name
}
