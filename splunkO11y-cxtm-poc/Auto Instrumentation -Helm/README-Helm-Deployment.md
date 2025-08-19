# CXTM Splunk O11y POC - Helm Deployment Guide

## 🎯 Project Background

### **Objective**
Implement Splunk Observability Cloud APM for CXTM applications to provide distributed tracing, performance monitoring, and service dependency mapping.

### **Why Helm + OpenTelemetry Operator Approach**
- **Previous Challenge**: Manual OpenTelemetry instrumentation failed due to Flask + Gunicorn runtime conflicts
- **Solution**: Industry-standard Helm + Operator pattern using init containers for reliable library injection
- **Benefit**: Solves Flask auto-instrumentation issues that manual patching couldn't resolve

### **Splunk Observability Cloud Configuration**
- **Token**: `oksFxD-9HYcsCHBqvwh9mg`
- **Realm**: `us1`
- **Organization**: Cisco Systems Inc.
- **Web Interface**: https://cisco-cx-observe.signalfx.com

## 🏗️ Environment Setup

### **Production Kubernetes Cluster**
- **Control Plane**: `10.122.28.111` (uta-k8s-ctrlplane-01)
- **Username**: `administrator` 
- **Password**: `C1sco123=`
- **Worker Nodes**: 16-node cluster with dedicated observability nodes
- **CXTM Namespace**: `cxtm` (running production CXTM applications)

### **Directory Structure**
- **Local**: `/Users/skumark5/Documents/observability-suite/splunkO11y-cxtm-poc`
- **Remote**: `/home/administrator/skumark5/splunkO11y-cxtm-poc`

### **Target CXTM Applications**
- **cxtm-web** - Main web service (Flask)
- **cxtm-scheduler** - Background scheduler (Python)
- **cxtm-zipservice** - API service (Python)
- **cxtm-logstream** - Log processing (Python)

## 📁 Files Required

### 🎯 Core Deployment Files
1. **`helm-values.yaml`** - Helm chart configuration for Splunk OpenTelemetry Collector
2. **`python-instrumentation.yaml`** - OpenTelemetry Operator instrumentation rules for Python/Flask
3. **`deploy-helm-otel.sh`** - Clean deployment script

### 🧹 Utility Files  
4. **`cleanup-manual-otel.sh`** - Optional cleanup script for manual configuration

## 🚀 Step-by-Step Deployment

### **Step 1: Copy Files to Control Plane**
```bash
# From your local machine terminal
cd /Users/skumark5/Documents/observability-suite/splunkO11y-cxtm-poc

# Copy deployment files to control plane
scp -o StrictHostKeyChecking=no \
  helm-values.yaml \
  python-instrumentation.yaml \
  deploy-helm-otel.sh \
  cleanup-manual-otel.sh \
  administrator@10.122.28.111:/home/administrator/skumark5/splunkO11y-cxtm-poc/
```

### **Step 2: SSH to Control Plane**
```bash
# Connect to Kubernetes control plane
ssh administrator@10.122.28.111
# Password: C1sco123=
```

### **Step 3: Navigate and Prepare**
```bash
# Navigate to project directory
cd /home/administrator/skumark5/splunkO11y-cxtm-poc

# Verify files and make scripts executable
ls -la
chmod +x deploy-helm-otel.sh cleanup-manual-otel.sh
```

### **Step 4: Examine CXTM Environment**
```bash
# Check current CXTM services
kubectl get pods -n cxtm -o wide
kubectl get deployments -n cxtm
kubectl get svc -n cxtm
```

### **Step 5: Deploy Splunk O11y**
```bash
# Execute Helm deployment
./deploy-helm-otel.sh
```

**Script will execute:**
1. ✅ Verify prerequisites (kubectl, helm, cluster connectivity)
2. ✅ Add Splunk Helm repository
3. ✅ Install OpenTelemetry Collector + Operator (in `splunk-monitoring` namespace)
4. ✅ Wait for components to be ready
5. ✅ Create Python instrumentation configuration
6. ⚠️ Ask permission to instrument CXTM services (will restart pods)

**When prompted:** Type **`y`** to proceed with CXTM instrumentation

## 📊 Verification Steps

### **Step 6: Verify Deployment**
```bash
# Check Splunk O11y components are running
kubectl get pods -n splunk-monitoring

# Should see:
# - splunk-otel-collector-agent-xxxxx (DaemonSet)
# - splunk-otel-collector-k8s-cluster-receiver-xxxxx
# - opentelemetry-operator-xxxxx
```

### **Step 7: Verify CXTM Instrumentation**
```bash
# Check CXTM pods restarted with instrumentation
kubectl get pods -n cxtm

# Check instrumentation annotation
kubectl describe deployment cxtm-web -n cxtm | grep instrumentation

# Check for init containers (sign of successful instrumentation)
kubectl describe pod -l app=cxtm-web -n cxtm | grep -A5 "Init Containers"
```

### **Step 8: Generate Test Traffic**
```bash
# Port forward to CXTM web service
kubectl port-forward -n cxtm service/cxtm-web 8080:8080 &

# Generate traffic to trigger traces
curl http://localhost:8080/
curl http://localhost:8080/healthz
```

### **Step 9: Verify Traces**
```bash
# Check collector logs for trace activity
kubectl logs -l app.kubernetes.io/name=splunk-otel-collector -n splunk-monitoring --tail=50

# Look for trace export success messages
```

### **Step 10: Check Splunk Observability Cloud**
1. **Login**: https://cisco-cx-observe.signalfx.com
2. **Navigate**: APM → Services
3. **Verify**: CXTM services (`cxtm-web`, `cxtm-scheduler`, `cxtm-zipservice`) visible
4. **Check**: Service map shows CXTM application dependencies

## 🎯 Success Indicators

### ✅ Infrastructure Level
- [ ] Splunk collector pods running in `splunk-monitoring` namespace
- [ ] OpenTelemetry operator deployed and running
- [ ] Python instrumentation CRD created

### ✅ Application Level  
- [ ] CXTM pods restarted with instrumentation annotations
- [ ] Init containers visible in instrumented pods
- [ ] Real trace IDs in application logs (not `trace_id=0`)

### ✅ Observability Level
- [ ] CXTM services visible in Splunk O11y APM
- [ ] Service map showing CXTM application topology
- [ ] Traces flowing from CXTM web requests

## 🔧 Troubleshooting Commands

### If Deployment Fails
```bash
# Check Helm status
helm list -n splunk-monitoring

# Check operator logs
kubectl logs -l app.kubernetes.io/name=opentelemetry-operator -n splunk-monitoring
```

### If Instrumentation Fails
```bash
# Check instrumentation CRD
kubectl get instrumentation

# Check pod events
kubectl describe pod -l app=cxtm-web -n cxtm

# Check init container logs
kubectl logs <cxtm-web-pod> -n cxtm -c opentelemetry-auto-instrumentation
```

### If No Traces Generated
```bash
# Check application logs for OpenTelemetry
kubectl logs -l app=cxtm-web -n cxtm | grep -i otel

# Check collector trace pipeline
kubectl logs -l app.kubernetes.io/name=splunk-otel-collector -n splunk-monitoring | grep -i trace
```

## ⚡ Expected Timeline

| Time | Activity | Expected Result |
|------|----------|----------------|
| 0-2 min | File copy + SSH | Files on control plane |
| 2-5 min | Helm deployment | Collector + operator running |
| 5-8 min | CXTM instrumentation | Pods restarted with sidecars |
| 8-12 min | Traffic generation | Traces in collector logs |
| 12-15 min | Splunk O11y UI | CXTM services visible in APM |

## 🎉 Expected Results

By completing this deployment, you'll have:

1. **✅ Production APM Pipeline**: Splunk O11y collecting traces from CXTM
2. **✅ Service Visibility**: All major CXTM services in service map  
3. **✅ Performance Insights**: Request latency, error rates, dependencies
4. **✅ Distributed Tracing**: End-to-end request flows across CXTM microservices

This provides comprehensive application performance monitoring for your entire CXTM platform! 🚀