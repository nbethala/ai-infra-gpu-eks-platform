# Project 1 Checklist : 

Stage 0: setup IAM roles, Github repo, AWS alarms
[x] Create AWS IAM role/user with least privilege (EKS, EC2, IAM, ECR, ALB, S3)

[x] Set AWS billing alarm at $5 and tag all resources (project=gpu-e2e, owner=Nancy)

[x] Scaffold GitHub repo folders (infra/, k8s/, model/, tests/, ci/, docs/)

[ ? ] Define KPIs (latency P50/P95, throughput, GPU utilization, error rate, cost)

Stage 1: Infrastructure Provisioning - Terraform
[x] Build VPC with private/public subnets + NAT gateway (Terraform)

[ ] Provision EKS cluster control plane (Terraform)

[x] Create IAM role for ALB ingress controller (IRSA)

[ ] Validate cluster connectivity (kubectl get nodes)

Stage 2: GPU Node Group & Scheduling
[ ] Add spot GPU node group (g4dn.xlarge) with max price cap

[ ] Apply taints (key=gpu, effect=NoSchedule) to GPU nodes

[ ] Label GPU nodes (accelerator=nvidia)

[ ] Deploy NVIDIA device plugin via Helm

[ ] Verify GPU resources (kubectl describe node | grep nvidia.com/gpu)

Stage 3: Triton Model Serving
[ ] Package sample ONNX model (ResNet50/MobileNet)

[ ] Build Triton Docker image and push to ECR

[ ] Deploy Triton via Helm with GPU scheduling + probes

[ ] Configure ALB ingress with HTTPS + health checks

[ ] Smoke test inference endpoint (curl /v2/models/<name>/infer)

Stage 4: Observability Stack
[ ] Deploy Prometheus Operator via Helm

[ ] Install NVIDIA DCGM exporter for GPU metrics

[ ] Deploy Grafana and import dashboards (GPU, latency, throughput)

[ ] Annotate dashboards with “Load Test Start/Stop”

Stage 5: Synthetic Load Testing
[ ] Define test scenarios (Smoke, Spike, Soak)

[ ] Run Locust/k6 headless from laptop or EC2 Free Tier

[ ] Capture latency P50/P95/P99, throughput, error %, GPU utilization

[ ] Export CSV/JSON results + Grafana snapshots

[ ] Annotate events (scale-ups, throttling, errors)

Stage 6: Teardown & Cost Audit
[ ] Run terraform destroy to remove cluster, nodes, ALB, ECR images

[ ] Verify no leftover resources (EKS, EC2, ALB, S3)

[ ] Use AWS Cost Explorer to report GPU hours, spot savings, total spend

[ ] Document in docs/cost-audit.md

Stage 7: Evidence Pack & Recruiter Narrative
[ ] Write README.md (Problem → Architecture → Run → KPIs → Cost → Teardown)

[ ] Create architecture diagram (VPC → EKS → GPU → Triton → ALB → Prometheus/Grafana)

[ ] Capture Grafana screenshots + load test graphs

[ ] Draft one‑pager case study with results + teardown discipline

[ ] Optional: Publish blog/LinkedIn post with visuals 