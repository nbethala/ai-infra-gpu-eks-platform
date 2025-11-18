provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "./modules/vpc"
  region  = var.region
  project = var.project
  owner   = var.owner
}

module "iam" {
  source       = "./modules/iam"
  project      = var.project
  owner        = var.owner
  cluster_name = var.cluster_name

  account_id               = var.account_id
  github_org               = var.github_org
  github_repo              = var.github_repo
  github_oidc_provider_arn = var.github_oidc_provider_arn
  eks_oidc_provider_arn    = var.eks_oidc_provider_arn
  eks_oidc_provider_sub    = var.eks_oidc_provider_sub
}

module "eks" {
  source             = "./modules/eks"
  project            = var.project
  owner              = var.owner
  region             = var.region
  cluster_name       = var.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids  #output from vpc module
  cluster_role_arn   = module.iam.cluster_role_arn  #output from iam module
}
