terraform {
  required_version = "~> 1.9.5"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.3.0"
    }
  }
}

data "aws_region" "current" {}

provider "helm" {
  kubernetes {
    host                   = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    }
  }
}

provider "flux" {
  kubernetes = {
    host                   = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.eks_cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    }
  }
  git = {
    url = "https://github.com/mvandenburgh/spack-infrastructure" # TODO: update this
    http = {
      username = "mvandenburgh" # TODO: update this
      password = var.flux_github_token
    }
    branch = "new-cluster" # TODO: update this
  }
}
