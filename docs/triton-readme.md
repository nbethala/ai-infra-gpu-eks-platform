# Triton is a tool for AI/ML workloads.

- model serving
- makes a trained model available so other apps can use it.
- Depends on : Model repository and batching 
- Model repo - how does it work ?
   - needs explicit folder structure 
   - done automatically
   - no need of writing code 
   - config.pbxt : input, output and batch size 
- makes inference aka prediction faster 
- lowers cost so GPU gets utilized efficiently 
- reduces GPU idle time


### Dynamic batching : Dynamic batching gives you BOTH low latency AND high GPU throughput.
Not all requests arrive at the same time.
If Triton waits for a full batch, it increases latency.
If Triton runs each request individually, it reduces GPU efficiency.
Dynamic batching solves this by doing smart batching on the fly.

### Multiple models on a single GPU 
GPUs are powerful — most real workloads don't use 100% of the GPU.
- Running only ONE model wastes GPU capacity.
- parallel execution
- automatic distribution of traffic
- maximizing GPU usage

⭐ Key point:
You get more performance per GPU → lower cost per inference.

### Why version folders matter
better accuracy
retraining
bug fixes
new data
avoid breaking production.

solution : 
✔️ You can load multiple versions of the same model
✔️ Traffic can target a specific version
✔️ Or Triton can auto-pick the "latest" one
✔️ You can roll back instantly
 - ⭐ Key point:
Versions allow safe updates, A/B testing, and easy rollback.

### How Triton routes traffic to correct models
http request : POST /v2/models/resnet/versions/2/infer
Triton guarantees the right model handles the right request, even with multiple versions and multiple models loaded.

## Triton Model Serving: 
### 3.1 . Package ONNX Model (ResNet50 or MobileNet)
 - config.pbtxt - protobuff style config file - important 
 - define model metadata in the pbtxt file.
 - batching, GPU acceleration, and correct tensor formatting — all critical for production-grade inference.

### 3.2 - Create Dockerfile - commands are in Makefile (automation)
 - build image locally 
 - Create ECR Repository (One-Time)
 - Tag and Push to ECR
 - triton/Makefile.triton : 
 -usage :
 ```
 cd triton
make push-triton
```
- note : to push triton model to ECR repo you need aws credentials. do not hardcode anything in files.
- create a .env file in the /triton folder with credentials 
- " make check-env " to verify your environment before pushing.
- " make push-triton "  - this will not expose any credentials

✅ Result
You now have a custom Triton image in ECR that:
Serves your ONNX model
Runs on GPU nodes
Deploys cleanly via Helm or YAML
Can be versioned, reused, and torn down easily

### 3.3: Deploy Triton via Helm (GPU + Probes) 
 - deploy via helm for easy teardown - helm unistall
 - Scalable: Add replicas, autoscaling, and metrics later
 
 ### Manual method of deploying triton via helm
 - Add Helm Repo (if using NVIDIA’s chart) 

 ```
 helm repo add nvcr https://helm.ngc.nvidia.com/nvcr
helm repo update
```
- triton/helm/values.yaml 
-  deploy via helm: 
```
helm upgrade --install triton-infer nvcr/triton-inference-server \
  --namespace triton \
  --create-namespace \
  -f triton/helm/values.yaml
```

- verify deployment: 
```
kubectl get pods -n triton
kubectl describe pod <triton-pod-name> -n triton | grep nvidia.com/gpu
```

- teardown: 
```
helm uninstall triton-infer -n triton
```
Resuls: 
Deployed Triton on GPU nodes using your custom ECR image, with health probes, node targeting, and teardown hygiene — all via Helm.

#### Automated deployment via Make utility
 - make deploy-triton (Add and update the Helm repo) 
 - make destroy-triton

### step 3.4 Smoke test inference endpoint: 

 #### Helm + Port-Forward + Scripted Smoke Test
This smoke test confirms that your Triton server is:
 - Running on GPU nodes
 - Serving your ONNX model correctly
 - Accepting and responding to inference requests

#### Manual method step-by-step smoke test
1. Port-forward Triton service
```
kubectl port-forward svc/triton-infer 8000:8000 -n triton
```

2. Prepare input.json ( run script triton/generate-input.py)
3. Send Inference Request
```
curl -X POST http://localhost:8000/v2/models/resnet50/infer \
  -H "Content-Type: application/json" \
  -d @input.json
```

4. Confirm GPU Usage (Optional)
```
kubectl exec -it <triton-pod> -n triton -- nvidia-smi
```
#### Automated smoke test
make smoke-test

