# Observability Suite

A comprehensive collection of **production-ready observability solutions** featuring **two enterprise POCs** and **one opensource product** for Kubernetes environments, enterprise platforms, and comprehensive monitoring needs.

**🎯 What's Included:**
- **🚀 Opensource Observability Package**: 17-service enterprise-grade platform
- **📊 Grafana CXTM POC**: Production monitoring with Prometheus + Loki + Dashboards
- **🔍 Splunk O11y POC**: Enterprise APM with distributed tracing

## Quick Start Guide

### Choose Your Observability Journey

#### **Beginner - Start Here**
```bash
cd opensource-observability-package
./start-observability.sh
# Access: http://localhost:3000 (Grafana)
```
**Perfect for**: First-time Kubernetes monitoring, learning fundamentals

#### **Intermediate - Complete Monitoring Stack**
```bash
cd grafana-cxtm-poc
./deploy-complete-monitoring.sh
# Access: http://10.122.28.111:30300 (Grafana)
# Access: http://10.122.28.111:30090 (Prometheus)
```
**Perfect for**: Production monitoring, Kubernetes cluster observability, prebuilt dashboards

#### **Advanced - Enterprise APM**
```bash
cd splunkO11y-cxtm-poc
./deploy-helm-otel.sh
# Access: https://cisco-cx-observe.signalfx.com
```
**Perfect for**: Distributed tracing, APM, enterprise observability

## Learning Path Recommendations

### **Phase 1: Foundation **
1. **Start**: [`opensource-observability-package`](./opensource-observability-package/)
   - Deploy complete **17-service enterprise stack**
   - Learn Prometheus, Grafana, Loki, Tempo basics
   - Understand Kubernetes monitoring patterns
   - **Direct NodePort access** with auto-configured datasources

### **Phase 2: Production Monitoring Stack **
2. **Expand**: [`grafana-cxtm-poc`](./grafana-cxtm-poc/)
   - Deploy **Grafana + Prometheus + Loki** production stack
   - Import **7 prebuilt Kubernetes dashboards**
   - Master SSH tunneling and direct NodePort access methods
   - **CXTM log monitoring** with comprehensive query examples
   - Production-ready monitoring with resource limits and RBAC

### **Phase 3: Enterprise **
3. **Scale**: [`splunkO11y-cxtm-poc`](./splunkO11y-cxtm-poc/)
   - **Splunk Observability Cloud** APM integration
   - **OpenTelemetry operator-based** instrumentation
   - **Distributed tracing** for Flask/Python applications
   - **Service dependency mapping** and performance insights
   - Enterprise-grade APM with automatic instrumentation


## Common Prerequisites

All projects assume you have:
- **Kubernetes cluster** (local minikube, remote cluster, or cloud)
- **kubectl** configured and accessible
- **SSH access** to deployment environment (for remote projects)
- **Basic networking** knowledge for port forwarding and tunneling

### **Grafana CXTM POC Specific Requirements**
- **Remote Kubernetes cluster** with `ao` namespace access
- **NodePort services** enabled (ports 30300, 30090)
- **RBAC permissions** for Prometheus cluster monitoring
- **Network access** to `10.122.28.111` or SSH tunneling capability

### **Quick Environment Check**
```bash
# Verify prerequisites
kubectl version --client
ssh -V
helm version

# Test connectivity
kubectl get nodes
kubectl get namespaces

# Test specific cluster access (for grafana-cxtm-poc)
kubectl get namespace ao
kubectl get pods -n ao
```

## Repository Structure

```
observability-suite/
├── README.md (this file - central hub)
├── opensource-observability-package/
│   ├── README.md (comprehensive 17-service enterprise stack)
│   ├── helm-kube-observability-stack/ (Helm chart)
│   ├── start-observability.sh (automated deployment)
│   ├── configure-nodeport-access.sh (NodePort configuration)
│   └── verify-installation.sh (health monitoring)
├── grafana-cxtm-poc/
│   ├── README.md (complete monitoring stack guide)  
│   ├── deploy-complete-monitoring.sh (Grafana + Prometheus deployment)
│   ├── grafana-deployment.yaml (Grafana configuration)
│   ├── grafana-config.yaml (data sources configuration)
│   ├── prometheus-deployment.yaml (Prometheus configuration)
│   ├── dashboards/ (7 prebuilt dashboard JSON files)
│   ├── scan-existing-monitoring.sh (resource scanner)
│   ├── cleanup-existing-monitoring.sh (clean removal)
│   ├── statusCheckGrafana-ao.sh (health monitoring)
│   └── connectGrafana-ao.sh (SSH tunnel setup)
├── splunkO11y-cxtm-poc/
│   ├── README.md (Splunk APM deployment guide)
│   ├── helm-values.yaml (Splunk Helm configuration)
│   ├── python-instrumentation.yaml (OpenTelemetry instrumentation)
│   ├── deploy-helm-otel.sh (automated Helm deployment)
│   └── cleanup-manual-otel.sh (cleanup utility)
├── elastic-stack-poc/ (planned)
├── datadog-lab/ (planned)
└── newrelic-setup/ (planned)
```

## Current Project Status

| Project | Deployment | Documentation | Testing | Production Ready | Latest Features |
|---------|------------|---------------|---------|------------------|-----------------|
| **Opensource Package** | Complete | Comprehensive | Validated | Yes | **17-service enterprise stack** |
| **Grafana CXTM POC** | Complete | Complete | Production-tested | Yes | **Prometheus + Loki + 7 Dashboards** |
| **Splunk O11y POC** | Complete | Complete | Production-ready | Yes | **OpenTelemetry + APM + Tracing** |

## Project Capabilities Overview

### **🚀 Opensource Observability Package**
- ✅ **17-Service Enterprise Stack**: Complete observability platform
- ✅ **Core Services**: Prometheus, Grafana, Loki, Tempo, AlertManager
- ✅ **Advanced Monitoring**: Smokeping, MTR, Blackbox, Node Exporter
- ✅ **Database/App Monitoring**: MongoDB, PostgreSQL, Redis, Jenkins exporters
- ✅ **Direct NodePort Access**: No port-forwarding required
- ✅ **Auto-configured Datasources**: Grafana pre-configured with all sources
- ✅ **Production Validated**: Tested on 16-node CALO lab cluster

### **📊 Grafana CXTM POC - Production Monitoring**
- ✅ **Complete Monitoring Stack**: Grafana + Prometheus + **Loki** integration
- ✅ **Prebuilt Dashboards**: 7 production-ready Kubernetes dashboards
- ✅ **CXTM Log Monitoring**: Comprehensive LogQL queries for CXTAF/CXTM apps
- ✅ **Health Monitoring**: Comprehensive status checking scripts
- ✅ **Dual Access**: Direct NodePort + SSH tunneling options
- ✅ **Production Ready**: Resource limits, persistent storage, RBAC

### **🔍 Splunk O11y POC - Enterprise APM**
- ✅ **Splunk Observability Cloud**: Enterprise APM integration
- ✅ **OpenTelemetry Operator**: Automated instrumentation via Helm
- ✅ **Flask/Python Support**: Solves auto-instrumentation conflicts
- ✅ **Distributed Tracing**: End-to-end request flows
- ✅ **Service Dependency Mapping**: CXTM application topology visualization
- ✅ **Production Deployment**: Init container-based instrumentation

## Service Access Summary

### **🚀 Opensource Observability Package** (Replace YOUR-NODE-IP)
| Service | URL | Port | Description |
|---------|-----|------|-------------|
| **🎯 Grafana** | `http://YOUR-NODE-IP:30300` | 30300 | Main dashboards (admin/admin) |
| **📈 Prometheus** | `http://YOUR-NODE-IP:30090` | 30090 | Metrics and monitoring |
| **🚨 AlertManager** | `http://YOUR-NODE-IP:30930` | 30930 | Alert management |
| **🔍 Tempo** | `http://YOUR-NODE-IP:30320` | 30320 | Distributed tracing |
| **📋 Loki** | `http://YOUR-NODE-IP:30310` | 30310 | Log aggregation |

### **📊 Grafana CXTM POC** (Production CXTM Environment)
| Service | URL | Description |
|---------|-----|-------------|
| **🎯 Grafana** | `http://10.122.28.111:30300` | Monitoring dashboards (admin/admin123) |
| **📈 Prometheus** | `http://10.122.28.111:30090` | Metrics collection |
| **📋 Loki** | `http://10.122.28.111:30310` | CXTM/CXTAF log aggregation |

### **🔍 Splunk O11y POC** (Enterprise APM)
| Service | URL | Description |
|---------|-----|-------------|
| **🔍 Splunk APM** | `https://cisco-cx-observe.signalfx.com` | Enterprise observability platform |

#### **Available Monitoring Dashboards (Grafana CXTM POC)**
1. **Kubernetes Cluster Monitoring** - Complete cluster overview
2. **Kubernetes Pods** - Pod-level metrics and performance
3. **Kubernetes Deployments** - Deployment status and health
4. **Node Exporter** - System-level node metrics (most popular)
5. **Blackbox Exporter** - Endpoint monitoring and availability
6. **Loki Dashboard** - Log aggregation and analysis
7. **Prometheus Stats** - Prometheus server performance metrics

#### **Quick Access**
- **Grafana UI**: `http://10.122.28.111:30300/` (admin/admin123)
- **Prometheus UI**: `http://10.122.28.111:30090/`
- **Dashboard Import**: Grafana → Dashboards → Import → Upload JSON

