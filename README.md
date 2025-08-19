# Observability Suite

A comprehensive collection of production-ready observability and monitoring solutions for Kubernetes environments, enterprise platforms, and learning purposes.

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

#### **Advanced - Enterprise**
```bash
cd splunkO11y-cxtm-poc
# Yet to do 
```

## Learning Path Recommendations

### **Phase 1: Foundation **
1. **Start**: [`opensource-observability-package`](./opensource-observability-package/)
   - Deploy complete 12-service stack
   - Learn Prometheus, Grafana, Loki basics
   - Understand Kubernetes monitoring patterns

### **Phase 2: Production Monitoring Stack **
2. **Expand**: [`grafana-cxtm-poc`](./grafana-cxtm-poc/)
   - Deploy complete Grafana + Prometheus stack
   - Import 7+ prebuilt Kubernetes dashboards
   - Master SSH tunneling and direct access methods
   - Implement production-ready monitoring configuration

### **Phase 3: Enterprise **
3. **Scale**: [`splunkO11y-cxtm-poc`](./splunkO11y-cxtm-poc/)
   - Advanced APM and distributed tracing
   - Enterprise-grade observability
   - Production deployment patterns


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
│   ├── README.md (comprehensive 12-service stack guide)
│   ├── helm-kube-observability-stack/ (Helm chart)
│   ├── start-observability.sh (automated deployment)
│   └── check-services.sh (health monitoring)
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
│   ├── README.md (enterprise observability)
│   ├── k8s-manifests/ (Kubernetes configs)
│   └── scripts/ (automation tools)
├── elastic-stack-poc/ (planned)
├── datadog-lab/ (planned)
└── newrelic-setup/ (planned)
```

## Current Project Status

| Project | Deployment | Documentation | Testing | Production Ready | Latest Features |
|---------|------------|---------------|---------|------------------|-----------------|
| **Opensource Package** | Complete | Comprehensive | Validated | Yes | 12-service stack |
| **Grafana CXTM POC** | Enhanced | Complete | Production-tested | Yes | Prometheus + 7 Dashboards |
| **Splunk O11y POC** | In Progress | In Progress | Testing | Development | Enterprise APM |

### **Grafana CXTM POC - Recent Enhancements**
- ✅ **Complete Monitoring Stack**: Grafana + Prometheus integration
- ✅ **Prebuilt Dashboards**: 7 production-ready Kubernetes dashboards
- ✅ **Auto-Configuration**: Prometheus data source pre-configured
- ✅ **Health Monitoring**: Comprehensive status checking scripts
- ✅ **Dual Access**: Direct NodePort + SSH tunneling options
- ✅ **Production Ready**: Resource limits, persistent storage, RBAC

#### **Available Monitoring Dashboards**
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

