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
