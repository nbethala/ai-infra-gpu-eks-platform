resource "helm_release" "nvidia_device_plugin" {
  name       = "nvidia-device-plugin"
  namespace  = "kube-system"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "k8s-device-plugin"
  version    = "0.14.0"

  set {
    name  = "tolerations[0].key"
    value = "gpu"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "nodeSelector.accelerator"
    value = "nvidia"
  }
}
