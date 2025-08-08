#\!/bin/bash

echo "Creating OpenTelemetry instrumentation wrapper script..."

kubectl exec cxtm-scheduler-557c95bbd9-j9n7h -- /bin/bash -c "
cat > /otel-auto-instrumentation/otel-run.py << 'PYTHON_EOF'
#\!/usr/bin/env python3
import os
import sys

# Add OpenTelemetry path to Python path
sys.path.insert(0, '/otel-auto-instrumentation')

try:
    from opentelemetry.instrumentation.auto_instrumentation import run
    print('Starting application with OpenTelemetry auto-instrumentation...')
    print(f'OTEL_SERVICE_NAME: {os.getenv("OTEL_SERVICE_NAME", "unknown")}')
    print(f'OTEL_EXPORTER_OTLP_ENDPOINT: {os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "not-set")}')
    
    # Run the auto-instrumentation
    sys.exit(run())
except Exception as e:
    print(f'Error starting OpenTelemetry auto-instrumentation: {e}')
    print('Falling back to normal execution...')
    # If instrumentation fails, just run the original command
    import subprocess
    sys.exit(subprocess.call(sys.argv[1:]))
PYTHON_EOF

chmod +x /otel-auto-instrumentation/otel-run.py
"

echo "Wrapper script created successfully\!"
