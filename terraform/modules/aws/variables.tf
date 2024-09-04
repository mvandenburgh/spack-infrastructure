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
