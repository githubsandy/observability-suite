#!/bin/bash
echo "🚀 Starting Comprehensive Observability Stack..."
echo "=============================================="
echo
echo "📊 Core Services:"
echo "   • Grafana: http://localhost:3000"
echo "   • Prometheus: http://localhost:9090"
echo "   • Loki: http://localhost:3100"
echo
echo "🔍 Infrastructure Exporters:"
echo "   • Blackbox Exporter: http://localhost:9115"
echo "   • Node Exporter: http://localhost:9100"
echo "   • Promtail: http://localhost:9080"
echo
echo "⚡ Foundation Exporters:"
echo "   • kube-state-metrics: http://localhost:8080"
# Commented out - requires actual database configuration:
# echo "   • MongoDB Exporter: http://localhost:9216"
# echo "   • PostgreSQL Exporter: http://localhost:9187"
echo
echo "🚀 Application Layer Exporters:"
# Commented out - requires external service configuration:
# echo "   • Jenkins Exporter: http://localhost:9118"
# echo "   • Redis Exporter: http://localhost:9121"
# echo "   • FastAPI Metrics: http://localhost:8001"
echo
echo "Press Ctrl+C to stop all services"
echo "=============================================="

# Start Core Services
echo "Starting core services..."
kubectl port-forward svc/grafana 3000:3000 -n kube-observability-stack &
PID1=$!

kubectl port-forward svc/prometheus 9090:9090 -n kube-observability-stack &
PID2=$!

kubectl port-forward svc/loki 3100:3100 -n kube-observability-stack &
PID3=$!

# Start Infrastructure Exporters
echo "Starting infrastructure exporters..."
kubectl port-forward svc/blackbox-exporter 9115:9115 -n kube-observability-stack &
PID4=$!

kubectl port-forward svc/node-exporter 9100:9100 -n kube-observability-stack &
PID5=$!

kubectl port-forward svc/promtail 9080:9080 -n kube-observability-stack &
PID6=$!

# Start Foundation Exporters
echo "Starting foundation exporters..."
kubectl port-forward svc/kube-state-metrics 8080:8080 -n kube-observability-stack &
PID7=$!

# Commented out - requires actual database configuration:
# kubectl port-forward svc/mongodb-exporter 9216:9216 -n kube-observability-stack &
# PID8=$!
# kubectl port-forward svc/postgres-exporter 9187:9187 -n kube-observability-stack &
# PID9=$!

# Start Application Layer Exporters
echo "Starting application layer exporters..."
# Commented out - requires external service configuration:
# kubectl port-forward svc/jenkins-exporter 9118:9118 -n kube-observability-stack &
# PID10=$!
# kubectl port-forward svc/redis-exporter 9121:9121 -n kube-observability-stack &
# PID11=$!
# kubectl port-forward svc/fastapi-metrics 8001:8001 -n kube-observability-stack &
# PID12=$!

echo "✅ Core services started! Use ./check-services.sh to verify status"

# Wait for interrupt
trap "echo 'Stopping all services...'; kill $PID1 $PID2 $PID3 $PID4 $PID5 $PID6 $PID7; exit" INT
wait