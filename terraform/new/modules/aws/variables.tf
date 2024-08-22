variable "deployment_name" {
  type = string
}

variable "region" {
  type = string
}

variable "gitlab_db_instance_class" {
  description = "AWS RDS DB instance class for the Spack GitLab PostgreSQL database."
  type        = string
}

variable "gitlab_redis_instance_class" {
  description = "AWS ElastiCache instance class for the Spack GitLab redis instance."
  type        = string
}

variable "ses_email_domain" {
  description = "value of the domain to be used for SES email sending."
  type        = string
}

variable "opensearch_instance_type" {
  description = "The instance type to use for the OpenSearch domain."
  type        = string
}

variable "opensearch_volume_size" {
  description = "The size of the EBS volume to use for the OpenSearch domain."
  type        = number
}
