Title: Execution Plan — Secure EC2 Dev → ECR Push → GPU Scheduling 

Goal: Stand up a secure dev environment, containerize and push Triton model to ECR, then deploy to GPU-backed Kubernetes node.

✅ Stage 1: Secure EC2 Dev Environment (t3.medium)
☐ Launch EC2 instance (t3.medium) in private subnet with SSM access (no SSH)
☐ Attach IAM role with:
ECR push permissions
S3 read (if model artifacts are remote)

✅ Install dev tools:
✅ Docker, AWS CLI, Python, jq
 ? create ECR to store triton images in artifact registry
✅ aws ecr get-login-password tested

✅ clone github repo for codebase

# ---------------------------------------------
✅ Stage 2: Build & Push Triton Model to ECR
☐ Clone repo to EC2 or mount via SSM

☐ Build Triton image:

bash
docker build -t triton-infer:latest .
☐ Tag and push to ECR:

bash
aws ecr get-login-password | docker login ...
docker tag triton-infer:latest <your-ecr-url>/triton-infer:latest
docker push <your-ecr-url>/triton-infer:latest
☐ Validate image in ECR console

✅ Stage 3: Schedule GPU Pod in EKS
☐ Confirm GPU node group is active (infra/terraform/modules/gpu_node_group)

☐ Label node:

bash
kubectl label node <gpu-node-name> accelerator=nvidia
☐ Deploy Triton via Helm:

bash
helm upgrade --install triton ./triton/helm \
  -f triton/helm/values.yaml \
  --namespace triton --create-namespace
☐ Confirm pod is scheduled on GPU node:

bash
kubectl get pods -n triton -o wide
✅ Stage 4: Validate Inference + Observability
☐ Port-forward Triton:

bash
kubectl port-forward svc/triton-infer 8000:8000 -n triton
☐ Run smoke test:

bash
curl -X POST http://localhost:8000/v2/models/resnet50/infer ...
☐ Confirm GPU metrics via Grafana (DCGM exporter)

☐ Annotate dashboard with “Dev Inference Test”

✅ Stage 5: Teardown Hygiene
☐ helm uninstall triton -n triton

☐ kubectl delete ns triton

☐ Optionally stop EC2 instance or terminate

☐ Clean up ECR image if not needed

🧠 Notes
Use infra/terraform/ to provision GPU node group and ECR repo

Use k8s/ for RBAC, Triton deployment, and observability

Use triton/ for Dockerfile, model repo, and load test scripts

Use make deploy-triton and make teardown-triton for lifecycle control

# =============================================================
### CHECKLIST : 

🧱 Stage 1: Secure EC2 Dev Environment (t3.medium)
[ ] Launch EC2 instance (t3.medium) in private subnet with SSM access (no SSH)

[ ] Attach IAM role with:

[ ] ECR push permissions

[ ] S3 read access (if model artifacts are remote)

[ ] Install dev tools:

[ ] Docker

[ ] AWS CLI

[ ] Python + jq

[ ] Test ECR login:

[ ] aws ecr get-login-password | docker login ...

[ ] Harden instance:

[ ] Disable SSH

[ ] Enable SSM Session Manager

[ ] Tag instance: env=dev, owner=nancy, purpose=triton-build

📦 Stage 2: Build & Push Triton Model to ECR
[ ] Clone repo or sync via SSM

[ ] Build Triton image:

[ ] docker build -t triton-infer:latest .

[ ] Tag and push to ECR:

[ ] docker tag triton-infer:latest <your-ecr-url>/triton-infer:latest

[ ] docker push <your-ecr-url>/triton-infer:latest

[ ] Validate image in ECR console

🚀 Stage 3: Schedule GPU Pod in EKS
[ ] Confirm GPU node group is active (infra/terraform/modules/gpu_node_group)

[ ] Label GPU node:

[ ] kubectl label node <gpu-node-name> accelerator=nvidia

[ ] Deploy Triton via Helm:

[ ] helm upgrade --install triton ./triton/helm -f triton/helm/values.yaml --namespace triton --create-namespace

[ ] Confirm pod is scheduled on GPU node:

[ ] kubectl get pods -n triton -o wide

📊 Stage 4: Validate Inference + Observability
[ ] Port-forward Triton:

[ ] kubectl port-forward svc/triton-infer 8000:8000 -n triton

[ ] Run smoke test:

[ ] curl -X POST http://localhost:8000/v2/models/resnet50/infer ...

[ ] Confirm GPU metrics in Grafana (DCGM exporter)

[ ] Annotate dashboard with “Dev Inference Test”

🧼 Stage 5: Teardown Hygiene
[ ] helm uninstall triton -n triton

[ ] kubectl delete ns triton

[ ] Stop or terminate EC2 instance

[ ] Clean up ECR image (optional)