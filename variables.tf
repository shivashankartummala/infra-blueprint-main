variable "aws_region" {
  description = "AWS region used for the deployment."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile used by the AWS provider."
  type        = string
  default     = "cloud_user"
}

variable "environment" {
  description = "Environment name used in resource naming and tagging."
  type        = string
  default     = "prod"
}

variable "vpc_name" {
  description = "Logical name for the VPC module."
  type        = string
  default     = "shared-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "bucket_names" {
  description = "S3 buckets to provision for application workloads."
  type        = list(string)
  default = [
    "prod-app-ingest-example",
    "prod-app-artifacts-example",
    "prod-app-logs-example",
    "prod-app-backups-example",
    "prod-app-archive-example",
    "prod-app-exports-example"
  ]
}

variable "transition_to_ia_after_days" {
  description = "Lifecycle transition window to STANDARD_IA."
  type        = number
  default     = 30
}

variable "bucket_specific_tags" {
  description = "Optional per-bucket tags. Logs and backups are marked as protected by default."
  type        = map(map(string))
  default = {
    "prod-app-logs-example" = {
      DataClass    = "logs"
      Retention    = "keep"
      Protected    = "true"
      DeletePolicy = "retain"
    }
    "prod-app-backups-example" = {
      DataClass    = "backups"
      Retention    = "keep"
      Protected    = "true"
      DeletePolicy = "retain"
    }
  }
}

variable "protected_bucket_names" {
  description = "Bucket names that Terraform must not destroy."
  type        = set(string)
  default = [
    "prod-app-logs-example",
    "prod-app-backups-example"
  ]
}

variable "cluster_name" {
  description = "Logical name for the EKS cluster."
  type        = string
  default     = "platform"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.30"
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS endpoint is exposed publicly."
  type        = bool
  default     = false
}

variable "eks_managed_node_group_defaults" {
  description = "Shared defaults for all EKS managed node groups."
  type        = any
  default = {
    ami_type       = "AL2_x86_64"
    capacity_type  = "ON_DEMAND"
    disk_size      = 80
    instance_types = ["t3.micro"]
  }
}

variable "eks_managed_node_groups" {
  description = "Managed node group definitions."
  type        = any
  default = {
    general = {
      min_size       = 3
      max_size       = 6
      desired_size   = 3
      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"
      labels = {
        workload = "general"
      }
    }
  }
}

variable "irsa_namespace" {
  description = "Namespace for the Kubernetes service account that should access S3."
  type        = string
  default     = "platform"
}

variable "irsa_service_account_name" {
  description = "Service account name that will receive the IRSA annotation."
  type        = string
  default     = "s3-writer"
}

variable "tags" {
  description = "Additional tags for all resources."
  type        = map(string)
  default = {
    Terraform = "true"
    Owner     = "platform-team"
  }
}
