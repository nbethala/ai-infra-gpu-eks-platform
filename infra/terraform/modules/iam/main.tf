# -----------------------------
# Operator Role
# -----------------------------
resource "aws_iam_role" "operator" {
  name = "NancyOperatorRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.account_id}:root" }
      Action    = "sts:AssumeRole"
      Condition = { Bool = { "aws:MultiFactorAuthPresent" = "true" } }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_policy" "operator_policy" {
  name   = "ProjectGPU-E2E-Operator"
  policy = file("${path.root}/policies/operator.json")
}

resource "aws_iam_role_policy_attachment" "operator_attach" {
  role       = aws_iam_role.operator.name
  policy_arn = aws_iam_policy.operator_policy.arn
}

# -----------------------------
# CI Role (GitHub OIDC)
# -----------------------------
resource "aws_iam_role" "ci" {
  name = "CICD_EKS_GPU_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.github_oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_policy" "ci_policy" {
  name   = "ProjectGPU-E2E-CI"
  policy = file("${path.root}/policies/ci.json")
}

resource "aws_iam_role_policy_attachment" "ci_attach" {
  role       = aws_iam_role.ci.name
  policy_arn = aws_iam_policy.ci_policy.arn
}

# -----------------------------
# ALB Controller Role (IRSA)
# -----------------------------
resource "aws_iam_role" "alb_controller" {
  name = "ALBControllerIRSA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.eks_oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.eks_oidc_provider_sub}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_policy" "alb_policy" {
  name   = "AWSLoadBalancerControllerPolicy"
  policy = file("${path.root}/policies/alb.json")
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_policy.arn
}

# -----------------------------
# EKS Controller Role (ARN)
# -----------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = file("${path.root}/policies/eks.json")

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# -----------------------------
# EKS GPU node group (ARN)
# -----------------------------
resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = file("${path.root}/policies/node-trust-policy.json")

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
