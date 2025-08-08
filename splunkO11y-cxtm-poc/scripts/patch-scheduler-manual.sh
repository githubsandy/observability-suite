#\!/bin/bash
echo "Adding OpenTelemetry init container to CXTM Scheduler..."

# First, let's try a simpler approach - just add the PYTHONPATH env var
kubectl set env deployment/cxtm-scheduler PYTHONPATH=/otel-auto-instrumentation

echo "PYTHONPATH environment variable added"

# Add init container using strategic merge patch
kubectl patch deployment cxtm-scheduler --patch '
{
  "spec": {
    "template": {
      "spec": {
        "initContainers": [
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
        ],
        "containers": [
          {
            "name": "scheduler",
            "volumeMounts": [
              {
                "name": "otel-auto-instrumentation",
                "mountPath": "/otel-auto-instrumentation"
              }
            ]
          }
        ],
        "volumes": [
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
      }
    }
  }
}'

echo "Waiting for rollout to complete..."
kubectl rollout status deployment/cxtm-scheduler --timeout=300s
echo "Scheduler patching complete\!"
