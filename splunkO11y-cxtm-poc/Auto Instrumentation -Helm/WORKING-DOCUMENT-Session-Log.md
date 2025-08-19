# CXTM Splunk O11y POC - Working Document & Session Log

**Date**: August 14, 2025  
**Session**: CXTM Application Monitoring Implementation  
**Objective**: Deploy Splunk Observability Cloud APM for CXTM applications using Helm + OpenTelemetry Operator

---

## 🏗️ **Environment Context**

### **Kubernetes Cluster Details**
- **Control Plane**: `10.122.28.111` (uta-k8s-ctrlplane-01)  
- **Credentials**: `administrator` / `C1sco123=`
- **Total Nodes**: 16 (3 control planes + 2 AO nodes + 11 worker nodes)
- **Kubernetes Version**: v1.32.6+rke2r1
- **Container Runtime**: containerd://2.0.5-k3s1

### **Project Directories**
- **Local**: `/Users/skumark5/Documents/observability-suite/splunkO11y-cxtm-poc`
- **Remote**: `/home/administrator/skumark5/splunkO11y-cxtm-poc`

### **Splunk O11y Configuration**
- **Token**: `oksFxD-9HYcsCHBqvwh9mg`
- **Realm**: `us1`
- **Organization**: Cisco Systems Inc.
- **Web Interface**: https://cisco-cx-observe.signalfx.com

---

## 📊 **Architecture Analysis**

### **Current CXTM Application Distribution**
**Command**: `kubectl get pods -n cxtm -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase`

**Output**:
```
NAME                                    NODE                STATUS
cxtm-clamav-754f5954fc-n5mhw            uta-k8s-worker-07   Running
cxtm-image-retriever-76997876c7-lsphh   uta-k8s-worker-04   Running
cxtm-logstream-7b774997c5-cc9k6         uta-k8s-worker-04   Running
cxtm-mariadb-9d86f8786-tr82l            uta-k8s-worker-08   Running
cxtm-migrate-6d477fc69c-tpsvq           uta-k8s-worker-06   Running
cxtm-minio-5d7b7c5964-qgwr6             uta-k8s-worker-07   Running
cxtm-redis-87c4ffc57-x6kx4              uta-k8s-worker-05   Running
cxtm-scheduler-64c97dc94f-mfvzg         uta-k8s-worker-04   Running
cxtm-taskdriver-979d58c56-jkhs8         uta-k8s-worker-03   Running
cxtm-vault-7dc4887f-76f28               uta-k8s-worker-06   Running
cxtm-web-5c8d4dc675-4csl8               uta-k8s-worker-01   Running
cxtm-webcron-79f4d98767-gzw6q           uta-k8s-worker-06   Running
cxtm-zipservice-55757d7ccd-x7wwt        uta-k8s-worker-07   Running
```

### **Key Target Applications for APM**
1. **cxtm-web** (worker-01) - Main Flask web application
2. **cxtm-scheduler** (worker-04) - Python background scheduler
3. **cxtm-zipservice** (worker-07) - API service
4. **cxtm-logstream** (worker-04) - Log processing service

### **Observability Node Labels**
**Commands**: 
```bash
kubectl describe node uta-k8s-ao-01 | grep Labels -A 10
kubectl describe node uta-k8s-ao-02 | grep Labels -A 10
```

**Results**:
- **uta-k8s-ao-01**: `ao-node=observability` (10.122.28.103)
- **uta-k8s-ao-02**: `ao-node=observability` (10.122.28.104)

---

## 🎯 **Deployment Strategy: Hybrid Approach**

### **Architecture Decision**
**Strategy B: Hybrid Deployment**
- **Control Components**: Deploy on AO nodes (ao-01, ao-02)
  - OpenTelemetry Operator
  - Cluster Receiver
- **Data Collection**: DaemonSet on ALL nodes
  - OTEL Agent on every worker node + AO nodes
  - Direct collection from CXTM applications

### **Benefits**
1. **Resource Isolation**: Observability management separate from applications
2. **Comprehensive Collection**: Agents close to all applications
3. **Scalability**: Independent scaling of control vs data collection
4. **Reliability**: Observability control remains available if app nodes fail

---

## 🔍 **Pre-Deployment Conflict Check**

### **Commands Executed**:
```bash
# Check existing Helm releases
helm list --all-namespaces

# Check for OpenTelemetry components
kubectl get pods --all-namespaces | grep -E "(otel|opentelemetry)"
kubectl get pods --all-namespaces | grep operator
kubectl get instrumentation --all-namespaces
kubectl get opentelemetrycollector --all-namespaces

# Check observability infrastructure
kubectl get all -n ao
kubectl get all -n monitoring
```

### **Results Summary**:
- ✅ **No existing OTEL** components found
- ✅ **No Splunk** deployments detected
- ✅ **Clean environment** for deployment
- ✅ **No conflicts** identified

### **Existing Infrastructure**:
- **CXTM Application**: Deployed via Helm (cxtm namespace)
- **System Components**: Cilium, CoreDNS, Longhorn storage
- **Observability**: Grafana/Prometheus visible (default namespace)

---

## 📁 **Configuration Files Created**

### **1. helm-values.yaml**
**Purpose**: Splunk OpenTelemetry Collector configuration with hybrid node placement

**Key Configurations**:
```yaml
# Splunk O11y Connection
splunkObservability:
  accessToken: "oksFxD-9HYcsCHBqvwh9mg"
  realm: "us1"

# Hybrid Node Placement
operator:
  enabled: true
  nodeSelector:
    ao-node: observability

clusterReceiver:
  enabled: true
  nodeSelector:
    ao-node: observability

agent:
  enabled: true
  # No nodeSelector = runs on ALL nodes
```

### **2. python-instrumentation.yaml**
**Purpose**: OpenTelemetry Operator instrumentation rules for Python/Flask applications

**Key Features**:
- Flask + Gunicorn instrumentation support
- Init container pattern for reliable library injection
- CXTM-specific environment variables

### **3. deploy-helm-otel.sh**
**Purpose**: Automated deployment script

**Process**:
1. Prerequisites verification
2. Helm repository setup
3. Collector + Operator installation
4. Python instrumentation CRD creation
5. CXTM service instrumentation

---

## 🚀 **File Copy Process**

### **Command Executed**:
```bash
# From local machine
cd /Users/skumark5/Documents/observability-suite/splunkO11y-cxtm-poc

scp -o StrictHostKeyChecking=no \
  helm-values.yaml \
  python-instrumentation.yaml \
  deploy-helm-otel.sh \
  cleanup-manual-otel.sh \
  administrator@10.122.28.111:/home/administrator/skumark5/splunkO11y-cxtm-poc/
```

### **Verification on Remote**:
```bash
# SSH to control plane
ssh administrator@10.122.28.111
cd /home/administrator/skumark5/splunkO11y-cxtm-poc

# Files confirmed present:
ls -la
# Output shows:
# deploy-helm-otel.sh* 
# helm-values.yaml 
# python-instrumentation.yaml
```

---

## 🎯 **Current Status & Next Steps**

### **Completed Actions**:
- ✅ Environment analysis and conflict check
- ✅ Architecture strategy defined (Hybrid approach)
- ✅ Configuration files created and optimized
- ✅ Files copied to control plane
- ✅ Node placement strategy configured

### **Ready to Execute**:
```bash
# On control plane (administrator@10.122.28.111)
cd /home/administrator/skumark5/splunkO11y-cxtm-poc
chmod +x deploy-helm-otel.sh
./deploy-helm-otel.sh
```

### **Expected Deployment Results**:

#### **Infrastructure Level** (2-5 minutes):
- **Namespace**: `splunk-monitoring` created
- **AO Node ao-01/ao-02**: 
  - opentelemetry-operator pod
  - splunk-otel-collector-k8s-cluster-receiver pod
- **All Nodes**: splunk-otel-collector-agent pods (DaemonSet)

#### **Application Level** (5-8 minutes):
- **Python Instrumentation CRD**: Created
- **CXTM Pods**: Restarted with instrumentation annotations
- **Init Containers**: Added for OpenTelemetry library injection

#### **Observability Level** (10-15 minutes):
- **Splunk O11y Cloud**: CXTM services visible in APM
- **Service Map**: Shows application dependencies
- **Traces**: Real trace IDs in application logs

---

## 🔧 **Verification Commands**

### **Infrastructure Check**:
```bash
# Check Splunk O11y components
kubectl get pods -n splunk-monitoring -o wide

# Verify node placement
kubectl get pods -n splunk-monitoring -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName

# Check DaemonSet distribution
kubectl get ds -n splunk-monitoring
```

### **Application Instrumentation Check**:
```bash
# Check CXTM pod restarts
kubectl get pods -n cxtm

# Verify instrumentation annotations
kubectl describe deployment cxtm-web -n cxtm | grep instrumentation

# Check init containers
kubectl describe pod -l app=cxtm-web -n cxtm | grep -A5 "Init Containers"
```

### **Trace Verification**:
```bash
# Generate test traffic
kubectl port-forward -n cxtm service/cxtm-web 8080:8080 &
curl http://localhost:8080/
curl http://localhost:8080/healthz

# Check collector logs for trace activity
kubectl logs -l app.kubernetes.io/name=splunk-otel-collector -n splunk-monitoring --tail=50
```

---

## 🚨 **Troubleshooting Guide**

### **If Deployment Fails**:
```bash
# Check Helm status
helm list -n splunk-monitoring

# Check operator logs
kubectl logs -l app.kubernetes.io/name=opentelemetry-operator -n splunk-monitoring

# Check collector pod status
kubectl describe pods -l app.kubernetes.io/name=splunk-otel-collector -n splunk-monitoring
```

### **If Instrumentation Fails**:
```bash
# Check CRD creation
kubectl get instrumentation

# Check pod events
kubectl describe pod -l app=cxtm-web -n cxtm

# Check init container logs
kubectl logs <cxtm-web-pod> -n cxtm -c opentelemetry-auto-instrumentation
```

### **If No Traces Generated**:
```bash
# Check application logs for OTEL
kubectl logs -l app=cxtm-web -n cxtm | grep -i otel

# Test collector connectivity
kubectl exec -it <collector-pod> -n splunk-monitoring -- curl -v https://ingest.us1.signalfx.com
```

---

## 📈 **Success Metrics**

### **Infrastructure Success Indicators**:
- [ ] Splunk collector pods running on target nodes
- [ ] OpenTelemetry operator deployed on AO nodes
- [ ] Python instrumentation CRD created
- [ ] No pod crash loops or errors

### **Application Success Indicators**:
- [ ] CXTM pods restarted with instrumentation annotations
- [ ] Init containers present in instrumented pods
- [ ] Real trace IDs in application logs (not trace_id=0)
- [ ] No application functionality degradation

### **Observability Success Indicators**:
- [ ] CXTM services visible in Splunk O11y APM dashboard
- [ ] Service map displays CXTM application topology
- [ ] Traces show request flows through CXTM services
- [ ] Performance metrics available (latency, error rates)

---

## 📊 **Expected Timeline**

| Time Frame | Activity | Expected Outcome |
|------------|----------|------------------|
| 0-2 min | Execute deployment script | Helm installation begins |
| 2-5 min | Infrastructure deployment | Collector + operator pods running |
| 5-8 min | CXTM instrumentation | Application pods restart with sidecars |
| 8-12 min | Traffic generation | Traces appear in collector logs |
| 12-15 min | Splunk O11y validation | Services visible in APM dashboard |

---

## 🔄 **Recovery/Rollback Procedures**

### **Quick Rollback**:
```bash
# Remove Helm deployment
helm uninstall splunk-otel-collector -n splunk-monitoring

# Remove namespace
kubectl delete namespace splunk-monitoring

# Remove instrumentation annotations from CXTM
kubectl patch deployment cxtm-web -n cxtm --type='strategic' -p='{"spec":{"template":{"metadata":{"annotations":{"instrumentation.opentelemetry.io/inject-python":null}}}}}'
```

### **Cleanup Script**:
```bash
# Use provided cleanup script if needed
./cleanup-manual-otel.sh
```

---

## 📝 **Session Context Preservation**

### **If Connection Lost**:
1. **Reconnect**: `ssh administrator@10.122.28.111`
2. **Navigate**: `cd /home/administrator/skumark5/splunkO11y-cxtm-poc`
3. **Check Status**: `kubectl get pods -n splunk-monitoring`
4. **Resume**: Based on deployment status, continue from appropriate step

### **Key Files Location**:
- **Local**: `/Users/skumark5/Documents/observability-suite/splunkO11y-cxtm-poc/`
- **Remote**: `/home/administrator/skumark5/splunkO11y-cxtm-poc/`
- **Documentation**: This working document contains complete context

---

## 🎯 **Current Action Required**

**Ready to execute deployment:**
```bash
# On control plane (10.122.28.111)
cd /home/administrator/skumark5/splunkO11y-cxtm-poc
./deploy-helm-otel.sh
```

**When prompted to instrument CXTM services: Type `y`**

This working document will be updated with deployment results and any issues encountered during execution.