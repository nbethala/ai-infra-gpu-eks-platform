# 🧱 Project Plan: AI Infra GPU EKS Platform

## Stage 0: Bootstrap
✅ IAM roles with least privilege
✅ AWS billing alarm + tagging hygiene
✅ GitHub repo scaffold (infra/, k8s/, model/, tests/, ci/, docs/)
☐ Define KPIs: latency (P50/P95), throughput, GPU utilization, error rate, cost

## Stage 1: Infrastructure Provisioning (Terraform)
✅ VPC with public/private subnets + NAT
✅ EKS control plane
✅ IAM role for ALB controller (IRSA)
[] Validate cluster connectivity (kubectl get nodes) 
### TO-DO :  
 - plan: terraform plan -var-file=terraform.tfvars
 - Apply: terraform apply -var-file=terraform.tfvars
 - update kubeconfig: aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>
 - validate cluster connectivity: kubectl get nodes

## Stage 2: GPU Node Group & Scheduling
✅ Spot GPU node group (e.g., g4dn.xlarge) # setup infra via module 
x Taints: key=gpu, effect=NoSchedule # not needed yet
✅ Labels: accelerator=nvidia # setup in the node group module
✅ NVIDIA device plugin via Helm provider using - Terraform
☐ Verify GPU visibility (kubectl describe node | grep nvidia.com/gpu)

## Stage 3: Triton Model Serving
[x] Package ONNX model (ResNet50 or MobileNet)
[x] Build + push Triton Docker image to ECR (AWS)
[x] Deploy Triton via Helm (with GPU scheduling + probes)
[ ]ALB ingress with HTTPS + health checks ( optional: if exposing dashboards extrenally then add an ALB ingress)
[x] Smoke test inference endpoint

## Stage 4: Observability Stack
x Prometheus Operator via Helm 
x NVIDIA DCGM exporter for GPU metrics
x Grafana dashboards (GPU, latency, throughput)
x Smoke Test : Annotate dashboards with “Load Test Start/Stop”

## Stage 5: Synthetic Load Testing - All scripts Wired !! X
☐ Define test scenarios (Smoke, Spike, Soak)
☐ Run Locust/k6 headless (laptop or EC2)
☐ Capture latency, throughput, error %, GPU utilization
☐ Export results (CSV/JSON) + Grafana snapshots
☐ Annotate events (scale-ups, throttling, errors)

## Stage 6: Teardown & Cost Audit
☐ terraform destroy all infra
☐ Verify no leftover resources
☐ AWS Cost Explorer: GPU hours, spot savings, total spend
☐ Document in docs/cost-audit.md

## Stage 7: Evidence Pack
☐ Write README.md (Problem → Architecture → Run → KPIs → Cost → Teardown)
☐ Architecture diagram (VPC → EKS → GPU → Triton → ALB → Prometheus/Grafana)
☐ Grafana screenshots + load test graphs
☐ One-pager case study
☐ (Optional) Publish blog/LinkedIn post




🧱 Stage-by-Stage Breakdown with Tools
Stage	Purpose	Tools & Technologies Used
Stage 0: Bootstrap	Setup IAM, billing guardrails, repo structure	- AWS IAM (least privilege roles)<br>- AWS Budgets (billing alarm)<br>- GitHub (repo scaffold: infra/, k8s/, model/, etc.)
Stage 1: Infra Provisioning	Build VPC, EKS control plane, IRSA	- Terraform (VPC, subnets, NAT, EKS)<br>- AWS IAM (IRSA for ALB controller)<br>- kubectl (cluster validation)
Stage 2: GPU Node Group & Scheduling	Add GPU nodes, taints, labels, device plugin	- Terraform (GPU node group)<br>- Kubernetes (taints, labels)<br>- Helm (NVIDIA device plugin)<br>- kubectl (GPU visibility check)
Stage 3: Triton Model Serving	Deploy ONNX model with GPU inference	- ONNX (ResNet50/MobileNet)<br>- Docker (Triton image)<br>- AWS ECR (image registry)<br>- Helm (Triton deployment)<br>- AWS ALB (ingress)<br>- curl (inference smoke test)
Stage 4: Observability Stack	Monitor GPU, latency, throughput	- Helm (Prometheus Operator)<br>- NVIDIA DCGM exporter<br>- Grafana (dashboards)<br>- Kubernetes annotations
Stage 5: Synthetic Load Testing	Stress test inference endpoint	- Locust or k6 (load generation)<br>- Grafana (metrics capture)<br>- CSV/JSON exports<br>- Event annotations
Stage 6: Teardown & Cost Audit	Clean up infra, report spend	- Terraform (destroy)<br>- AWS Cost Explorer<br>- Manual verification (EKS, EC2, ALB, S3)<br>- Markdown (docs/cost-audit.md)
Stage 7: Evidence Pack	Document architecture, results, teardown	- Markdown (README.md, case study)<br>- Diagrams (draw.io, Excalidraw, or Mermaid)<br>- Screenshots (Grafana, load test)<br>- Optional: LinkedIn/blog post
🧠 Optional KPIs to Track
Latency: P50, P95, P99

Throughput: requests/sec

GPU Utilization: % usage

Error Rate: 4xx/5xx %

Cost: total spend, spot savings, GPU hours