# Common issues we ran into during execution and fixes. 

###  Disk Size Issue and Resolution

#### Problem
While building the Triton Inference Server Docker image, the build failed with: no space left on device.

This happened because the EC2 root volume was only **15 GB**, and the Triton image layers (CUDA + runtime) consumed more than the available free space.

---

#### Solution: Growing the Filesystem
We increased the root volume size to **30 GB** in the AWS Console, then expanded the partition and filesystem inside the instance:
```
# Expand partition 1 on the NVMe root disk
sudo growpart /dev/nvme0n1 1

# Resize the filesystem to use the new partition size
sudo resize2fs /dev/root
```

#### Monitor doscker disk usage 

# Show Docker disk usage
docker system df

# Clean up unused images, containers, and volumes
docker system prune -af
docker volume prune -f

# Clear build cache
docker builder prune -af

#### GPU Node debug : 

- check system logs - dmesg | grep -i nvidia
- driver module is loaded - lsmod | grep nvidia

### stuck Node group: 
Error : Node group was stuck in create phase with timeout. Missing IAM policy for CNI plugin

Solution: IAM role definition for your GPU node group:
 - Trust policy → comes from node-trust-policy.json (lets EC2 assume the role).
 - Attached managed policies → all the required ones are here:
 - AmazonEKSWorkerNodePolicy
 - AmazonEKS_CNI_Policy ← this was the missing piece
 - AmazonEC2ContainerRegistryReadOnly
 - CloudWatchAgentServerPolicy (optional, but useful for metrics/logging)

Process : 
- When your GPU EC2 nodes boot, they need to:
- Register with the EKS control plane → AmazonEKSWorkerNodePolicy
- Get pod IPs via the VPC CNI plugin → AmazonEKS_CNI_Policy
- Pull images from ECR → AmazonEC2ContainerRegistryReadOnly
- Send logs/metrics to CloudWatch → CloudWatchAgentServerPolicy

### NVIDIA device plugin does not install:
found the right location use yaml 
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.17.3/deployments/static/nvidia-device-plugin.yml
verigy : 
kubectl get pods -n kube-system | grep nvidia
nvidia-device-plugin-daemonset-kdcg6   1/1     Running   0          2m

#### plugin cannot talk to GPU drivers
Even though nvidia-smi works on the node, the plugin container may NOT have:
✅ access to /dev/nvidia*
❌ correct driver volume mount
❌ correct privileged mode
❌ correct GPU feature gate in kubelet
❌ correct nvidia-container-toolkit inside AMI

#### /opt/nvidia/nvidia_entrypoint.sh: line 49: exec: tritonserver: not found
When you try to inference the model it gives an error not found.
Reason : Always Install Triton server first for testing purposes if doing manually. Then docker build the image. 

The right pattern is: start from the official Triton Server image (which already has the tritonserver binary installed), then layer your own models/configs on top. That way you don’t end up with a “base only” image missing the server executable.

#### disk space out 
- These are large images/models make sure you have plenty of space allocated. 
# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes
docker volume prune -f

# Remove unused networks
docker network prune -f

#### Ensure correct model path is given otherwise triton will not detect 

docker run --rm --gpus all \
  -p8000:8000 -p8001:8001 -p8002:8002 \
  -v /home/ubuntu/triton-mlops-gpu-platform/services/triton/models:/models \
  nvcr.io/nvidia/tritonserver:24.01-py3 \
  tritonserver --model-repository=/models

### verify absolute path : 
cd ~/triton-mlops-gpu-platform

ls -R services/triton/models

### Update config.pbtxt

Your TRT/ONNX model (ResNet50-v2-7) uses:

### Errors continue and inference dosent work config.pbtxt dosent match the model. 
solution Let triton generate the config file matching your model
--strict-model-config=false # this generates the config

docker run --rm --gpus all \
  -p8000:8000 -p8001:8001 -p8002:8002 \
  -v /home/ubuntu/triton-mlops-gpu-platform/services/triton/models:/models \
  nvcr.io/nvidia/tritonserver:24.01-py3 \
  tritonserver --model-repository=/models --strict-model-config=false


Triton will:

Load your ONNX model
Inspect tensor names & shapes
Generate an internal config automatically
You can GET it via HTTP:

###cleanup docker cache 
df -h
docker system df

Final Result

Your GPU node is now fully ready, and Triton is correctly:

installed

running

exposing all inference endpoints

loading ONNX model

generating config

using GPU

batching requests

This was the exact purpose of the GPU-node smoke test — and you passed 100%.

### CRD's- Prometheus Mish-Mash - hours wasted! 
===============================================
The key is to manage PrometheusRules declaratively via Helm values, not kubernetes_manifest. 
This approach is robust, repeatable, and CI/CD-friendly. 

with kubernetes_manifest timing was an issue

use helm deployment for CRD's 