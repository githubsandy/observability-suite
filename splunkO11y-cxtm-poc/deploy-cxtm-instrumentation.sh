#!/bin/bash

# CXTM Application Instrumentation Script
# Works with existing Splunk O11y infrastructure deployed by Preeti
# Only instruments CXTM applications without disrupting infrastructure monitoring

set -e

echo "🎯 CXTM Application Instrumentation for Splunk O11y"
echo "===================================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}📋 Step $1: $2${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verify prerequisites
print_step "1" "Verifying existing Splunk O11y infrastructure"

# Check if operator is running
if ! kubectl get pods -n ao -l app.kubernetes.io/name=opentelemetry-operator | grep -q "Running"; then
    print_error "OpenTelemetry operator not found in ao namespace!"
    print_error "Please ensure Preeti's infrastructure deployment is running."
    exit 1
fi

print_success "OpenTelemetry operator found and running"

# Check if splunk collector is running
if ! kubectl get pods -n ao -l app.kubernetes.io/name=splunk-otel-collector | grep -q "Running"; then
    print_error "Splunk OTEL collector not found in ao namespace!"
    exit 1
fi

print_success "Splunk OTEL collector found and running"

# CXTM services discovered in the cluster
CXTM_SERVICES=(
    "cxtm-web"
    "cxtm-scheduler" 
    "cxtm-zipservice"
    "cxtm-taskdriver"
    "cxtm-webcron"
    "cxtm-logstream"
)

print_step "2" "Deploying CXTM instrumentation configuration"

# Apply the instrumentation CRD
if kubectl apply -f python-instrumentation.yaml; then
    print_success "CXTM instrumentation configuration deployed"
else
    print_error "Failed to deploy instrumentation configuration"
    exit 1
fi

# Wait for instrumentation to be ready
sleep 5

print_step "3" "Instrumenting CXTM applications"

print_warning "This will restart CXTM pods to apply OpenTelemetry instrumentation"
print_warning "Services to be instrumented: ${CXTM_SERVICES[*]}"
echo ""
read -p "Continue with instrumentation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Instrumentation cancelled"
    exit 0
fi

# Instrument each CXTM service
for service in "${CXTM_SERVICES[@]}"; do
    echo ""
    print_step "4" "Instrumenting $service"
    
    # Check if deployment exists
    if ! kubectl get deployment $service -n cxtm >/dev/null 2>&1; then
        print_warning "$service deployment not found, skipping"
        continue
    fi
    
    # Add instrumentation annotation and service name
    kubectl patch deployment $service -n cxtm -p '{
      "spec": {
        "template": {
          "metadata": {
            "annotations": {
              "instrumentation.opentelemetry.io/inject-python": "cxtm-python-instrumentation"
            }
          },
          "spec": {
            "containers": [{
              "name": "'$service'",
              "env": [{
                "name": "OTEL_SERVICE_NAME",
                "value": "'$service'"
              }]
            }]
          }
        }
      }
    }'
    
    if [ $? -eq 0 ]; then
        print_success "$service instrumented successfully"
    else
        print_warning "Failed to instrument $service - continuing with others"
    fi
    
    sleep 2
done

print_step "5" "Verifying instrumentation deployment"

echo ""
print_success "Instrumentation Configuration:"
kubectl get instrumentation -n cxtm

echo ""
print_success "CXTM Pod Status:"
kubectl get pods -n cxtm

echo ""
print_success "Splunk O11y Infrastructure Status:"
kubectl get pods -n ao -l app.kubernetes.io/name=opentelemetry-operator
kubectl get pods -n ao -l app.kubernetes.io/name=splunk-otel-collector

print_success "CXTM instrumentation completed!"

echo ""
echo "🎯 Next Steps:"
echo "1. Wait 2-3 minutes for CXTM pods to restart with instrumentation"
echo "2. Check pod events: kubectl describe pod -l app=cxtm-web -n cxtm"
echo "3. Generate traffic to CXTM services to create traces"
echo "4. Monitor traces in Splunk O11y: https://cisco-cx-observe.signalfx.com"
echo "5. Check collector logs: kubectl logs -l app.kubernetes.io/name=splunk-otel-collector -n ao"
echo ""
echo "🔍 Troubleshooting:"
echo "• Check init containers: kubectl logs <pod-name> -n cxtm -c opentelemetry-auto-instrumentation"
echo "• Verify annotations: kubectl describe deployment cxtm-web -n cxtm"
echo "• Test connectivity: kubectl port-forward -n cxtm service/cxtm-web 8080:8080"