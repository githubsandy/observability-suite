#\!/bin/bash

echo "Enabling Flask auto-instrumentation for CXTM Scheduler..."

# Create a startup script that enables Flask instrumentation
kubectl exec cxtm-scheduler-557c95bbd9-j9n7h -- python3 -c "
import sys
sys.path.insert(0, '/otel-auto-instrumentation')

# Create instrumentation script
with open('/tmp/instrument_app.py', 'w') as f:
    f.write('''
import sys
import os
sys.path.insert(0, '/otel-auto-instrumentation')

# Configure OpenTelemetry
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.resources import Resource
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Set up tracing
resource = Resource.create({
    'service.name': 'cxtm-scheduler',
    'service.version': '1.0',
    'deployment.environment': 'development'
})

trace.set_tracer_provider(TracerProvider(resource=resource))
tracer = trace.get_tracer(__name__)

otlp_exporter = OTLPSpanExporter(
    endpoint='http://otel-collector:4318/v1/traces'
)
span_processor = BatchSpanProcessor(otlp_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

# Enable Flask auto-instrumentation
try:
    from opentelemetry.instrumentation.flask import FlaskInstrumentor
    FlaskInstrumentor().instrument()
    print('Flask instrumentation enabled\!')
except ImportError:
    print('Flask instrumentation not available, trying requests instrumentation...')
    try:
        from opentelemetry.instrumentation.requests import RequestsInstrumentor
        RequestsInstrumentor().instrument()
        print('Requests instrumentation enabled\!')
    except ImportError:
        print('No instrumentation available')

print('OpenTelemetry instrumentation setup complete\!')
''')

print('Instrumentation script created at /tmp/instrument_app.py')
"

echo "Flask auto-instrumentation script created\!"
