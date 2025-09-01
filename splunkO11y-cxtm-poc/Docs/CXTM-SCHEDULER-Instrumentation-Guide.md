# CXTM-SCHEDULER OpenTelemetry Instrumentation Documentation

## Service Overview
- **Service Name**: cxtm-scheduler
- **Namespace**: cxtm
- **Container Type**: Single container deployment
- **Application**: Python application with scheduling functionality
- **Status**: ✅ Successfully Instrumented
- **Splunk O11y Status**: Visible with complete telemetry data

## Implementation Approach Used
**Method**: Manual init container approach (OpenTelemetry Operator webhook failed to inject)

## Problem Identified
The OpenTelemetry Operator webhook was **not injecting init containers** despite having the correct annotation. This required manual replication of webhook functionality.

## Steps Followed

### Step 1: Initial Annotation (Failed)
```bash
kubectl annotate deployment cxtm-scheduler -n cxtm instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
```
**Result**: Annotation added but no init container appeared

### Step 2: Node Selector Addition
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='merge' -p='{"spec":{"template":{"spec":{"nodeSelector":{"ao-node":"observability"}}}}}'
```
**Reason**: Ensure pods run on nodes with access to container registry

### Step 3: Manual Init Container Injection
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/initContainers", "value": [{"name": "opentelemetry-auto-instrumentation-python", "image": "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.54b1", "command": ["cp", "-r", "/autoinstrumentation/.", "/otel-auto-instrumentation/"], "volumeMounts": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]}]'
```

### Step 4: Volume Addition
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "opentelemetry-auto-instrumentation-python", "emptyDir": {}}]}]'
```

### Step 5: Volume Mount Addition
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]'
```

### Step 6: Environment Variables Addition
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env", "value": [{"name": "PYTHONPATH", "value": "/otel-auto-instrumentation/opentelemetry/instrumentation/auto_instrumentation:/otel-auto-instrumentation"}, {"name": "OTEL_TRACES_EXPORTER", "value": "otlp"}, {"name": "OTEL_METRICS_EXPORTER", "value": "otlp"}, {"name": "OTEL_LOGS_EXPORTER", "value": "otlp"}, {"name": "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED", "value": "true"}, {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "http://splunk-otel-collector-agent.ao.svc.cluster.local:4318"}, {"name": "OTEL_EXPORTER_OTLP_PROTOCOL", "value": "http/protobuf"}, {"name": "OTEL_RESOURCE_ATTRIBUTES", "value": "deployment.environment=production,service.version=25.2.2,service.namespace=cxtm"}, {"name": "OTEL_SERVICE_NAME", "value": "cxtm-scheduler"}]}]'
```

### Step 7: Application Command Wrapper
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["python3", "/otel-auto-instrumentation/bin/opentelemetry-instrument", "python3", "cron.py"]}]'
```

## What Was Modified

### Added Node Selector:
```yaml
nodeSelector:
  ao-node: observability
```

### Added Init Container:
```yaml
initContainers:
- name: opentelemetry-auto-instrumentation-python
  image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.54b1
  command: ["cp", "-r", "/autoinstrumentation/.", "/otel-auto-instrumentation/"]
  volumeMounts:
  - mountPath: /otel-auto-instrumentation
    name: opentelemetry-auto-instrumentation-python
```

### Added Volume:
```yaml
volumes:
- name: opentelemetry-auto-instrumentation-python
  emptyDir: {}
```

### Added Volume Mount:
```yaml
volumeMounts:
- mountPath: /otel-auto-instrumentation
  name: opentelemetry-auto-instrumentation-python
```

### Added Environment Variables:
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
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: http://splunk-otel-collector-agent.ao.svc.cluster.local:4318
- name: OTEL_EXPORTER_OTLP_PROTOCOL
  value: http/protobuf
- name: OTEL_RESOURCE_ATTRIBUTES
  value: deployment.environment=production,service.version=25.2.2,service.namespace=cxtm
- name: OTEL_SERVICE_NAME
  value: cxtm-scheduler
```

### Modified Command:
```yaml
command:
- python3
- /otel-auto-instrumentation/bin/opentelemetry-instrument
- python3
- cron.py
```

## What Was Removed
**Nothing was removed** - all changes were additions to the existing deployment.

## Why Manual Init Container Was Needed

### Root Cause: OpenTelemetry Operator Webhook Failure
1. **Annotation Present**: The instrumentation annotation was correctly applied
2. **Webhook Not Triggering**: Despite annotation, webhook didn't inject init container
3. **Manual Replication Required**: Had to manually implement what webhook should have done

### Technical Reasons for Webhook Failure:
1. **Webhook Dependencies**: OpenTelemetry operator webhook may have timing issues
2. **Resource Conflicts**: Possible conflicts with existing pod specifications
3. **Operator Version**: Specific operator version may have bugs with certain deployments
4. **Admission Controller**: Webhook admission controller may have failed silently

### Why Manual Approach Works:
1. **Direct Control**: Explicit specification of all required components
2. **No Dependencies**: Doesn't rely on webhook functionality
3. **Predictable**: Same result every time, no timing issues
4. **Debuggable**: Clear visibility into what was added

## Commands Used (Complete List)

### Initial Diagnosis:
```bash
# Check if annotation exists
kubectl describe deployment cxtm-scheduler -n cxtm | grep instrumentation

# Check pod for init containers (none found)
kubectl get pods -n cxtm | grep cxtm-scheduler
kubectl describe pod <pod-name> -n cxtm | grep -A10 "Init Containers"
```

### Manual Implementation:
```bash
# 1. Add node selector for registry access
kubectl patch deployment cxtm-scheduler -n cxtm --type='merge' -p='{"spec":{"template":{"spec":{"nodeSelector":{"ao-node":"observability"}}}}}'

# 2. Add init container
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/initContainers", "value": [{"name": "opentelemetry-auto-instrumentation-python", "image": "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.54b1", "command": ["cp", "-r", "/autoinstrumentation/.", "/otel-auto-instrumentation/"], "volumeMounts": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]}]'

# 3. Add volume
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "opentelemetry-auto-instrumentation-python", "emptyDir": {}}]}]'

# 4. Add volume mount
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]'

# 5. Add environment variables
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env", "value": [{"name": "PYTHONPATH", "value": "/otel-auto-instrumentation/opentelemetry/instrumentation/auto_instrumentation:/otel-auto-instrumentation"}, {"name": "OTEL_TRACES_EXPORTER", "value": "otlp"}, {"name": "OTEL_METRICS_EXPORTER", "value": "otlp"}, {"name": "OTEL_LOGS_EXPORTER", "value": "otlp"}, {"name": "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED", "value": "true"}, {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "http://splunk-otel-collector-agent.ao.svc.cluster.local:4318"}, {"name": "OTEL_EXPORTER_OTLP_PROTOCOL", "value": "http/protobuf"}, {"name": "OTEL_RESOURCE_ATTRIBUTES", "value": "deployment.environment=production,service.version=25.2.2,service.namespace=cxtm"}, {"name": "OTEL_SERVICE_NAME", "value": "cxtm-scheduler"}]}]'

# 6. Modify startup command
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["python3", "/otel-auto-instrumentation/bin/opentelemetry-instrument", "python3", "cron.py"]}]'
```

### Verification Commands:
```bash
# Check pod status
kubectl get pods -n cxtm | grep cxtm-scheduler

# Verify init container was added
kubectl describe pod <pod-name> -n cxtm | grep -A10 "Init Containers"

# Check environment variables
kubectl exec <pod-name> -n cxtm -- env | grep OTEL

# Check OpenTelemetry libraries
kubectl exec <pod-name> -n cxtm -- ls -la /otel-auto-instrumentation/

# Check startup command
kubectl exec <pod-name> -n cxtm -- ps aux | head -5

# Check collector logs
kubectl logs -l app=splunk-otel-collector -n ao --tail=50
```

## Success Indicators

### Pod Status:
- ✅ Pod running: `1/1 Running`
- ✅ Init container completed successfully
- ✅ Application container running with OpenTelemetry

### Manual Implementation Verification:
- ✅ Init container present in pod description
- ✅ Volume mounts configured correctly
- ✅ Environment variables set properly
- ✅ Application startup wrapped with `opentelemetry-instrument`
- ✅ OpenTelemetry libraries accessible at `/otel-auto-instrumentation/`

### Splunk Observability Cloud:
- ✅ Service visible in APM dashboard
- ✅ Traces being generated and collected
- ✅ Performance metrics available
- ✅ Service identified as `cxtm-scheduler`

## Telemetry Data Flow

```
cxtm-scheduler (Python cron app)
    ↓
OpenTelemetry Auto-Instrumentation (Manual)
    ↓
OTLP HTTP Endpoint (port 4318)
    ↓
splunk-otel-collector-agent.ao.svc.cluster.local
    ↓
Splunk Observability Cloud
    ↓
APM Dashboard (Service: cxtm-scheduler)
```

## Key Patch Commands Breakdown

### 1. Node Selector Patch:
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='merge' -p='{"spec":{"template":{"spec":{"nodeSelector":{"ao-node":"observability"}}}}}'
```
**Purpose**: Ensure pod runs on nodes with container registry access

### 2. Init Container Patch:
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/initContainers", "value": [{"name": "opentelemetry-auto-instrumentation-python", "image": "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.54b1", "command": ["cp", "-r", "/autoinstrumentation/.", "/otel-auto-instrumentation/"], "volumeMounts": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]}]'
```
**Purpose**: Add init container to copy OpenTelemetry libraries

### 3. Volume Patch:
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "opentelemetry-auto-instrumentation-python", "emptyDir": {}}]}]'
```
**Purpose**: Create shared volume for OpenTelemetry libraries

### 4. Volume Mount Patch:
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]'
```
**Purpose**: Mount shared volume in application container

### 5. Environment Variables Patch:
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env", "value": [{"name": "PYTHONPATH", "value": "/otel-auto-instrumentation/opentelemetry/instrumentation/auto_instrumentation:/otel-auto-instrumentation"}, {"name": "OTEL_TRACES_EXPORTER", "value": "otlp"}, {"name": "OTEL_METRICS_EXPORTER", "value": "otlp"}, {"name": "OTEL_LOGS_EXPORTER", "value": "otlp"}, {"name": "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED", "value": "true"}, {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "http://splunk-otel-collector-agent.ao.svc.cluster.local:4318"}, {"name": "OTEL_EXPORTER_OTLP_PROTOCOL", "value": "http/protobuf"}, {"name": "OTEL_RESOURCE_ATTRIBUTES", "value": "deployment.environment=production,service.version=25.2.2,service.namespace=cxtm"}, {"name": "OTEL_SERVICE_NAME", "value": "cxtm-scheduler"}]}]'
```
**Purpose**: Configure OpenTelemetry behavior and endpoints

### 6. Command Patch:
```bash
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["python3", "/otel-auto-instrumentation/bin/opentelemetry-instrument", "python3", "cron.py"]}]'
```
**Purpose**: Wrap application startup with OpenTelemetry instrumentation

## Troubleshooting Notes

### If Manual Patches Fail:
1. **Check existing fields**: Some patches may fail if fields already exist
2. **Use replace instead of add**: For existing fields, use `"op": "replace"`
3. **Verify JSON syntax**: Malformed JSON will cause patch failures
4. **Check array indices**: Container indices must be correct (usually 0)

### If Pod Still Crashes:
1. Check init container logs: `kubectl logs <pod-name> -c opentelemetry-auto-instrumentation-python -n cxtm`
2. Verify image accessibility from observability nodes
3. Check volume mount permissions
4. Verify startup command syntax matches application expectations

## Key Success Factors

1. **Manual Implementation**: When webhook fails, manual approach provides reliable results
2. **Node Selector**: Critical for registry access and pod scheduling
3. **Complete Configuration**: All components (init container, volumes, env vars, command) must be present
4. **Systematic Approach**: Apply patches in logical order (volumes before mounts, etc.)
5. **Verification at Each Step**: Check pod status after each major change

## Timeline
- **Diagnosis**: 10 minutes (identifying webhook failure)
- **Manual Implementation**: 15 minutes (applying all patches)
- **Verification**: 5 minutes
- **Total Time**: ~30 minutes

---

**Result**: ✅ Complete success with manual init container approach
**Complexity**: Medium (manual patches required)
**Maintenance**: Manual updates needed for changes (webhook doesn't work)