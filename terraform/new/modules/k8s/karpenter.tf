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

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: ${var.karpenter_node_iam_role_name}
      subnetSelectorTerms:
        # This value *must* match one of the tags placed on the subnets for this
        # EKS cluster (see vpc.tf for these).
        # We use the "deployment_name" variable here instead of the full cluster name
        # because the full cluster name isn't available at the time that we bootstrap
        # the VPC resources (including subnets). However, "deployment_name" is also
        # a unique-per-cluster value, so it should work just as well.
        - tags:
            karpenter.sh/discovery: ${var.deployment_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.deployment_name}
      tags:
        karpenter.sh/discovery: ${var.deployment_name}
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 200Gi
            volumeType: gp3
            deleteOnTermination: true
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "windows_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: windows
    spec:
      amiFamily: Windows2022
      role: ${var.karpenter_node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.eks_cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.eks_cluster_name}
      tags:
        karpenter.sh/discovery: ${var.eks_cluster_name}
      blockDeviceMappings:
        - deviceName: /dev/sda1
          ebs:
            volumeSize: 200Gi
            volumeType: gp3
            deleteOnTermination: true
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}
