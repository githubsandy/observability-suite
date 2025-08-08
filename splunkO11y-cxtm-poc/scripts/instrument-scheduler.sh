#\!/bin/bash

# Script to instrument CXTM Scheduler with OpenTelemetry
echo "Instrumenting CXTM Scheduler with OpenTelemetry..."

# Get current environment variables for backup
kubectl get deployment cxtm-scheduler -o yaml > /home/cloud-user/splunkO11y-cxtm-poc/backups/cxtm-scheduler-backup.yaml

echo "Adding OpenTelemetry environment variables to cxtm-scheduler..."

# Add OpenTelemetry environment variables using kubectl set env
kubectl set env deployment/cxtm-scheduler   OTEL_SERVICE_NAME=cxtm-scheduler   OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318   OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf   OTEL_TRACES_EXPORTER=otlp   OTEL_METRICS_EXPORTER=otlp   OTEL_PROPAGATORS=tracecontext,baggage   OTEL_RESOURCE_ATTRIBUTES="deployment.environment=development,k8s.cluster.name=cxtm-dev,k8s.namespace.name=default,service.name=cxtm-scheduler,service.instance.id=scheduler-${HOSTNAME}"

if [ $? -eq 0 ]; then
    echo "Environment variables added successfully"
    echo "Waiting for deployment rollout..."
    kubectl rollout status deployment/cxtm-scheduler --timeout=300s
    echo "Scheduler instrumentation complete\!"
else
    echo "Failed to add environment variables"
    exit 1
fi
