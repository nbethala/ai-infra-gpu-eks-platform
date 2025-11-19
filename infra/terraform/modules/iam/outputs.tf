output "operator_role_arn" {
  value = aws_iam_role.operator.arn
}

output "ci_role_arn" {
  value = aws_iam_role.ci.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}

output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "node_role_arn" {
  value       = aws_iam_role.eks_node_role.arn
  description = "IAM role ARN for EKS GPU node group"
}
