# (Infrastructure → Build → Deploy)

The Correct Logical Order : 

Think of your system in 3 layers:

Layer 1 — Infrastructure (Terraform)

Creates:

VPC, subnets

EKS cluster

Node groups (GPU + general)

IAM roles

ECR

OIDC for GitHub Actions

Karpenter/autoscaler (optional)

This is done once or only when infra changes.

Layer 2 — Application Build (Docker → ECR)

Build the Triton image:

build

test (optional)

push to ECR

Runs every time you push model or code changes.

Layer 3 — Deployment (Helm / kubectl)

Deploy:

Triton Inference Server

service

configmap

model repository mount

autoscaling

GPU monitoring

Runs after image push.

