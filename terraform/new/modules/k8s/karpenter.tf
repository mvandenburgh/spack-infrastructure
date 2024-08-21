locals {
  karpenter_chart_version = "1.0.0"
}

resource "helm_release" "karpenter_crds" {
  namespace        = "kube-system"
  create_namespace = true

  name       = "karpenter-crd"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"
  version    = local.karpenter_chart_version
}

resource "helm_release" "karpenter" {
  name      = "karpenter"
  namespace = "kube-system"

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = local.karpenter_chart_version

  values = [
    <<-EOT
    nodeSelector:
      karpenter.sh/controller: 'true'
    tolerations:
      - key: CriticalAddonsOnly
        operator: Exists
    settings:
      clusterName: ${var.eks_cluster_name}
      clusterEndpoint: ${var.eks_cluster_endpoint}
      interruptionQueue: ${var.karpenter_queue_name}
    EOT
  ]

  depends_on = [helm_release.karpenter_crds]
}
