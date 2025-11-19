resource "aws_eks_node_group" "gpu_spot" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-gpu-spot"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types  = ["g4dn.xlarge"]
  capacity_type   = "SPOT"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 0
  }

  labels = {
    accelerator = "nvidia"
  }

  tags = {
    project = var.project
    owner   = var.owner
  }
}
