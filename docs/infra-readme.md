# IAM Configuration for GPU EKS Platform ---created bY CURSOR - NOTE !!!!

This Terraform configuration creates IAM roles and users with least privilege permissions for managing the GPU-accelerated ML inference platform on AWS EKS.

## Resources Created

### IAM User (Optional)
- **Name**: `gpu-eks-terraform-user` (configurable)
- **Purpose**: For Terraform operations and infrastructure management
- **Permissions**: Least privilege access to:
  - EKS (cluster and node group management)
  - EC2 (VPC, subnets, security groups, instances)
  - IAM (role creation and management for project resources)
  - ECR (container registry operations)
  - ALB (load balancer management)
  - S3 (bucket operations)
  - CloudWatch (alarms and logging)

### IAM Roles

1. **EKS Cluster Role**
   - **Name**: `gpu-e2e-eks-cluster-role`
   - **Purpose**: Service role for EKS cluster control plane
   - **Attached Policies**: `AmazonEKSClusterPolicy`

2. **EKS Node Group Role**
   - **Name**: `gpu-e2e-eks-node-group-role`
   - **Purpose**: Role for EKS worker nodes
   - **Attached Policies**:
     - `AmazonEKSWorkerNodePolicy`
     - `AmazonEKS_CNI_Policy`
     - `AmazonEC2ContainerRegistryReadOnly`
   - **Additional Permissions**: ECR read access for pulling container images

3. **ALB Ingress Controller Role (IRSA)**
   - **Name**: `gpu-e2e-alb-ingress-controller-role`
   - **Purpose**: IAM Role for Service Account (IRSA) for AWS Load Balancer Controller
   - **Permissions**: Least privilege access to:
     - EC2 (describe resources for ALB creation)
     - ELB (create and manage load balancers, target groups, listeners)
     - IAM (create service-linked role for ELB)

## Usage

### Initialize Terraform

```bash
cd infra/terraform
terraform init
```

### Plan and Apply

```bash
terraform plan
terraform apply
```

### Variables

You can customize the configuration using variables:

```hcl
# terraform.tfvars
project_name = "gpu-e2e"
owner        = "Nancy"
aws_region   = "us-east-1"
cluster_name = "gpu-eks-cluster"
ecr_repository_names = ["triton-inference-server"]
create_iam_user = true
```

### Outputs

After applying, you'll get:
- IAM user credentials (if created)
- ARNs for all IAM roles
- Role names for Kubernetes service account configuration

**Important**: The ALB ingress controller role uses IRSA (IAM Roles for Service Accounts) and requires the EKS cluster OIDC provider to be configured. 

### Setting up ALB Ingress Controller Role

The ALB role can be created in two ways:

1. **Before cluster creation**: The role will be created with a placeholder assume role policy. After the cluster is created:
   ```bash
   # Get the OIDC issuer URL
   aws eks describe-cluster --name <cluster-name> --query "cluster.identity.oidc.issuer" --output text
   
   # Update terraform.tfvars with the OIDC issuer URL
   eks_cluster_oidc_issuer_url = "https://oidc.eks.us-east-1.amazonaws.com/id/XXXXXXXXXXXXX"
   
   # Apply again to update the assume role policy
   terraform apply
   ```

2. **After cluster creation**: Set the `eks_cluster_oidc_issuer_url` variable before the first apply.

## Security Notes

- All resources are tagged with `project` and `owner` tags
- IAM policies follow least privilege principles
- The Terraform user policy is scoped to project-specific resources where possible
- Access keys are marked as sensitive in outputs

## Next Steps

1. Use the EKS cluster role ARN when creating the EKS cluster
2. Use the node group role ARN when creating EKS node groups
3. Configure the ALB ingress controller role as an IRSA in Kubernetes after cluster creation

