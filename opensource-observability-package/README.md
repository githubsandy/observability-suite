# 🚀 Enhanced Observability Stack

**Infrastructure-Agnostic • Complete Observability • Zero External Dependencies**

This repository provides a comprehensive, production-ready observability stack for Kubernetes environments. The solution delivers complete **Logs + Metrics + Traces (L.M.T)** observability with advanced network monitoring, auto-discovery capabilities, and zero external cost dependencies.

## ✨ Enhanced Features

**🎯 Complete Observability Stack:**
- **📊 Logs**: Loki + Promtail with advanced log aggregation
- **📈 Metrics**: Prometheus + Enhanced exporters + cAdvisor container metrics with auto-discovery
- **🔍 Traces**: Grafana Tempo for distributed tracing with direct ingestion
- **🚨 Alerting**: AlertManager with production-ready alert rules

**🌐 Advanced Network Monitoring:**
- **🔍 Smokeping**: Network latency and connectivity graphs
- **📡 MTR**: Network path analysis with Python-based metrics
- **🛡️ Enhanced Blackbox**: 15+ monitoring modules for comprehensive endpoint testing

**⚡ Infrastructure Intelligence:**
- **🤖 Auto-Discovery**: Automatic detection of CXTAF/CXTM services
- **🏷️ Dynamic Configuration**: Infrastructure-agnostic deployment
- **🎯 CALO Lab Optimized**: Specialized for UTA CALO lab environment
- **📦 Plug-and-Play**: One-command deployment with intelligent defaults

**Complete 15+ Service Enhanced Observability Platform** for modern Kubernetes infrastructure.

---

## Prerequisites

**Required Tools:**
1. **kubectl**: Kubernetes command-line tool  
   [Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. **Helm 3.x**: Kubernetes package manager  
   [Installation Guide](https://helm.sh/docs/intro/install/)

**Kubernetes Cluster:**
- Any Kubernetes cluster (Minikube, CALO lab, Cloud providers, etc.)
- Minimum 2GB RAM and 2 CPU cores available
- Default storage class configured (for persistent volumes)

**Network Requirements:**
- Cluster DNS working properly
- Inter-pod communication enabled
- Port-forwarding capabilities

---

## 🚀 Enhanced Quick Start

**1-Minute Deployment** - Complete observability stack with intelligent auto-configuration:

```bash
# 1. Clone and navigate
git clone <repository-url>
cd opensource-observability-package

# 2. Deploy with intelligent defaults (CALO lab detection)
chmod +x install-observability-stack.sh
./install-observability-stack.sh

# 3. Verify installation
chmod +x verify-installation.sh  
./verify-installation.sh

# 4. Start all enhanced services
chmod +x start-observability.sh
./start-observability.sh

# 5. Check comprehensive service health
chmod +x check-services.sh
./check-services.sh
```

### Custom Environment Deployment

```bash
# For different environments/namespaces
./install-observability-stack.sh [RELEASE_NAME] [NAMESPACE] [ENVIRONMENT]

# Examples:
./install-observability-stack.sh                           # CALO lab defaults
./install-observability-stack.sh obs-stack monitoring aws  # AWS deployment
./install-observability-stack.sh prod-obs observability gcp # GCP deployment
```

## 🌟 Service Access URLs

**📊 Core Observability:**
- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **Prometheus Query**: http://localhost:9090
- **Loki Logs**: http://localhost:3100

**🔍 Enhanced Services:**
- **Grafana Tempo (Tracing)**: http://localhost:3200
- **AlertManager**: http://localhost:9093
- **Tempo Tracing**: http://localhost:3200

**🌐 Network Monitoring:**
- **Smokeping Graphs**: http://localhost:80/smokeping/
- **MTR Network Analysis**: http://localhost:8080/metrics
- **Blackbox Monitoring**: http://localhost:9115/metrics

**⚡ Infrastructure Metrics:**
- **Kubernetes Metrics**: http://localhost:8081/metrics
- **Node System Metrics**: http://localhost:9100/metrics
- **Log Collection**: http://localhost:9080/metrics

**🗄️ Database Monitoring:**
- **CXTM MariaDB**: Auto-discovered (Internal)
- **CXTM Redis**: Auto-discovered (Internal)

---

## 📂 Enhanced Directory Structure

```
opensource-observability-package/
├── 🎯 Enhanced Helm Chart
│   helm-kube-observability-stack/
│   ├── templates/
│   │   ├── 📊 Core Observability Stack
│   │   │   ├── grafana-deployment.yaml         # Enhanced Grafana with Tempo integration
│   │   │   ├── grafana-service.yaml
│   │   │   ├── grafana-datasources-config.yaml # Auto-configured datasources (Prometheus, Loki, Tempo)
│   │   │   ├── prometheus-deployment.yaml      # Enhanced with auto-discovery
│   │   │   ├── prometheus-service.yaml
│   │   │   ├── prometheus-config.yaml          # Dynamic service discovery
│   │   │   ├── loki-deployment.yaml
│   │   │   ├── loki-service.yaml
│   │   │   ├── promtail-deployment.yaml
│   │   │   └── promtail-config.yaml
│   │   ├── 🔍 Distributed Tracing (NEW)
│   │   │   ├── tempo-deployment.yaml                   # Distributed tracing backend
│   │   │   ├── tempo-config.yaml                       # Direct ingestion configuration  
│   │   │   ├── tempo-deployment.yaml                   # Distributed tracing backend
│   │   │   └── tempo-service.yaml
│   │   ├── 🚨 Enhanced Alerting (NEW)
│   │   │   ├── alertmanager-deployment.yaml     # Production-ready alerting
│   │   │   ├── alertmanager-service.yaml
│   │   │   └── alertmanager-config.yaml         # CALO lab alert rules
│   │   ├── 🌐 Network Monitoring (NEW)
│   │   │   ├── smokeping-deployment.yaml        # Network latency graphs
│   │   │   ├── smokeping-service.yaml
│   │   │   ├── smokeping-config.yaml
│   │   │   ├── mtr-deployment.yaml              # Network path analysis
│   │   │   └── mtr-service.yaml
│   │   ├── ⚡ Enhanced Infrastructure
│   │   │   ├── blackbox-exporter-deployment.yaml # Enhanced with 15+ modules
│   │   │   ├── blackbox-exporter-config.yaml     # Comprehensive endpoint testing
│   │   │   ├── node-exporter-daemonset.yaml
│   │   │   ├── kube-state-metrics-deployment.yaml
│   │   │   └── kube-state-metrics-rbac.yaml
│   │   └── 🎯 CALO Lab Integration
│   │       └── # Auto-discovery for CXTAF/CXTM services
│   ├── values.yaml                    # Enhanced dynamic configuration
│   └── Chart.yaml
├── 🚀 Enhanced Automation Scripts
│   ├── install-observability-stack.sh    # Intelligent deployment with environment detection
│   ├── verify-installation.sh            # Comprehensive installation verification
│   ├── start-observability.sh            # Enhanced multi-service port forwarding
│   └── check-services.sh                 # Complete service health monitoring
├── 📖 Documentation
│   └── Document/
└── README.md                          # This comprehensive guide
```

---

## 🛠️ Enhanced Installation Guide

### Method 1: Automated Installation (Recommended)

**⚡ One-Command Deployment** with intelligent environment detection:

```bash
# 1. Make scripts executable
chmod +x *.sh

# 2. Deploy with automatic CALO lab detection
./install-observability-stack.sh

# 3. Verify deployment
./verify-installation.sh

# 4. Start all services
./start-observability.sh

# 5. Check health status
./check-services.sh
```

### Method 2: Custom Environment Installation

```bash
# Deploy to specific environment/namespace
./install-observability-stack.sh [RELEASE_NAME] [NAMESPACE] [ENVIRONMENT]

# Examples:
./install-observability-stack.sh obs-stack ao calo-lab          # CALO lab
./install-observability-stack.sh monitoring observability aws   # AWS deployment  
./install-observability-stack.sh prod-stack production gcp      # GCP deployment
```

### Method 3: Manual Helm Installation

```bash
# For manual control over deployment
helm install observability-stack ./helm-kube-observability-stack \
  --namespace ao \
  --create-namespace \
  --set environment.namespace=ao \
  --set environment.name=calo-lab
```

## 🔍 Installation Verification

The enhanced verification process provides comprehensive checks:

```bash
./verify-installation.sh [RELEASE_NAME] [NAMESPACE]
```

**What it checks:**
- ✅ Prerequisites (Helm, kubectl, cluster connectivity)
- ✅ Helm release status and health
- ✅ Kubernetes resource deployment
- ✅ Pod status with detailed analysis
- ✅ Service availability
- ✅ Storage provisioning

## 🚀 Service Management

### Start All Enhanced Services

```bash
# Start all 15+ observability services with dynamic namespace support
./start-observability.sh [NAMESPACE]

# Examples:
./start-observability.sh         # Uses default 'ao' namespace
./start-observability.sh monitoring   # Uses 'monitoring' namespace
```

**Enhanced Features:**
- 🔄 Automatic error handling and recovery
- 📊 Real-time service status feedback  
- 🌐 Complete network monitoring suite
- 🔍 Distributed tracing capabilities
- 🚨 Production alerting system

### Health Monitoring

```bash
# Comprehensive service health check
./check-services.sh [NAMESPACE]
```

**Health Check Coverage:**
- 📊 Core services (Grafana, Prometheus, Loki)
- 🔍 Enhanced services (Tempo, AlertManager)
- 🌐 Network monitoring (Smokeping, MTR, Blackbox)
- ⚡ Infrastructure exporters (Node, kube-state-metrics)
- 🗄️ Auto-discovered CXTM database services

### Service Control

```bash
# Stop all port-forwarding services
# Press Ctrl+C in the start-observability.sh terminal

# Or force kill all port forwards
pkill -f "kubectl port-forward"
```

---

## 🎯 Enhanced Observability Features

### Complete L.M.T Stack (Logs + Metrics + Traces)

**📊 Logs (Loki + Promtail):**
- Centralized log aggregation from all cluster nodes
- Advanced log parsing and labeling  
- Integration with trace correlation

**📈 Metrics (Prometheus + Enhanced Exporters):**
- Comprehensive metrics collection with auto-discovery
- 15+ specialized exporters for infrastructure and applications
- Custom CALO lab metrics for CXTAF/CXTM frameworks

**🔍 Traces (Tempo Direct Ingestion):**
- Distributed tracing with direct application integration
- Multi-protocol support (OTLP, Jaeger, Zipkin)
- Correlation with logs and metrics

### Auto-Configured Grafana Integration

**🎨 Pre-configured Dashboards:**
All data sources are automatically configured in Grafana:
- ✅ **Prometheus**: http://prometheus:9090 (metrics)
- ✅ **Loki**: http://loki:3100 (logs)  
- ✅ **Tempo**: http://tempo:3200 (traces)
- ✅ **AlertManager**: http://alertmanager:9093 (alerts)

**🔗 Intelligent Correlation:**
- Traces automatically link to related logs
- Metrics include trace exemplars
- Logs contain trace IDs for correlation
- Alerts link to relevant dashboards

### Network Monitoring Excellence

**🔍 Smokeping Network Graphs:**
- Visual network latency monitoring
- Multi-target connectivity analysis
- Historical performance tracking
- CALO lab network topology awareness

**📡 MTR Path Analysis:**
- Real-time network path discovery
- Hop-by-hop latency measurement  
- Network troubleshooting metrics
- Route optimization insights

**🛡️ Enhanced Blackbox Monitoring:**
- 15+ comprehensive monitoring modules:
  - HTTP/HTTPS endpoint testing
  - TCP port connectivity checks
  - DNS resolution monitoring
  - SSL certificate validation
  - ICMP ping monitoring
  - Custom CXTAF/CXTM health checks

### CALO Lab Intelligence

**🤖 Auto-Discovery:**
- Automatic detection of CXTAF test automation services
- CXTM workflow monitoring integration  
- Dynamic service endpoint discovery
- Smart namespace scanning

**🏷️ Environment Adaptation:**
- Automatic CALO lab node detection (ao-node=observability)
- Dynamic storage class selection (longhorn-single)
- Network topology awareness
- Resource optimization for lab environment

---

## 📊 Enhanced Query Examples

### 📋 Logs (Loki) - Advanced Log Analysis

**Basic Log Queries:**
```logql
# All container logs with enhanced labeling
{job="varlogs"}

# Error analysis with trace correlation
{job="varlogs"} |= "error" | json | trace_id != ""

# CALO lab specific services
{namespace=~"cxtaf-.*|cxtm.*"} |= "test"

# Observability stack logs
{namespace="ao"} |~ "prometheus|grafana|loki"

# Distributed tracing log correlation
{job="varlogs"} | json | trace_id="<trace_id_from_tempo>"
```

**Advanced Log Processing:**
```logql
# Performance analysis with metrics extraction  
rate({job="varlogs"} |= "response_time" | json [5m])

# Error rate by service
sum(rate({job="varlogs"} |= "ERROR" [5m])) by (service_name)

# CXTAF test execution logs with duration extraction
{namespace=~"cxtaf-.*"} |= "test_complete" | json | unwrap duration | rate[5m]
```

### 📈 Metrics (Prometheus) - Complete Infrastructure

**Enhanced Core Metrics:**
```promql
# Service availability with enhanced labels
up{job=~"prometheus|grafana|loki|tempo"}

# Enhanced blackbox monitoring (15+ modules)
probe_success{job="blackbox"}
probe_duration_seconds{job="blackbox"}
probe_http_status_code{job="blackbox"}

# Network monitoring integration
smokeping_rtt_seconds
mtr_hop_count
```

**Auto-Discovered CALO Lab Services:**
```promql
# CXTAF test automation metrics
up{job=~"cxtaf-.*"}
cxtaf_tests_running
cxtaf_device_connections_active

# CXTM workflow metrics  
up{job=~"cxtm-.*"}
cxtm_workflows_active
cxtm_database_connections

# Auto-discovered database metrics
mysql_up{instance=~"cxtm-mariadb.*"}
redis_up{instance=~"cxtm-redis.*"}
```

**Infrastructure Intelligence:**
```promql
# Kubernetes cluster health
kube_pod_status_phase{namespace="ao"}
kube_deployment_status_replicas{namespace="ao"}

# Node health with CALO lab awareness
kube_node_info{node=~"uta-k8s-ao-.*"}
node_memory_utilization{instance=~"uta-k8s-ao-.*"}

# Storage performance (Longhorn integration)
longhorn_volume_actual_size_bytes
longhorn_volume_state{storageclass="longhorn-single"}
```

### 🔍 Traces (Tempo) - Distributed Tracing

**Trace Analysis Queries:**
```promql
# Find traces by service name
{service.name="cxtaf-test-runner"}

# Performance analysis by operation
{service.name="cxtm-workflow-engine" && span.kind="server"}

# Error trace discovery
{status.code="error"}

# Database query traces
{service.name=~".*mariadb.*|.*redis.*"}
```

**Trace-to-Metrics Correlation:**
```promql
# Request rate from traces
rate(traces_spanmetrics_calls_total[5m])

# P95 latency by service
histogram_quantile(0.95, rate(traces_spanmetrics_latency_bucket[5m]))

# Error rate from distributed traces
rate(traces_spanmetrics_calls_total{status_code="error"}[5m])
```

### 🌐 Network Monitoring - Advanced Analytics

**Smokeping Network Analysis:**
```promql
# Network latency trends
smokeping_rtt_seconds{target="cxtaf-api"}
smokeping_packet_loss_percent

# Multi-target comparison
avg_over_time(smokeping_rtt_seconds[1h]) by (target)

# Network performance baseline
quantile_over_time(0.95, smokeping_rtt_seconds[24h])
```

**MTR Path Analysis:**
```promql
# Network path metrics
mtr_hop_count{target="external-api"}
mtr_packet_loss_percent by (hop)
mtr_rtt_ms{hop="1"} # First hop analysis

# Network troubleshooting
increase(mtr_timeouts_total[5m])
mtr_path_changes_total
```

### 🚨 Enhanced Alerting - Production Rules

**Critical Infrastructure Alerts:**
```promql
# Service down detection
up{job=~"prometheus|grafana|loki|tempo"} == 0

# High error rate
rate(http_requests_total{status=~"5.."}[5m]) > 0.1

# CALO lab specific alerts
up{job=~"cxtaf-.*|cxtm-.*"} == 0
kube_pod_status_phase{phase!="Running",namespace="ao"} > 0
```

**Network Performance Alerts:**
```promql
# Network latency threshold
smokeping_rtt_seconds > 0.1

# Packet loss detection
smokeping_packet_loss_percent > 5

# Path instability
increase(mtr_path_changes_total[5m]) > 0
```

### 🎯 CXTAF/CXTM Specific Queries

**Test Automation Intelligence:**
```promql
# Active test execution monitoring
cxtaf_tests_running by (test_suite)
cxtm_workflows_active by (workflow_type)

# Device connectivity health
cxtaf_device_connections_active
cxtaf_device_connection_failures_total

# Performance benchmarking
histogram_quantile(0.95, rate(cxtaf_test_duration_seconds_bucket[5m]))
rate(cxtm_workflow_completion_total[5m])
```

**Database Performance (Auto-Discovered):**
```promql
# MariaDB metrics (CXTM)
mysql_global_status_connections{instance=~"cxtm-mariadb.*"}
rate(mysql_global_status_queries[5m])

# Redis metrics (CXTM)  
redis_connected_clients{instance=~"cxtm-redis.*"}
rate(redis_commands_processed_total[5m])
```

## 🔧 Dynamic Configuration & Customization

### Environment-Specific Deployment

The enhanced values.yaml supports dynamic configuration:

```yaml
# Dynamic environment configuration
environment:
  name: "calo-lab"              # Environment identifier
  namespace: "ao"               # Target namespace
  
  cluster:
    nodeSelector:
      enabled: true             # Enable node targeting
      strategy: "labels"        # Selection strategy
      nodeLabels:
        ao-node: observability  # CALO lab node labels
    
    storage:
      storageClass: "longhorn-single"  # Dynamic storage class
      
# Component enablement flags
components:
  core:
    prometheus: true
    grafana: true
    loki: true
    promtail: true
    
  enhanced:
    tempo: true                 # Distributed tracing
    alertmanager: true          # Production alerting
    # Note: Direct Tempo ingestion - no OTEL collector needed
    
  network:
    smokeping: true            # Network monitoring
    mtrAnalyzer: true          # Path analysis
    blackboxEnhanced: true     # 15+ monitoring modules
    
  databases:
    redis: true                # Auto-enable for CALO lab
    mariadb: true              # Auto-enable for CALO lab
```

### Custom Environment Examples

**AWS Deployment:**
```bash
./install-observability-stack.sh aws-obs observability aws
```
```yaml
environment:
  name: "aws"
  cluster:
    storage:
      storageClass: "gp2"
    nodeSelector:
      enabled: false
```

**GCP Deployment:**
```bash  
./install-observability-stack.sh gcp-obs monitoring gcp
```
```yaml
environment:
  name: "gcp"
  cluster:
    storage:
      storageClass: "ssd"
    nodeSelector:
      strategy: "zones"
```

## 🎯 Production-Ready Features

### Zero External Dependencies
- ✅ **Self-Contained**: No external SaaS dependencies
- ✅ **Cost-Free**: Zero external service costs
- ✅ **Air-Gapped Compatible**: Works in isolated environments
- ✅ **CALO Lab Optimized**: Purpose-built for UTA infrastructure

### Infrastructure Agnostic  
- 🌐 **Multi-Cloud**: AWS, GCP, Azure, On-premises
- 🔄 **Dynamic Adaptation**: Auto-detects environment capabilities
- 📦 **Plug-and-Play**: One-command deployment anywhere
- 🎯 **Smart Defaults**: Intelligent configuration selection

### Enterprise-Grade Reliability
- 🚨 **Production Alerting**: Pre-configured alert rules
- 📊 **SLA Monitoring**: Service level objectives tracking
- 🔒 **Security Hardened**: Best practice configurations
- 🔄 **High Availability**: Multi-replica deployments

---

## 🚀 Advanced Deployment Options

### Permanent Access Solutions

**Ingress Configuration (Recommended):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: enhanced-observability-ingress
  namespace: ao
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: grafana.observability.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 3000
  - host: prometheus.observability.local  
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus
            port:
              number: 9090
  - host: tempo.observability.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tempo
            port:
              number: 3200
```

**LoadBalancer for Cloud Deployments:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana-lb
  namespace: ao
spec:
  type: LoadBalancer
  selector:
    app: grafana
  ports:
  - name: http
    port: 80
    targetPort: 3000
```

### CALO Lab Network Integration

**NodePort Configuration:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana-nodeport
  namespace: ao
spec:
  type: NodePort
  selector:
    app: grafana
  ports:
  - name: http
    port: 3000
    targetPort: 3000
    nodePort: 30000  # Access via any CALO lab node
```

---

## 📊 Enhanced Service Port Reference

### 🎯 Core Observability Services
| Service | Port | Protocol | Description | Health Check |
|---------|------|----------|-------------|--------------|
| **Grafana** | 3000 | HTTP | Enhanced visualization with auto-configured datasources | http://localhost:3000 |
| **Prometheus** | 9090 | HTTP | Metrics collection with auto-discovery | http://localhost:9090/targets |
| **Loki** | 3100 | HTTP | Log aggregation with trace correlation | http://localhost:3100/ready |

### 🔍 Enhanced Monitoring Services  
| Service | Port | Protocol | Description | Health Check |
|---------|------|----------|-------------|--------------|
| **Tempo** | 3200 | HTTP | Distributed tracing backend | http://localhost:3200/ready |
| **AlertManager** | 9093 | HTTP | Production-ready alerting | http://localhost:9093/#/status |
| **Tempo Direct** | 3200 | HTTP | Direct trace ingestion | http://localhost:3200/ready |

### 🌐 Network Monitoring Suite
| Service | Port | Protocol | Description | Health Check |
|---------|------|----------|-------------|--------------|
| **Smokeping** | 80 | HTTP | Network latency visualization | http://localhost:80/smokeping/ |
| **MTR Analyzer** | 8080 | HTTP | Network path analysis | http://localhost:8080/metrics |
| **Blackbox Enhanced** | 9115 | HTTP | 15+ endpoint monitoring modules | http://localhost:9115/metrics |

### ⚡ Infrastructure Intelligence
| Service | Port | Protocol | Description | Health Check |
|---------|------|----------|-------------|--------------|
| **Kube-State-Metrics** | 8081 | HTTP | Kubernetes cluster intelligence | http://localhost:8081/metrics |
| **Node Exporter** | 9100 | HTTP | System-level metrics | http://localhost:9100/metrics |
| **Promtail** | 9080 | HTTP | Log collection agent | http://localhost:9080/metrics |

---

## 🎯 Enhanced Helm Chart Architecture

### Why Enhanced Helm Chart?

1. **🚀 Advanced Modularity**: Individual component lifecycle management
2. **🌐 Infrastructure Agnostic**: Deploy anywhere with intelligent adaptation  
3. **🔄 Auto-Discovery**: Dynamic service detection and configuration
4. **📊 Complete Observability**: Integrated L.M.T (Logs, Metrics, Traces) stack
5. **🎯 Production Ready**: Enterprise-grade configurations and security
6. **💰 Zero Cost**: No external dependencies or SaaS fees

### Helm Command Reference

**Enhanced Installation:**
```bash
# Intelligent deployment with auto-detection
./install-observability-stack.sh

# Custom environment deployment
./install-observability-stack.sh [RELEASE] [NAMESPACE] [ENVIRONMENT]

# Manual Helm with custom values
helm install observability-stack ./helm-kube-observability-stack \
  --namespace ao --create-namespace \
  --set environment.name=calo-lab \
  --set components.enhanced.tempo=true \
  --set components.network.smokeping=true
```

**Management Commands:**
```bash
# Verify comprehensive installation
./verify-installation.sh [RELEASE] [NAMESPACE]

# Start all enhanced services  
./start-observability.sh [NAMESPACE]

# Complete health monitoring
./check-services.sh [NAMESPACE]

# Helm operations
helm status observability-stack -n ao
helm upgrade observability-stack ./helm-kube-observability-stack -n ao
helm uninstall observability-stack -n ao
```

**Kubernetes Operations:**
```bash
# Monitor deployment progress
kubectl get pods -n ao -w

# Check comprehensive resources
kubectl get all -n ao

# Debug specific services
kubectl logs -n ao -l app=tempo
kubectl logs -n ao -l app=tempo
kubectl describe pod -n ao -l app=smokeping
```

---

## 🎉 Summary: Complete Observability Achievement

**🎯 What You Get:**
- ✅ **Complete L.M.T Stack**: Logs + Metrics + Traces integration
- ✅ **Advanced Network Monitoring**: Smokeping + MTR + Enhanced Blackbox
- ✅ **Auto-Discovery Intelligence**: CXTAF/CXTM service auto-detection
- ✅ **Production Alerting**: Pre-configured AlertManager rules
- ✅ **Zero External Costs**: Complete self-hosted solution
- ✅ **Infrastructure Agnostic**: Deploy anywhere with smart adaptation
- ✅ **CALO Lab Optimized**: Purpose-built for UTA research environment

**🚀 Enhanced Workflow:**
1. `./install-observability-stack.sh` → **Intelligent deployment**
2. `./verify-installation.sh` → **Comprehensive validation**  
3. `./start-observability.sh` → **15+ service activation**
4. `./check-services.sh` → **Complete health monitoring**
5. **Access Grafana** → http://localhost:3000 (admin/admin)

**📊 Complete Visibility:**
- **Distributed Traces**: End-to-end request tracking
- **Network Intelligence**: Path analysis and latency monitoring  
- **Infrastructure Health**: Kubernetes and node-level insights
- **Application Performance**: CXTAF/CXTM test automation metrics
- **Database Monitoring**: Auto-discovered MariaDB and Redis metrics

---

**🎯 Ready for Production** • **🌐 Infrastructure Agnostic** • **💰 Zero External Costs**