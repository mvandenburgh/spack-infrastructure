resource "kubectl_manifest" "gitlab_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: gitlab
  YAML
}

# AWS secrets for Postgres
resource "kubectl_manifest" "gitlab_secrets" {
  # https://docs.gitlab.com/charts/charts/globals.html#connection
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: gitlab-secrets
      namespace: ${kubectl_manifest.gitlab_namespace.name}
    stringData:
      postgres-password: "${var.gitlab_db_password}"
      values.yaml: |
        global:
          psql:
            host: "${var.gitlab_db_hostname}"
  YAML
}

# AWS secrets for Redis
resource "kubectl_manifest" "gitlab_redis_config" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: gitlab-elasticache-config
      namespace: ${kubectl_manifest.gitlab_namespace.name}
    data:
      values.yaml: |
        global:
          redis:
            host: ${var.gitlab_redis_hostname}
            auth:
              enabled: false
  YAML
}


locals {
  connection_secret_name = "gitlab-s3-bucket-secrets"
  connection_secret_key  = "connection"

  backups_secret_name = "gitlab-s3-backup-bucket-secrets"
  backups_secret_key  = "config"
}

resource "kubectl_manifest" "gitlab_object_stores_config_map" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: gitlab-s3-bucket-config
      namespace: ${kubectl_manifest.gitlab_namespace.name}
    data:
      values.yaml: |
        global:
          serviceAccount:
            create: true
            enabled: true
            annotations:
              eks.amazonaws.com/role-arn: ${var.gitlab_s3_role_arn}
          # https://docs.gitlab.com/charts/advanced/external-object-storage/#lfs-artifacts-uploads-packages-external-diffs-terraform-state-dependency-proxy-secure-files
          appConfig:
            artifacts:
              bucket: ${var.gitlab_s3_buckets["artifacts"]}
              connection:
                secret: ${local.connection_secret_name}
                key: ${local.connection_secret_key}
            uploads:
              bucket: ${var.gitlab_s3_buckets["uploads"]}
              connection:
                secret: ${local.connection_secret_name}
                key: ${local.connection_secret_key}
            backups:
              objectStorage:
                backend: s3
              bucket: ${var.gitlab_s3_buckets["backups"]}
              tmpBucket: ${var.gitlab_s3_buckets["tmp-storage"]}
        # https://docs.gitlab.com/charts/advanced/external-object-storage/#backups
        gitlab:
          toolbox:
            backups:
              objectStorage:
                config:
                  secret: ${local.backups_secret_name}
                  key: ${local.backups_secret_key}
  YAML
}

resource "kubectl_manifest" "gitlab_object_stores_secret" {
  # https://docs.gitlab.com/charts/charts/globals.html#connection
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${local.connection_secret_name}
      namespace: ${kubectl_manifest.gitlab_namespace.name}
    stringData:
      ${local.connection_secret_key}: |
        provider: "AWS"
        use_iam_profile: "true"
        region: "${data.aws_region.current.name}"
  YAML
}

resource "kubectl_manifest" "gitlab_object_stores_backup_secret" {
  # https://docs.gitlab.com/charts/advanced/external-object-storage/#backups-storage-example
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${local.backups_secret_name}
      namespace: ${kubectl_manifest.gitlab_namespace.name}
    stringData:
      ${local.backups_secret_key}: |
        [default]
        bucket_location = ${data.aws_region.current.name}
  YAML
}
