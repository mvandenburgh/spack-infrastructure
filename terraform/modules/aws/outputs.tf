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
