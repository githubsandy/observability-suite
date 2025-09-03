#!/bin/bash

# Enhanced Observability Stack Port-Forward Script
# Supports dynamic namespace and all components

# Configuration
DEFAULT_NAMESPACE="ao"
NAMESPACE="${1:-$DEFAULT_NAMESPACE}"

echo "🚀 Starting Enhanced Observability Stack..."
echo "==============================================="
echo "🌐 Environment: CALO Lab"
echo "📦 Namespace: $NAMESPACE"
echo "==============================================="
echo

# Function to start port-forward with error handling
start_port_forward() {
    local service=$1
    local port=$2
    local namespace=$3
    local display_name=$4
    local pid_var=$5
    
    echo "   Starting $display_name on port $port..."
    kubectl port-forward svc/$service $port:$port -n $namespace >/dev/null 2>&1 &
    local pid=$!
    eval "$pid_var=$pid"
    
    # Brief check if service started
    sleep 1
    if kill -0 $pid 2>/dev/null; then
        echo "   ✅ $display_name: http://localhost:$port"
    else
        echo "   ⚠️  $display_name: Failed to start (service may not exist)"
    fi
}

echo "📊 Core Observability Services:"
start_port_forward "grafana" "3000" "$NAMESPACE" "Grafana Dashboard" "PID_GRAFANA"
start_port_forward "prometheus" "9090" "$NAMESPACE" "Prometheus Metrics" "PID_PROMETHEUS"
start_port_forward "loki" "3100" "$NAMESPACE" "Loki Logs" "PID_LOKI"

echo
echo "🔍 Enhanced Monitoring Services:"
start_port_forward "tempo" "3200" "$NAMESPACE" "Grafana Tempo (Tracing)" "PID_TEMPO"
start_port_forward "alertmanager" "9093" "$NAMESPACE" "AlertManager" "PID_ALERTMANAGER"
# Direct Tempo ingestion - no OTEL collector needed

echo
echo "🌐 Network Monitoring Services:"
start_port_forward "smokeping" "80" "$NAMESPACE" "Smokeping (Network Graphs)" "PID_SMOKEPING"
start_port_forward "mtr-analyzer" "8080" "$NAMESPACE" "MTR Network Analysis" "PID_MTR"
start_port_forward "blackbox-exporter" "9115" "$NAMESPACE" "Blackbox Exporter" "PID_BLACKBOX"

echo
echo "⚡ Infrastructure Exporters:"
start_port_forward "kube-state-metrics" "8081" "$NAMESPACE" "Kube-State-Metrics" "PID_KUBE_STATE"
start_port_forward "node-exporter-prometheus-node-exporter" "9100" "$NAMESPACE" "Node Exporter" "PID_NODE_EXPORTER"
start_port_forward "promtail" "9080" "$NAMESPACE" "Promtail" "PID_PROMTAIL"

echo
echo "🗄️ Database Monitoring (CXTM Services):"
echo "   📊 MariaDB Metrics: http://cxtm-mariadb.cxtm.svc.cluster.local:9104 (Internal)"
echo "   📊 Redis Metrics: http://cxtm-redis.cxtm.svc.cluster.local:9121 (Internal)"
echo "   ℹ️  Database metrics are auto-discovered by Prometheus"

echo
echo "==============================================="
echo "🎯 Service Access Summary:"
echo "==============================================="
echo
echo "📊 Core Services:"
echo "   • Grafana Dashboard:     http://localhost:3000 (admin/admin)"
echo "   • Prometheus Query:      http://localhost:9090"
echo "   • Loki Logs:             http://localhost:3100"
echo
echo "🔍 Enhanced Services:"
echo "   • Grafana Tempo:         http://localhost:3200"
echo "   • AlertManager:          http://localhost:9093"
echo "   • Direct Tempo Ingestion:  Multi-protocol trace collection"
echo
echo "🌐 Network Monitoring:"
echo "   • Smokeping Graphs:      http://localhost:80/smokeping/"
echo "   • MTR Path Analysis:     http://localhost:8080/metrics"
echo "   • Blackbox Monitoring:   http://localhost:9115/metrics"
echo
echo "⚡ Infrastructure:"
echo "   • Kubernetes Metrics:    http://localhost:8081/metrics"
echo "   • Node System Metrics:   http://localhost:9100/metrics"
echo "   • Log Collection:        http://localhost:9080/metrics"
echo
echo "==============================================="
echo "🔧 Useful Commands:"
echo "==============================================="
echo "   Check Services:    ./check-services.sh"
echo "   View All Pods:     kubectl get pods -n $NAMESPACE"
echo "   Grafana Logs:      kubectl logs -n $NAMESPACE -l app=grafana"
echo "   Prometheus Logs:   kubectl logs -n $NAMESPACE -l app=prometheus"
echo
echo "💡 Tips:"
echo "   • All data sources are pre-configured in Grafana"
echo "   • Traces are sent directly to Tempo (OTLP, Jaeger, Zipkin support)"
echo "   • CXTAF/CXTM services are auto-discovered"
echo "   • Check http://localhost:9090/targets for all monitored services"
echo
echo "Press Ctrl+C to stop all port-forwarding services"
echo "==============================================="

# Collect all PIDs for cleanup
ALL_PIDS="$PID_GRAFANA $PID_PROMETHEUS $PID_LOKI $PID_TEMPO $PID_ALERTMANAGER $PID_SMOKEPING $PID_MTR $PID_BLACKBOX $PID_KUBE_STATE $PID_NODE_EXPORTER $PID_PROMTAIL"

# Cleanup function
cleanup() {
    echo
    echo "🛑 Stopping all observability services..."
    for pid in $ALL_PIDS; do
        if [ ! -z "$pid" ] && kill -0 $pid 2>/dev/null; then
            kill $pid
        fi
    done
    echo "✅ All services stopped"
    exit 0
}

# Set up signal handling
trap cleanup INT TERM

# Wait for interrupt
echo "✅ All services started! Waiting for Ctrl+C to stop..."
wait