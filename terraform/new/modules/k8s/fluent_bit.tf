resource "kubectl_manifest" "custom_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: custom
  YAML
}

resource "kubectl_manifest" "opensearch_secrets" {
  yaml_body = <<-YAML
     apiVersion: v1
     kind: Secret
     metadata:
       name: opensearch-secrets
       namespace: ${kubectl_manifest.custom_namespace.name}
     data:
       opensearch-endpoint: ${base64encode("https://${var.opensearch_endpoint}")}
       opensearch-username: ${base64encode("${var.opensearch_master_user_name}")}
       opensearch-password: ${base64encode("${var.opensearch_master_user_password}")}
   YAML
}

resource "kubectl_manifest" "fluent_bit_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: fluent-bit
  YAML
}

resource "kubectl_manifest" "fluent_bit_service_account" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: fluent-bit
      namespace: ${kubectl_manifest.fluent_bit_namespace.name}
      annotations:
        eks.amazonaws.com/role-arn: ${var.fluent_bit_role_arn}
  YAML
}
