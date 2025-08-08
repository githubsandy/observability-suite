# CXTM Lab - Prometheus & Grafana Monitoring Setup

This repository contains Kubernetes manifests to deploy Prometheus and Grafana for monitoring your CXTM lab environment. This comprehensive guide covers everything from quick deployment to advanced troubleshooting.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Connection Management Scripts](#connection-management-scripts)
3. [Prerequisites](#prerequisites)
4. [Architecture Overview](#architecture-overview)
5. [Deployment Options](#deployment-options)
6. [Access Methods & SSH Tunneling](#access-methods--ssh-tunneling)
7. [Verification & Testing](#verification--testing)
8. [Configuration Tuning](#configuration-tuning)
9. [Troubleshooting](#troubleshooting)
10. [Performance Optimization](#performance-optimization)

---

## Quick Start

### 1. Copy files to your CXTM lab instance
```bash
# Set correct permissions on SSH key
chmod 600 /path/to/id_rsa_nightly

# Copy all deployment files to the correct directory
scp -i /path/to/id_rsa_nightly *.yaml *.sh cloud-user@10.123.230.40:~/
ssh -i /path/to/id_rsa_nightly cloud-user@10.123.230.40 "mkdir -p /home/cloud-user/skumark5/grafana-cxtm-poc && mv *.yaml *.sh /home/cloud-user/skumark5/grafana-cxtm-poc/"
```

### 2. SSH into your CXTM lab and deploy
```bash
ssh -i /path/to/id_rsa_nightly cloud-user@10.123.230.40
cd /home/cloud-user/skumark5/grafana-cxtm-poc
chmod +x deploy.sh
./deploy.sh
```

### 3. Access applications via SSH tunnel
```bash
# Step 1: Start port forwarding on CXTM server (run on server)
ssh -i /path/to/id_rsa_nightly cloud-user@10.123.230.40
kubectl port-forward svc/grafana 3000:3000 --address 127.0.0.1 &
kubectl port-forward svc/prometheus 9090:9090 --address 127.0.0.1 &

# Step 2: Create SSH tunnel from your local machine
ssh -i /path/to/id_rsa_nightly -L 3000:localhost:3000 cloud-user@10.123.230.40 -N &
ssh -i /path/to/id_rsa_nightly -L 9090:localhost:9090 cloud-user@10.123.230.40 -N &

# Step 3: Access via browser
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin123)
```

---

## Connection Management Scripts

Once deployed, you can use these intelligent scripts to manage your monitoring connections. These scripts automatically detect what's already working and only fix what's broken.

### 🔍 check-status.sh - Quick Status Check

Shows the current state of all connections without making any changes:

```bash
./check-status.sh
```

**Sample Output:**
```
📊 CXTM Monitoring Status Check
===============================

🖥️  Local SSH Tunnels:
   ✅ Port 3000: Active (PID: 88822)
   ❌ Port 9090: Not active

🌐 Remote Port Forwarding:
   ✅ kubectl port-forward processes found

🧪 Connectivity Tests:
   ✅ Grafana: Accessible (HTTP 302)
   ❌ Prometheus: Not accessible (HTTP 000)
```

### 🔄 reconnect.sh - Intelligent Reconnect

Automatically detects and fixes connection issues. Only creates connections that are missing:

```bash
./reconnect.sh
```

**Features:**
- ✅ **Smart Detection**: Only fixes what's broken, leaves working connections alone
- ✅ **Progress Reporting**: Clear status messages for each step
- ✅ **Verification**: Tests connectivity after establishing connections
- ✅ **Non-Disruptive**: Won't interrupt existing working tunnels

**Sample Output:**
```
🔍 CXTM Monitoring Connection Manager
======================================

📊 Current Status Check
----------------------
✅ Remote port forwarding for Grafana is active
❌ Remote port forwarding for Prometheus is not active
✅ Local SSH tunnel for Grafana is active
❌ Local SSH tunnel for Prometheus is not active

🔧 Connection Management
-----------------------
🚀 Starting remote port forwarding for Prometheus...
✅ Remote port forwarding for Prometheus started successfully
🚀 Starting SSH tunnel for Prometheus...
✅ SSH tunnel for Prometheus started successfully
```

### 🧹 cleanup.sh - Clean Disconnect

Safely terminates all monitoring connections:

```bash
./cleanup.sh
```

**Features:**
- 🔌 Terminates all local SSH tunnels
- 🌐 Stops all remote port forwarding
- 🔍 Verifies cleanup completed
- 📊 Shows post-cleanup status

### 🎯 Usage Examples

```bash
# Daily workflow - check status first
./check-status.sh

# If connections are broken, smart reconnect
./reconnect.sh

# When done for the day, clean disconnect
./cleanup.sh

# Quick check if services are accessible
curl -I http://localhost:3000  # Should return 302
curl -I http://localhost:9090  # Should return 200 or 405
```

### ⚡ Quick Reference

| Script | Purpose | Safe to Run Anytime |
|--------|---------|---------------------|
| `check-status.sh` | Show current status | ✅ Yes (read-only) |
| `reconnect.sh` | Fix broken connections | ✅ Yes (non-disruptive) |
| `cleanup.sh` | Disconnect everything | ⚠️ No (terminates access) |

---

## Prerequisites

### Local Machine Requirements
- SSH client with SCP support
- Private key file (`id_rsa_nightly`) with proper permissions (chmod 600)
- Network access to CXTM lab instance (10.123.230.40)

### CXTM Lab Instance Requirements
- Kubernetes cluster running
- kubectl configured and accessible
- Cloud-user account with cluster access
- Network access to internet for image pulls

### Verification Commands
```bash
# Test SSH connectivity and cluster access
ssh -i /path/to/id_rsa_nightly cloud-user@10.123.230.40 "kubectl version --short"
ssh -i /path/to/id_rsa_nightly cloud-user@10.123.230.40 "kubectl cluster-info"
```

---

## Architecture Overview

### Components Overview
```
┌─────────────────────────────────────────────┐
│               CXTM Lab Cluster              │
├─────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────────────┐│
│  │ Prometheus  │  │     Node Exporter       ││
│  │   :9090     │  │      (DaemonSet)        ││
│  │ NodePort    │  │       :9100             ││
│  │   :30090    │  └─────────────────────────┘│
│  └─────────────┘                            │
│                                              │
│  ┌─────────────┐  ┌─────────────────────────┐│
│  │   Grafana   │  │    ConfigMaps           ││
│  │   :3000     │  │  - prometheus-config    ││
│  │ NodePort    │  │  - grafana-config       ││
│  │   :30300    │  │  - grafana-datasources  ││
│  └─────────────┘  └─────────────────────────┘│
│                                              │
│  External Access via SSH Tunnel:            │
│  Local:3000 → SSH → Server → kubectl → K8s  │
└─────────────────────────────────────────────┘
```

### Network Flow
- **External Access**: Local → SSH Tunnel → kubectl port-forward → Services
- **Internal Communication**: Grafana → Prometheus:9090 (pre-configured datasource)
- **Metrics Collection**: Prometheus → Node Exporter:9100 (each node)
- **Service Discovery**: Prometheus auto-discovers Kubernetes nodes and pods

### Default Configuration
- **Prometheus**: Scrapes metrics every 15 seconds, RBAC configured for Kubernetes discovery
- **Grafana**: Pre-configured with Prometheus as datasource (admin/admin123)
- **Node Exporter**: Runs on all nodes as DaemonSet, collects system metrics
- **Storage**: EmptyDir volumes (non-persistent, suitable for POC)
- **Resources**: Minimal requests suitable for lab environment

---

## Deployment Options

### Option 1: Automated Deployment (Recommended)
```bash
cd /home/cloud-user/skumark5/grafana-cxtm-poc
./deploy.sh

# Monitor deployment progress
kubectl get pods -w
```

### Option 2: Manual Step-by-Step Deployment

#### Phase 1: Configuration Deployment
```bash
# Apply Prometheus configuration
kubectl apply -f prometheus-config.yaml
kubectl get configmap prometheus-config -o yaml

# Apply Grafana configurations  
kubectl apply -f grafana-config.yaml
kubectl get configmap grafana-config grafana-datasources
```

#### Phase 2: Service Deployment
```bash
# Deploy Prometheus
kubectl apply -f prometheus-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/prometheus

# Deploy Node Exporter
kubectl apply -f node-exporter.yaml
kubectl wait --for=condition=ready --timeout=300s pod -l app=node-exporter

# Deploy Grafana
kubectl apply -f grafana-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/grafana
```

#### Phase 3: Verification
```bash
kubectl get svc prometheus node-exporter grafana
kubectl get pods | grep -E "(prometheus|grafana|node-exporter)"
kubectl get nodes -o wide
```

---

## Access Methods & SSH Tunneling

### Why SSH Tunneling is Required

**🔒 Network Security**: The Kubernetes cluster nodes (192.168.100.x IPs) are on an internal network that's not directly accessible from external machines. NodePort services (30090, 30300) only work if you're on the same network as the cluster nodes.

**🚧 Corporate Security**: Corporate networks typically block direct access to high-numbered ports (30000+) for security reasons, even if the IPs were reachable. Firewalls and security policies prevent exposing cluster services directly.

**🔐 SSH as Secure Tunnel**: SSH provides an encrypted tunnel through the bastion host (10.123.230.40) to reach internal services securely, following security best practices.

### Two-Step Access Process Explained

**Why Two Steps (Port Forward + SSH Tunnel)?**
- **Step 1**: `kubectl port-forward` makes Kubernetes services available on the CXTM server's localhost
- **Step 2**: SSH tunnel forwards from your local machine to the CXTM server's localhost
- **Result**: This creates a secure chain: `Your Machine` → `SSH Tunnel` → `CXTM Server` → `kubectl port-forward` → `Kubernetes Service`

### Direct NodePort Access (Internal Network Only)
⚠️ **Note**: Only works if your machine is on the same internal network (192.168.100.x)

```bash
# Get node IP addresses
kubectl get nodes -o wide

# Access URLs (replace NODE_IP with actual IP)
# Prometheus: http://NODE_IP:30090
# Grafana: http://NODE_IP:30300
```

### External Access via SSH Tunneling (Required for most users)

#### Step 1: Start Port Forwarding on CXTM Server
```bash
# SSH into CXTM server
ssh -i /path/to/id_rsa_nightly cloud-user@10.123.230.40

# Start port forwarding in background
nohup kubectl port-forward svc/grafana 3000:3000 --address 127.0.0.1 > grafana.log 2>&1 &
nohup kubectl port-forward svc/prometheus 9090:9090 --address 127.0.0.1 > prometheus.log 2>&1 &

# Verify port forwarding is active
netstat -tulpn | grep -E ":3000|:9090"
```

#### Step 2: Create SSH Tunnel from Local Machine
```bash
# Create SSH tunnel for Grafana (run from your local machine)
ssh -i /path/to/id_rsa_nightly -L 3000:localhost:3000 cloud-user@10.123.230.40 -N &

# Create SSH tunnel for Prometheus (run from your local machine)
ssh -i /path/to/id_rsa_nightly -L 9090:localhost:9090 cloud-user@10.123.230.40 -N &

# Verify tunnels are active
lsof -i :3000
lsof -i :9090
```

#### Step 3: Access Applications
```bash
# Test connections
curl -s -o /dev/null -w '%{http_code}' http://localhost:3000  # Should return 302
curl -s -o /dev/null -w '%{http_code}' http://localhost:9090  # Should return 200

# Access URLs in browser
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin123)
```

#### SSH Tunnel Troubleshooting
```bash
# Kill existing tunnels if needed
pkill -f "ssh.*-L.*3000"
pkill -f "ssh.*-L.*9090"

# Kill port forwarding on server
ssh -i /path/to/id_rsa_nightly cloud-user@10.123.230.40 "pkill -f 'kubectl port-forward'"

# Check what's using ports locally
lsof -i :3000
lsof -i :9090
```

---

## Verification & Testing

### Component Health Checks

#### Prometheus Health
```bash
# Check Prometheus pod status
kubectl get pods -l app=prometheus
kubectl logs -l app=prometheus --tail=50

# Check Prometheus configuration
kubectl exec -it deployment/prometheus -- cat /etc/prometheus/prometheus.yml

# Test Prometheus API
kubectl exec -it deployment/prometheus -- wget -qO- http://localhost:9090/api/v1/status/config
```

#### Node Exporter Health
```bash
# Verify Node Exporter on all nodes
kubectl get pods -l app=node-exporter -o wide
kubectl logs -l app=node-exporter --tail=20

# Test Node Exporter metrics endpoint
kubectl exec -it deployment/prometheus -- wget -qO- http://node-exporter:9100/metrics | head -20
```

#### Grafana Health
```bash
# Check Grafana pod status
kubectl get pods -l app=grafana
kubectl logs -l app=grafana --tail=50

# Test Grafana API
kubectl exec -it deployment/grafana -- wget -qO- http://localhost:3000/api/health
```

### Metrics Validation

#### Prometheus Targets
Access Prometheus web UI: http://localhost:9090/targets
Verify all targets are "UP":
- prometheus (1/1 up)
- kubernetes-apiservers (1/1 up)
- kubernetes-nodes (X/X up)
- node-exporter (X/X up)

#### Sample Queries (test in Prometheus UI)
```bash
# Basic connectivity
up

# Node metrics
node_memory_MemTotal_bytes
node_filesystem_size_bytes
rate(node_cpu_seconds_total[5m])

# Kubernetes metrics
kube_pod_status_phase
kube_deployment_status_replicas

# Prometheus internal metrics
prometheus_tsdb_head_samples_appended_total
```

#### Grafana Data Source Verification
1. Login to Grafana (admin/admin123)
2. Navigate to: Connections → Data Sources
3. Verify Prometheus data source shows "Data source is working"
4. Test dashboard queries:
```bash
# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage percentage
100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100)

# Network traffic
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

---

## Configuration Tuning

### Prometheus Configuration Tuning

#### Scrape Interval Optimization
```yaml
# prometheus-config.yaml adjustments
global:
  scrape_interval: 15s      # Default: Good for lab
  # scrape_interval: 5s     # High-frequency monitoring
  # scrape_interval: 30s    # Resource-constrained environments
  evaluation_interval: 15s
```

#### Memory and CPU Tuning
```yaml
# prometheus-deployment.yaml resource adjustments
resources:
  limits:
    cpu: 1000m              # Increase for heavy workloads
    memory: 1Gi             # Increase for longer retention
  requests:
    cpu: 500m               # Minimum guaranteed
    memory: 512Mi           # Minimum guaranteed
```

#### Storage Retention Tuning
```yaml
# prometheus-deployment.yaml container args
args:
  - '--storage.tsdb.retention.time=7d'    # Extended retention
  - '--storage.tsdb.retention.size=5GB'   # Size-based retention
```

### Grafana Configuration Tuning

#### Performance Settings
```ini
# grafana-config.yaml - grafana.ini section
[server]
http_port = 3000
root_url = http://localhost:3000

[database]
type = sqlite3
path = grafana.db

[session]
provider = memory

[analytics]
reporting_enabled = false
check_for_updates = false
```

#### Security Hardening
```ini
[security]
admin_user = admin
admin_password = admin123          # Change in production!
secret_key = SW2YcwTIb9zpOOhoPsMm   # Generate unique key
disable_gravatar = true
```

### Node Exporter Tuning

#### Resource Constraints
```yaml
# node-exporter.yaml resource tuning
resources:
  limits:
    cpu: 250m       # Sufficient for most environments
    memory: 180Mi   # Memory footprint is typically low
  requests:
    cpu: 102m       # Minimal CPU guarantee
    memory: 180Mi   # Memory guarantee
```

#### Collector Configuration
```yaml
# Additional collectors (add to args in node-exporter.yaml)
args:
- --collector.systemd              # SystemD service metrics
- --collector.processes            # Process metrics
- --collector.tcpstat              # TCP connection metrics
- --no-collector.hwmon             # Disable hardware monitoring
```

---

## Troubleshooting

### Common Issues and Solutions

#### Pods Not Starting
```bash
# Symptom: Pods stuck in Pending/CrashLoopBackOff
kubectl get pods -l app=prometheus
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Common causes and fixes:
# 1. Resource constraints
kubectl top nodes
kubectl describe node <node-name>

# 2. Image pull issues
kubectl describe pod <pod-name> | grep -i image

# 3. Configuration errors
kubectl get configmap prometheus-config -o yaml
```

#### Services Not Accessible
```bash
# Check service endpoints
kubectl get endpoints prometheus grafana node-exporter

# Check service configuration
kubectl describe svc prometheus grafana

# Test internal connectivity
kubectl exec -it deployment/prometheus -- nslookup grafana
kubectl exec -it deployment/grafana -- wget -T5 http://prometheus:9090/api/v1/status/config
```

#### Prometheus Not Scraping Targets
```bash
# Check RBAC permissions
kubectl get clusterrolebinding prometheus
kubectl describe clusterrolebinding prometheus

# Check service discovery
kubectl get endpoints --all-namespaces
kubectl logs -l app=prometheus | grep -i "discovery\|scrape\|error"

# Verify target configuration
kubectl exec -it deployment/prometheus -- cat /etc/prometheus/prometheus.yml
```

#### SSH Tunnel Connection Issues
```bash
# Check SSH key permissions
ls -la /path/to/id_rsa_nightly  # Should be 600

# Test SSH connectivity
ssh -i /path/to/id_rsa_nightly cloud-user@10.123.230.40 "echo 'SSH working'"

# Check port conflicts
lsof -i :3000
lsof -i :9090

# Kill conflicting processes
pkill -f "port-forward"
pkill -f "ssh.*-L"
```

#### High Memory Usage
```bash
# Check resource consumption
kubectl top pods
kubectl describe pod <pod-name>

# Prometheus specific
kubectl exec -it deployment/prometheus -- wget -qO- http://localhost:9090/api/v1/status/tsdb

# Solutions:
# 1. Reduce retention time in prometheus-deployment.yaml
# 2. Increase scrape intervals in prometheus-config.yaml
# 3. Add resource limits
```

### Network Connectivity Issues

#### NodePort Access Problems
```bash
# Verify NodePort services
kubectl get svc -o wide | grep NodePort

# Check node firewall/security groups
kubectl get nodes -o wide
# Verify ports 30090, 30300 are accessible

# Test from within cluster
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl http://<NODE_IP>:30090/api/v1/status/config
```

#### DNS Resolution Issues
```bash
# Test DNS resolution
kubectl exec -it deployment/prometheus -- nslookup kubernetes.default.svc.cluster.local
kubectl exec -it deployment/grafana -- nslookup prometheus.default.svc.cluster.local

# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

---

## Performance Optimization

### Resource Optimization

#### Prometheus Optimization
```yaml
# Optimized prometheus-deployment.yaml
spec:
  template:
    spec:
      containers:
      - name: prometheus
        resources:
          limits:
            cpu: 2000m
            memory: 4Gi
          requests:
            cpu: 1000m
            memory: 2Gi
        args:
          - '--storage.tsdb.retention.time=15d'
          - '--storage.tsdb.retention.size=10GB'
          - '--query.max-concurrency=50'
          - '--query.timeout=2m'
```

### Monitoring Best Practices

#### Query Optimization
```yaml
# Use recording rules for expensive queries
# Create prometheus-rules.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
data:
  rules.yml: |
    groups:
    - name: node_recording_rules
      interval: 30s
      rules:
      - record: node:memory_utilization:ratio
        expr: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
      - record: node:disk_utilization:ratio  
        expr: (1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})
```

### Maintenance Procedures

#### Regular Maintenance Tasks
```bash
# Weekly maintenance script
#!/bin/bash

# 1. Check resource usage
kubectl top nodes
kubectl top pods

# 2. Verify all targets are up
kubectl exec -it deployment/prometheus -- wget -qO- http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'

# 3. Check for pod restarts
kubectl get pods --all-namespaces --field-selector=status.phase!=Running

# 4. Cleanup old data (if needed)
kubectl exec -it deployment/prometheus -- wget -qO- --method=POST http://localhost:9090/api/v1/admin/tsdb/clean_tombstones

# 5. Backup configuration
kubectl get configmap -o yaml > backup-configmaps-$(date +%Y%m%d).yaml
```

---

## Security Considerations

### Access Control
```bash
# Limit Prometheus RBAC permissions
kubectl edit clusterrole prometheus

# Change default Grafana credentials
kubectl patch configmap grafana-config --patch='{"data":{"grafana.ini":"[security]\nadmin_password = NewSecurePassword123"}}'
kubectl rollout restart deployment/grafana
```

### Network Security
```bash
# Use NetworkPolicies to restrict traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: monitoring-network-policy
spec:
  podSelector:
    matchLabels:
      app: prometheus
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: grafana
    ports:
    - protocol: TCP
      port: 9090
```

---

## Quick Reference

### Key Commands
```bash
# Deployment
./deploy.sh

# Connection Management (Recommended)
./check-status.sh                  # Check connection status
./reconnect.sh                     # Intelligent reconnect  
./cleanup.sh                       # Clean disconnect

# Manual Commands (Advanced)
kubectl get pods,svc | grep -E "(prometheus|grafana|node-exporter)"
kubectl port-forward svc/grafana 3000:3000 --address 127.0.0.1 &
ssh -i /path/to/id_rsa_nightly -L 3000:localhost:3000 cloud-user@10.123.230.40 -N &
pkill -f "kubectl port-forward"
pkill -f "ssh.*-L"
```

### Access URLs
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin123)

### File Locations
- **Local**: `/Users/skumark5/Documents/grafana-cxtm-poc`
- **Nightly**: `/home/cloud-user/skumark5/grafana-cxtm-poc`

---

*This comprehensive guide covers everything from basic deployment to advanced troubleshooting. For additional help or to contribute improvements, refer to the project repository.*