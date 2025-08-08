#\!/bin/bash

# Script to instrument CXTM ZipService with OpenTelemetry

echo "Adding OpenTelemetry environment variables to CXTM ZipService..."

# Add environment variables to zip-controller container
kubectl patch deployment cxtm-zipservice --type='json' -p='[
{
  "op": "add",
  "path": "/spec/template/spec/containers/0/env/-",
  "value": {
    "name": "OTEL_SERVICE_NAME",
    "value": "cxtm-zip-controller"
  }
},
{
  "op": "add",
  "path": "/spec/template/spec/containers/0/env/-",
  "value": {
    "name": "OTEL_EXPORTER_OTLP_ENDPOINT",
    "value": "http://otel-collector:4318"
  }
},
{
  "op": "add",
  "path": "/spec/template/spec/containers/0/env/-",
  "value": {
    "name": "OTEL_TRACES_EXPORTER",
    "value": "otlp"
  }
},
{
  "op": "add",
  "path": "/spec/template/spec/containers/0/env/-",
  "value": {
    "name": "OTEL_RESOURCE_ATTRIBUTES",
    "value": "deployment.environment=development,k8s.cluster.name=cxtm-dev,service.instance.id=zip-controller,service.namespace=default"
  }
}]'

echo "Environment variables added to zip-controller"

# Add environment variables to zip-worker container (container index 1)
kubectl patch deployment cxtm-zipservice --type='json' -p='[
{
  "op": "add",
  "path": "/spec/template/spec/containers/1/env/-",
  "value": {
    "name": "OTEL_SERVICE_NAME",
    "value": "cxtm-zip-worker"
  }
},
{
  "op": "add",
  "path": "/spec/template/spec/containers/1/env/-",
  "value": {
    "name": "OTEL_EXPORTER_OTLP_ENDPOINT",
    "value": "http://otel-collector:4318"
  }
},
{
  "op": "add",
  "path": "/spec/template/spec/containers/1/env/-",
  "value": {
    "name": "OTEL_TRACES_EXPORTER",
    "value": "otlp"
  }
},
{
  "op": "add",
  "path": "/spec/template/spec/containers/1/env/-",
  "value": {
    "name": "OTEL_RESOURCE_ATTRIBUTES",
    "value": "deployment.environment=development,k8s.cluster.name=cxtm-dev,service.instance.id=zip-worker,service.namespace=default"
  }
}]'

echo "Environment variables added to zip-worker"
echo "OpenTelemetry instrumentation applied to CXTM ZipService"

# Wait for rollout
kubectl rollout status deployment/cxtm-zipservice --timeout=300s

echo "ZipService instrumentation complete\!"
