# Title: Execution Plan — Secure EC2 Dev → ECR Push → GPU Scheduling 

Goal: Setup up a secure dev environment, containerize and push Triton model to ECR, then deploy to GPU-backed Kubernetes node.

✅ Stage 1: Secure EC2 Dev Environment (t3.medium)
✅ Launch EC2 instance (t3.medium) in private subnet with SSM access (no SSH)
✅ Attach IAM role with:
ECR push permissions
S3 read (if model artifacts are remote)

✅ Install dev tools:
✅ Docker, AWS CLI, Python, jq
✅ clone github repo for codebase
✅ create ECR to store triton images in artifact registry

✅ aws ecr get-login-password tested
```
aws ecr create-repository --repository-name triton-server --region us-east-1
```

# ---------------------------------------------
✅ Stage 2: Build & Push Triton Model to ECR
☐ Clone repo to EC2 or mount via SSM

☐ Build Triton image:
```
docker build -t triton-infer:latest .
```
☐ Authenticate, Tag and push to ECR then verify:
```
aws ecr get-login-password | docker login ...

aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

docker tag triton-infer:latest <your-ecr-url>/triton-infer:latest

docker push <your-ecr-url>/triton-infer:latest

aws ecr describe-images --repository-name triton-infer --region us-east-1
```

✅ Stage 3: Schedule GPU Pod in EKS

### Prep gpu node : 
  - disable swap
  - install NVIDIA drivers (the kernel module will allow the OS to talk to the GPU hardware. Without this the GPU is invisible to the system)
  ```
  sudo apt update && sudo apt install -y build-essential dkms
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/525.125.06/NVIDIA-Linux-x86_64-525.125.06.run
chmod +x NVIDIA-Linux-x86_64-525.125.06.run
sudo ./NVIDIA-Linux-x86_64-525.125.06.run --silent
nvidia-smi
```

- NVIDIA Container Toolkit (bridge GPU into Docker.) + Docker Install
```
curl -fsSL https://get.docker.com | sudo bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker
```
- Verify : nvidia-smi

Driver: 535.274.02
CUDA: 12.2
GPU: Tesla T4, 15 GB VRAM
Status: Idle, no processes yet

# ----------------------------------------------
### Spin Triton Server 
```
docker run --rm --gpus all -p8000:8000 -p8001:8001 -p8002:8002 \
  nvcr.io/nvidia/tritonserver:23.10-py3 tritonserver --help
```








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