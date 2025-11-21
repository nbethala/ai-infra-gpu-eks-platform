## Stage 4: Observability Stack

4.1 Prometheus Operator via Helm 
Why: Central metrics engine for Kubernetes, Triton, and GPU exporters
How : Scaffold prometheus-values.yaml to include service monitors and retention settings.

4.2 NVIDIA DCGM exporter for GPU metrics
Why: Why: Exposes GPU memory, utilization, temperature, and error states
How: Make sure GPU nodes are labeled and tolerations are set.

4.3 Grafana dashboards (GPU, latency, throughput)
WHY: Why: Visualize Triton performance, GPU health, and inference latency
How: Use built-in dashboards from kube-prometheus-stack

4.4 Annotate dashboards with “Load Test Start/Stop
WHy: Correlate performance spikes with test events
How: Use Grafana API to post annotations 
     Automate this in your load test script or CI pipeline.( optional)


#### grafana-dashboards/
gpu-dashboard.json: NVIDIA DCGM metrics (GPU memory, utilization, temperature)

triton-latency.json: Triton model latency, throughput, load time

loadtest-annotated.json: Panels with annotation support for start/stop markers

You can import these via Grafana UI or provision them via ConfigMap.

### setup : 

4.1 : Deploy Prometheus Operator via Helm 
This sets up Prometheus, Alertmanager, and Grafana in one go.

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install prom-operator prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f triton/observability/prometheus-values.yaml
```

4.2 Deploy DCGM Exporter for GPU Metrics
This exposes GPU metrics like memory usage, temperature, and utilization to Prometheus.

```
helm repo add nvdp https://nvidia.github.io/dcgm-exporter/helm-charts
helm repo update

helm upgrade --install dcgm-exporter nvdp/dcgm-exporter \
  --namespace monitoring \
  -f triton/observability/dcgm-values.yaml
```

4.3 grafana dashboards - Access Grafana UI
```
kubectl port-forward svc/prom-operator-grafana 3000:80 -n monitoring
```
Then open: http://localhost:3000 
Login: admin / admin (default)

4.4 Create Dashboards in Grafana
Go to Dashboards → New

Add panels for:

DCGM_FI_DEV_GPU_UTIL → GPU utilization

DCGM_FI_DEV_MEM_USED → GPU memory used

nv_inference_request_duration_us → Triton latency

nv_inference_count → Throughput

Set Prometheus as the data source

Customize layout, thresholds, colors

4.5 Export Dashboard as JSON
Open the dashboard

Click the gear icon → JSON Model

Copy the entire JSON

Save it to your repo:
```
triton/
└── observability/
    └── grafana-dashboards/
        ├── gpu-dashboard.json
        ├── triton-latency.json
        └── loadtest-annotated.json
```
 These files can now be version-controlled and provisioned via ConfigMap or Helm.
 
 summary :
 
Building dashboards from live Prometheus + DCGM metrics, customizing them in Grafana, and exporting them as JSON for reproducible deployment. This is how real AI platforms manage observability — modular, versioned, and automation-ready.


4.4 : Step-by-Step: Triton Load Test with Dashboard Annotation
#### prform a load testing 

1. Prep: Port-forward Triton
```
kubectl port-forward svc/triton-infer 8000:8000 -n triton &
PORT_PID=$!
sleep 5
```
2. Annotate “Load Test Start” in Grafana
```
bash annotate-start.sh
```

3. Run Load Test (e.g. 100 requests)
 python loadtest.py

4. Annotate “Load Test Stop”
 bash annotate-stop.sh

5. cleanup 
kill $PORT_PID


📊 What You’ll See in Grafana 

GPU utilization spike (DCGM_FI_DEV_GPU_UTIL)

Memory usage increase (DCGM_FI_DEV_MEM_USED)

Inference latency (nv_inference_request_duration_us)

Throughput (nv_inference_count)

Vertical lines: “Load Test Start” and “Load Test Stop”

- Real-time, annotated load test against Triton — with metrics, dashboard markers
- Purpose: Endpoint validation, GPU spike confirmation 

## Stage 5: Synthetic Load Testing - Triton
============================================
This is performance validation — not just “does it work,” but “how well does it scale, recover, and behave under stress.”


