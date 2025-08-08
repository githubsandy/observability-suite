#!/bin/bash

# CXTM Grafana/Prometheus Reconnect Script
# This script intelligently checks and establishes connections only if needed

set -e

# Configuration
SSH_KEY="/Users/skumark5/Downloads/id_rsa_nightly"
REMOTE_HOST="cloud-user@10.123.230.40"
LOCAL_GRAFANA_PORT=3000
LOCAL_PROMETHEUS_PORT=9090
REMOTE_GRAFANA_PORT=3000
REMOTE_PROMETHEUS_PORT=9090

echo "🔍 CXTM Monitoring Connection Manager"
echo "======================================"

# Function to check if a local port is in use by SSH tunnel
check_local_tunnel() {
    local port=$1
    local service_name=$2
    
    if lsof -i :$port >/dev/null 2>&1; then
        local process=$(lsof -i :$port | grep ssh | head -1)
        if [[ -n "$process" ]]; then
            echo "✅ Local SSH tunnel for $service_name (port $port) is active"
            return 0
        else
            echo "⚠️  Port $port is in use but not by SSH tunnel"
            return 1
        fi
    else
        echo "❌ Local SSH tunnel for $service_name (port $port) is not active"
        return 1
    fi
}

# Function to check if remote port forwarding is active
check_remote_port_forward() {
    local port=$1
    local service_name=$2
    
    echo "🔍 Checking remote port forwarding for $service_name (port $port)..."
    
    if ssh -i "$SSH_KEY" "$REMOTE_HOST" "netstat -tulpn 2>/dev/null | grep :$port | grep kubectl" >/dev/null 2>&1; then
        echo "✅ Remote port forwarding for $service_name (port $port) is active"
        return 0
    else
        echo "❌ Remote port forwarding for $service_name (port $port) is not active"
        return 1
    fi
}

# Function to start remote port forwarding
start_remote_port_forward() {
    local port=$1
    local service=$2
    local service_name=$3
    
    echo "🚀 Starting remote port forwarding for $service_name..."
    ssh -i "$SSH_KEY" "$REMOTE_HOST" "cd /home/cloud-user/skumark5/grafana-cxtm-poc && nohup kubectl port-forward svc/$service $port:$port --address 127.0.0.1 > ${service}.log 2>&1 &" 
    
    # Wait for port forwarding to start
    sleep 3
    
    # Verify it started
    if ssh -i "$SSH_KEY" "$REMOTE_HOST" "netstat -tulpn 2>/dev/null | grep :$port | grep kubectl" >/dev/null 2>&1; then
        echo "✅ Remote port forwarding for $service_name started successfully"
        return 0
    else
        echo "❌ Failed to start remote port forwarding for $service_name"
        return 1
    fi
}

# Function to start local SSH tunnel
start_local_tunnel() {
    local local_port=$1
    local remote_port=$2
    local service_name=$3
    
    echo "🚀 Starting SSH tunnel for $service_name..."
    ssh -i "$SSH_KEY" -L $local_port:localhost:$remote_port "$REMOTE_HOST" -N &
    
    # Wait for tunnel to establish
    sleep 2
    
    # Verify tunnel started
    if lsof -i :$local_port >/dev/null 2>&1; then
        echo "✅ SSH tunnel for $service_name started successfully"
        return 0
    else
        echo "❌ Failed to start SSH tunnel for $service_name"
        return 1
    fi
}

# Function to test service connectivity
test_connectivity() {
    local port=$1
    local service_name=$2
    local expected_code=$3
    
    echo "🧪 Testing $service_name connectivity..."
    
    local response=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$port 2>/dev/null || echo "000")
    
    if [[ "$response" == "$expected_code" ]]; then
        echo "✅ $service_name is accessible (HTTP $response)"
        return 0
    else
        echo "❌ $service_name is not accessible (HTTP $response)"
        return 1
    fi
}

echo ""
echo "📊 Current Status Check"
echo "----------------------"

# Check current status
GRAFANA_REMOTE_OK=false
PROMETHEUS_REMOTE_OK=false
GRAFANA_LOCAL_OK=false
PROMETHEUS_LOCAL_OK=false

# Check remote port forwarding
if check_remote_port_forward $REMOTE_GRAFANA_PORT "Grafana"; then
    GRAFANA_REMOTE_OK=true
fi

if check_remote_port_forward $REMOTE_PROMETHEUS_PORT "Prometheus"; then
    PROMETHEUS_REMOTE_OK=true
fi

# Check local SSH tunnels
if check_local_tunnel $LOCAL_GRAFANA_PORT "Grafana"; then
    GRAFANA_LOCAL_OK=true
fi

if check_local_tunnel $LOCAL_PROMETHEUS_PORT "Prometheus"; then
    PROMETHEUS_LOCAL_OK=true
fi

echo ""
echo "🔧 Connection Management"
echo "-----------------------"

# Start remote port forwarding if needed
if [[ "$GRAFANA_REMOTE_OK" == false ]]; then
    start_remote_port_forward $REMOTE_GRAFANA_PORT "grafana" "Grafana"
fi

if [[ "$PROMETHEUS_REMOTE_OK" == false ]]; then
    start_remote_port_forward $REMOTE_PROMETHEUS_PORT "prometheus" "Prometheus"
fi

# Start SSH tunnels if needed
if [[ "$GRAFANA_LOCAL_OK" == false ]]; then
    start_local_tunnel $LOCAL_GRAFANA_PORT $REMOTE_GRAFANA_PORT "Grafana"
fi

if [[ "$PROMETHEUS_LOCAL_OK" == false ]]; then
    start_local_tunnel $LOCAL_PROMETHEUS_PORT $REMOTE_PROMETHEUS_PORT "Prometheus"
fi

# If nothing was needed
if [[ "$GRAFANA_REMOTE_OK" == true && "$PROMETHEUS_REMOTE_OK" == true && "$GRAFANA_LOCAL_OK" == true && "$PROMETHEUS_LOCAL_OK" == true ]]; then
    echo "ℹ️  All connections are already active - no action needed!"
fi

echo ""
echo "🧪 Connectivity Testing"
echo "----------------------"

# Test connectivity
sleep 2
test_connectivity $LOCAL_GRAFANA_PORT "Grafana" "302"
# Test Prometheus with special handling for 200 or 405 responses
echo "🧪 Testing Prometheus connectivity..."
local prometheus_response=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$LOCAL_PROMETHEUS_PORT 2>/dev/null || echo "000")
if [[ "$prometheus_response" == "200" || "$prometheus_response" == "405" ]]; then
    echo "✅ Prometheus is accessible (HTTP $prometheus_response)"
else
    echo "❌ Prometheus is not accessible (HTTP $prometheus_response)"
fi

echo ""
echo "📋 Connection Summary"
echo "===================="
echo "🌐 Access URLs:"
echo "   Grafana:    http://localhost:$LOCAL_GRAFANA_PORT (admin/admin123)"
echo "   Prometheus: http://localhost:$LOCAL_PROMETHEUS_PORT"
echo ""
echo "🔍 Status Commands:"
echo "   Check tunnels: lsof -i :$LOCAL_GRAFANA_PORT :$LOCAL_PROMETHEUS_PORT"
echo "   Check forward: ssh -i \"$SSH_KEY\" \"$REMOTE_HOST\" \"ps aux | grep 'kubectl port-forward'\""
echo ""
echo "🛑 Stop Commands:"
echo "   Kill tunnels: pkill -f 'ssh.*-L.*(3000|9090)'"
echo "   Kill forward: ssh -i \"$SSH_KEY\" \"$REMOTE_HOST\" \"pkill -f 'kubectl port-forward'\""

echo ""
echo "✅ Connection management complete!"