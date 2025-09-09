# Observability Stack

## Overview

A comprehensive observability solution for Kubernetes that provides monitoring, logging, and distributed tracing. This stack includes **14 active components** delivering complete visibility into your applications and infrastructure.

**Core Components:** Prometheus, Grafana, Loki, Alertmanager, Tempo  
**Monitoring:** Node metrics, network analysis, database monitoring  
**Environment:** Production-ready deployment for CALO Lab and general use

## Quick Start

### Prerequisites
- Kubernetes cluster with kubectl access
- Helm 3.x installed
- Longhorn storage class (for CALO Lab)

### Deploy
```bash
# Navigate to project directory
cd /path/to/observability-suite/opensource-observability-package

# Remove conflicting namespace template
rm -f ./helm-kube-observability-stack/templates/000_namespace.yaml

# Deploy observability stack
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace
```

### Verify Deployment
```bash
# Check all components are running
kubectl get pods -n ao-os

# Check deployment status
helm status ao-observability -n ao-os
```

## Access Services

After deployment, access the observability services using NodePort or port-forwarding:

| Service | NodePort URL | Description |
|---------|-------------|-------------|
| **Grafana** | `http://NODE-IP:30300` | Main dashboard (admin/admin) |
| **Prometheus** | `http://NODE-IP:30090` | Metrics and monitoring |
| **Loki** | `http://NODE-IP:30310` | Log aggregation |
| **Alertmanager** | `http://NODE-IP:30930` | Alert management |

```bash
# Get node IP addresses
kubectl get nodes -o wide

# Alternative: Use port-forwarding for localhost access
kubectl port-forward -n ao-os svc/grafana 3000:3000
```

## Configuration Updates

```bash
# Upgrade existing deployment
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os

# Remove deployment
helm uninstall ao-observability -n ao-os
```

## Support & Documentation

- **Installation Script:** `./install-observability-stack.sh`
- **Technical Details:** See `Document/Technical-Design-Document.md`
- **Troubleshooting:** Check technical documentation for detailed guides
- **Issues:** Report problems via project issue tracker

---

**🎉 Your observability stack is ready! Access Grafana at `http://NODE-IP:30300` to start monitoring.**