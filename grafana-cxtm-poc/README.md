
## 📊 Current Deployment Status

### **Complete Monitoring Stack:**
- **Namespace:** `ao`
- **Node:** `uta-k8s-ao-01`
- **Components:** Grafana + Prometheus + **Loki (NEW)**

### **Grafana Configuration:**
- **Service Type:** `NodePort`
- **Internal Port:** `3000`
- **NodePort:** `30300`
- **Data Sources:** Prometheus (http://prometheus:9090)

### **Prometheus Configuration:**
- **Service Type:** `NodePort`
- **Internal Port:** `9090`
- **NodePort:** `30090`
- **Monitoring:** Kubernetes cluster, pods, services, nodes

### **Loki Configuration (NEW - Log Aggregation):**
- **Service Type:** `NodePort`
- **Internal Port:** `3100` (HTTP), `9096` (gRPC)
- **NodePort:** `30310`
- **Storage:** 20GB Longhorn PVC (`loki-storage`)
- **Retention:** 7 days (configurable)
- **Log Collection:** Promtail DaemonSet (all nodes)

### **Access URLs:**
- **Grafana Direct:** `http://10.122.28.111:30300`
- **Prometheus Direct:** `http://10.122.28.111:30090`
- **Loki Direct:** `http://10.122.28.111:30310` (API endpoint)
- **Grafana Tunneled:** `http://localhost:3000`

### **Login Credentials:**
- **Grafana Username:** `admin`
- **Grafana Password:** `admin123`
- **Prometheus:** No authentication required

---

## 🛠️ Management Commands

### **Deploy Complete Monitoring Stack:**
```bash
# Deploy Grafana and Prometheus (existing)
./deploy-complete-monitoring.sh

# Deploy Loki Log Aggregation (NEW)
cd ../loki-caloLab-logging-poc
kubectl apply -f loki-deployment.yaml
kubectl apply -f promtail-deployment.yaml
```

### **Check Full Stack Status:**
```bash
kubectl get pods,svc -n ao
kubectl get all -n ao
```

### **Grafana Management:**
```bash
# Check Grafana status
kubectl get pods,svc -n ao | grep grafana
kubectl logs -n ao deployment/grafana --tail=20

# Restart Grafana
kubectl rollout restart deployment/grafana -n ao
kubectl rollout status deployment/grafana -n ao
```

### **Prometheus Management:**
```bash
# Check Prometheus status
kubectl get pods,svc -n ao | grep prometheus
kubectl logs -n ao deployment/prometheus --tail=20

# Restart Prometheus
kubectl rollout restart deployment/prometheus -n ao
kubectl rollout status deployment/prometheus -n ao
```

### **Loki Management (NEW):**
```bash
# Check Loki status
kubectl get pods,svc,pvc -n ao | grep loki
kubectl logs -n ao deployment/loki --tail=20

# Check Promtail DaemonSet
kubectl get daemonset promtail -n ao
kubectl logs -n ao daemonset/promtail --tail=20

# Restart Loki
kubectl rollout restart deployment/loki -n ao
kubectl rollout status deployment/loki -n ao

# Restart Promtail (log collector)
kubectl rollout restart daemonset/promtail -n ao

# Test Loki API
curl http://10.122.28.111:30310/ready
curl http://10.122.28.111:30310/metrics
```

### **Update Configuration:**
```bash
# After editing config files locally
scp grafana-config.yaml administrator@10.122.28.111:/home/administrator/skumark5/grafana-cxtm-poc/
scp prometheus-deployment.yaml administrator@10.122.28.111:/home/administrator/skumark5/grafana-cxtm-poc/
kubectl apply -f grafana-config.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl rollout restart deployment/grafana -n ao
kubectl rollout restart deployment/prometheus -n ao
```

---

## 🔍 Quick Health Checks

### **Grafana Health Tests:**
```bash
# Direct access test
curl -I http://10.122.28.111:30300
# Expected: HTTP/1.1 302 Found

# Service test
kubectl get svc grafana -n ao
# Expected: Shows NodePort 30300

# Pod health test
kubectl get pods -n ao | grep grafana
# Expected: 1/1 Running
```

### **Prometheus Health Tests:**
```bash
# Direct access test
curl -I http://10.122.28.111:30090
# Expected: HTTP/1.1 200 OK

# Service test
kubectl get svc prometheus -n ao
# Expected: Shows NodePort 30090

# Pod health test
kubectl get pods -n ao | grep prometheus
# Expected: 1/1 Running

# Metrics endpoint test
curl http://10.122.28.111:30090/metrics | head -5
# Expected: Prometheus metrics output
```

### **Loki Health Tests (NEW):**
```bash
# Direct access test
curl -I http://10.122.28.111:30310/ready
# Expected: HTTP/1.1 200 OK

# Service test
kubectl get svc loki -n ao
# Expected: Shows NodePort 30310

# Pod health test  
kubectl get pods -n ao | grep loki
# Expected: 1/1 Running

# Storage test
kubectl get pvc loki-storage -n ao
# Expected: Bound status, 20Gi size

# Log ingestion test
curl -G -s "http://10.122.28.111:30310/loki/api/v1/query" --data-urlencode 'query={container_name=~".*"}' | head -5
# Expected: JSON response with log entries
```

### **Complete Stack Test:**
```bash
kubectl get all -n ao
# Expected: grafana, prometheus, loki, and promtail resources running
```

---

## 📊 Dashboard Management

### **Available Prebuilt Dashboards:**
```bash
ls dashboards/
# Available dashboards:
#   - kubernetes-cluster-monitoring.json    (Kubernetes cluster overview)
#   - kubernetes-pods.json                  (Kubernetes pods monitoring)
#   - kubernetes-deployment.json            (Kubernetes deployments)  
#   - node-exporter.json                    (Node Exporter metrics)
#   - blackbox-exporter.json                (Blackbox Exporter monitoring)
#   - loki-dashboard.json                   (Loki logs dashboard)
#   - prometheus-stats.json                 (Prometheus statistics)
```

### **Import Dashboards:**
1. **Access Grafana:** `http://10.122.28.111:30300/`
2. **Login:** admin/admin123
3. **Navigate:** Dashboards → Import
4. **Upload:** Select JSON file from `dashboards/` folder
5. **Configure:** Select "Prometheus" as data source
6. **Import:** Click Import button

### **Verify Data Sources:**
```bash
# Check if Prometheus data source is configured in Grafana
curl -u admin:admin123 http://10.122.28.111:30300/api/datasources
# Expected: Shows Prometheus data source with URL http://prometheus:9090

# Add Loki data source via Grafana UI:
# 1. Go to Configuration → Data Sources
# 2. Click "Add data source" → Select "Loki"  
# 3. Set URL: http://loki:3100
# 4. Click "Save & Test"
```

### **Dashboard Import via API:**
```bash
# Example: Import Kubernetes cluster dashboard
curl -X POST \
  -H "Content-Type: application/json" \
  -u admin:admin123 \
  -d @dashboards/kubernetes-cluster-monitoring.json \
  http://10.122.28.111:30300/api/dashboards/db
```

---

## 📋 CXTAF Log Monitoring with Loki (NEW)

### **🎯 CXTAF Log Queries (Use in Grafana Explore)**

**1. All CXTAF Application Logs:**
```logql
{container_name=~"cxtaf.*"}
```

**2. CXTAF Error Logs Only:**
```logql
{container_name=~"cxtaf.*"} |= "ERROR"
```

**3. CXTAF Logs by Component:**
```logql
{container_name=~"cxtaf.*", cxtaf_component="scheduler"}
```

**4. Recent Critical Issues (Last 1 hour):**
```logql
{container_name=~"cxtaf.*"} |= "ERROR" [1h]
```

**5. Log Rate by CXTAF Component:**
```logql
rate({container_name=~"cxtaf.*"}[5m]) by (cxtaf_component)
```

### **🔍 CXTM Legacy System Logs:**

**1. All CXTM Application Logs:**
```logql
{namespace="cxtm"}
```

**2. CXTM Migration Service Logs:**
```logql
{namespace="cxtm", cxtm_app="migrate"}
```

**3. CXTM Database Connection Issues:**
```logql
{namespace="cxtm"} |= "database" |= "ERROR"
```

### **🏗️ Infrastructure & Observability Logs:**

**1. Observability Stack Logs:**
```logql
{namespace="ao"}
```

**2. Kubernetes System Logs:**
```logql
{job="system-logs"}
```

**3. All Error Logs Across Environment:**
```logql
{container_name=~".*"} |= "ERROR"
```

### **📈 Log Analytics Queries:**

**1. Error Rate by Application:**
```logql
sum by (container_name) (rate({container_name=~".*"} |= "ERROR" [5m]))
```

**2. Log Volume by Namespace:**
```logql
sum by (namespace) (rate({namespace=~".*"}[5m]))
```

**3. Top 10 Most Active Pods:**
```logql
topk(10, sum by (pod_name) (rate({pod_name=~".*"}[5m])))
```

### **🚨 Alerting Queries (for Setting up Alerts):**

**1. High Error Rate Alert:**
```logql
sum by (container_name) (rate({container_name=~"cxtaf.*"} |= "ERROR" [5m])) > 0.1
```

**2. CXTAF Component Down:**
```logql
absent(rate({container_name=~"cxtaf.*"}[5m]))
```

**3. Database Connection Failures:**
```logql
sum(rate({container_name=~"cxtaf.*|cxtm.*"} |= "database" |= "ERROR" [5m])) > 0
```

---

# Monitoring Stack Access Methods - CXTM AO Environment

This guide covers access methods for the complete monitoring stack (Grafana + Prometheus + **Loki**) deployed in the `ao` namespace on the CXTM Kubernetes cluster.

## 📋 Quick Summary

| Service | Direct NodePort | SSH Tunneling | Complexity | Use Case |
|---------|----------------|---------------|------------|----------|
| **Grafana** | `http://10.122.28.111:30300` | `http://localhost:3000` | Simple/Complex | Dashboard visualization |
| **Prometheus** | `http://10.122.28.111:30090` | `http://localhost:9090` | Simple/Complex | Metrics and monitoring |
| **Loki** | `http://10.122.28.111:30310` | *Via Grafana* | Simple | Log aggregation & search |

### **Access Method Comparison:**
| Method | Complexity | Stability | Use Case |
|--------|------------|-----------|----------|
| **Direct NodePort** | Simple | High | Recommended for stable network access |
| **SSH Tunneling** | Complex | Medium | Required for restricted networks |

---

## 🌐 Method 1: Direct NodePort Access (Recommended)

### ✅ When to Use
- You have direct network access to `10.122.28.111`
- Your network/firewall allows port `30300`
- You want the simplest, most stable connection
- Working from a consistent network location

### 🚀 How to Access

**Simply open your browser and go to:**
```
http://10.122.28.111:30300
```

**Login credentials:**
- Username: `admin`
- Password: `admin123`

### ✅ Advantages
- **Simple**: No additional setup required
- **Stable**: No connection timeouts or broken pipes
- **Fast**: Direct connection to the service
- **Always available**: Works as long as the service is running

### ❌ Disadvantages
- **Network dependent**: Only works if you can reach the IP directly
- **Security**: Service exposed on node IP (less secure than tunneling)
- **Location specific**: May not work from different networks

### 🔧 Troubleshooting Direct Access

**Test connectivity:**
```bash
# Test if you can reach the server
ping 10.122.28.111

# Test if the port is accessible
curl -I http://10.122.28.111:30300
```

**Expected response:**
```
HTTP/1.1 302 Found
Location: /login
```

---

## 🔐 Method 2: SSH Tunneling/Port Forwarding

### ✅ When to Use
- Direct access to `10.122.28.111:30300` is blocked by firewall
- Working from different networks (home, office, travel)
- Security policies require bastion host access
- Corporate network blocks high-numbered ports

### 🚀 How to Setup

#### **Step 1: SSH to Remote Machine**
```bash
ssh administrator@10.122.28.111
```
*Password: `C1sco123=`*

#### **Step 2: Start Port Forwarding (Remote Machine)**
```bash
cd /home/administrator/skumark5/grafana-cxtm-poc
kubectl port-forward svc/grafana 3000:3000 -n ao --address 0.0.0.0
```
*Keep this terminal open*

#### **Step 3: Create SSH Tunnel (Local Machine)**
```bash
# Open new terminal on your local machine
ssh -L 3000:localhost:3000 administrator@10.122.28.111 -N
```
*Password: `C1sco123=`*
*Keep this terminal open*

#### **Step 4: Access Grafana**
**Open browser:** `http://localhost:3000`

### ✅ Advantages
- **Secure**: Traffic encrypted through SSH tunnel
- **Network flexible**: Works from any network that can SSH to the bastion
- **Firewall friendly**: Uses standard SSH port (22)

### ❌ Disadvantages
- **Complex setup**: Requires two terminal sessions
- **Connection stability**: Can timeout or break
- **Resource intensive**: Multiple processes running
- **Maintenance**: Need to restart if connections drop

### 🔧 Troubleshooting SSH Tunneling

#### **Check Local SSH Tunnel:**
```bash
lsof -i :3000
# Should show ssh process listening
```

#### **Check Remote Port Forward:**
```bash
# On remote machine
ps aux | grep "kubectl port-forward"
lsof -i :3000
```

#### **Common Issues:**

**1. "Connection refused" on localhost:3000**
- Remote port-forward is not running
- SSH tunnel is not established

**2. "Timeout errors" in kubectl port-forward**
- Network latency too high
- Try adding timeout: `--pod-running-timeout=5m`

**3. Browser shows "Loading Grafana" forever**
- JavaScript files timing out
- Try direct NodePort method instead

#### **Reset All Connections:**
```bash
# Kill local SSH tunnel
pkill -f 'ssh.*-L.*3000'

# Kill remote port-forward (on remote machine)
pkill -f "kubectl port-forward"

# Start fresh (follow steps 1-4 above)
```

---

## 🎯 Decision Matrix

### Use **Direct NodePort** if:
- ✅ `ping 10.122.28.111` works
- ✅ `curl -I http://10.122.28.111:30300` returns HTTP 302
- ✅ You work from a stable network location
- ✅ No corporate firewall restrictions

### Use **SSH Tunneling** if:
- ❌ Direct access is blocked by firewall
- ❌ Working from multiple network locations
- ❌ Security policies require bastion access
- ❌ Port 30300 is blocked but SSH (22) works

---

## 📁 Key Configuration Files

### **grafana-deployment.yaml**
Main Grafana deployment configuration for the `ao` namespace.

**Key settings:**
```yaml
# Deployment targeting AO node
nodeSelector:
  kubernetes.io/hostname: uta-k8s-ao-01

# NodePort service for direct access
spec:
  type: NodePort
  ports:
    - port: 3000
      targetPort: 3000
      nodePort: 30300

# Resource allocation
resources:
  limits:
    memory: "512Mi"
    cpu: "500m"
  requests:
    memory: "256Mi"
    cpu: "200m"
```

**To modify:**
1. Edit the file locally
2. Copy to remote: `scp grafana-deployment.yaml administrator@10.122.28.111:/home/administrator/skumark5/grafana-cxtm-poc/`
3. Apply: `kubectl apply -f grafana-deployment.yaml`
4. Restart: `kubectl rollout restart deployment/grafana -n ao`

### **grafana-config.yaml**
Contains ConfigMaps for Grafana configuration and data sources.

**Structure:**
```yaml
# Main Grafana configuration
grafana-config:
  grafana.ini: |
    [security]
    admin_user = admin
    admin_password = admin123
    
# Data sources (currently empty - cleaned up)
grafana-datasources:
  datasources.yaml: |-
    {
        "apiVersion": 1,
        "datasources": []
    }
```

**To add data sources:**
1. Edit `grafana-datasources` section in grafana-config.yaml
2. Add your data source configuration JSON
3. Copy to remote and apply using update commands above

### **File Locations:**
- **Local:** `/Users/skumark5/Documents/observability-suite/grafana-cxtm-poc/`
- **Remote:** `/home/administrator/skumark5/grafana-cxtm-poc/`

---

## 📝 Notes

- **Recommendation:** Start with Direct NodePort access (Method 1)
- **Fallback:** Use SSH Tunneling if direct access fails
- **Performance:** Direct access is faster due to fewer network hops
- **Security:** SSH tunneling is more secure for production environments
- **Maintenance:** Direct access requires less ongoing maintenance

---

*Last updated: September 03, 2025 - Added Loki Log Monitoring Integration*
*Environment: CXTM AO Namespace (10.122.28.111)*