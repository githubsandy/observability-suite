# Splunk APM Auto vs Manual Instrumentation POC

## 📋 POC Objective
Compare Splunk APM auto instrumentation with manual instrumentation by creating a sample application and deploying it in a Kubernetes pod, documenting the differences in pod configuration, application code changes, and behavioral differences.

---

## 🎯 Current Progress

### ✅ Completed Tasks

#### 1. Environment Analysis
- **Existing Infrastructure**: Analyzed current Splunk O11y setup with cxtm-web application
- **Target Cluster**: Production Kubernetes cluster (10.122.28.111 - uta-k8s-ctrlplane-01)
- **Existing Components**:
  - OpenTelemetry Operator running in `ao` namespace
  - Splunk OTEL Collector deployed and functional
  - Successful cxtm-web instrumentation as reference

#### 2. Sample Application Creation
- **Application Type**: Flask web service (similar to cxtm-web)
- **Language**: Python 3.11
- **Framework**: Flask + Gunicorn
- **Endpoints Created**:
  - `/` - Main endpoint with simulated database calls
  - `/healthz` - Health check
  - `/api/users` - Users API with business logic
- **Application Features**:
  - Simulated database operations with random latency
  - Logging configured
  - Multiple endpoints for comprehensive testing

#### 3. Deployment Configuration
- **Target Namespace**: `app-test` (isolated from production `cxtm`)
- **Service Type**: NodePort (port 30080) for external access
- **Access Method**: Via node IP (10.122.28.111:30080)
- **Deployment Strategy**: Standard Kubernetes deployment with 1 replica

#### 4. Files Prepared and Deployed
```
sample-app/
├── app.py                 # Simple Flask application (NO instrumentation)
├── requirements.txt       # Minimal dependencies (Flask + gunicorn only)
├── Dockerfile            # Clean Docker build (no OTEL packages)
└── deployment.yaml       # K8s deployment for app-test namespace
```

---

## 🏗️ Current State - BASELINE APPLICATION

### Application Code Characteristics (Before Instrumentation)
```python
# Current app.py - CLEAN, NO INSTRUMENTATION
from flask import Flask, jsonify, request
import time
import random
import logging

# NO OpenTelemetry imports
# NO SDK initialization
# NO trace creation code
# Simple business logic only
```

### Dockerfile Characteristics
```dockerfile
# Current Dockerfile - MINIMAL DEPENDENCIES
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt    # Only Flask + gunicorn
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]               # Direct startup, no wrapper
```

### Current Pod Configuration
```yaml
# Expected baseline pod (no instrumentation yet):
spec:
  containers:
  - name: sample-app
    image: sample-app:latest
    ports:
    - containerPort: 5000
    # NO init containers
    # NO volume mounts
    # NO OTEL environment variables
    # Clean, simple pod spec
```

### Current Service Access
- **URL**: `http://10.122.28.111:30080/`
- **Health Check**: `http://10.122.28.111:30080/healthz`
- **API Test**: `http://10.122.28.111:30080/api/users`

---

## 🚀 Next Steps - Instrumentation Experiments

### Phase 1: Auto Instrumentation Experiment

#### Step 1: Apply Auto Instrumentation (Like cxtm-web)
```bash
# Add environment variables
kubectl set env deployment sample-app -n app-test \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://splunk-otel-collector-agent.ao.svc.cluster.local:4318

kubectl set env deployment sample-app -n app-test \
  OTEL_SERVICE_NAME=sample-app-auto

# Add instrumentation annotation
kubectl annotate deployment sample-app -n app-test \
  instrumentation.opentelemetry.io/inject-python=python-instrumentation --overwrite
```

#### Step 2: Observe Auto Instrumentation Changes
**Pod Configuration Changes to Document:**
- [ ] Init containers added automatically
- [ ] Volume mounts injected by operator
- [ ] Environment variables added by operator
- [ ] Command wrapper applied
- [ ] Pod startup time changes

**Application-Level Changes to Document:**
- [ ] Application code changes (expected: NONE)
- [ ] Dockerfile changes (expected: NONE)
- [ ] Runtime behavior changes
- [ ] Log output differences
- [ ] Trace generation verification

#### Step 3: Test Auto-Instrumented Application
```bash
# Test all endpoints and observe trace generation
curl http://10.122.28.111:30080/
curl http://10.122.28.111:30080/healthz
curl http://10.122.28.111:30080/api/users

# Check pod logs for OTEL initialization
kubectl logs -n app-test deployment/sample-app

# Verify traces in Splunk O11y
# Check: https://cisco-cx-observe.signalfx.com
```

### Phase 2: Manual Instrumentation Experiment

#### Step 1: Remove Auto Instrumentation
```bash
# Remove annotation
kubectl annotate deployment sample-app -n app-test instrumentation.opentelemetry.io/inject-python-

# Remove environment variables
kubectl set env deployment sample-app -n app-test OTEL_EXPORTER_OTLP_ENDPOINT- OTEL_SERVICE_NAME-
```

#### Step 2: Implement Manual Instrumentation
**Code Changes Required:**
- [ ] Add OpenTelemetry imports to app.py
- [ ] Add SDK initialization code
- [ ] Add manual span creation
- [ ] Add custom metrics and attributes

**Dockerfile Changes Required:**
- [ ] Add OpenTelemetry packages to requirements.txt
- [ ] Rebuild Docker image with OTEL dependencies
- [ ] Update environment configuration

**Deployment Changes Required:**
- [ ] Add OTEL environment variables manually
- [ ] Configure exporter endpoints
- [ ] Set resource attributes

#### Step 3: Test Manually Instrumented Application
```bash
# Test same endpoints and compare behavior
curl http://10.122.28.111:30080/
curl http://10.122.28.111:30080/healthz
curl http://10.122.28.111:30080/api/users

# Compare trace quality and detail level
# Verify custom spans and attributes
```

---

## 📊 Documentation Plan - Key Differences to Capture

### 1. Application Code Level Changes
| Aspect | Auto Instrumentation | Manual Instrumentation |
|--------|----------------------|------------------------|
| Code Changes | None required | Extensive imports, SDK setup |
| Imports | No changes | OpenTelemetry libraries |
| Startup Code | No changes | SDK initialization required |
| Business Logic | No changes | Manual span creation |

### 2. Build and Deployment Changes
| Aspect | Auto Instrumentation | Manual Instrumentation |
|--------|----------------------|------------------------|
| Dockerfile | No changes | Add OTEL packages |
| Image Size | Original size | Larger (OTEL libraries) |
| Build Time | No change | Longer (more dependencies) |
| Dependencies | App deps only | App + OTEL deps |

### 3. Runtime Pod Configuration Changes
| Aspect | Auto Instrumentation | Manual Instrumentation |
|--------|----------------------|------------------------|
| Init Containers | Added by operator | None |
| Volume Mounts | Injected automatically | None |
| Environment Variables | Set by operator | Manual configuration |
| Command Wrapper | Applied by operator | Direct execution |
| Startup Time | +2-3 seconds | +0.1-0.2 seconds |

### 4. Observability and Control
| Aspect | Auto Instrumentation | Manual Instrumentation |
|--------|----------------------|------------------------|
| Span Creation | Automatic | Full control |
| Trace Detail | Standard | Customizable |
| Custom Metrics | Limited | Full control |
| Error Handling | Automatic | Manual handling |
| Debugging | Operator logs | Application logs |

---

## 🎯 Expected Outcomes

### Auto Instrumentation Benefits
- ✅ Zero code changes required
- ✅ Quick deployment via annotations
- ✅ Standardized instrumentation
- ✅ Operator manages complexity

### Manual Instrumentation Benefits
- ✅ Full control over trace data
- ✅ Custom business metrics
- ✅ Fine-grained instrumentation
- ✅ No external dependencies

### Key Decision Factors
- **Development Speed**: Auto wins (no code changes)
- **Trace Quality**: Manual wins (custom spans/metrics)
- **Maintenance**: Auto wins (operator managed)
- **Debugging**: Manual wins (full visibility)
- **Team Skills**: Auto wins (no OTEL expertise required)

---

## 📅 Timeline

| Phase | Task | Duration | Status |
|-------|------|----------|--------|
| **Setup** | Create sample app | 30 min | ✅ Complete |
| **Baseline** | Deploy and test | 15 min | 🔄 In Progress |
| **Auto** | Apply auto instrumentation | 20 min | ⏳ Pending |
| **Auto** | Document pod changes | 30 min | ⏳ Pending |
| **Manual** | Remove auto, add manual | 45 min | ⏳ Pending |
| **Manual** | Document code changes | 30 min | ⏳ Pending |
| **Analysis** | Compare and document | 30 min | ⏳ Pending |

**Total Estimated POC Time**: ~3 hours

---

## 🔧 Commands Reference

### Deployment Commands
```bash
# Initial deployment
kubectl create namespace app-test
sudo docker build -t sample-app:latest .
kubectl apply -f deployment.yaml

# Check status
kubectl get pods -n app-test -o wide
kubectl get svc -n app-test

# Test application
curl http://10.122.28.111:30080/
```

### Auto Instrumentation Commands
```bash
# Apply auto instrumentation
kubectl set env deployment sample-app -n app-test OTEL_EXPORTER_OTLP_ENDPOINT=http://splunk-otel-collector-agent.ao.svc.cluster.local:4318
kubectl set env deployment sample-app -n app-test OTEL_SERVICE_NAME=sample-app-auto
kubectl annotate deployment sample-app -n app-test instrumentation.opentelemetry.io/inject-python=python-instrumentation

# Observe changes
kubectl describe pod -l app=sample-app -n app-test
kubectl logs -l app=sample-app -n app-test
```

### Manual Instrumentation Commands
```bash
# Remove auto instrumentation
kubectl annotate deployment sample-app -n app-test instrumentation.opentelemetry.io/inject-python-
kubectl set env deployment sample-app -n app-test OTEL_EXPORTER_OTLP_ENDPOINT- OTEL_SERVICE_NAME-

# Apply manual configuration (after code changes)
kubectl set env deployment sample-app -n app-test OTEL_SERVICE_NAME=sample-app-manual
kubectl set env deployment sample-app -n app-test OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://splunk-otel-collector-agent.ao.svc.cluster.local:4318/v1/traces
```

---

## 📝 Next Immediate Action

**Current Status**: Baseline application deployed and ready for testing

**Next Step**: Verify baseline application is working, then proceed with auto instrumentation experiment.

Run: `curl http://10.122.28.111:30080/` to confirm baseline is functional, then we'll begin the instrumentation comparison!