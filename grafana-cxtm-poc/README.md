
## 📊 Current Deployment Status

### **Complete Monitoring Stack:**
- **Namespace:** `ao`
- **Node:** `uta-k8s-ao-01`
- **Components:** Grafana + Prometheus

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

### **Access URLs:**
- **Grafana Direct:** `http://10.122.28.111:30300`
- **Prometheus Direct:** `http://10.122.28.111:30090`
- **Grafana Tunneled:** `http://localhost:3000`

### **Login Credentials:**
- **Grafana Username:** `admin`
- **Grafana Password:** `admin123`
- **Prometheus:** No authentication required

---

## 🛠️ Management Commands

### **Deploy Complete Monitoring Stack:**
```bash
# Deploy both Grafana and Prometheus
./deploy-complete-monitoring.sh
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

### **Complete Stack Test:**
```bash
kubectl get all -n ao
# Expected: Both grafana and prometheus resources running
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

### **Verify Data Source:**
```bash
# Check if Prometheus data source is configured in Grafana
curl -u admin:admin123 http://10.122.28.111:30300/api/datasources
# Expected: Shows Prometheus data source with URL http://prometheus:9090
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

# Monitoring Stack Access Methods - CXTM AO Environment

This guide covers two methods to access the complete monitoring stack (Grafana + Prometheus) deployed in the `ao` namespace on the CXTM Kubernetes cluster.

## 📋 Quick Summary

| Service | Direct NodePort | SSH Tunneling | Complexity | Use Case |
|---------|----------------|---------------|------------|----------|
| **Grafana** | `http://10.122.28.111:30300` | `http://localhost:3000` | Simple/Complex | Dashboard visualization |
| **Prometheus** | `http://10.122.28.111:30090` | `http://localhost:9090` | Simple/Complex | Metrics and monitoring |

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

*Last updated: August 19, 2025*
*Environment: CXTM AO Namespace (10.122.28.111)*