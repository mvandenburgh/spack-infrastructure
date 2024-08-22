resource "aws_s3_bucket" "gitlab_object_stores" {
  for_each = toset(["artifacts", "uploads", "backups", "tmp-storage"])

  bucket = "spack-${var.deployment_name}-gitlab-${each.value}"

  lifecycle {
    prevent_destroy = true
  }
}

# Bucket policy that prevents deletion of GitLab buckets.
resource "aws_s3_bucket_policy" "gitlab_object_stores" {
  for_each = aws_s3_bucket.gitlab_object_stores

  bucket = each.value.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Principal" : "*"
        "Effect" : "Deny",
        "Action" : [
          "s3:DeleteBucket",
        ],
        "Resource" : each.value.arn,
      }
    ]
  })
}

# Lifecycle rule that deletes artifacts older than 3 months
resource "aws_s3_bucket_lifecycle_configuration" "delete_old_artifacts" {
  bucket = aws_s3_bucket.gitlab_object_stores["artifacts"].id

  rule {
    id = "DeleteObjectsOlderThan3Months"

    filter {} # Empty filter; all objects in bucket should be affected

    expiration {
      days = 90
    }

    status = "Enabled"
  }
}

resource "aws_iam_policy" "gitlab_object_stores" {
  name        = "GitlabS3Role-${var.deployment_name}"
  description = "Managed by Terraform. Grants required permissions for GitLab to read/write to relevant S3 buckets."

  # https://docs.gitlab.com/ee/install/aws/manual_install_aws.html#create-an-iam-policy
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
        ],
        "Resource" : [for bucket in aws_s3_bucket.gitlab_object_stores : "${bucket.arn}/*"],
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : [for bucket in aws_s3_bucket.gitlab_object_stores : bucket.arn]
      }
    ]
  })
}

resource "aws_iam_role" "gitlab_object_stores" {
  name        = "GitlabS3Role-${var.deployment_name}"
  description = "Managed by Terraform. Role for GitLab to assume so that it can access relevant S3 buckets."
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : module.eks.oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gitlab_object_stores" {
  role       = aws_iam_role.gitlab_object_stores.name
  policy_arn = aws_iam_policy.gitlab_object_stores.arn
}
