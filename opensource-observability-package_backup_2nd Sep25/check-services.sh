#!/bin/bash
echo "🔍 Checking Observability Services Status"
echo "=========================================="
echo

# Function to check service
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
echo "🔹 Core Observability Services:"
check_service "Grafana        " "http://localhost:3000"
check_service "Prometheus     " "http://localhost:9090"
check_service "Loki           " "http://localhost:3100/metrics"

echo
echo "🔹 Infrastructure Exporters:"
check_service "Blackbox Export" "http://localhost:9115"
check_service "Node Exporter  " "http://localhost:9100"
check_service "Promtail       " "http://localhost:9080"

echo
echo "🔹 Foundation Exporters:"
check_service "kube-state-metrics" "http://localhost:8080"
# Commented out - requires actual database configuration:
# check_service "MongoDB Exporter  " "http://localhost:9216"
# check_service "PostgreSQL Exporter" "http://localhost:9187"

echo
echo "🔹 Application Layer Exporters:"
# Commented out - requires external service configuration:
# check_service "Jenkins Exporter  " "http://localhost:9118"
# check_service "Redis Exporter    " "http://localhost:9121"
# check_service "FastAPI Metrics   " "http://localhost:8001"

echo
echo "📋 Default Credentials:"
echo "   Grafana: admin/admin"
echo
echo "🔗 Quick Links:"
echo "   • Grafana Dashboard: http://localhost:3000"
echo "   • Prometheus Targets: http://localhost:9090/targets"
echo "   • Prometheus Graph: http://localhost:9090/graph"
echo "   • Loki Labels: http://localhost:3100/loki/api/v1/labels"
echo "   • Blackbox Metrics: http://localhost:9115/metrics"
echo "   • Kubernetes Metrics: http://localhost:8080/metrics"
echo "   • Node Metrics: http://localhost:9100/metrics"
echo "   • Promtail Metrics: http://localhost:9080/metrics"
# Commented out - requires external service configuration:
# echo "   • Jenkins Metrics: http://localhost:9118/metrics"
# echo "   • Redis Metrics: http://localhost:9121/metrics"
# echo "   • FastAPI Metrics: http://localhost:8001/metrics"
# echo "   • FastAPI App: http://localhost:8000"