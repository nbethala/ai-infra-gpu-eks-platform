Helm charts can look confusing until you realize there’s a two‑level structure at play. Let’s break down the difference between services/triton/helm/ and services/triton/helm/templates/:

🔹 Helm Chart Directory Layout
A typical Helm chart looks like this:
```
services/triton/helm/
├── Chart.yaml          # metadata about the chart (name, version, description)
├── values.yaml         # default configuration values
├── templates/          # Kubernetes manifests, parameterized with Helm templating
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── _helpers.tpl
│   └── ...
```

🔹 Key Difference
helm/ (root of the chart)

Holds chart metadata and configuration.

Files like:

Chart.yaml → defines chart name, version, description.

values.yaml → default values for variables (image repo, tag, replicas, etc.).

README.md or NOTES.txt → optional documentation.

Think of this as the blueprint header.

helm/templates/

Holds Kubernetes resource definitions written in YAML, but parameterized with Helm’s Go templating ({{ ... }}).

Files like:

deployment.yaml → defines your Triton Deployment.

service.yaml → defines Service for exposing Triton.

ingress.yaml → optional ingress rules.

_helpers.tpl → reusable template snippets.

These are the actual manifests that get rendered into Kubernetes YAML when you run helm install or helm upgrade.

### ZZWhen you run helm install, Helm merges values.yaml (plus any overrides you pass with --set or -f) into the templates, producing final Kubernetes manifests.

✅ Bottom Line
services/triton/helm/ → chart metadata + configuration defaults.

services/triton/helm/templates/ → actual Kubernetes manifests, parameterized with Helm templating.

Together, they let you reuse the same chart across environments by swapping values, while keeping the resource definitions consistent.

############3
erraform code straightforward and practical (Helm provider helm_release for the charts, Kubernetes provider for ConfigMap/Secret, and a kubernetes_manifest for the PrometheusRule). There are small placeholders you must fill (Slack webhook, chart versions, and any account-specific ARNs). After you apply these (or run CI), Prometheus + Grafana + dashboards + alert rules will be deployed as part of your infra pipeline and will be ready for Triton to be deployed on top.