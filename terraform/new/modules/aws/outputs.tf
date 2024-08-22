output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "karpenter_queue_name" {
  value = module.karpenter.queue_name
}

output "karpenter_node_iam_role_name" {
  value = module.karpenter.node_iam_role_name
}

output "flux_github_token" {
  value = jsondecode(data.aws_secretsmanager_secret_version.flux_github_token.secret_string).flux_github_token
}

output "gitlab_db_password" {
  value = random_password.gitlab_db_password.result
}

output "gitlab_db_hostname" {
  value = module.gitlab_db.db_instance_address
}

output "gitlab_redis_hostname" {
  value = aws_elasticache_replication_group.gitlab.primary_endpoint_address
}

output "gitlab_s3_buckets" {
  value = {
    for k, v in aws_s3_bucket.gitlab_object_stores :
    k => v.id
  }
}

output "gitlab_s3_role_arn" {
  value = aws_iam_role.gitlab_object_stores.arn
}

output "ses_iam_user_name" {
  value = aws_iam_user.ses_user.name
}

output "ses_iam_user_access_key" {
  value     = aws_iam_access_key.ses_user.ses_smtp_password_v4
  sensitive = true
}
