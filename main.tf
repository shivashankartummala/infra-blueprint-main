terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "shivashankartummala-terraform-state"
    key            = "infra-blueprint-main/terraform.tfstate"
    region         = "us-east-1"
    profile        = "cloud_user"
    dynamodb_table = "shivashankartummala-terraform-locks"
    encrypt        = true
  }

}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

locals {
  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Stack       = "infra-blueprint-main"
    },
    var.tags
  )
}

module "vpc" {
  source = "git::https://github.com/shivashankartummala/terraform-aws-vpc.git?ref=v1.0.0"

  name     = "${var.environment}-${var.vpc_name}"
  vpc_cidr = var.vpc_cidr
  tags     = local.common_tags
}

module "s3" {
  source = "git::https://github.com/shivashankartummala/terraform-aws-s3.git?ref=v1.1.1"

  bucket_names                = var.bucket_names
  transition_to_ia_after_days = var.transition_to_ia_after_days
  bucket_specific_tags        = var.bucket_specific_tags
  protected_bucket_names      = var.protected_bucket_names
  tags                        = local.common_tags
}

data "aws_iam_policy_document" "pods_s3_access" {
  statement {
    sid    = "ListBucketForManagedBuckets"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = module.s3.bucket_arns
  }

  statement {
    sid    = "ReadWriteObjectsForManagedBuckets"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      for bucket_arn in module.s3.bucket_arns :
      "${bucket_arn}/*"
    ]
  }
}

module "eks" {
  source = "git::https://github.com/shivashankartummala/terraform-aws-eks.git?ref=v1.0.0"

  cluster_name                   = "${var.environment}-${var.cluster_name}"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups         = var.eks_managed_node_groups

  irsa_namespace            = var.irsa_namespace
  irsa_service_account_name = var.irsa_service_account_name
  irsa_policy_name          = "${var.environment}-${var.cluster_name}-pods-s3-access"
  irsa_role_name            = "${var.environment}-${var.cluster_name}-${var.irsa_service_account_name}-irsa"
  irsa_policy_json          = data.aws_iam_policy_document.pods_s3_access.json

  tags = local.common_tags
}
