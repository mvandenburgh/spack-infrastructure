locals {
  suffix = var.deployment_name != "prod" ? "-${var.deployment_name}" : ""
}

locals {
  eks_cluster_name = "spack${local.suffix}"
}
