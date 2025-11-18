variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "gpu-e2e"
}

variable "owner" {
  description = "Owner tag"
  type        = string
  default     = "Nancy"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "gpu-e2e-cluster"
}

variable "account_id" {
  description = "account ID tag for resources"   
  type = string 
}

variable "github_org" { 
  description = "github_org tag for resources"  
  type = string 
}

variable "github_repo" {
   description = "github_repo tag for resources"  
   type = string
 }

variable "github_oidc_provider_arn" { 
  description = "github_oidc tag for resources"  
  type = string 
}

variable "eks_oidc_provider_arn" {
  description = "eks_oidc_provider_arn tag for resources" 
  type = string 
}

variable "eks_oidc_provider_sub" {
   description = "eks_oidc_provider_sub tag for resources" 
   type = string 
}

