variable "deployment_name" {
  type = string
}

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

variable "karpenter_node_iam_role_name" {
  description = "The name of the IAM role to use for Karpenter nodes"
  type        = string
}
