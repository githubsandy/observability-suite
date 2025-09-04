# CXTM-WEB OpenTelemetry Instrumentation Documentation

## Service Overview
- **Service Name**: cxtm-web
- **Namespace**: cxtm
- **Container Type**: Single container deployment
- **Application**: Flask web application with Gunicorn
- **Status**: ✅ Successfully Instrumented
- **Splunk O11y Status**: Visible with complete telemetry data

## Implementation Approach Used
**Method**: Simple annotation-based approach (OpenTelemetry Operator webhook worked correctly)

## Steps Followed

### Step 1: Environment Variable Configuration
```bash
kubectl set env deployment cxtm-web -n cxtm OTEL_EXPORTER_OTLP_ENDPOINT=http://splunk-otel-collector-agent.ao.svc.cluster.local:4318
kubectl set env deployment cxtm-web -n cxtm OTEL_SERVICE_NAME=cxtm-web
```

### Step 2: OpenTelemetry Annotation
```bash
kubectl annotate deployment cxtm-web -n cxtm instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
```

### Step 3: Verification
```bash
kubectl get pods -n cxtm | grep cxtm-web
kubectl describe pod <pod-name> -n cxtm | grep -A10 "Init Containers"
```

## What Was Modified

### Added Environment Variables:
1. **OTEL_EXPORTER_OTLP_ENDPOINT**: `http://splunk-otel-collector-agent.ao.svc.cluster.local:4318`
2. **OTEL_SERVICE_NAME**: `cxtm-web`

### Added Annotations:
- **instrumentation.opentelemetry.io/inject-python**: `cxtm-python-instrumentation`

## What Was Added by OpenTelemetry Operator Webhook

### Init Container (Automatic):
```yaml
initContainers:
- name: opentelemetry-auto-instrumentation-python
  image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.54b1
  command: ["cp", "-r", "/autoinstrumentation/.", "/otel-auto-instrumentation/"]
  volumeMounts:
  - mountPath: /otel-auto-instrumentation
    name: opentelemetry-auto-instrumentation-python
```

### Volume Mount (Automatic):
```yaml
volumeMounts:
- mountPath: /otel-auto-instrumentation
  name: opentelemetry-auto-instrumentation-python
```

### Volume (Automatic):
```yaml
volumes:
- emptyDir: {}
  name: opentelemetry-auto-instrumentation-python
```

### Environment Variables (Automatic):
```yaml
env:
- name: PYTHONPATH
  value: /otel-auto-instrumentation/opentelemetry/instrumentation/auto_instrumentation:/otel-auto-instrumentation
- name: OTEL_TRACES_EXPORTER
  value: otlp
- name: OTEL_METRICS_EXPORTER
  value: otlp
- name: OTEL_LOGS_EXPORTER
  value: otlp
- name: OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED
  value: "true"
- name: OTEL_EXPORTER_OTLP_PROTOCOL
  value: http/protobuf
- name: OTEL_RESOURCE_ATTRIBUTES
  value: deployment.environment=production,service.version=25.2.2,service.namespace=cxtm
```

### Command Wrapper (Automatic):
```yaml
command:
- python3
- /otel-auto-instrumentation/bin/opentelemetry-instrument
- python3
- src/app.py
```

## Why Manual Init Container Was NOT Needed

**Reason**: The OpenTelemetry Operator webhook worked correctly for cxtm-web because:

1. **Simple single-container deployment** - No complex multi-container architecture
2. **Webhook functioned properly** - Init container was automatically injected
3. **No registry access issues** - Pod was scheduled on correct nodes
4. **Standard Flask application** - Compatible with auto-instrumentation
5. **No startup command conflicts** - Application startup was properly wrapped

## Commands Used (Complete List)

### Initial Setup:
```bash
# 1. Add environment variables
kubectl set env deployment cxtm-web -n cxtm OTEL_EXPORTER_OTLP_ENDPOINT=http://splunk-otel-collector-agent.ao.svc.cluster.local:4318
kubectl set env deployment cxtm-web -n cxtm OTEL_SERVICE_NAME=cxtm-web

# 2. Add instrumentation annotation
kubectl annotate deployment cxtm-web -n cxtm instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
```

### Verification Commands:
```bash
# Check pod status
kubectl get pods -n cxtm | grep cxtm-web

# Check init containers
kubectl describe pod <pod-name> -n cxtm | grep -A10 "Init Containers"

# Check environment variables
kubectl exec <pod-name> -n cxtm -- env | grep OTEL

# Check OpenTelemetry libraries
kubectl exec <pod-name> -n cxtm -- ls -la /otel-auto-instrumentation/

# Check process
kubectl exec <pod-name> -n cxtm -- ps aux | head -5
```

### Traffic Testing:
```bash
# Port forward for testing
kubectl port-forward -n cxtm service/cxtm-web 8081:8080 &

# Generate test traffic
curl http://localhost:8081/
curl http://localhost:8081/healthz

# Check collector logs
kubectl logs -l app=splunk-otel-collector -n ao --tail=50
```

## Success Indicators

### Pod Status:
- ✅ Pod running: `1/1 Running`
- ✅ Init container completed successfully
- ✅ Application container running with OpenTelemetry

### OpenTelemetry Integration:
- ✅ Init container injected automatically
- ✅ Volume mounts configured correctly
- ✅ Environment variables set properly
- ✅ Application startup wrapped with `opentelemetry-instrument`

### Splunk Observability Cloud:
- ✅ Service visible in APM dashboard
- ✅ Traces being generated and collected
- ✅ Service map showing dependencies
- ✅ Performance metrics available
- ✅ Request/response data captured

## Telemetry Data Flow

```
cxtm-web (Flask app)
    ↓
OpenTelemetry Auto-Instrumentation
    ↓
OTLP HTTP Endpoint (port 4318)
    ↓
splunk-otel-collector-agent.ao.svc.cluster.local
    ↓
Splunk Observability Cloud
    ↓
APM Dashboard (Service: cxtm-web)
```

## Configuration References

### Instrumentation CRD:
```yaml
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: cxtm-python-instrumentation
  namespace: cxtm
spec:
  exporter:
    endpoint: http://splunk-otel-collector-agent.ao.svc.cluster.local:4317
  python:
    image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.54b1
    env:
      - name: OTEL_EXPORTER_OTLP_ENDPOINT
        value: "http://splunk-otel-collector-agent.ao.svc.cluster.local:4318"
      - name: OTEL_EXPORTER_OTLP_PROTOCOL
        value: "http/protobuf"
```

## Troubleshooting Notes

### If Service Not Visible:
1. Check namespace scoping (instrumentation and app in same namespace)
2. Verify collector endpoint accessibility
3. Generate test traffic to create traces
4. Check collector logs for data reception

### If Pod Crashes:
1. Check init container logs: `kubectl logs <pod-name> -c opentelemetry-auto-instrumentation-python -n cxtm`
2. Check main container logs: `kubectl logs <pod-name> -n cxtm`
3. Verify working directory and file paths
4. Check startup command syntax

## Key Success Factors

1. **Namespace Alignment**: Both instrumentation config and application in `cxtm` namespace
2. **Working Webhook**: OpenTelemetry Operator webhook functioning correctly
3. **Simple Architecture**: Single container deployment easier to instrument
4. **Standard Application**: Flask application compatible with auto-instrumentation
5. **Proper Endpoint**: Using HTTP endpoint (4318) instead of gRPC (4317)

## Timeline
- **Initial Setup**: 5 minutes
- **Verification**: 2 minutes  
- **Traffic Testing**: 3 minutes
- **Total Time**: ~10 minutes

---

**Result**: ✅ Complete success with automatic webhook-based instrumentation
**Complexity**: Low (webhook handled everything automatically)
**Maintenance**: Minimal (standard annotation-based approach)