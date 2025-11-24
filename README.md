# GPU-Accelerated ML Inference Platform on AWS EKS

This project demonstrates a **modular, production-grade architecture** for serving machine learning models at scale using **NVIDIA Triton Inference Server** on **AWS Elastic Kubernetes Service (EKS)**.

## 🚀 What It Does
- Runs ML models (e.g., ResNet50) on **GPU nodes** for high-throughput, low-latency inference.
- Uses **private subnets with NAT Gateway** for secure networking.
- Provides **observability** with Prometheus, DCGM exporter, and Grafana dashboards.
- Codified with **Terraform + Helm** for reproducibility, teardown hygiene, and cost control.

## 🛠 Key Components
- **Triton Inference Server** → Core engine for serving models (ONNX, PyTorch, TensorFlow).
- **API Gateway / Ingress** → Routes client requests into the cluster.
- **Observability Stack** → Real-time metrics on GPU utilization, latency, and errors.
- **CI/CD Ready** → Modular design for automated model deployment pipelines.

## ✅ Outcome
A secure, scalable, and observable ML inference platform that bridges the gap between **research models** and **enterprise deployment**.

##  Infrastructure Setup via Terraform

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

Docker Build : 
Load a ResNet‑50 ONNX model.
Accept batches of up to 8 RGB images (224×224).
Output a 1000‑dimensional vector (ImageNet classes).
Run inference on GPU using ONNX Runtime.

completed :  deploying a model  operationalizing inference:

  - With GPU scheduling
  - With health probes
  - With endpoint validation
  - With teardown hygiene


  Summary: Very Important Notes
🔐 RBAC is mandatory for secure, scoped access — always pair ServiceAccount + Role + RoleBinding

🧪 GPU scheduling needs nvidia.com/gpu limits and node labeling

📊 Observability stack must be Helm-deployed with values files and dashboard ConfigMaps

🚀 Load testing should be headless, automated, and annotated

🧼 Teardown hygiene = namespaces + declarative manifests + Kustomize

### k8s/base/secrets.yaml — Kubernetes Secret
Always base64 encode values (echo -n "value" | base64)

Use type: Opaque unless integrating with CSI or external secret stores

Never commit secrets to Git — use .gitignore or external secret managers (e.g., AWS Secrets Manager via IRSA) 

#### How to Read the Flow
- EC2‑dev (default VPC) → builds Docker images and pushes them to ECR.
- Terraform modules (VPC, IAM, EKS, GPU node group) → spin up a new VPC with an EKS cluster and GPU nodes (g4dn.xlarge).
- NVIDIA plugin (Helm) → enables GPU scheduling inside Kubernetes.
- Triton Inference Server → runs on GPU nodes, pulling images from ECR.
- Observability stack (Prometheus/Grafana/DCGM exporter) → monitors GPU utilization and cost impact.
- IAM roles → secure access to ECR, SSM, and S3 without static keys.

### Triton Inference : GPU 

## 🏗️ Architecture: Triton in the ML Inference Platform

Client (App / Service / User)
        │
        ▼
API Gateway / Ingress
        │
        ▼
Kubernetes Service (EKS)
        │
        ▼
Triton Inference Server Pod
   ├── Model Repository (/models)
   ├── ONNX / PyTorch / TensorFlow models
   └── Configs (config.pbtxt)
        │
        ▼
GPU Node (AWS EC2 with NVIDIA GPUs)
        │
        ▼
Inference Results (HTTP/gRPC Response)

---

## 🔎 Observability Layer
- **Prometheus** → scrapes Triton + GPU metrics (latency, throughput, utilization).
- **DCGM Exporter** → exposes GPU health and performance data.
- **Grafana Dashboards** → visualize inference performance, GPU usage, errors.

---

## ✅ Flow Summary
1. Clients send inference requests (HTTP/gRPC).
2. Gateway routes requests into EKS.
3. Triton loads models from `/models` and executes inference on GPU.
4. Results are returned to clients.
5. Observability stack monitors everything in real time.
