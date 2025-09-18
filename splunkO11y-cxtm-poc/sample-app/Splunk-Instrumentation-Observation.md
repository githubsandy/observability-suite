# Splunk Instrumentation Observation

**Date**: September 18, 2025
**Environment**: Production Kubernetes Cluster (uta-k8s-ctrlplane-01)
**Application**: Simple Flask Web Service
**Namespace**: app-test

---

## 🔧 Auto Instrumentation Section

### Baseline Application State
- **Pod**: `sample-app-5bd59c4d5f-glwkt`
- **Image**: `tiangolo/uwsgi-nginx-flask:python3.11`
- **Access**: `http://10.122.28.111:30080/`
- **Response**: `"instrumentation": "none"`
- **Application Code**: Clean Flask app, no OpenTelemetry imports

### Auto Instrumentation Steps Applied
```bash
# Step 1: Environment variables added manually
kubectl set env deployment sample-app -n app-test \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://splunk-otel-collector-agent.ao.svc.cluster.local:4318
kubectl set env deployment sample-app -n app-test \
  OTEL_SERVICE_NAME=sample-app-auto

# Step 2: Annotation applied (first attempt - failed)
kubectl annotate deployment sample-app -n app-test \
  instrumentation.opentelemetry.io/inject-python=python-instrumentation

# Step 3: Corrected annotation (second attempt)
kubectl annotate deployment sample-app -n app-test \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation

# Step 4: Forced restart
kubectl rollout restart deployment sample-app -n app-test
```

### Auto Instrumentation Results

#### What We Expected:
- ✅ Pod restart with init containers
- ✅ Volume mounts for OpenTelemetry libraries
- ✅ Additional environment variables injected
- ✅ Command wrapper applied
- ✅ OpenTelemetry initialization messages in logs

#### What Actually Happened:
- ✅ Pod restarted (new pod: `sample-app-d7c455df7-fl24k`)
- ✅ Environment variables added (only the 2 we manually set)
- ❌ **NO init containers added**
- ❌ **NO volume mounts added**
- ❌ **NO additional OTEL environment variables**
- ❌ **NO command wrapper applied**
- ❌ **NO OpenTelemetry messages in logs**

#### Pod Configuration Comparison:
```diff
# Only differences between baseline and "auto-instrumented" pod:
+ Environment:
+   OTEL_EXPORTER_OTLP_ENDPOINT: http://splunk-otel-collector-agent.ao.svc.cluster.local:4318
+   OTEL_SERVICE_NAME: sample-app-auto
+ Annotations:
+   kubectl.kubernetes.io/restartedAt: 2025-09-18T03:46:24-04:00
```

#### Root Cause Analysis:
- ❌ Referenced instrumentation CRD didn't exist in app-test namespace
- ❌ Cross-namespace instrumentation reference may not be supported
- ❌ OpenTelemetry operator not properly processing annotation
- ❌ Silent failure - no error messages in operator logs

### Auto Instrumentation Key Findings:
1. **Application Code Changes**: ✅ **ZERO** - No code modifications required
2. **Infrastructure Complexity**: ❌ High - Multiple dependencies and configuration points
3. **Failure Modes**: ❌ Silent failures common, difficult to troubleshoot
4. **Cross-namespace Issues**: ❌ Operator may not support references across namespaces

---

## ⚙️ Manual Instrumentation Section

### Manual Instrumentation Implementation
*[To be completed in next phase]*

#### Expected Steps:
1. **Modify Application Code**
   - Add OpenTelemetry imports
   - Initialize SDK
   - Add manual span creation
   - Configure exporters

2. **Update Dependencies**
   - Add OpenTelemetry packages to requirements.txt
   - Rebuild Docker image

3. **Configure Environment**
   - Set OTEL environment variables manually
   - Configure exporter endpoints

4. **Deploy and Test**
   - Deploy modified application
   - Verify trace generation

#### Expected Results:
- ❌ Application code changes required
- ✅ Full control over instrumentation
- ✅ Custom spans and metrics
- ✅ No operator dependencies

### Manual Instrumentation Key Findings:
*[To be documented after implementation]*

---

## 📊 Comparison Summary

| Aspect | Auto Instrumentation | Manual Instrumentation |
|--------|---------------------|------------------------|
| **Code Changes** | ✅ None required | ❌ Extensive changes needed |
| **Dependencies** | ❌ Operator + CRD required | ✅ Self-contained |
| **Configuration** | ❌ Complex, error-prone | ✅ Direct control |
| **Troubleshooting** | ❌ Silent failures | ✅ Application logs |
| **Implementation Time** | ❌ Failed (30+ min debugging) | ⏳ TBD |
| **Maintenance** | ❌ Infrastructure dependency | ✅ Application-owned |

---

## 🎯 Current Status

### Completed:
- ✅ Baseline application established
- ✅ Auto instrumentation attempted and analyzed
- ✅ Configuration issues identified and documented

### Next Steps:
- ⏳ Implement manual instrumentation
- ⏳ Compare actual runtime behavior
- ⏳ Document final recommendations