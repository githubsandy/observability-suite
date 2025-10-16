# Kubernetes Observability Stack

Open source observability solution with monitoring, logging, and tracing for Kubernetes environments.

## 🏗️ Architecture

### Component Overview

This observability stack consists of the following core components:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Applications  │    │  Kubernetes     │    │   Infrastructure│
│                 │    │  Components     │    │                 │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │ metrics/logs         │ metrics              │ metrics
          │                      │                      │
          ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Data Collection Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │ Prometheus  │  │    Loki     │  │     Node Exporters      │ │
│  │  (Metrics)  │  │   (Logs)    │  │  (System Metrics)       │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
          │                      │                      │
          │ query/api            │ query/api            │
          │                      │                      │
          ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Visualization Layer                          │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                      Grafana                                ││
│  │              (Dashboards & Alerting)                       ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Core Components

**Prometheus**
- Metrics collection and storage
- Service discovery for Kubernetes
- AlertManager for notification routing
- Exposed on port 30090

**Grafana**
- Unified dashboard interface
- Data source integration (Prometheus, Loki)
- User management and alerting
- Exposed on port 30300

**Loki**
- Log aggregation and storage
- Kubernetes log collection via Promtail
- LogQL query language support
- Exposed on port 30310

### Data Flow

1. **Metrics Collection**: Prometheus scrapes metrics from:
   - Application endpoints (/metrics)
   - Kubernetes API server
   - Node exporters
   - kube-state-metrics

2. **Log Collection**: Promtail agents collect logs from:
   - Container stdout/stderr
   - System logs
   - Application log files

3. **Visualization**: Grafana queries both:
   - Prometheus for metrics and alerts
   - Loki for log exploration and correlation

4. **Storage**:
   - Prometheus: Time-series data in local storage
   - Loki: Log chunks in object storage or local filesystem

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

## ⎈ Helm Charts

### Chart Structure

This observability stack uses multiple Helm charts for modular deployment:

```
charts/
├── prometheus/                 # Metrics collection and storage
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── grafana/                   # Visualization and dashboards
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── loki/                      # Log aggregation
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── observability-stack/       # Umbrella chart
    ├── Chart.yaml
    ├── values.yaml
    └── charts/               # Subcharts
```

### Chart Dependencies

The main `observability-stack` chart manages dependencies:

```yaml
# Chart.yaml
dependencies:
  - name: prometheus
    version: "~15.0.0"
    repository: "https://prometheus-community.github.io/helm-charts"
  - name: grafana
    version: "~6.50.0"
    repository: "https://grafana.github.io/helm-charts"
  - name: loki
    version: "~4.0.0"
    repository: "https://grafana.github.io/helm-charts"
```

### Values Configuration

#### Global Values Override

Edit `values.yaml` to customize the entire stack:

```yaml
global:
  storageClass: "longhorn"  # Your storage class
  nodeIP: "192.168.1.100"   # Cluster node IP

prometheus:
  server:
    persistentVolume:
      size: 50Gi
    resources:
      limits:
        cpu: 2000m
        memory: 4Gi

grafana:
  persistence:
    enabled: true
    size: 10Gi
  adminPassword: "your-secure-password"

loki:
  storage:
    type: filesystem
    filesystem:
      chunk_store_config:
        max_look_back_period: 168h  # 7 days
```

#### Component-Specific Customization

**Prometheus Configuration:**
```yaml
prometheus:
  alertmanager:
    enabled: true
  server:
    retention: "30d"
    scrapeInterval: "30s"
  nodeExporter:
    enabled: true
```

**Grafana Configuration:**
```yaml
grafana:
  adminUser: admin
  adminPassword: admin
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - name: Prometheus
          type: prometheus
          url: http://prometheus-server:80
        - name: Loki
          type: loki
          url: http://loki:3100
```

**Loki Configuration:**
```yaml
loki:
  config:
    auth_enabled: false
    server:
      http_listen_port: 3100
    schema_config:
      configs:
        - from: 2020-10-24
          store: boltdb-shipper
          object_store: filesystem
          schema: v11
```

### Helm Chart Commands

**Install/Upgrade with custom values:**
```bash
# Using custom values file
helm upgrade --install observability-stack ./charts/observability-stack \
  --namespace ao-os --create-namespace \
  --values custom-values.yaml

# Override specific values
helm upgrade --install observability-stack ./charts/observability-stack \
  --namespace ao-os --create-namespace \
  --set global.nodeIP=192.168.1.100 \
  --set prometheus.server.persistentVolume.size=100Gi
```

**Chart Management:**
```bash
# Update chart dependencies
helm dependency update ./charts/observability-stack

# Validate chart templates
helm lint ./charts/observability-stack

# Generate templates (dry-run)
helm template observability-stack ./charts/observability-stack \
  --namespace ao-os --values values.yaml

# Check current values
helm get values observability-stack -n ao-os

# Rollback to previous version
helm rollback observability-stack 1 -n ao-os
```

### Custom Values File Example

Create `custom-values.yaml` for environment-specific configurations:

```yaml
# custom-values.yaml
global:
  storageClass: "fast-ssd"
  nodeIP: "10.0.1.100"

prometheus:
  server:
    persistentVolume:
      size: 100Gi
      storageClass: "fast-ssd"
    resources:
      requests:
        cpu: 1000m
        memory: 2Gi
      limits:
        cpu: 2000m
        memory: 4Gi
    retention: "90d"

  alertmanager:
    enabled: true
    persistentVolume:
      size: 10Gi

grafana:
  adminPassword: "secure-admin-password"
  persistence:
    enabled: true
    size: 20Gi
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

loki:
  persistence:
    enabled: true
    size: 50Gi
  config:
    limits_config:
      retention_period: 720h  # 30 days
```

### Chart Versioning

Track chart versions for reliable deployments:

```bash
# List available chart versions
helm search repo prometheus-community/prometheus --versions

# Install specific chart version
helm upgrade --install observability-stack ./charts/observability-stack \
  --version 1.0.0 --namespace ao-os
```
