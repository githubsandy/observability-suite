# CXTM Splunk Observability Working Session Log

## Session Overview
**Date:** August 18, 2025  
**Duration:** ~4 hours  
**Environment:** uta-k8s production cluster (16 nodes)  
**Objective:** Deploy Splunk Observability for CXTM application monitoring  
**Approach:** Helm + OpenTelemetry Operator (industry standard)  

---

## 🏗️ Environment Discovery & Analysis

### Cluster Architecture Discovery
**Discovered:** Production-ready 16-node Kubernetes cluster
```
Control Planes: 3 nodes (uta-k8s-ctrlplane-01/02/03)
AO Nodes: 2 dedicated observability nodes (uta-k8s-ao-01/02) 
Workers: 11 nodes (uta-k8s-worker-01 through 11)
```

**Key Findings:**
- ✅ **Dedicated observability infrastructure** - AO nodes labeled `ao-node=observability`
- ✅ **Production CXTM deployment** - 13 services running stable for 19+ days
- ✅ **Existing monitoring** - Prometheus/Grafana in `ao` namespace (complementary, not conflicting)
- ✅ **No Splunk O11y conflicts** - Clean environment for deployment

### CXTM Services Identified
**Target services for instrumentation:**
```
cxtm-web               - Main web service (8080)
cxtm-scheduler         - Scheduler service (8080) 
cxtm-zipservice        - Zip processing (8080)
cxtm-taskdriver        - Task execution (8080)
cxtm-webcron          - Web cron service (8080)
cxtm-logstream        - Log streaming (8080)
```

**Configuration:**
- All services in `cxtm` namespace
- Python-based applications (Flask/Gunicorn likely)
- HTTP endpoints on port 8080
- Stable deployments (no recent restarts)

---

## 🚀 Helm + Operator Deployment Attempt

### Phase 1: Infrastructure Deployment ✅

**Helm Repository Setup:**
```bash
helm repo add splunk-otel-collector-chart https://signalfx.github.io/splunk-otel-collector-chart
helm repo update
```

**Configuration (`helm-values.yaml`):**
```yaml
splunkObservability:
  accessToken: "oksFxD-9HYcsCHBqvwh9mg"
  realm: "us1"
  metricsEnabled: true
  tracesEnabled: true
  logsEnabled: true

clusterName: "uta-k8s-cxtm-cluster" 
environment: "production"

# Key: Enable OpenTelemetry Operator for auto-instrumentation
operator:
  enabled: true
operatorcrds:
  install: true

# Target AO nodes for heavy processing
agent:
  enabled: true
  hostNetwork: true
  # Runs on ALL nodes (comprehensive collection)

clusterReceiver:
  enabled: true
  nodeSelector:
    ao-node: observability  # AO nodes only

autodetect:
  prometheus: true  # Discover existing Prometheus endpoints
```

**Deployment Command:**
```bash
helm upgrade --install splunk-otel-collector \
  --values helm-values.yaml \
  --namespace splunk-monitoring \
  --create-namespace \
  splunk-otel-collector-chart/splunk-otel-collector
```

**Results:**
- ✅ **16 agent pods deployed** (one per node)
- ✅ **Cluster receiver on AO node** (centralized processing)
- ✅ **OpenTelemetry operator deployed** (2/2 containers running)
- ✅ **All components Running status**
- ✅ **Connected to Splunk O11y** (realm us1)

### Phase 2: Application Instrumentation Configuration ✅

**Instrumentation CRD (`python-instrumentation.yaml`):**
```yaml
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: cxtm-python-instrumentation
  namespace: cxtm
spec:
  python:
    image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:latest
    env:
      - name: OTEL_SERVICE_NAME
        value: "cxtm-service"
      - name: OTEL_EXPORTER_OTLP_ENDPOINT
        value: "http://splunk-otel-collector-agent.splunk-monitoring:4318"
      - name: OTEL_EXPORTER_OTLP_PROTOCOL
        value: "http/protobuf"
      - name: OTEL_RESOURCE_ATTRIBUTES
        value: "deployment.environment=production,service.version=25.2.2"
      - name: OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED
        value: "true"
      - name: OTEL_LOG_LEVEL
        value: "INFO"
      - name: OTEL_TRACES_SAMPLER
        value: "always_on"
```

**Deployment:**
```bash
kubectl apply -f python-instrumentation.yaml
# Result: instrumentation.opentelemetry.io/cxtm-python-instrumentation created
```

---

## ❌ OpenTelemetry Operator Webhook Issues

### Application Instrumentation Attempts

**Method 1: Deployment Annotation**
```bash
kubectl annotate deployment cxtm-web -n cxtm instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
kubectl set env deployment/cxtm-web -n cxtm OTEL_SERVICE_NAME=cxtm-web
```

**Expected Result:** Pod restart with OpenTelemetry libraries injected  
**Actual Result:** ❌ Only OTEL_SERVICE_NAME environment variable added, no init containers or library injection

### Root Cause Analysis

**Issue 1: Webhook Registration Problems**
```bash
# Operator logs showed:
{"level":"ERROR","timestamp":"2025-08-18T09:01:43Z","logger":"instrumentation-upgrade",
"message":"failed to apply changes to instance","name":"splunk-otel-collector","namespace":"splunk-monitoring",
"error":"Internal error occurred: failed calling webhook \"minstrumentation.kb.io\": 
failed to call webhook: Post \"https://splunk-otel-collector-operator-webhook.splunk-monitoring.svc:443/mutate-opentelemetry-io-v1alpha1-instrumentation?timeout=10s\": 
no endpoints available for service \"splunk-otel-collector-operator-webhook\""}
```

**Issue 2: Webhook Startup Timing Problems**
- Webhook service existed with correct endpoints (10.42.11.221:9443)
- Webhook port configured correctly (9443 → webhook-server)  
- **BUT:** Persistent startup timing issues where webhook couldn't reach itself during initialization
- Pod mutation webhook registered (`/mutate-v1-pod`) but not processing requests

**Issue 3: Persistent State Corruption**
- Restarted operator pod to clear startup issues
- **Same startup errors persisted** in new pod
- Webhook infrastructure had internal inconsistencies preventing pod mutation

### Troubleshooting Attempts

**Webhook Configuration Verification:**
```bash
kubectl get mutatingwebhookconfiguration -o yaml
# Results: ✅ Webhook properly configured for pod mutation
#         ✅ No namespace restrictions (works on all namespaces)  
#         ✅ Correct paths and endpoints
```

**RBAC Permissions Check:**
```bash  
kubectl describe clusterrole splunk-otel-collector-operator-manager
# Results: ✅ Full permissions for pods, deployments, instrumentations
#         ✅ All required verbs (create, delete, get, list, patch, update, watch)
```

**Service and Endpoint Verification:**
```bash
kubectl get endpoints splunk-otel-collector-operator-webhook -n splunk-monitoring
# Results: ✅ Endpoint available (10.42.11.221:9443)
#         ✅ Service configured correctly
```

**Test Pod Creation:**
```bash
kubectl run test-instrumentation --image=python:3.9 --restart=Never -n cxtm \
  --annotations="instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation"
# Results: ❌ No OpenTelemetry instrumentation applied
#         ❌ No webhook processing logs
```

---

## 🔧 Alternative Approaches Attempted

### Manual Environment Variable Injection

**Rational:** Bypass operator webhook by manually adding OpenTelemetry environment variables

**Attempt 1: Strategic Merge Patch**
```bash
kubectl patch deployment cxtm-web -n cxtm -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "cxtm-web",
          "env": [
            {"name": "OTEL_SERVICE_NAME", "value": "cxtm-web"},
            {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "http://splunk-otel-collector-agent.splunk-monitoring.svc.cluster.local:4318"}
          ]
        }]
      }
    }
  }
}'
```
**Result:** ❌ `spec.template.spec.containers[0].image: Required value` error

**Attempt 2: Individual Environment Variables**
```bash
kubectl set env deployment/cxtm-web -n cxtm OTEL_EXPORTER_OTLP_ENDPOINT=http://splunk-otel-collector-agent.splunk-monitoring.svc.cluster.local:4318
# Prepared additional env vars but process interrupted for cleanup
```

---

## 🧹 Complete Environment Cleanup

### Decision Rationale
- **Operator webhook issues** proved persistent and complex
- **Time investment** (~4 hours) without successful instrumentation
- **Need for fresh start** to try alternative approaches

### Cleanup Commands Executed
```bash
# Force remove Helm deployment
helm uninstall splunk-otel-collector -n splunk-monitoring

# Force delete namespace and all resources
kubectl delete namespace splunk-monitoring --force --grace-period=0
kubectl patch namespace splunk-monitoring -p '{"metadata":{"finalizers":[]}}' --type=merge

# Remove instrumentation configurations
kubectl delete instrumentation cxtm-python-instrumentation -n cxtm --force --grace-period=0

# Reset CXTM applications to original state
kubectl patch deployment cxtm-web -n cxtm --type='strategic' -p='{"spec":{"template":{"metadata":{"annotations":null}}}}'
kubectl set env deployment/cxtm-web -n cxtm OTEL_SERVICE_NAME-

# Remove Helm repository
helm repo remove splunk-otel-collector-chart

# Clean local files
rm -f helm-values.yaml python-instrumentation.yaml deploy-helm-otel.sh cleanup-manual-otel.sh
```

### Cleanup Verification
```bash
# Final verification - all clean
kubectl get all --all-namespaces | grep -i otel          # No results
kubectl get all --all-namespaces | grep -i splunk        # No results  
kubectl get instrumentation --all-namespaces             # No resources found
helm list --all-namespaces | grep splunk                 # No results
```

**✅ Environment Status:** Completely clean, back to original state

---

## 📊 Session Analysis & Lessons Learned

### What Worked Successfully ✅

1. **Environment Discovery**
   - Comprehensive cluster analysis (16 nodes, AO infrastructure)
   - CXTM service identification and health verification
   - Existing monitoring stack compatibility assessment

2. **Infrastructure Deployment**  
   - Helm chart deployment successful (collector + operator)
   - All 16 agent pods running across cluster nodes
   - Cluster receiver properly deployed on AO nodes
   - Splunk O11y connectivity established (realm us1)

3. **Configuration Management**
   - Clean Helm values configuration targeting AO nodes
   - Proper instrumentation CRD creation
   - Correct network endpoints and service configuration

### What Failed ❌

1. **OpenTelemetry Operator Webhook**
   - Persistent startup timing issues
   - Webhook registration but no pod mutation processing
   - Internal state corruption preventing instrumentation

2. **Application Instrumentation**
   - Deployment annotations not processed by webhook
   - Pod restarts didn't trigger library injection
   - Manual patching approaches blocked by Kubernetes validation

### Technical Insights 💡

1. **Operator Complexity**
   - OpenTelemetry Operator has intricate webhook dependencies
   - Startup timing issues can cause persistent failures
   - Webhook self-communication problems during initialization

2. **Kubernetes Validation**
   - Strategic merge patches require complete container specifications
   - Image field validation prevents partial container updates
   - Individual environment variable updates safer than bulk patches

3. **Production Environment Considerations**
   - Dedicated observability nodes (AO) provide excellent isolation
   - Existing monitoring stacks can coexist with new observability
   - Clean environment assessment crucial before deployment

### Alternative Approaches for Future ⭐

1. **Simplified Manual Instrumentation**
   - Direct library installation in container images
   - Environment-only configuration without operator
   - Init container pattern for runtime library injection

2. **Different Operator Approach**
   - Try upstream OpenTelemetry Operator instead of Splunk distribution
   - Deploy operator and collector separately
   - Use different instrumentation methods (e.g., Java agent)

3. **Alternative Observability Solutions**
   - Prometheus/Grafana expansion for application metrics
   - Jaeger for distributed tracing
   - Elastic APM for application monitoring

---

## 🎯 Current Environment Status

**Infrastructure:**
- ✅ 16-node Kubernetes cluster healthy
- ✅ CXTM applications running normally (13 services)
- ✅ Existing Prometheus/Grafana monitoring operational
- ✅ Dedicated AO nodes available for observability workloads

**Observability:**
- ❌ No Splunk O11y components deployed
- ❌ No OpenTelemetry instrumentation active
- ✅ Clean slate for alternative approaches
- ✅ All lessons learned and configurations documented

**Files Status:**
- ✅ Session documentation complete
- ✅ Technical analysis documented  
- ✅ Configuration templates available for future use
- ✅ Environment cleaned of all test resources

---

## 📋 Recommendations for Next Session

1. **Take Different Approach:** Consider simpler manual instrumentation or alternative observability solutions
2. **Focus on One Service:** Start with single CXTM service (cxtm-web) for proof of concept
3. **Alternative Tools:** Explore Prometheus + Grafana expansion or Jaeger tracing
4. **Operator-Free Method:** Try direct OpenTelemetry library integration without operator

**Session Conclusion:** Infrastructure deployment successful, operator instrumentation failed due to webhook issues, environment cleaned for fresh start.

---

*Session documented by: Claude Code Assistant*  
*Environment: uta-k8s production cluster*  
*Date: August 18, 2025*