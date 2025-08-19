#!/bin/bash

# Cleanup Script for Manual OpenTelemetry Configuration
# Removes manual OTEL collector and resets CXTM services to original state

set -e

echo "🧹 Cleaning Up Manual OpenTelemetry Configuration"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Step 1: Verify what exists
print_step "1" "Checking existing manual configuration"

echo "Checking for manual OTEL collector..."
if kubectl get deployment otel-collector &> /dev/null; then
    echo "✓ Found manual otel-collector deployment"
    COLLECTOR_EXISTS=true
else
    echo "✗ No manual otel-collector deployment found"
    COLLECTOR_EXISTS=false
fi

echo ""
echo "Checking CXTM service configurations..."
kubectl get deployment cxtm-notifications -o jsonpath='{.spec.template.spec.containers[0].command}' 2>/dev/null || echo "✗ No custom command found on cxtm-notifications"
kubectl get daemonset cxtm-web -o jsonpath='{.spec.template.spec.containers[0].command}' 2>/dev/null || echo "✗ No custom command found on cxtm-web"

# Step 2: Remove manual OTEL collector
print_step "2" "Removing manual OTEL collector configuration"

if [ "$COLLECTOR_EXISTS" = true ]; then
    print_warning "This will remove the manual OTEL collector deployment"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Cleanup cancelled"
        exit 0
    fi
    
    echo "Removing manual OTEL collector..."
    kubectl delete -f otel-collector.yaml --ignore-not-found=true
    
    # Wait for cleanup
    echo "Waiting for cleanup to complete..."
    kubectl wait --for=delete pod -l app=otel-collector --timeout=60s || true
    
    print_success "Manual OTEL collector removed"
else
    print_success "No manual OTEL collector to remove"
fi

# Step 3: Reset CXTM services to original configuration
print_step "3" "Resetting CXTM services to original configuration"

print_warning "This will restart CXTM pods and reset them to original configuration"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "CXTM reset cancelled"
    exit 0
fi

echo "Resetting cxtm-notifications deployment..."
kubectl patch deployment cxtm-notifications --type='strategic' -p='{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "cxtm-notifications",
          "command": null,
          "env": []
        }]
      }
    }
  }
}' --dry-run=client -o yaml | kubectl apply -f -

echo "Resetting cxtm-web daemonset..."
kubectl patch daemonset cxtm-web --type='strategic' -p='{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "web",
          "command": null,
          "env": []
        }]
      }
    }
  }
}' --dry-run=client -o yaml | kubectl apply -f -

print_success "CXTM services reset to original configuration"

# Step 4: Wait for pods to restart
print_step "4" "Waiting for CXTM services to restart"

echo "Waiting for cxtm-notifications rollout..."
kubectl rollout status deployment/cxtm-notifications --timeout=300s

echo "Waiting for cxtm-web rollout..."
kubectl rollout status daemonset/cxtm-web --timeout=300s

print_success "All services restarted successfully"

# Step 5: Verify cleanup
print_step "5" "Verifying cleanup"

echo "Checking for any remaining OTEL resources..."
kubectl get pods -l app=otel-collector || echo "✓ No manual OTEL collector pods found"

echo ""
echo "Checking CXTM service status..."
kubectl get pods -l app=cxtm-notifications
kubectl get pods -l app=cxtm-web

echo ""
echo "Verifying CXTM services are healthy..."
kubectl wait --for=condition=Ready pods -l app=cxtm-notifications --timeout=120s
kubectl wait --for=condition=Ready pods -l app=cxtm-web --timeout=120s

print_success "Cleanup verification completed"

# Step 6: Summary
print_step "6" "Cleanup Summary"

echo ""
echo "📋 Cleanup Results:"
echo "=================="
echo "✅ Manual OTEL collector removed"
echo "✅ CXTM services reset to original configuration"  
echo "✅ All pods restarted and healthy"
echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. Your CXTM services are now back to their original state"
echo "2. You can now proceed with the Helm deployment:"
echo "   ./deploy-helm-otel.sh"
echo "3. Or verify services are working normally:"
echo "   kubectl port-forward service/cxtm-notifications 8080:8080"
echo "   curl http://localhost:8080/healthz"
echo ""

print_success "Cleanup completed successfully! 🎉"