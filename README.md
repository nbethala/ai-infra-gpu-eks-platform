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


🧩 The Business Problem
Modern AI workloads — especially those involving deep learning, large language models, or computer vision — require:

GPU acceleration for training and inference
Scalable orchestration of containerized workloads
Multi-tenant isolation and secure access control
Cost-aware scheduling and resource lifecycle hygiene
Reproducibility across environments (dev, staging, prod)
Observability and compliance for regulated industries
But most enterprises struggle with:
Ad hoc GPU provisioning (manual, error-prone, expensive)
Poor reproducibility of ML pipelines
Lack of infrastructure-as-code for AI environments
Security gaps in IAM, CI/CD, and service-to-service trust
No clear disaster recovery or multi-region strategy

✅ The Solution: AI Infra GPU EKS Platform
Your platform solves this by delivering a modular, reproducible, GPU-ready Kubernetes environment on AWS, built with:

Layer	What It Solves
VPC + Subnets	Isolated, AZ-resilient network for GPU workloads
IAM + Policies	Fine-grained access for operators, CI/CD, and IRSA
EKS Cluster	Managed Kubernetes control plane with GPU node groups
Node Groups	Separate GPU and general-purpose pools for cost control
CI/CD Integration	GitHub OIDC + Terraform for secure automation  - " DEFFERED for now in phase 1 setup "
ALB Controller (IRSA)	Ingress with service account–scoped permissions
Observability (Planned)	Hooks for Prometheus/Grafana, FluentBit, etc.
Disaster Recovery (Planned)	Multi-region failover and backup scaffolding

🧠 Summary
You're building a reproducible, secure, GPU-accelerated Kubernetes platform that enables teams to run AI/ML workloads at scale — with infrastructure-as-code, cost control, and compliance baked in.

This isn’t just a cluster — it’s a launchpad for AI workloads that need to be:

Scalable
Auditable
Cost-efficient
Secure by default

-----
## Good Notes : sequential setup/execution order 
----
- Infra - provisioned via terraform
- provision EKS cluster 
- Provision GPU Node group 
- Nvidia devlive plugin via helm --> plugin exposes GPU resources to Kubernetes as nvidia.com/gpu. Without it, your GPU nodes won’t  advertise GPU capacity, and Triton won’t be able to request GPU resources.
- verify - Kubernetes sees the GPU as a schedulable resource.
- kubectl describe node | grep -i nvidia.com/gpu
- NVIDIA device plugin via Helm provider using - Terraform ( This way clean life cycle - to destroy IAC)

## Triton : for model serving
 Triton is a powerful inference(making predictions) server that lets you easily deploy and run AI models at scale, using GPUs for fast inference.
 - Package ONNX model (ResNet50 or MobileNet)