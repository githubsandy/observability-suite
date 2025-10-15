# Kubernetes Observability Stack

Open source observability solution with monitoring, logging, and tracing for Kubernetes environments.

## 📋 Prerequisites

- Kubernetes cluster (1.20+)
- kubectl configured
- Helm 3.x  
- **Resources**: 6GB RAM, 4 CPU cores available
- **Storage**: RWO volume support (Longhorn, EBS, etc.)

## Quick Deployment

1. Edit configuration:
```bash
vi customer-config.env
```

2. Deploy the stack:
```bash
./deploy-observability-stack.sh
```

## Service Access

Replace `YOUR-NODE-IP` with your cluster node IP:

- **Grafana**: `http://YOUR-NODE-IP:30300` (admin/admin)
- **Prometheus**: `http://YOUR-NODE-IP:30090`
- **Loki**: `http://YOUR-NODE-IP:30310`


## Configuration

Edit `customer-config.env` to set:
```bash
# Set your cluster node IP
KUBERNETES_NODE_IP=192.168.1.100

# Resource limits (optional)
PROMETHEUS_CPU_LIMIT=2
PROMETHEUS_MEMORY_LIMIT=4Gi
```
## Management Commands

**Initial deployment or configuration changes:**
```bash
./deploy-observability-stack.sh
```
Use this for:
- First-time deployment
- After editing `customer-config.env`
- Applying configuration changes

**Upgrade existing deployment (no config changes):**
```bash
./upgrade-observability-stack.sh
```
Use this for:
- Helm chart updates
- When `values.yaml` was manually updated

**Check deployment status:**
```bash
kubectl get pods -n ao-os
kubectl get svc -n ao-os
```

## Troubleshooting

```bash
# Check pod status
kubectl get pods -n ao-os

# Check logs
kubectl logs <pod-name> -n ao-os

# Describe failing pods
kubectl describe pod <pod-name> -n ao-os
```
