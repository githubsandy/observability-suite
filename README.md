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

#### **Intermediate - Remote Access**
```bash
cd grafana-cxtm-poc
./deploy.sh
./reconnect.sh
# Access: http://localhost:3000 (via SSH tunnel)
```
**Perfect for**: Remote monitoring, external cluster access

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

### **Phase 2: External Access **
2. **Expand**: [`grafana-cxtm-poc`](./grafana-cxtm-poc/)
   - Master SSH tunneling techniques
   - Implement intelligent connection management
   - Handle network disruptions gracefully

### **Phase 3: Enterprise **
3. **Scale**: [`splunkO11y-cxtm-poc`](./splunkO11y-cxtm-poc/)
   - Advanced APM and distributed tracing
   - Enterprise-grade observability
   - Production deployment patterns


## Common Prerequisites

All projects assume you have:
- **Kubernetes cluster** (local minikube, remote cluster, or cloud)
- **kubectl** configured and accessible
- **SSH access** to deployment environment (for tunneling projects)
- **Basic networking** knowledge for port forwarding and tunneling

### **Quick Environment Check**
```bash
# Verify prerequisites
kubectl version --client
ssh -V
helm version

# Test connectivity
kubectl get nodes
kubectl get namespaces
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
│   ├── README.md (SSH tunneling guide)  
│   ├── deploy.sh (automated deployment)
│   ├── reconnect.sh (intelligent connection mgmt)
│   ├── check-status.sh (connection status)
│   └── cleanup.sh (clean disconnect)
├── splunkO11y-cxtm-poc/
│   ├── README.md (enterprise observability)
│   ├── k8s-manifests/ (Kubernetes configs)
│   └── scripts/ (automation tools)
├── elastic-stack-poc/ (planned)
├── datadog-lab/ (planned)
└── newrelic-setup/ (planned)
```

## Current Project Status

| Project | Deployment | Documentation | Testing | Production Ready |
|---------|------------|---------------|---------|------------------|
| **Opensource Package** | Complete | Comprehensive | Validated | Yes |
| **Grafana CXTM POC** | Complete | Complete | Production-tested | Yes |
| **Splunk O11y POC** | In Progress | In Progress | Testing | Development |

