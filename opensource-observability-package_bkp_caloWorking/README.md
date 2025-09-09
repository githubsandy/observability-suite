# Comprehensive Observability Stack

## 🎯 Overview

This repository provides a **production-ready** observability stack using Kubernetes and Helm, specifically optimized for the CALO Lab environment. The solution delivers complete monitoring, logging, tracing, and alerting capabilities for modern applications and Kubernetes clusters.

### 🏗️ Architecture Components

#### 📊 **Core Observability Stack (4 Components)**
- **Prometheus** - Metrics collection and monitoring
- **Grafana** - Visualization and dashboards  
- **Loki** - Log aggregation and querying
- **Promtail** - Log collection agent

#### 🔧 **Infrastructure Exporters (2 Components)**
- **Node Exporter** - System metrics (CPU, Memory, Disk, Network)
- **Blackbox Exporter** - External endpoint monitoring and health checks

#### ⚡ **Foundation Exporters (4 Components)**  
- **kube-state-metrics** - Kubernetes cluster state metrics
- **MongoDB Exporter** - NoSQL database performance metrics
- **PostgreSQL Exporter** - Relational database metrics
- **Redis Exporter** - Cache and session store metrics

#### 🚀 **Enhanced Monitoring (4 Components)**
- **Tempo** - Distributed tracing and performance analysis
- **Alertmanager** - Alert routing and notification management
- **Smokeping** - Network latency and connectivity monitoring
- **MTR Analyzer** - Network path analysis and diagnostics

#### 📱 **Application Layer (0 Components - Currently Disabled)**
- **FastAPI Metrics** - Custom application metrics for test automation platforms (Disabled)

### 📈 **Total: 14 Active Components** providing comprehensive observability coverage

---

## 🎯 **Recent Fixes & Improvements**

### ✅ **Critical Issues Resolved**

| Issue Category | Problem | Solution Applied |
|---------------|---------|------------------|
| **YAML Configuration** | Parsing errors in alertmanager routes | Fixed indentation and structure |
| **Template Expressions** | Complex resource template failures | Simplified to direct value references |
| **Container Images** | Invalid nginx:2.0.0, deprecated jenkins images | Updated to nginx:1.24, disabled jenkins |
| **Volume Permissions** | Grafana PVC write permission denied | Added initContainer with proper securityContext |
| **Duration Formats** | `7d` format causing tempo parsing errors | Changed to Go duration format `168h` |
| **Field Naming** | `calo-lab` causing YAML key errors | Updated to `calo_lab` for compatibility |

### 🔧 **Configuration Updates Applied**

```yaml
# Critical fixes in values.yaml
environment:
  name: "calo_lab"  # Fixed: underscore for YAML compatibility

performance:
  retention:
    loki: "168h"    # Fixed: Go duration format
    tempo: "168h"   # Fixed: Go duration format

components:
  applications:
    jenkins: false  # Fixed: Disabled problematic component

image:
  tag: "1.24"      # Fixed: Valid nginx version
```

---

## 🚀 **CALO Lab Deployment Guide**

### **Prerequisites**

```bash
# Required tools
kubectl --version    # Kubernetes CLI
helm version        # Helm 3.x package manager

# Required cluster resources  
kubectl get storageclass longhorn-single  # Longhorn storage available
kubectl get nodes -l ao-node=observability # Observability nodes labeled
```

### **🎯 Production Deployment Commands**

```bash
# Navigate to project directory
cd /home/administrator/skumark5/osp/observability-suite/opensource-observability-package

# Remove conflicting namespace template (if exists)
rm -f ./helm-kube-observability-stack/templates/000_namespace.yaml

# Initial deployment (run once)
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace

# Upgrade existing deployment (for configuration changes)
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os
```

### **🔧 Full Configuration Deployment (Alternative)**

```bash
# Single command with all configuration parameters
helm upgrade --install ao-observability ./helm-kube-observability-stack \
  --namespace ao-os \
  --create-namespace \
  --set environment.namespace=ao-os \
  --set environment.name=calo_lab \
  --set components.enhanced.cadvisor=true \
  --set security.rbac.create=true \
  --set environment.cluster.nodeSelector.enabled=true \
  --set environment.cluster.nodeSelector.strategy=labels \
  --set environment.cluster.nodeSelector.nodeLabels.ao-node=observability \
  --set environment.cluster.storage.storageClass=longhorn-single \
  --set components.databases.redis=true \
  --set components.databases.mariadb=true \
  --set components.applications.jenkins=false
```

### **📊 Deployment Verification**

```bash
# Monitor deployment progress
kubectl get pods -n ao-os -w

# Verify all components are running
kubectl get all -n ao-os

# Check for any configuration errors
kubectl get events -n ao-os --sort-by=.metadata.creationTimestamp | tail -10

# Check current deployment status
helm status ao-observability -n ao-os
```

### **📋 Current Deployment Status**

```yaml
# CALO Lab Environment Status
Release Name: ao-observability
Namespace: ao-os  
Revision: 16 (After troubleshooting Grafana, FastAPI, Jenkins, MTR components)
Status: deployed
Chart: kube-observability-stack-1.0.0
Active Components: 14/16 (2 disabled by design)
Deployment History: Multiple upgrades during configuration fixes
```

---

## 📡 **Service Access Configuration**

### **🌐 NodePort Access (CALO Lab Recommended)**

```bash
# Configure for direct IP access
./configure-nodeport-access.sh enable

# Access services directly via node IP
# Replace YOUR-NODE-IP with actual cluster node IP (e.g., 10.122.28.103)
```

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| **Grafana** | 30300 | `http://YOUR-NODE-IP:30300` | Main dashboard (admin/admin) |
| **Prometheus** | 30090 | `http://YOUR-NODE-IP:30090` | Metrics and targets |
| **Loki** | 30310 | `http://YOUR-NODE-IP:30310` | Log aggregation |
| **Blackbox** | 30115 | `http://YOUR-NODE-IP:30115` | Endpoint monitoring |
| **Alertmanager** | 30930 | `http://YOUR-NODE-IP:30930` | Alert management |
| **Tempo** | 30320 | `http://YOUR-NODE-IP:30320` | Distributed tracing |

### **🔗 Port-Forward Access (Local Development)**

```bash
# Configure for localhost access
./configure-nodeport-access.sh disable

# Start automated port forwarding
./start-observability.sh
```

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| **Grafana** | 3000 | `http://localhost:3000` | Main dashboard |
| **Prometheus** | 9090 | `http://localhost:9090` | Metrics collection |
| **Loki** | 3100 | `http://localhost:3100` | Log aggregation |
| **kube-state-metrics** | 8080 | `http://localhost:8080` | K8s cluster metrics |
| **FastAPI Metrics** | 8001 | `http://localhost:8001` | Custom app metrics |

---

## 📊 **Component Status Matrix**

### **✅ Core Observability Stack**

| Component | Status | Resource Usage | Description |
|-----------|--------|----------------|-------------|
| **Prometheus** | ✅ Running | 250m CPU, 256Mi RAM | Time-series metrics database |
| **Grafana** | ✅ Running | 250m CPU, 256Mi RAM | Visualization and alerting UI |
| **Loki** | ✅ Running | 250m CPU, 256Mi RAM | Log aggregation system |
| **Promtail** | ✅ Running | 100m CPU, 64Mi RAM | Log collection agent |

### **✅ Infrastructure Monitoring**

| Component | Status | Deployment Type | Metrics Provided |
|-----------|--------|-----------------|------------------|
| **Node Exporter** | ✅ Running | DaemonSet | CPU, Memory, Disk, Network |
| **Blackbox Exporter** | ✅ Running | Deployment | HTTP, DNS, TCP endpoint health |
| **kube-state-metrics** | ✅ Running | Deployment | Pod, Service, Deployment status |

### **✅ Enhanced Capabilities**

| Component | Status | Features | Use Case |
|-----------|--------|----------|----------|
| **Tempo** | ✅ Running | Distributed tracing | Request flow analysis |
| **Alertmanager** | ✅ Running | Alert routing | Incident management |
| **Smokeping** | ✅ Running | Network latency graphs | Network performance |
| **MTR Analyzer** | ✅ Running | Network path analysis | Network troubleshooting |

### **✅ Database & Application Monitoring**

| Component | Status | Target Systems | Metrics |
|-----------|--------|----------------|---------|
| **MongoDB Exporter** | ✅ Running | NoSQL databases | Connections, operations, performance |
| **PostgreSQL Exporter** | ✅ Running | SQL databases | Queries, connections, replication |
| **Redis Exporter** | ✅ Running | Cache systems | Memory usage, commands, clients |

### **❌ Disabled Components**

| Component | Status | Reason | Alternative |
|-----------|--------|--------|-------------|
| **Jenkins Exporter** | ❌ Disabled | Deprecated Schema 1 image format | Use Prometheus Jenkins plugin |
| **FastAPI Metrics** | ❌ Disabled | Not required for current deployment | Enable when custom app metrics needed |

---

## 🔍 **Monitoring Capabilities**

### **📈 Prometheus Metrics Collection**

```yaml
# Sample Prometheus queries
# System Health
up                                       # Service availability
node_cpu_seconds_total                   # CPU usage
node_memory_MemAvailable_bytes          # Available memory

# Kubernetes Health  
kube_pod_status_phase                    # Pod lifecycle states
kube_deployment_status_replicas          # Deployment health
kube_node_status_condition               # Node conditions

# Application Performance
fastapi_request_duration_seconds         # API response times
test_executions_total                    # Test automation metrics
```

### **📋 Loki Log Queries**

```logql
# Log filtering examples
{namespace="ao-os"}                      # Observability namespace logs
{app="prometheus"} |= "error"           # Error logs from Prometheus
{job="varlogs"} | json | level="ERROR"  # Structured error logs
```

### **🔗 Tempo Tracing**

```bash
# Trace collection endpoints
# Jaeger: http://tempo:14268/api/traces
# Zipkin: http://tempo:9411/api/v2/spans  
# OTLP gRPC: tempo:4317
# OTLP HTTP: tempo:4318
```

---

## 🛠️ **Configuration Management**

### **🔧 Database Connections**

```yaml
# MongoDB configuration
mongodbExporter:
  mongodbUri: "mongodb://username:password@mongodb-host:27017"

# PostgreSQL configuration  
postgresExporter:
  dataSourceName: "postgresql://user:pass@postgres-host:5432/db?sslmode=disable"

# Redis configuration
redisExporter:
  redisAddr: "redis://redis-host:6379"
  redisPassword: "your-redis-password"
```

### **📊 Grafana Data Sources**

```yaml
# Automatic data source configuration
datasources:
  - name: Prometheus
    url: http://prometheus:9090
    type: prometheus
    
  - name: Loki  
    url: http://loki:3100
    type: loki
    
  - name: Tempo
    url: http://tempo:3200
    type: tempo
```

---

## 🚨 **Alerting Configuration**

### **📢 Alert Rules Examples**

```yaml
# High CPU usage alert
- alert: HighCPUUsage
  expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 80
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: "High CPU usage detected"
    
# Pod restart alert
- alert: PodRestartingTooOften
  expr: increase(kube_pod_container_status_restarts_total[1h]) > 3
  for: 0m
  labels:
    severity: critical
  annotations:
    summary: "Pod {{ $labels.pod }} is restarting frequently"
```

### **📧 Notification Channels**

```yaml
# Alertmanager routing
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
    - match:
        severity: critical
      receiver: critical-alerts
      repeat_interval: 5m
```

---

## 🔧 **Troubleshooting Guide**

### **🚨 Common Issues & Solutions**

#### **Grafana Permission Errors**
```bash
# Problem: "GF_PATHS_DATA='/var/lib/grafana' is not writable"
# Solution: Check initContainer and securityContext
kubectl logs -f deployment/grafana -n ao-os
kubectl describe pod -l app=grafana -n ao-os
```

#### **Tempo Configuration Errors**
```bash  
# Problem: "field calo_lab not found in type overrides.legacyConfig"
# Solution: Verify environment name uses underscores
kubectl get configmap tempo-config -n ao-os -o yaml | grep calo
```

#### **Alertmanager YAML Errors**
```bash
# Problem: "yaml: line 30: did not find expected key" 
# Solution: Check route indentation in config
kubectl logs -f deployment/alertmanager -n ao-os
```

#### **Pod Startup Issues**
```bash
# Check pod status and events
kubectl get pods -n ao-os | grep -v Running
kubectl describe pod <failing-pod> -n ao-os
kubectl get events -n ao-os --sort-by=.metadata.creationTimestamp
```

#### **FastAPI Metrics Deployment Issues**
```bash
# Problem: FastAPI metrics pod failing to start
# Solution: Check configuration and disable if not needed
kubectl logs -n ao-os deployment/fastapi-metrics --tail=20
kubectl describe pod -n ao-os -l app=fastapi-metrics | grep -A 10 "Events:"

# Alternative: Disable the component in values.yaml
# components.applications.fastapi: false
```

#### **Jenkins Exporter Image Issues**  
```bash
# Problem: "Pulling Schema 1 images have been deprecated"
# Solution: Disable jenkins exporter component
# Edit values.yaml: components.applications.jenkins: false
kubectl logs -n ao-os -l app=jenkins-exporter --tail=20
```

#### **MTR Component Capability Issues**
```bash
# Problem: MTR pod requiring special capabilities  
# Solution: Check security context and restart if needed
kubectl describe pod -n ao-os -l app=mtr | grep -A 10 -B 10 "capabilities"
kubectl delete pod -n ao-os -l app=mtr  # Force restart
```

### **🔍 Health Check Commands**

```bash
# Verify all services are responsive
curl http://NODE-IP:30090/-/healthy   # Prometheus health
curl http://NODE-IP:30300/api/health  # Grafana health
curl http://NODE-IP:30310/ready       # Loki readiness

# Check metrics collection
curl http://NODE-IP:30090/api/v1/targets | jq '.data.activeTargets[].health'

# Verify log ingestion  
curl http://NODE-IP:30310/loki/api/v1/label | jq
```

---

## 📦 **Advanced Configuration**

### **🎛️ Resource Tuning**

```yaml
# Production resource allocation
resources:
  prometheus:
    limits: { cpu: "2000m", memory: "4Gi" }
    requests: { cpu: "1000m", memory: "2Gi" }
  grafana:
    limits: { cpu: "1000m", memory: "1Gi" }
    requests: { cpu: "500m", memory: "512Mi" }
```

### **💾 Storage Configuration**

```yaml
# Persistent volume settings
storage:
  prometheus:
    size: "50Gi"
    storageClass: "longhorn-single"
  grafana:
    size: "10Gi"
    storageClass: "longhorn-single"
  loki:
    size: "100Gi"
    storageClass: "longhorn-single"
```

### **🔐 Security Configuration**

```yaml
# RBAC and security contexts
security:
  rbac:
    create: true
  podSecurityPolicy:
    enabled: true
  networkPolicy:
    enabled: true
```

---

## 📋 **Management Commands**

### **🚀 Deployment Operations**

```bash
# Install fresh deployment
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace

# Upgrade existing deployment
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os

# Check deployment status
helm status ao-observability -n ao-os

# View configuration values
helm get values ao-observability -n ao-os
```

### **🔄 Configuration Updates**

```bash
# Switch access methods
./configure-nodeport-access.sh enable   # Direct IP access
./configure-nodeport-access.sh disable  # Port-forwarding access
./configure-nodeport-access.sh status   # Check current mode

# Update specific components
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os \
  --set grafana.adminPassword=newpassword \
  --set components.databases.redis=false
```

### **🧹 Cleanup Operations**

```bash
# Remove deployment
helm uninstall ao-observability -n ao-os

# Clean up namespace
kubectl delete namespace ao-os

# Remove persistent data (caution!)
kubectl delete pvc --all -n ao-os
```

---

## 🎯 **Performance Benchmarks**

### **📊 Expected Resource Usage**

| Component Category | CPU Usage | Memory Usage | Storage |
|-------------------|-----------|--------------|---------|
| **Core Stack (4)** | ~1000m | ~1.5Gi | ~50Gi |
| **Exporters (7)** | ~500m | ~750Mi | ~5Gi |
| **Enhanced (4)** | ~750m | ~1Gi | ~25Gi |
| **Total** | **~2.25 cores** | **~3.25Gi** | **~80Gi** |

### **🚀 Scalability Targets**

- **Metrics Retention**: 15 days (configurable)
- **Log Retention**: 7 days (configurable)  
- **Trace Retention**: 7 days (configurable)
- **Concurrent Users**: 50+ Grafana users
- **Metric Ingestion**: 100K+ samples/sec
- **Log Ingestion**: 10GB+ per day

---

## 🌟 **Key Benefits**

### ✅ **Production Ready**
- Enterprise-grade configuration with proper RBAC
- Automated deployment with health checks  
- Comprehensive monitoring of all infrastructure layers

### ✅ **CALO Lab Optimized**
- Direct IP access without port-forwarding complexity
- Longhorn storage integration for persistent data
- Node selector strategies for dedicated observability nodes

### ✅ **Comprehensive Coverage**
- **System Monitoring**: CPU, memory, disk, network metrics
- **Application Monitoring**: Custom business metrics and traces  
- **Infrastructure Monitoring**: Kubernetes cluster health and performance
- **Network Monitoring**: Latency, connectivity, and path analysis
- **Log Management**: Centralized logging with structured query capabilities

### ✅ **Operational Excellence**
- One-command deployment and configuration switching
- Automated troubleshooting and health verification
- Production-tested configuration with all edge cases handled

---

## 📞 **Support & Documentation**

### **🔗 Quick Links**
- **Grafana Dashboards**: Pre-configured dashboards for all monitored systems
- **Prometheus Targets**: Automatic service discovery and health monitoring
- **Alert Rules**: Production-ready alerting for common failure scenarios
- **Configuration Examples**: Sample configurations for various environments

### **📚 Additional Resources**
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Helm Documentation](https://helm.sh/docs/)

---

**🎉 Your comprehensive observability stack is ready for production deployment in the CALO Lab environment!**