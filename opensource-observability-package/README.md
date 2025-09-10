# Enterprise Kubernetes Observability Platform

Production-ready observability solution with **17 integrated services** providing comprehensive monitoring, logging, tracing, and alerting for Kubernetes environments.

## 🚀 Platform Overview

**Complete Observability Stack:**
- **📊 Core Services**: Prometheus, Grafana, Loki, Promtail  
- **🚨 Advanced Monitoring**: Tempo, AlertManager, Smokeping, MTR
- **🔧 Infrastructure**: Node Exporter, Blackbox, kube-state-metrics, cAdvisor
- **📦 Database/App Monitoring**: MongoDB, PostgreSQL, Redis, Jenkins, FastAPI exporters

**Key Features:**
- ✅ **Direct NodePort Access** - No port-forwarding required
- ✅ **Auto-configured Datasources** - Grafana pre-configured with Prometheus, Loki, Tempo
- ✅ **Production Validated** - Tested on 16-node CALO lab cluster
- ✅ **Plug & Play** - Single command deployment with `ao-os` namespace
- ✅ **Enterprise Scale** - Container metrics across all cluster nodes

## 📋 Prerequisites

- Kubernetes cluster (1.20+)
- kubectl configured
- Helm 3.x  
- **Resources**: 6GB RAM, 4 CPU cores available
- **Storage**: RWO volume support (Longhorn, EBS, etc.)

## ⚡ Quick Deployment

```bash
# 1. Configure for direct access (NodePort)
./configure-nodeport-access.sh enable

# 2. Deploy complete observability stack
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace

# 3. Verify deployment
kubectl get pods -n ao-os
```

## 🌐 Service Access

Replace `YOUR-NODE-IP` with your cluster node IP:

| Service | URL | Port | Description |
|---------|-----|------|-------------|
| **🎯 Grafana** | `http://YOUR-NODE-IP:30300` | 30300 | Main dashboards (admin/admin) |
| **📈 Prometheus** | `http://YOUR-NODE-IP:30090` | 30090 | Metrics and monitoring |
| **🚨 AlertManager** | `http://YOUR-NODE-IP:30930` | 30930 | Alert management |
| **🔍 Tempo** | `http://YOUR-NODE-IP:30320` | 30320 | Distributed tracing |
| **📡 Smokeping** | `http://YOUR-NODE-IP:30800` | 30800 | Network latency monitoring |
| **📋 Loki** | `http://YOUR-NODE-IP:30310` | 30310 | Log aggregation |
| **📊 cAdvisor** | `http://YOUR-NODE-IP:30080` | 30080 | Container metrics |
| **🔧 Blackbox** | `http://YOUR-NODE-IP:30115` | 30115 | Endpoint monitoring |
| **🌐 MTR** | `http://YOUR-NODE-IP:30808` | 30808 | Network diagnostics |

## 🛠️ Management Commands

```bash
# Update deployment
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os

# Check all pods
kubectl get pods -n ao-os

# Check services and ports  
kubectl get svc -n ao-os

# Check node distribution
kubectl get pods -n ao-os -o wide

# View specific service logs
kubectl logs -n ao-os -l app=prometheus

# Verify installation
./verify-installation.sh
```

## 🔄 Configuration Options

**NodePort Access (Production):**
```bash
./configure-nodeport-access.sh enable
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os
```

**Port-forwarding Access (Development):**
```bash
./configure-nodeport-access.sh disable
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os
./start-observability.sh
```

## 📊 Service Architecture

**📊 Core Observability (4 services):**
- **Prometheus**: Time-series metrics database  
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation system
- **Promtail**: Log collection agent

**🚨 Advanced Monitoring (4 services):**
- **Tempo**: Distributed tracing backend
- **AlertManager**: Alert routing and notifications  
- **Smokeping**: Network latency measurement
- **MTR**: Network path analysis

**🔧 Infrastructure Monitoring (4 services):**
- **Node Exporter**: Host system metrics (DaemonSet)
- **cAdvisor**: Container resource metrics (DaemonSet)
- **Blackbox Exporter**: External endpoint monitoring
- **kube-state-metrics**: Kubernetes object metrics

**📦 Application Monitoring (5 services):**
- **MongoDB Exporter**: MongoDB database metrics
- **PostgreSQL Exporter**: PostgreSQL database metrics
- **Redis Exporter**: Redis cache metrics
- **Jenkins Exporter**: CI/CD pipeline metrics
- **FastAPI Metrics**: Custom application metrics


## 🔍 Troubleshooting

```bash
# Check pod status
kubectl get pods -n ao-os

# Describe failing pods
kubectl describe pod <pod-name> -n ao-os

# Check logs
kubectl logs <pod-name> -n ao-os --previous

# Check PVC issues
kubectl get pvc -n ao-os

# Check service endpoints
kubectl get endpoints -n ao-os
```

## 📈 Metrics Available

- **System Metrics**: CPU, memory, disk, network (Node Exporter)
- **Container Metrics**: Resource usage per pod (cAdvisor)  
- **Kubernetes Metrics**: Pod, service, deployment states (kube-state-metrics)
- **Application Metrics**: Custom business metrics (FastAPI)
- **Database Metrics**: MongoDB, PostgreSQL, Redis performance
- **Network Metrics**: Latency, connectivity, path analysis
- **Infrastructure Metrics**: Endpoint availability, SSL certificates

## 🌟 Success Metrics

- **17+ Services Running** across production cluster
- **100% Deployment Success** on lab environment
- **Direct IP Access** without ingress or port-forwarding
- **Auto-configured** Grafana with all datasources
- **Enterprise-Ready** for production workloads