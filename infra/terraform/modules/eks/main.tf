resource "aws_eks_cluster" "gpu_e2e" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  tags = {
    project = var.project
    owner   = var.owner
    Name    = var.cluster_name
  }
}
