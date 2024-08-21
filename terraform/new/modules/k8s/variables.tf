variable "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  type        = string
}

variable "eks_cluster_certificate_authority_data" {
  description = "The base64 encoded certificate authority data for the EKS cluster"
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "karpenter_queue_name" {
  description = "The name of the SQS queue to use for Karpenter interruption handling"
  type        = string
}

variable "flux_github_token" {
  description = "The GitHub personal access token to use for Flux"
  type        = string
  sensitive   = true
}

variable "flux_path" {
  description = "Path relative to the repository root that Flux will use to sync resources"
  type        = string
}
