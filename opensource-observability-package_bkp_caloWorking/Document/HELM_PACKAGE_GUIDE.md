# 🚀 Kubernetes Observability Stack - Helm Package

**Complete Enterprise Observability Platform** packaged as a ready-to-deploy Helm chart.

## 📦 Package Information

- **Package Name**: `kube-observability-stack-1.0.0.tgz`
- **Chart Version**: 1.0.0
- **App Version**: 1.0.0
- **Package Size**: ~12KB
- **Total Services**: 12 (7 core + 5 optional)

## 🎯 What's Included

### ✅ Core Services (Ready to Use)
- **Grafana** with persistent storage - Visualization & dashboards
- **Prometheus** - Metrics collection and storage
- **Loki** - Log aggregation and querying
- **Promtail** - Log collection agent with RBAC
- **Node Exporter** - System metrics (CPU, Memory, Disk)
- **Blackbox Exporter** - External endpoint monitoring
- **kube-state-metrics** - Kubernetes cluster health with RBAC

### ⚙️ Application Layer Services (Need Configuration)
- **Jenkins Exporter** - CI/CD pipeline monitoring
- **Redis Exporter** - Cache and session metrics
- **MongoDB Exporter** - NoSQL database monitoring
- **PostgreSQL Exporter** - SQL database monitoring
- **FastAPI Metrics** - Custom application metrics

## 🔧 Installation

### Method 1: Install from Local Package

```bash
# Install the package
helm install my-observability-stack ./kube-observability-stack-1.0.0.tgz --create-namespace

# Or with custom namespace
helm install my-observability-stack ./kube-observability-stack-1.0.0.tgz --namespace my-monitoring --create-namespace
```

### Method 2: Install from Source Directory

```bash
# From the chart directory
helm install my-observability-stack ./helm-kube-observability-stack --create-namespace
```

### Method 3: Upgrade Existing Installation

```bash
# Upgrade from package
helm upgrade my-observability-stack ./kube-observability-stack-1.0.0.tgz

# Check status
helm status my-observability-stack
```

## 📋 Post-Installation Setup

### 1. Start Port Forwarding
```bash
# Make scripts executable
chmod +x start-observability.sh check-services.sh

# Start all services
./start-observability.sh
```

### 2. Access Services
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090  
- **Loki**: http://localhost:3100

### 3. Configure Grafana Data Sources
1. Login to Grafana at http://localhost:3000
2. Go to Configuration → Data Sources
3. Add Prometheus: `http://prometheus:9090`
4. Add Loki: `http://loki:3100`
5. Test connections and start creating dashboards

## 🎛️ Configuration Options

### Key Values (values.yaml)

```yaml
# Namespace
namespace: kube-observability-stack

# Grafana with persistent storage
grafana:
  adminPassword: admin
  storage:
    size: 10Gi

# External service configurations (optional)
jenkinsExporter:
  jenkinsServer: "http://your-jenkins-host:8080"
  jenkinsUsername: "your-username"
  
redisExporter:
  redisAddr: "redis://your-redis-host:6379"

mongodbExporter:
  mongodbUri: "mongodb://username:password@mongodb-host:27017"
```

## 🔍 Verification

### Check Installation
```bash
# Check all pods
kubectl get pods -n kube-observability-stack

# Check services  
kubectl get svc -n kube-observability-stack

# Check persistent volumes
kubectl get pvc -n kube-observability-stack
```

### Health Check
```bash
# Use included health check script
./check-services.sh
```

Expected output:
```
✅ Grafana        : Running (http://localhost:3000)
✅ Prometheus     : Running (http://localhost:9090)
✅ Loki           : Running (http://localhost:3100/metrics)
✅ Blackbox Export: Running (http://localhost:9115)
✅ Node Exporter  : Running (http://localhost:9100)
✅ kube-state-metrics: Running (http://localhost:8080)
```

## 📊 Features

### ✅ Production Ready Features
- **Persistent Storage** for Grafana (survives restarts)
- **RBAC Configuration** for Kubernetes access
- **Resource Limits** and requests configured
- **Health Checks** and monitoring endpoints
- **Service Discovery** for dynamic targets
- **Comprehensive Logging** with proper labels

### 🔐 Security Features
- Kubernetes RBAC for service accounts
- Secret management for external services
- Network policies ready (optional)
- Non-root container execution where applicable

### 📈 Monitoring Capabilities
- **Infrastructure**: CPU, Memory, Disk, Network
- **Kubernetes**: Pods, Services, Deployments, Nodes
- **Application**: Custom metrics endpoints
- **External**: Website/API uptime monitoring
- **Logs**: Container logs with filtering and search

## 🗑️ Uninstallation

```bash
# Uninstall the release
helm uninstall my-observability-stack

# Clean up persistent data (optional)
kubectl delete pvc grafana-pvc -n kube-observability-stack

# Remove namespace (if no other resources)
kubectl delete namespace kube-observability-stack
```

## 🔧 Troubleshooting

### Common Issues

1. **Services not accessible**: Check port forwarding with `./check-services.sh`
2. **Pods not starting**: Check resource limits with `kubectl describe pod <pod-name>`
3. **Storage issues**: Verify PVC with `kubectl get pvc -n kube-observability-stack`
4. **Permission errors**: Check RBAC with `kubectl get clusterrolebinding`

### Support Commands

```bash
# Check Helm release
helm list

# Get release notes
helm get notes my-observability-stack

# Get full manifest
helm get manifest my-observability-stack

# Debug template rendering
helm template my-observability-stack ./kube-observability-stack-1.0.0.tgz --debug
```

## 📚 Next Steps

1. **Create Custom Dashboards** in Grafana
2. **Set up Alerts** in Prometheus/Grafana
3. **Configure External Services** (Jenkins, Redis, Databases)
4. **Add Custom Metrics** from your applications
5. **Set up Log Queries** in Loki for troubleshooting

## 🏷️ Package Tags

- observability, monitoring, prometheus, grafana, loki
- kubernetes, exporters, test-automation, enterprise
- helm-chart, cloud-native, devops, sre

---

**Package Created**: August 2025  
**Compatibility**: Kubernetes 1.19+, Helm 3.0+  
**License**: Open Source  
**Support**: Community driven