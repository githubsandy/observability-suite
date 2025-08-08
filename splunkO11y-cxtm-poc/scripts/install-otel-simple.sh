#\!/bin/bash

# Simple script to add OpenTelemetry init container to CXTM services

echo "Creating OpenTelemetry auto-instrumentation ConfigMap..."

kubectl apply -f - << 'YAML_EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-init-script
  namespace: default
data:
  install-otel.sh: |
    #\!/bin/bash
    set -ex
    echo "Installing OpenTelemetry packages..."
    
    # Install to shared volume
    pip3 install --target /otel-auto-instrumentation \
        opentelemetry-api==1.21.0 \
        opentelemetry-sdk==1.21.0 \
        opentelemetry-exporter-otlp-proto-http==1.21.0 \
        opentelemetry-instrumentation==0.42b0 \
        opentelemetry-instrumentation-flask \
        opentelemetry-instrumentation-requests \
        opentelemetry-instrumentation-urllib3 \
        opentelemetry-instrumentation-logging
    
    echo "OpenTelemetry packages installed successfully\!"
    ls -la /otel-auto-instrumentation/
YAML_EOF

echo "ConfigMap created successfully\!"

# Create script to add init container to scheduler
echo "Creating script to patch scheduler deployment..."

cat > patch-scheduler.sh << 'PATCH_EOF'
#\!/bin/bash
echo "Patching CXTM Scheduler with OpenTelemetry init container..."

kubectl patch deployment cxtm-scheduler --type='json' -p='[
{
  "op": "add",
  "path": "/spec/template/spec/initContainers",
  "value": [
    {
      "name": "otel-init",
      "image": "python:3.8-slim", 
      "command": ["/bin/bash", "/scripts/install-otel.sh"],
      "volumeMounts": [
        {
          "name": "otel-auto-instrumentation",
          "mountPath": "/otel-auto-instrumentation"
        },
        {
          "name": "otel-scripts",
          "mountPath": "/scripts"
        }
      ]
    }
  ]
},
{
  "op": "add",
  "path": "/spec/template/spec/containers/0/volumeMounts",
  "value": [
    {
      "name": "otel-auto-instrumentation",
      "mountPath": "/otel-auto-instrumentation"
    }
  ]
},
{
  "op": "add",
  "path": "/spec/template/spec/containers/0/env/-",
  "value": {
    "name": "PYTHONPATH",
    "value": "/otel-auto-instrumentation"
  }
},
{
  "op": "add",
  "path": "/spec/template/spec/volumes",
  "value": [
    {
      "name": "otel-auto-instrumentation",
      "emptyDir": {}
    },
    {
      "name": "otel-scripts",
      "configMap": {
        "name": "otel-init-script",
        "defaultMode": 493
      }
    }
  ]
}]'

echo "Waiting for deployment to complete..."
kubectl rollout status deployment/cxtm-scheduler --timeout=300s
echo "Scheduler patched successfully\!"
PATCH_EOF

chmod +x patch-scheduler.sh
echo "Scripts created. Run ./patch-scheduler.sh to apply the patch."
