# GPU-accelerated ML inference platform on AWS EKS with modular architecture and observability
Gpu-ready ml inference platform on aws eks 

Goal: Build, test, deploy, and teardown a cost-aware GPU inference stack on EKS. 

## Step 0 : Preliminary setup 

### Identity and Access Management (IAM)
Strong identity boundaries are the backbone of secure cloud platforms — especially when you're running GPU workloads at scale. This project follows a **least-privilege, no static keys** approach across three key roles:

### Human Operator  
Used for occasional manual access — like debugging, validating deployments, or handling incidents.  
- **Secured with MFA**  
- **Short-lived sessions only**  
- No long-term credentials, ever.

### CI/CD Automation  
This is how code gets deployed — safely and automatically.  
- **GitHub OIDC federation** replaces static AWS keys  
- Used by GitHub Actions to run Terraform, Helm, and deploy workloads  
- Scoped tightly to what the pipeline actually needs

### In-Cluster Controller  
This is how your inference pods talk to AWS services like S3 or CloudWatch — from inside Kubernetes.  
- Uses **IRSA (IAM Roles for Service Accounts)**  
- No secrets in containers  
- Each pod gets just the access it needs, nothing more

## Step  : Infrastructure Setup via Terraform

### Setup VPC : The VPC is segmented into public and private subnets across two availability zones. Public subnets route outbound traffic via an Internet Gateway, hosting ingress resources like ALBs. Private subnets route outbound traffic via a NAT Gateway, hosting GPU workloads shielded from direct internet exposure. This design demonstrates secure egress and network segmentation.