# Commands Used - Splunk O11y CXTM POC Implementation

This document contains all the commands we ran during our 2-day Splunk Observability POC implementation journey, organized by purpose and use case.

---

## 🔍 Environment Discovery Commands

### Initial Environment Assessment
```bash
# Check Kubernetes cluster version
kubectl version --short
# Use: Verify cluster compatibility

# List all namespaces 
kubectl get namespaces
# Use: Understand cluster organization and find existing namespaces

# Find existing Splunk/OpenTelemetry components across all namespaces
kubectl get all --all-namespaces | grep -E "(otel|splunk)"
# Use: Discover existing infrastructure before deploying new components

# Check for existing instrumentation configurations
kubectl get instrumentation --all-namespaces
# Use: See if OpenTelemetry instrumentation is already configured

# List services in ao namespace (infrastructure)
kubectl get services -n ao
# Use: Find correct collector service names and endpoints
```

### SSH Connection to Lab Environment
```bash
# Connect to CALO lab machine
ssh administrator@10.122.28.111
# Password: C1sco123=
# Use: Access the Kubernetes cluster environment
```

---

## 🏗️ Infrastructure Verification Commands

### Splunk Collector Status
```bash
# Check if Splunk collector pods are running
kubectl get pods -n ao | grep splunk-otel-collector
# Use: Verify existing collector infrastructure is healthy

# Get detailed collector pod information
kubectl get pods -n ao -o wide | grep splunk
# Use: See which nodes collectors are running on

# Check collector logs
kubectl logs -l app=splunk-otel-collector -n ao --tail=50
# Use: Verify collector is receiving and forwarding telemetry data

# Get collector service details
kubectl describe service splunk-otel-collector-agent -n ao
# Use: Confirm service endpoints and ports for OTLP configuration
```

### OpenTelemetry Operator Status
```bash
# Check if OpenTelemetry operator is running
kubectl get pods -n ao | grep opentelemetry-operator
# Use: Ensure operator is available for auto-instrumentation

# Verify operator webhook configuration
kubectl get validatingwebhookconfiguration | grep opentelemetry
kubectl get mutatingwebhookconfiguration | grep opentelemetry
# Use: Troubleshoot webhook issues that prevent pod mutations
```

---

## ⚙️ Instrumentation Configuration Commands

### Creating Instrumentation CRD
```bash
# Apply Python instrumentation configuration
kubectl apply -f python-instrumentation.yaml
# Use: Create OpenTelemetry instrumentation configuration for CXTM namespace

# Verify instrumentation was created
kubectl get instrumentation -n cxtm
# Use: Confirm the instrumentation CRD exists in correct namespace

# Get detailed instrumentation configuration
kubectl describe instrumentation cxtm-python-instrumentation -n cxtm
# Use: Verify all configuration parameters are correct
```

### Direct Environment Variable Setting (Working Solution)
```bash
# Set OTLP endpoint directly on deployment
kubectl set env deployment cxtm-web -n cxtm \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://splunk-otel-collector-agent.ao.svc.cluster.local:4318
# Use: Bypass CRD configuration issues by setting endpoint directly

# Set service name for identification
kubectl set env deployment cxtm-web -n cxtm OTEL_SERVICE_NAME=cxtm-web
# Use: Ensure service appears with correct name in Splunk O11y
```

---

## 🎯 Application Instrumentation Commands

### Adding OpenTelemetry Annotations
```bash
# Enable auto-instrumentation with annotation
kubectl annotate deployment cxtm-web -n cxtm \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation
# Use: Tell OpenTelemetry operator to inject instrumentation libraries

# Add annotation with overwrite (if already exists)
kubectl annotate deployment cxtm-web -n cxtm \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
# Use: Update existing annotation or force re-instrumentation
```

### Deployment Status and Rollout
```bash
# Check deployment status
kubectl get deployments -n cxtm
# Use: Verify deployment is ready and updated

# Watch deployment rollout
kubectl rollout status deployment/cxtm-web -n cxtm
# Use: Monitor pod restart after instrumentation changes

# Force deployment restart
kubectl rollout restart deployment/cxtm-web -n cxtm
# Use: Trigger new pods with instrumentation when automatic restart fails
```

---

## 🔍 Pod Debugging and Inspection Commands

### Pod Status and Details
```bash
# List pods in CXTM namespace
kubectl get pods -n cxtm
# Use: Check pod status and readiness after instrumentation

# Get detailed pod information
kubectl describe pod <pod-name> -n cxtm
# Use: Inspect pod configuration, events, and troubleshoot issues

# Check for init containers (OpenTelemetry injection)
kubectl describe pod <pod-name> -n cxtm | grep -A10 "Init Containers"
# Use: Verify OpenTelemetry operator injected instrumentation libraries
```

### Container Inspection
```bash
# Check running processes in container
kubectl exec <pod-name> -n cxtm -- ps aux | head -5
# Use: Verify if OpenTelemetry wrapper is actually running the application

# Check working directory
kubectl exec <pod-name> -n cxtm -- pwd
# Use: Debug file path issues and startup command problems

# List files in container
kubectl exec <pod-name> -n cxtm -- ls -la
kubectl exec <pod-name> -n cxtm -- ls -la /app
# Use: Verify application files and configuration are in expected locations

# Check OpenTelemetry instrumentation files
kubectl exec <pod-name> -n cxtm -- ls -la /otel-auto-instrumentation/
# Use: Confirm instrumentation libraries were properly injected
```

### Environment Variables Inspection
```bash
# Check all environment variables
kubectl exec <pod-name> -n cxtm -- env
# Use: Debug environment configuration issues

# Check OpenTelemetry specific variables
kubectl exec <pod-name> -n cxtm -- env | grep OTEL
# Use: Verify OpenTelemetry configuration is set correctly

# Check deployment environment variables
kubectl describe deployment cxtm-web -n cxtm | grep -A20 "Environment"
# Use: See what environment variables are configured on deployment
```

---

## 🧪 Testing and Traffic Generation Commands

### Application Testing
```bash
# Port forward to access application locally
kubectl port-forward -n cxtm service/cxtm-web 8081:8080 &
kubectl port-forward -n cxtm service/cxtm-web 8082:8080 &
# Use: Create local access to test application and generate traces

# Test application endpoints
curl http://localhost:8081/
curl http://localhost:8081/healthz
curl http://localhost:8082/healthz
# Use: Generate HTTP requests to create traces and spans

# Kill port forward processes
pkill -f "kubectl port-forward"
# Use: Clean up port forwarding when done testing
```

### Load Testing
```bash
# Generate multiple requests for trace visibility
for i in {1..10}; do curl http://localhost:8081/healthz; done
# Use: Create multiple traces to verify telemetry is working consistently
```

---

## 📊 Logs and Monitoring Commands

### Application Logs
```bash
# Get current pod logs
kubectl logs <pod-name> -n cxtm
# Use: Debug application startup issues and runtime errors

# Follow live logs
kubectl logs -f <pod-name> -n cxtm
# Use: Monitor application behavior in real-time

# Get logs from previous pod (after crash)
kubectl logs <pod-name> -n cxtm --previous
# Use: Debug why pod crashed or restarted
```

### Collector and Infrastructure Logs
```bash
# Check collector logs for incoming data
kubectl logs -l app=splunk-otel-collector -n ao --tail=50
# Use: Verify collector is receiving telemetry from instrumented applications

# Monitor collector logs in real-time
kubectl logs -f -l app=splunk-otel-collector -n ao
# Use: Watch telemetry data flow during testing

# Check operator logs
kubectl logs -l app.kubernetes.io/name=opentelemetry-operator -n ao
# Use: Debug operator webhook and instrumentation injection issues
```

---

## 🔧 Troubleshooting Commands We Tried

### Deployment Patches (Complex Approaches That Didn't Work)
```bash
# Attempted to patch deployment startup command
kubectl patch deployment cxtm-web -n cxtm --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/command",
    "value": ["opentelemetry-instrument"]
  },
  {
    "op": "replace", 
    "path": "/spec/template/spec/containers/0/args",
    "value": ["gunicorn", "--bind", "0.0.0.0:8080", "-c", "src/gunicorn_conf.py", "src.main:app"]
  }
]'
# Use: Attempted to wrap application with OpenTelemetry manually (failed due to complexity)

# Attempted to set working directory
kubectl patch deployment cxtm-web -n cxtm --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/workingDir",
    "value": "/app"
  }
]'
# Use: Fix file path issues (worked but complex approach)
```

### CRD Configuration Attempts
```bash
# Multiple attempts to update instrumentation CRD
kubectl edit instrumentation cxtm-python-instrumentation -n cxtm
# Use: Tried to fix endpoint and configuration issues (often got overridden)

# Attempted to delete and recreate instrumentation
kubectl delete instrumentation cxtm-python-instrumentation -n cxtm
kubectl apply -f python-instrumentation.yaml
# Use: Reset configuration when changes weren't taking effect
```

---

## ✅ Verification Commands (What Actually Worked)

### End-to-End Verification Process
```bash
# 1. Check instrumentation exists
kubectl get instrumentation -n cxtm
# Expected: cxtm-python-instrumentation listed

# 2. Verify annotation is applied
kubectl describe deployment cxtm-web -n cxtm | grep instrumentation
# Expected: instrumentation.opentelemetry.io/inject-python annotation visible

# 3. Confirm pod restarted
kubectl get pods -n cxtm | grep cxtm-web
# Expected: Recent pod creation time

# 4. Test application
kubectl port-forward -n cxtm service/cxtm-web 8081:8080 &
curl http://localhost:8081/healthz
# Expected: HTTP 200 response

# 5. Check traces are being generated
kubectl logs -l app=splunk-otel-collector -n ao --tail=20 | grep -i trace
# Expected: Log entries showing trace data processing
```

---

## 🚀 Scaling to Other Services Commands

### Applying to Additional CXTM Services
```bash
# For cxtm-scheduler
kubectl annotate deployment cxtm-scheduler -n cxtm \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
kubectl set env deployment cxtm-scheduler -n cxtm OTEL_SERVICE_NAME=cxtm-scheduler

# For cxtm-zipservice  
kubectl annotate deployment cxtm-zipservice -n cxtm \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
kubectl set env deployment cxtm-zipservice -n cxtm OTEL_SERVICE_NAME=cxtm-zipservice

# For cxtm-taskdriver
kubectl annotate deployment cxtm-taskdriver -n cxtm \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
kubectl set env deployment cxtm-taskdriver -n cxtm OTEL_SERVICE_NAME=cxtm-taskdriver
```

---

## 📝 Information Gathering Commands

### System and Cluster Information
```bash
# Get cluster nodes
kubectl get nodes
# Use: Understand cluster topology

# Check resource usage
kubectl top pods -n cxtm
kubectl top pods -n ao
# Use: Monitor resource consumption of instrumented applications

# Get events for troubleshooting
kubectl get events -n cxtm --sort-by='.lastTimestamp'
# Use: Debug pod startup and configuration issues
```

---

## 🎯 Key Success Commands (The Working Solution)

**These are the core commands that actually worked:**

```bash
# 1. Verify existing infrastructure
kubectl get pods -n ao | grep splunk-otel-collector

# 2. Set endpoint directly (bypass CRD issues)  
kubectl set env deployment cxtm-web -n cxtm \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://splunk-otel-collector-agent.ao.svc.cluster.local:4318

# 3. Enable auto-instrumentation
kubectl annotate deployment cxtm-web -n cxtm \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation

# 4. Set service name
kubectl set env deployment cxtm-web -n cxtm OTEL_SERVICE_NAME=cxtm-web

# 5. Verify and test
kubectl get pods -n cxtm | grep cxtm-web
kubectl port-forward -n cxtm service/cxtm-web 8081:8080 &
curl http://localhost:8081/healthz
```

---

## 🚫 Commands That Didn't Work (Lessons Learned)

### Complex JSON Patches
- **Problem**: Too complex, error-prone, hard to debug
- **Solution**: Use simple kubectl set env and annotate commands

### Cross-namespace Instrumentation Attempts  
- **Problem**: Tried to use instrumentation from ao namespace for cxtm apps
- **Solution**: Create instrumentation in same namespace as applications

### Manual Library Installation
- **Problem**: Attempted runtime pip install of OpenTelemetry libraries
- **Solution**: Use OpenTelemetry operator for automatic injection

---

## 📊 Results Verification

After running the successful commands, verification in Splunk Observability Cloud showed:
- ✅ 720+ traces captured
- ✅ Service map showing: cxtm-web → redis → mysql dependencies  
- ✅ Performance metrics and response times
- ✅ Real-time monitoring and alerting capability

**Total time from start to working solution: 15 minutes using the final approach**

---

*This command reference captures our complete 2-day journey from August 19-20, 2025*  
*Environment: CALO Lab Kubernetes cluster (uta-k8s)*  
*Final Status: Production-ready CXTM observability in Splunk O11y Cloud*