#\!/bin/bash

# Script to instrument CXTM Notifications with OpenTelemetry
echo "Instrumenting CXTM Notifications with OpenTelemetry..."

# Get current environment variables for backup
kubectl get deployment cxtm-notifications -o yaml > /home/cloud-user/splunkO11y-cxtm-poc/backups/cxtm-notifications-backup.yaml

echo "Adding OpenTelemetry environment variables to cxtm-notifications..."

# Add OpenTelemetry environment variables using kubectl set env
kubectl set env deployment/cxtm-notifications   OTEL_SERVICE_NAME=cxtm-notifications   OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318   OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf   OTEL_TRACES_EXPORTER=otlp   OTEL_METRICS_EXPORTER=otlp   OTEL_PROPAGATORS=tracecontext,baggage   OTEL_RESOURCE_ATTRIBUTES="deployment.environment=development,k8s.cluster.name=cxtm-dev,k8s.namespace.name=default,service.name=cxtm-notifications,service.instance.id=notifications-${HOSTNAME}"

if [ $? -eq 0 ]; then
    echo "Environment variables added successfully"
    echo "Waiting for deployment rollout..."
    kubectl rollout status deployment/cxtm-notifications --timeout=300s
    echo "Notifications instrumentation complete\!"
else
    echo "Failed to add environment variables"
    exit 1
fi
