# ------------------export prometheus & NVIDIA DCGM ------------------# 

deploy-observability:
    helm upgrade --install prom-operator prometheus-community/kube-prometheus-stack \
      --namespace monitoring --create-namespace \
      -f observability/prometheus-values.yaml

    helm upgrade --install dcgm-exporter nvdp/dcgm-exporter \
      --namespace monitoring \
      -f observability/dcgm-values.yaml
	