# Comprehensive Observability Stack

This repository provides a step-by-step guide to set up a comprehensive observability stack using Kubernetes and Helm. The solution provides complete monitoring and logging capabilities for modern applications, especially test automation platforms and Kubernetes clusters.

**Components Include:**
- **🎯 Core Stack**: Prometheus, Grafana, Loki, Promtail
- **🔧 Infrastructure Exporters**: Node Exporter, Blackbox Exporter  
- **⚡ Foundation Exporters**: kube-state-metrics, MongoDB Exporter, PostgreSQL Exporter
- **🚀 Application Layer**: Custom FastAPI metrics, Jenkins Exporter, Redis Exporter

**Complete 12-Service Observability Platform** for modern test automation and Kubernetes monitoring.

## ✅ **Latest Improvements & Fixes**

**🔧 Issues Fixed:**
- ✅ **Service Type Configuration**: Fixed hardcoded ClusterIP in templates to support dynamic NodePort
- ✅ **NodePort Support**: Added proper NodePort configuration with predefined ports (30300, 30090, 30310, 30115)
- ✅ **Configure Script**: Fixed `configure-nodeport-access.sh` to correctly switch between ClusterIP and NodePort
- ✅ **Values.yaml Structure**: Updated configuration structure for observability-specific settings
- ✅ **Template Compatibility**: All service templates now support both ClusterIP and NodePort modes

**🚀 New Features:**
- 🆕 **One-Command Configuration**: `./configure-nodeport-access.sh enable/disable`
- 🆕 **Direct Access Support**: Perfect for CALO lab environment - no port-forwarding needed
- 🆕 **Deployment Flexibility**: Switch between access methods without changing code
- 🆕 **Production Ready**: Validated configuration for enterprise deployment

**📦 Ready for CALO Lab Deployment Today!**

---

## Prerequisites

Before starting, ensure the following tools are installed and configured:

1. **kubectl**: Kubernetes command-line tool.  
   [Installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. **Helm**: Kubernetes package manager.  
   [Installation guide](https://helm.sh/docs/intro/install/)
3. **Minikube** (optional): Local Kubernetes cluster for testing.  
   [Installation guide](https://minikube.sigs.k8s.io/docs/start/)

---

## 🚀 Quick Start

### Option A: Direct Access (CALO Lab - Recommended)

For direct IP access without port-forwarding:

```bash
# 1. Configure for NodePort access
chmod +x configure-nodeport-access.sh
./configure-nodeport-access.sh enable

# 2. Deploy the Helm chart (auto-creates ao-os namespace)
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace

# 3. Access directly via node IP (no port-forwarding needed)
# Replace YOUR-NODE-IP with your cluster node IP (e.g., 10.122.28.111)
```

### Option B: Port-Forwarding Access (Local Development)

For local development with port-forwarding:

```bash
# 1. Configure for ClusterIP access (default)
./configure-nodeport-access.sh disable

# 2. Deploy the Helm chart (auto-creates ao-os namespace)
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace

# 3. Start port forwarding
chmod +x start-observability.sh
./start-observability.sh

# 4. Check service status
chmod +x check-services.sh  
./check-services.sh
```

**Access URLs:**

### Direct Access (NodePort) - CALO Lab
Replace `YOUR-NODE-IP` with your cluster node IP:

**📊 Core Services:**
- **Grafana**: http://YOUR-NODE-IP:30300 (admin/admin)
- **Prometheus**: http://YOUR-NODE-IP:30090
- **Loki**: http://YOUR-NODE-IP:30310
- **Blackbox Exporter**: http://YOUR-NODE-IP:30115

**⚡ Foundation Exporters:**
- **kube-state-metrics**: http://YOUR-NODE-IP:30808
- **MongoDB Exporter**: http://YOUR-NODE-IP:30916  
- **PostgreSQL Exporter**: http://YOUR-NODE-IP:30987

**🚀 Application Layer:**
- **Jenkins Exporter**: http://YOUR-NODE-IP:30918
- **Redis Exporter**: http://YOUR-NODE-IP:30921
- **FastAPI Metrics**: http://YOUR-NODE-IP:30801

### Port-Forward Access (Local Development)
When using port-forwarding:

**📊 Core Services:**
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100
- **Blackbox Exporter**: http://localhost:9115

**⚡ Foundation Exporters:**
- **kube-state-metrics**: http://localhost:8080
- **MongoDB Exporter**: http://localhost:9216
- **PostgreSQL Exporter**: http://localhost:9187

**🚀 Application Layer:**
- **Jenkins Exporter**: http://localhost:9118
- **Redis Exporter**: http://localhost:9121
- **FastAPI Metrics**: http://localhost:8001

---

## Directory Structure

```
opensource-observability-package/
├── helm-kube-observability-stack/
│   ├── charts/
│   ├── templates/
│   │   ├── # Core Stack
│   │   ├── grafana-deployment.yaml
│   │   ├── grafana-service.yaml
│   │   ├── loki-deployment.yaml
│   │   ├── loki-service.yaml
│   │   ├── prometheus-deployment.yaml
│   │   ├── prometheus-service.yaml
│   │   ├── prometheus-config.yaml
│   │   ├── promtail-deployment.yaml
│   │   ├── promtail-service.yaml
│   │   ├── promtail-config.yaml
│   │   ├── promtail-rbac.yaml
│   │   ├── # Infrastructure Exporters  
│   │   ├── node-exporter-daemonset.yaml
│   │   ├── node-exporter-service.yaml
│   │   ├── blackbox-exporter-deployment.yaml
│   │   ├── blackbox-exporter-service.yaml
│   │   ├── blackbox-exporter-config.yaml
│   │   ├── # Foundation Exporters
│   │   ├── kube-state-metrics-deployment.yaml
│   │   ├── kube-state-metrics-service.yaml
│   │   ├── kube-state-metrics-rbac.yaml
│   │   ├── mongodb-exporter-deployment.yaml
│   │   ├── mongodb-exporter-service.yaml
│   │   ├── mongodb-exporter-secret.yaml
│   │   ├── postgres-exporter-deployment.yaml
│   │   ├── postgres-exporter-service.yaml
│   │   ├── postgres-exporter-secret.yaml
│   │   ├── # Application Layer
│   │   ├── jenkins-exporter-deployment.yaml
│   │   ├── jenkins-exporter-service.yaml
│   │   ├── jenkins-exporter-secret.yaml
│   │   ├── redis-exporter-deployment.yaml
│   │   ├── redis-exporter-service.yaml
│   │   ├── redis-exporter-secret.yaml
│   │   ├── fastapi-metrics-deployment.yaml
│   │   ├── fastapi-metrics-service.yaml
│   │   ├── fastapi-metrics-config.yaml
│   │   ├── # Kubernetes Resources
│   │   ├── namespace.yaml
│   │   ├── ingress.yaml
│   │   ├── NOTES.txt
│   ├── values.yaml
│   ├── Chart.yaml
├── start-observability.sh       # Comprehensive multi-port forwarding script
├── check-services.sh           # Enhanced service health check script
├── configure-nodeport-access.sh # NodePort configuration script for direct access
├── install-observability-stack.sh # Helm installation script
├── verify-installation.sh     # Installation verification script
├── Document/
│   ├── Technical-design-document.md  # Technical documentation
│   ├── HELM_PACKAGE_GUIDE.md   # Helm packaging guide
│   ├── OpenTelemetry-Integration-Plan.md # OpenTelemetry integration
│   └── architecture.png
└── README.md
```

---

## 🎯 CALO Lab Deployment Guide - **PLUG & PLAY**

**One-command deployment!** Your observability stack creates its own `ao-os` namespace and handles everything automatically.

### 🚀 **Plug & Play Deployment** (Recommended)
```bash
# Single command - does everything!
./configure-nodeport-access.sh enable && \
helm install ao-observability ./helm-kube-observability-stack \
  --namespace ao-os --create-namespace
```

### 📋 **Step-by-Step Deployment** (Manual)
```bash
# Step 1: Enable Direct Access  
chmod +x configure-nodeport-access.sh
./configure-nodeport-access.sh enable

# Step 2: Deploy to ao-os namespace (auto-created)
helm install ao-observability ./helm-kube-observability-stack \
  --namespace ao-os --create-namespace

# Step 3: Verify Installation  
kubectl get all -n ao-os
./verify-installation.sh
```

### Step 4: Access Your Services
Replace `YOUR-NODE-IP` with your CALO lab node IP:

- **📊 Grafana Dashboard**: http://YOUR-NODE-IP:30300 (admin/admin)
- **📈 Prometheus Metrics**: http://YOUR-NODE-IP:30090
- **📋 Loki Logs**: http://YOUR-NODE-IP:30310
- **🔍 Blackbox Monitoring**: http://YOUR-NODE-IP:30115

**✅ No port-forwarding needed - Direct access ready!**

---

## Installation Steps (Detailed)

### Step 1: Configure Access Method

**For CALO Lab (Direct Access):**
```bash
# Enable NodePort for direct IP access
chmod +x configure-nodeport-access.sh
./configure-nodeport-access.sh enable
```

**For Local Development (Port-Forwarding):**
```bash  
# Use ClusterIP (default) for port-forwarding
./configure-nodeport-access.sh disable
```

### Step 2: Deploy the Helm Chart
Install the Helm chart using the command below. The `--create-namespace` flag will automatically create the `ao-os` namespace for you if it doesn't exist.

```bash  
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace
```

If you need to upgrade the chart after making changes, use this command:

```bash
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os
```

### Configure NodePort Access

Use the `configure-nodeport-access.sh` script to easily switch between access methods:

```bash
# Check current configuration
./configure-nodeport-access.sh status

# Enable direct access (NodePort)  
./configure-nodeport-access.sh enable

# Disable direct access (ClusterIP for port-forwarding)
./configure-nodeport-access.sh disable

# Interactive mode
./configure-nodeport-access.sh

# Get help
./configure-nodeport-access.sh --help
```

### Step 3: Verify Deployments and Services
Check the status of deployments:
```bash
kubectl get deployments -n ao-os
```

Check the status of services:
```bash
kubectl get services -n ao-os
```

### Step 4: Access Applications via Port Forwarding

You can access the observability services using either **manual port forwarding** (individual commands) or **automated scripts** (recommended for easier management).

#### Option A: Automated Multi-Port Forwarding (Recommended)

**Start All Services:**
```bash
# Make the script executable
chmod +x start-observability.sh

# Start all services with a single command
./start-observability.sh
```

**Check Service Status:**
```bash
# Make the script executable
chmod +x check-services.sh

# Check health of all services
./check-services.sh
```

**Stop All Services:**
```bash
# Press Ctrl+C in the start-observability.sh terminal, or
pkill -f "kubectl port-forward"
```

#### Option B: Manual Port Forwarding (Individual Commands)

#### Grafana
```bash
kubectl port-forward svc/grafana 3000:3000 -n ao-os
```
Access Grafana at `http://localhost:3000`.

#### Prometheus
```bash
kubectl port-forward svc/prometheus 9090:9090 -n ao-os
```
Access Prometheus at `http://localhost:9090`.

#### Loki
```bash
kubectl port-forward svc/loki 3100:3100 -n ao-os
```
Access Loki at `http://localhost:3100`.

#### Blackbox Exporter
```bash
kubectl port-forward svc/blackbox-exporter 9115:9115 -n ao-os
```
Access Blackbox Exporter at `http://localhost:9115`.

#### Node Exporter (If Needed)
```bash
kubectl port-forward svc/node-exporter 9100:9100 -n ao-os
```
Access Node Exporter at `http://localhost:9100`.

#### Promtail (If Needed)
```bash
kubectl port-forward svc/promtail 9080:9080 -n ao-os
```
Access Promtail at `http://localhost:9080`.

### Foundation Exporters

#### kube-state-metrics
```bash
kubectl port-forward svc/kube-state-metrics 8080:8080 -n ao-os
```
Access kube-state-metrics at `http://localhost:8080`.

#### MongoDB Exporter
```bash
kubectl port-forward svc/mongodb-exporter 9216:9216 -n ao-os
```
Access MongoDB Exporter at `http://localhost:9216`.

#### PostgreSQL Exporter
```bash
kubectl port-forward svc/postgres-exporter 9187:9187 -n ao-os
```
Access PostgreSQL Exporter at `http://localhost:9187`.

### Application Layer

#### Jenkins Exporter
```bash
kubectl port-forward svc/jenkins-exporter 9118:9118 -n ao-os
```
Access Jenkins Exporter at `http://localhost:9118`.

#### Redis Exporter
```bash
kubectl port-forward svc/redis-exporter 9121:9121 -n ao-os
```
Access Redis Exporter at `http://localhost:9121`.

#### FastAPI Metrics
```bash
kubectl port-forward svc/fastapi-metrics 8001:8001 -n ao-os
```
Access FastAPI Metrics at `http://localhost:8001`.
---

### Step 5: Access the Services
Once the ports are forwarded (using either automated scripts or manual commands), you can access the services locally using the following URLs:

**📊 Core Services:**
```bash
Grafana: http://localhost:3000        (Username: admin, Password: admin)
Prometheus: http://localhost:9090
Loki: http://localhost:3100
```

**🔧 Infrastructure Exporters:**
```bash
Node Exporter: http://localhost:9100
Promtail: http://localhost:9080
Blackbox Exporter: http://localhost:9115
```

**⚡ Foundation Exporters:**
```bash
kube-state-metrics: http://localhost:8080
MongoDB Exporter: http://localhost:9216
PostgreSQL Exporter: http://localhost:9187
```

**🚀 Application Layer:**
```bash
Jenkins Exporter: http://localhost:9118
Redis Exporter: http://localhost:9121
FastAPI Metrics: http://localhost:8001
```

---

## Foundation Exporters Configuration

### MongoDB Exporter Setup
Before using the MongoDB Exporter, configure your database connection in `values.yaml`:

```yaml
mongodbExporter:
  mongodbUri: "mongodb://your-username:your-password@your-mongodb-host:27017/admin"
```

### PostgreSQL Exporter Setup
Before using the PostgreSQL Exporter, configure your database connection in `values.yaml`:

```yaml
postgresExporter:
  dataSourceName: "postgresql://your-username:your-password@your-postgres-host:5432/your-database?sslmode=disable"
```

### Update Deployment
After updating the configuration, redeploy the stack:
```bash
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os
```

---

## Application Layer Configuration

### Jenkins Exporter Setup
Before using the Jenkins Exporter, configure your Jenkins server connection in `values.yaml`:

```yaml
jenkinsExporter:
  jenkinsServer: "http://your-jenkins-host:8080"
  jenkinsUsername: "your-jenkins-username"  
  jenkinsPassword: "your-jenkins-password"  # Use API token for security
```

### Redis Exporter Setup
Before using the Redis Exporter, configure your Redis connection in `values.yaml`:

```yaml
redisExporter:
  redisAddr: "redis://your-redis-host:6379"
  redisPassword: "your-redis-password"     # Leave empty if no password
```

### FastAPI Custom Metrics Setup
The FastAPI metrics service provides sample test automation metrics. You can customize the application by modifying the ConfigMap in `fastapi-metrics-config.yaml`. The sample includes:

- **Test execution metrics** (CXTAF/CXTM frameworks)
- **API performance monitoring**
- **Device connection tracking**
- **Workflow management metrics**

### Update Deployment
After updating any configuration, redeploy the complete stack:
```bash
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os
```

---

## Adding Data Sources in Grafana

### Prometheus
1. **Access Grafana**:
   Run the following command to port-forward Grafana:
   ```bash
   kubectl port-forward svc/grafana 3000:3000 -n ao-os
   ```
   Open your browser and navigate to `http://localhost:3000`.

2. **Login to Grafana**:
   Use the default credentials:
   - Username: `admin`
   - Password: `admin` (or the value set in `values.yaml` under `grafana.adminPassword`).

3. **Add Prometheus Data Source**:
   - Go to **Configuration** > **Data Sources** > **Add Data Source**.
   - Select **Prometheus**.
   - Set the URL to `http://prometheus:9090` (internal service name and port for Prometheus in Kubernetes).
   - Click **Save & Test**.

---

### Loki
1. **Add Loki Data Source**:
   - Go to **Configuration** > **Data Sources** > **Add Data Source**.
   - Select **Loki**.
   - Set the URL to `http://loki:3100` (internal service name and port for Loki in Kubernetes).
   - Click **Save & Test**.

---

## Sample Queries

### Logs (Loki)
```promql
{job="varlogs"}                          # All container logs
{job="varlogs"} |= "error"              # Error logs only
{namespace="ao-os"}                      # Observability namespace logs
```

### Core Infrastructure (Prometheus)
```promql
up                                       # Service availability
probe_success{job="blackbox"}           # External endpoint health
rate(prometheus_http_requests_total[5m]) # Prometheus request rate
```

### Kubernetes Health (kube-state-metrics)
```promql
kube_pod_status_phase                    # Pod status across cluster
kube_deployment_status_replicas          # Deployment replica status
kube_node_status_condition               # Node health status
kube_pod_container_status_restarts_total # Container restart rates
```

### Database Metrics
```promql
mongodb_up                               # MongoDB connection status
pg_up                                    # PostgreSQL connection status
mongodb_connections                      # MongoDB active connections
postgres_connections                     # PostgreSQL connections
```

### Application Layer

#### CI/CD Pipeline Metrics (Jenkins)
```promql
jenkins_job_success_percentage           # Build success rates
jenkins_queue_size                      # Build queue backlogs
jenkins_job_duration_milliseconds       # Pipeline execution times
jenkins_builds_duration_milliseconds_summary # Build duration summary
```

#### Cache & Session Metrics (Redis)
```promql
redis_connected_clients                 # Active Redis connections
redis_memory_used_bytes                # Memory usage
redis_commands_processed_total          # Commands processed per second
redis_up                               # Redis connection status
```

#### Test Automation Metrics (FastAPI)
```promql
test_executions_total{framework="cxtaf"} # CXTAF test executions
test_executions_total{framework="cxtm"}  # CXTM test executions
cxtaf_device_connections_active         # Active device connections
cxtm_workflows_active                   # Active test workflows
active_test_sessions_total              # Concurrent test capacity
fastapi_request_duration_seconds        # API response times
test_execution_duration_seconds         # Test execution duration
```

## Enhanced Service Health Monitoring

The `check-services.sh` script now provides comprehensive status monitoring for all components:

```bash
🔍 Checking Observability Services Status
==========================================

🔹 Core Observability Services:
✅ Grafana        : Running (http://localhost:3000)
✅ Prometheus     : Running (http://localhost:9090)
✅ Loki           : Running (http://localhost:3100/metrics)

🔹 Infrastructure Exporters:
✅ Blackbox Export: Running (http://localhost:9115)
✅ Node Exporter  : Running (http://localhost:9100)
✅ Promtail       : Running (http://localhost:9080)

🔹 Foundation Exporters:
✅ kube-state-metrics: Running (http://localhost:8080)
✅ MongoDB Exporter  : Running (http://localhost:9216)
✅ PostgreSQL Exporter: Running (http://localhost:9187)

🔹 Application Layer Exporters:
✅ Jenkins Exporter  : Running (http://localhost:9118)
✅ Redis Exporter    : Running (http://localhost:9121)
✅ FastAPI Metrics   : Running (http://localhost:8001)

📋 Default Credentials:
   Grafana: admin/admin

🔗 Quick Links:
   • Grafana Dashboard: http://localhost:3000
   • Prometheus Targets: http://localhost:9090/targets
   • Kubernetes Metrics: http://localhost:8080/metrics
   • Node Metrics: http://localhost:9100/metrics
   • Jenkins Metrics: http://localhost:9118/metrics
   • Redis Metrics: http://localhost:9121/metrics
   • FastAPI Metrics: http://localhost:8001/metrics
   • FastAPI App: http://localhost:8000
```

---

## Access Methods

### Method 1: NodePort (Direct Access) - RECOMMENDED for CALO Lab

**Advantages:**
- ✅ Direct IP access without port-forwarding
- ✅ Perfect for CALO lab environment  
- ✅ No additional setup required
- ✅ Works with any cluster node IP

**Configuration:**
```bash
# Enable NodePort access
./configure-nodeport-access.sh enable

# Deploy with NodePort configuration
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os

# Access via: http://YOUR-NODE-IP:PORT
```

**NodePort Assignments:**
- Grafana: 30300
- Prometheus: 30090  
- Loki: 30310
- Blackbox Exporter: 30115

### Method 2: Ingress (Hostname-based)
Use an Ingress resource for hostname-based routing:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: ao-os
spec:
  rules:
  - host: grafana.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 3000
```

### Method 3: LoadBalancer
Expose services using a LoadBalancer:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: ao-os
spec:
  selector:
    app: grafana
  ports:
  - name: http
    port: 3000
    targetPort: 3000
  type: LoadBalancer
```

### Method 4: Port-Forwarding (Local Development)
For local development and testing:
```bash
# Configure for port-forwarding
./configure-nodeport-access.sh disable

# Start port-forwarding
./start-observability.sh

# Access via: http://localhost:PORT
```

---

## Ports and Access

### Core Observability Services
| Application   | Port  | Access Method           | Description |
|---------------|-------|-------------------------|-------------|
| Grafana       | 3000  | Port-forward or NodePort| Visualization & Dashboards |
| Prometheus    | 9090  | Port-forward            | Metrics Collection & Query |
| Loki          | 3100  | Port-forward            | Log Aggregation |

### Infrastructure Exporters
| Application   | Port  | Access Method           | Description |
|---------------|-------|-------------------------|-------------|
| Node Exporter | 9100  | Port-forward / Internal | System Metrics (CPU, Memory, Disk) |
| Promtail      | 9080  | Port-forward / Internal | Log Collection Agent |
| Blackbox      | 9115  | Port-forward / Internal | External Endpoint Monitoring |

### Foundation Exporters
| Application   | Port  | Access Method           | Description |
|---------------|-------|-------------------------|-------------|
| kube-state-metrics | 8080  | Port-forward / Internal | Kubernetes Cluster Health |
| MongoDB Exporter   | 9216  | Port-forward / Internal | NoSQL Database Metrics |
| PostgreSQL Exporter| 9187  | Port-forward / Internal | Relational Database Metrics |

### Application Layer
| Application   | Port  | Access Method           | Description |
|---------------|-------|-------------------------|-------------|
| Jenkins Exporter   | 9118  | Port-forward / Internal | CI/CD Pipeline Monitoring |
| Redis Exporter     | 9121  | Port-forward / Internal | Cache & Session Metrics |
| FastAPI Metrics    | 8001  | Port-forward / Internal | Test Automation Application Metrics |

---

## Why Helm Chart?

1. **Modularity**: Easy to update individual components.
2. **Reusability**: Can be reused across environments.
3. **Scalability**: Simplifies scaling and upgrading applications.
4. **Declarative Approach**: YAML-based configuration for easier management.

---

## Commands Summary

### CALO Lab Deployment (NodePort) - **PLUG & PLAY**
```bash
# 🚀 One-Command Deployment!
./configure-nodeport-access.sh enable && \
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace

# OR Step-by-Step:
# Configure for direct access
./configure-nodeport-access.sh enable

# Install with NodePort (auto-creates ao-os namespace)
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace

# Upgrade existing deployment
helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os

# Check status
kubectl get all -n ao-os
./verify-installation.sh

# Access directly: http://NODE-IP:30300 (Grafana)
```

### Local Development (Port-Forward)
```bash
# Configure for port-forwarding  
./configure-nodeport-access.sh disable

# Install with ClusterIP (auto-creates ao-os namespace)
helm install ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace

# Start port forwarding
./start-observability.sh

# Check service health
./check-services.sh

# Stop all port forwards
pkill -f "kubectl port-forward"
```

### Configuration Management
```bash
# Check current configuration
./configure-nodeport-access.sh status

# Switch to NodePort (CALO Lab)
./configure-nodeport-access.sh enable

# Switch to ClusterIP (Local)
./configure-nodeport-access.sh disable

# Interactive configuration
./configure-nodeport-access.sh
```

### Troubleshooting
```bash
# Check pods status in ao-os namespace
kubectl get pods -n ao-os

# Check services
kubectl get svc -n ao-os

# Check NodePort services  
kubectl get svc -n ao-os -o wide | grep NodePort

# View pod logs
kubectl logs -n ao-os <pod-name>

# Describe failing pods
kubectl describe pod -n ao-os <pod-name>

# Check events
kubectl get events -n ao-os --sort-by='.lastTimestamp'

# Check entire ao-os namespace
kubectl get all -n ao-os
```

### Ingress Access (Domain-based)
```bash
# Enable minikube ingress addon
minikube addons enable ingress

# Start minikube tunnel for ingress access
minikube tunnel

# Access services via domains (requires /etc/hosts entries)
# Core Services
# http://grafana.os.com
# http://prometheus.os.com
# http://loki.os.com
# Infrastructure Exporters
# http://blackbox.os.com
# http://node-exporter.os.com
# Foundation Exporters
# http://kube-state-metrics.os.com
# http://mongodb-exporter.os.com
# http://postgres-exporter.os.com
# Application Layer Exporters
# http://jenkins-exporter.os.com
# http://redis-exporter.os.com
# http://fastapi-metrics.os.com
```

---

## 🎉 **Deployment Summary**

### ✅ **Your observability package is now:**
- **🔧 Fixed & Validated** - All critical issues resolved  
- **🚀 CALO Lab Ready** - Configured for direct IP access
- **📦 Production Ready** - Enterprise-grade deployment
- **⚡ Easy to Use** - One command configuration switching

### 🎯 **For CALO Lab Deployment:**
```bash
# 1. Enable direct access
./configure-nodeport-access.sh enable

# 2. Deploy to ao-os namespace (auto-created)
helm install ao-observability ./helm-kube-observability-stack \
  --namespace ao-os --create-namespace

# 3. Access directly via your node IP
# Grafana: http://YOUR-NODE-IP:30300
# Prometheus: http://YOUR-NODE-IP:30090
# Loki: http://YOUR-NODE-IP:30310
```

### 🌟 **Key Benefits:**
- ✅ **No Port-Forwarding** - Direct access from any network
- ✅ **Production Scale** - 12 comprehensive monitoring services
- ✅ **Enterprise Ready** - Proper RBAC, secrets, and configuration
- ✅ **Deployment Flexibility** - Works in any Kubernetes environment

**🚀 Ready to deploy today - Your observability stack is production-ready!**