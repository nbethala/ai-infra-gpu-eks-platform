output "cluster_name" {
  value = aws_eks_cluster.gpu_e2e.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.gpu_e2e.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.gpu_e2e.certificate_authority[0].data
}
