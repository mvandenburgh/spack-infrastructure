module "aws" {
  source = "../modules/aws"

  deployment_name = "sandbox"
  region          = "us-east-2"

  # TODO: these are taken from the current staging deployment
  gitlab_db_instance_class    = "db.t3.small"
  gitlab_redis_instance_class = "cache.t4g.small"
}

module "k8s" {
  source = "../modules/k8s"

  deployment_name = local.deployment_name

  eks_cluster_name                       = module.aws.cluster_name
  eks_cluster_endpoint                   = module.aws.cluster_endpoint
  eks_cluster_certificate_authority_data = module.aws.cluster_certificate_authority_data
  karpenter_queue_name                   = module.aws.karpenter_queue_name
  karpenter_node_iam_role_name           = module.aws.karpenter_node_iam_role_name

  flux_github_token = module.aws.flux_github_token
  flux_path         = "terraform/new/sandbox/yamls/"

  gitlab_db_hostname = module.aws.gitlab_db_hostname
  gitlab_db_password = module.aws.gitlab_db_password
  gitlab_redis_hostname = module.aws.gitlab_redis_hostname
  gitlab_s3_buckets = module.aws.gitlab_s3_buckets
  gitlab_s3_role_arn = module.aws.gitlab_s3_role_arn
}
