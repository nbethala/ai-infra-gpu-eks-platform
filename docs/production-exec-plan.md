## Production step-by-step execution plan 

### Stage 1: Provision Infrastructure (Terraform)
Navigate to infra/terraform/

```
cd infra/terraform
terraform init
terraform apply -var-file=dev.tfvars

#Verify:
kubectl get nodes -l accelerator=nvidia

#check node group status to verify its healthy
aws eks describe-nodegroup \
  --cluster-name gpu-e2e-cluster \
  --nodegroup-name gpu-e2e-cluster-gpu-spot

kubectl get nodes -o wide


```

Result: 
VPC + subnets created (modules/vpc)
IAM roles/policies applied (modules/iam, policies/*.json)
EKS cluster provisioned (modules/eks)
GPU node group spun up (modules/gpu_node_group)
NVIDIA device plugin Helm release installed (modules/nvidia_plugin)

### Stage 2: Triton Image Build & Push
```
docker build -t triton-infer:latest ./triton
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com
docker tag triton-infer:latest <account_id>.dkr.ecr.us-east-1.amazonaws.com/triton-infer:latest
docker push <account_id>.dkr.ecr.us-east-1.amazonaws.com/triton-infer:latest
```

Result: 
 - Triton image with your model repo is built.
 - Image pushed to ECR for reproducible deployment.


### Stage 3: Deploy Triton on GPU Node (K8s + Helm)
 - Apply base namespace + RBAC:
```
kubectl apply -k k8s/base/
```
 - Deploy Triton:
```
kubectl apply -k k8s/triton/

# or via Helm:

helm upgrade --install triton ./triton/helm \
  -f triton/helm/values.yaml \
  --namespace triton --create-namespace

# Verify pod scheduling:
kubectl get pods -n triton -o wide
```

### Stage 4: Observability & Validation
 - Deploy monitoring stack:
```
kubectl apply -k k8s/monitoring/

#Prometheus scrapes Triton (:8002/metrics) + DCGM exporter (:9400/metrics).
#grafana dashboards loaded from triton/observability/grafana-dashboards/.
```

- Smoke test Triton:
```
kubectl port-forward svc/triton-infer 8000:8000 -n triton
curl localhost:8000/v2/health/ready

#Should return true.
```

- Run inference test:
```
./triton/smoke-test-triton.sh

#Confirms ResNet50 inference works.
```

- Load test:
```
cd triton/loadtest
./run-locust.sh

# Annotate Grafana dashboards with annotate-start.sh / annotate-stop.sh.
```

### Stage 5: Teardown Hygiene
 - Remove Triton:
```
helm uninstall triton -n triton
kubectl delete ns triton
```

- Destroy infra:
```
terraform destroy -var-file=dev.tfvars
```

##### Optional cleanup:

 - Delete ECR images.
 - Remove IAM roles/policies.
 - remove elastic IP if any 

================================
✅ Bottom Line
 - Terraform builds infra (VPC, EKS, GPU nodes, IAM).
 - K8s base wires namespaces + RBAC.
 - Triton manifests deploy inference server from ECR.
 - Monitoring manifests deploy DCGM exporter, Prometheus, Grafana dashboards.
 - Smoke/load tests validate inference + metrics.
 - Teardown hygiene keeps costs under control.