output "vpc_id" {
  description = "Provisioned VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs where EKS workloads run."
  value       = module.vpc.private_subnet_ids
}

output "s3_bucket_names" {
  description = "Provisioned S3 bucket names."
  value       = module.s3.bucket_names
}

output "s3_bucket_arns" {
  description = "Provisioned S3 bucket ARNs."
  value       = module.s3.bucket_arns
}

output "pods_s3_access_policy_json" {
  description = "Least-privilege IAM policy generated for EKS workloads."
  value       = data.aws_iam_policy_document.pods_s3_access.json
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "irsa_role_arn" {
  description = "IAM role ARN for the Kubernetes service account."
  value       = module.eks.irsa_role_arn
}

output "irsa_service_account_manifest" {
  description = "Rendered Kubernetes ServiceAccount manifest annotated with the IRSA role."
  value       = module.eks.service_account_manifest
}
