#!/bin/bash

# Enhanced Observability Stack Service Checker
# Supports dynamic namespace and all enhanced components

# Configuration
DEFAULT_NAMESPACE="ao"
NAMESPACE="${1:-$DEFAULT_NAMESPACE}"

echo "🔍 Enhanced Observability Services Health Check"
echo "==============================================="
echo "📦 Namespace: $NAMESPACE"
echo "==============================================="
echo

# Function to check service with enhanced validation
check_service() {
    local name=$1
    local url=$2
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" = "200" ] || [ "$response" = "302" ] || [ "$response" = "405" ]; then
        echo "✅ $name: Running (http://localhost:${url##*:})"
    else
        echo "❌ $name: Not accessible"
    fi
}

# Check Core Observability Services
echo "📊 Core Observability Services:"
check_service "Grafana Dashboard    " "http://localhost:3000"
check_service "Prometheus Metrics   " "http://localhost:9090"
check_service "Loki Logs           " "http://localhost:3100/metrics"

echo
echo "🔍 Enhanced Monitoring Services:"
check_service "Grafana Tempo       " "http://localhost:3200"
check_service "AlertManager        " "http://localhost:9093"
echo "   📊 Direct Tempo Ingestion: Multi-protocol trace collection"

echo
echo "🌐 Network Monitoring Services:"
check_service "Smokeping           " "http://localhost:80/smokeping/"
check_service "MTR Network Analysis" "http://localhost:8080/metrics"
check_service "Blackbox Exporter   " "http://localhost:9115/metrics"

echo
echo "⚡ Infrastructure Exporters:"
check_service "Kube-State-Metrics  " "http://localhost:8081/metrics"
check_service "Node Exporter       " "http://localhost:9100/metrics"
check_service "Promtail            " "http://localhost:9080/metrics"

echo
echo "🗄️ Database Monitoring (CXTM Services):"
echo "   📊 MariaDB Metrics: Auto-discovered by Prometheus (Internal)"
echo "   📊 Redis Metrics: Auto-discovered by Prometheus (Internal)"
echo "   ℹ️  Database services are monitored via internal cluster endpoints"

echo
echo "==============================================="
echo "📋 Access Information:"
echo "==============================================="
echo
echo "📊 Primary Dashboards:"
echo "   • Grafana Dashboard:     http://localhost:3000 (admin/admin)"
echo "   • Prometheus Query:      http://localhost:9090"
echo "   • AlertManager:          http://localhost:9093"

echo
echo "🔍 Specialized Services:"
echo "   • Grafana Tempo:         http://localhost:3200"
echo "   • Smokeping Graphs:      http://localhost:80/smokeping/"
echo "   • Direct Tempo Tracing:      http://localhost:3200 (OTLP, Jaeger, Zipkin)"

echo
echo "📈 Metrics Endpoints:"
echo "   • Prometheus Targets:    http://localhost:9090/targets"
echo "   • Loki API:              http://localhost:3100/loki/api/v1/labels"
echo "   • Blackbox Monitoring:   http://localhost:9115/metrics"
echo "   • Kubernetes Metrics:    http://localhost:8081/metrics"
echo "   • Node System Metrics:   http://localhost:9100/metrics"
echo "   • MTR Network Analysis:  http://localhost:8080/metrics"

echo
echo "🎯 Enhanced Features:"
echo "   ✅ Complete Logs + Metrics + Traces (L.M.T)"
echo "   ✅ Network Path Analysis (MTR + Smokeping)"
echo "   ✅ Auto-Discovery of CXTAF/CXTM Services"
echo "   ✅ Enhanced Blackbox Monitoring (15+ modules)"
echo "   ✅ Production-Ready Alerting"
echo "   ✅ Zero External Dependencies"

echo
echo "🛠️ Troubleshooting Commands:"
echo "   kubectl get pods -n $NAMESPACE"
echo "   kubectl logs -n $NAMESPACE -l app=grafana"
echo "   kubectl logs -n $NAMESPACE -l app=prometheus"
echo "   ./start-observability.sh $NAMESPACE"

echo
echo "==============================================="