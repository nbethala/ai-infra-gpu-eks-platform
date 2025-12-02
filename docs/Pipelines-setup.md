## Production pipeline setup : 
#### Phase 3 — CI-Infra Pipeline + CI Helm Deploy + CD Build-Push-Triton

📌 LAYER 1 — Infra CI Pipeline (Terraform)

This pipeline:

Builds VPC, EKS, GPU node group, IAM, OIDC role

Stores state in S3 + DynamoDB

Runs terraform fmt, validate, plan, apply

Uses GitHub → OIDC → AWS IAM (no credentials!)

🔧 WHEN DOES IT RUN?

On pull_request → validate only

On main merge → full apply

On destroy branch → teardown infra

1️⃣ Infra Pipeline: .github/workflows/infra-provision.yaml
Workflow Summary
Event	Action
PR → feat/triton-ci-deploy	Lint + Validate + Plan
merge → main	Auto-provision infra (apply)
push → teardown-infra	Destroys all AWS infra

📌 LAYER 2 — CI Helm Deploy (EKS + Triton + Prometheus + Grafana)

This pipeline:

Connects to EKS using AWS OIDC

Gets kubeconfig dynamically

Installs or upgrades:

Triton Helm chart

Prometheus

Grafana

GPU monitoring

🔧 WHEN DOES IT RUN?

On merge into main

Only after Terraform infra is provisioned


LAYER 3 — CD Build + Push Triton Container Image
🔧 WHEN DOES IT RUN?

Every commit to main

Every time model changes in services/triton/models/*

Tags ECR image:

latest

Git SHA

Semantic version


FINAL END-TO-END PIPELINE FLOW

```
              ┌────────────────────────────┐
              │   feat/triton-ci-deploy    │
              └──────────────┬─────────────┘
                             PR
                              ↓
              ┌────────────────────────────┐
              │      Terraform Validate     │
              └──────────────┬─────────────┘
                         Merge to main
                              ↓
    ┌────────────────────────────────────────────────┐
    │           Phase 1 — Infra CI (Terraform)        │
    │   VPC → EKS → GPU Nodes → IAM → OIDC → Outputs  │
    └──────────────────────┬──────────────────────────┘
                           ↓
    ┌────────────────────────────────────────────────┐
    │      Phase 2 — Helm Deploy (EKS)               │
    │ Triton + Prometheus + Grafana + GPU Metrics    │
    └──────────────────────┬──────────────────────────┘
                           ↓
    ┌────────────────────────────────────────────────┐
    │        Phase 3 — CD Container Pipeline          │
    │ Build → Push → Tag → Update ECR → Redeploy      │
    └─────────────────────────────────────────────────┘
```

✅ You now have a complete professional-grade MLOps CI/CD system

with:

AWS OIDC

Terraform infra automation

EKS GPU nodes

Triton Helm chart

Prometheus/Grafana monitoring

GPU-metrics dashboards

End-to-end build → deploy → observe flow


### ======================Final Pipeline worklflow Dependencies ###############
- on Main trigger Infra provision 
- check github environment files if  infra is provisioned 
(Option B — GitHub Environment Protection (Recommended))
- THEN deploy via helm to provision 
      -Deploy:

Triton Inference Server Helm chart

Prometheus (monitoring)

Grafana (dashboards)

NVIDIA DCGM exporter (GPU metrics)

- Infra -destroy - On Manual trigger only 

=============================================

🎯 You Now Have a Fully Integrated Monitoring Stack

This matches your REAL folder layout and includes:

✔ Full Prometheus alert rules
✔ ServiceMonitor for Triton
✔ Grafana dashboards auto-loader
✔ Clean Helm packaging per component
✔ Uses your EXACT monitoring folder structure


OPTIONS FOR NEXT:
=============####################i
