#!/bin/bash

  # CXTM Services Instrumentation Script
  # Instruments actual CXTM services discovered in the cluster

  set -e

  echo "🎯 CXTM Services OpenTelemetry Instrumentation"
  echo "=============================================="

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

  # CXTM services to instrument (based on actual discovery)
  CXTM_SERVICES=(
      "cxtm-web"
      "cxtm-scheduler"
      "cxtm-zipservice"
      "cxtm-taskdriver"
      "cxtm-webcron"
      "cxtm-logstream"
  )

  print_step "1" "Instrumenting CXTM Services"

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
      print_step "2" "Instrumenting $service"

      kubectl patch deployment $service -n cxtm -p '{
        "spec": {
          "template": {
            "metadata": {
              "annotations": {
                "instrumentation.opentelemetry.io/inject-python": 
  "cxtm-python-instrumentation"
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
          print_warning "Failed to instrument $service (might not be a deployment)"
      fi

      sleep 2
  done

  print_step "3" "Verifying instrumentation"

  echo ""
  echo "Checking instrumentation status..."
  kubectl get instrumentation -n cxtm

  echo ""
  echo "Checking CXTM pod status..."
  kubectl get pods -n cxtm

  print_success "CXTM instrumentation completed!"

  echo ""
  echo "🎯 Next Steps:"
  echo "1. Wait 2-3 minutes for pods to restart"
  echo "2. Generate traffic to CXTM services"
  echo "3. Check traces in Splunk Observability Cloud: 
  https://cisco-cx-observe.signalfx.com"
  echo "4. Monitor collector logs: kubectl logs -l 
  app.kubernetes.io/name=splunk-otel-collector -n splunk-monitoring"