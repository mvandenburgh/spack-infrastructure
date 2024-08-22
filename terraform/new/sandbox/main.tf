locals {
  deployment_name  = "sandbox"
  ses_email_domain = "sandbox.spack.io"
}
module "aws" {
  source = "../modules/aws"

  deployment_name = local.deployment_name
  region          = "us-east-2"

  ses_email_domain = local.ses_email_domain

  # TODO: these are taken from the current staging deployment
  gitlab_db_instance_class    = "db.t3.small"
  gitlab_redis_instance_class = "cache.t4g.small"

  # TODO: temporarily using an OpenSearch instance type from staging deployment
  opensearch_instance_type = "t3.small.search"
  opensearch_volume_size   = 100
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

  gitlab_db_hostname    = module.aws.gitlab_db_hostname
  gitlab_db_password    = module.aws.gitlab_db_password
  gitlab_redis_hostname = module.aws.gitlab_redis_hostname
  gitlab_s3_buckets     = module.aws.gitlab_s3_buckets
  gitlab_s3_role_arn    = module.aws.gitlab_s3_role_arn

  ses_email_domain              = local.ses_email_domain
  ses_email_iam_user_name       = module.aws.ses_iam_user_name
  ses_email_iam_user_access_key = module.aws.ses_iam_user_access_key

  opensearch_endpoint             = module.aws.opensearch_endpoint
  opensearch_master_user_name     = module.aws.opensearch_master_user_name
  opensearch_master_user_password = module.aws.opensearch_master_user_password
  fluent_bit_role_arn             = module.aws.fluent_bit_role_arn
}
