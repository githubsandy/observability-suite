#!/bin/bash

# CXTM AO Environment Grafana Access Script
# Connects to 10.122.28.111 and creates SSH tunnel for Grafana

# Configuration
REMOTE_HOST="administrator@10.122.28.111"
REMOTE_PASSWORD="C1sco123="
LOCAL_GRAFANA_PORT=3000
REMOTE_GRAFANA_PORT=3000
NAMESPACE="ao"

echo "🔍 CXTM AO Environment - Grafana Connection Manager"
echo "=================================================="

# Function to check if sshpass is available
check_sshpass() {
    if ! command -v sshpass &> /dev/null; then
        echo "⚠️  sshpass is not installed. You'll need to enter password manually."
        echo "   To install: brew install sshpass (on macOS)"
        return 1
    fi
    return 0
}

# Function to start remote port forwarding
start_remote_port_forward() {
    echo "🚀 Starting remote port forwarding for Grafana..."
    
    if check_sshpass; then
        sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "cd /home/administrator/skumark5/grafana-cxtm-poc && nohup kubectl port-forward svc/grafana $REMOTE_GRAFANA_PORT:$REMOTE_GRAFANA_PORT --address 0.0.0.0 -n $NAMESPACE > grafana.log 2>&1 &"
    else
        echo "📝 Manual command (enter password when prompted):"
        echo "ssh $REMOTE_HOST \"cd /home/administrator/skumark5/grafana-cxtm-poc && nohup kubectl port-forward svc/grafana $REMOTE_GRAFANA_PORT:$REMOTE_GRAFANA_PORT --address 0.0.0.0 -n $NAMESPACE > grafana.log 2>&1 &\""
        ssh "$REMOTE_HOST" "cd /home/administrator/skumark5/grafana-cxtm-poc && nohup kubectl port-forward svc/grafana $REMOTE_GRAFANA_PORT:$REMOTE_GRAFANA_PORT --address 0.0.0.0 -n $NAMESPACE > grafana.log 2>&1 &"
    fi
    
    sleep 3
    echo "✅ Remote port forwarding started"
}

# Function to start local SSH tunnel
start_local_tunnel() {
    echo "🚀 Starting SSH tunnel for Grafana..."
    
    if check_sshpass; then
        sshpass -p "$REMOTE_PASSWORD" ssh -L $LOCAL_GRAFANA_PORT:localhost:$REMOTE_GRAFANA_PORT "$REMOTE_HOST" -N &
    else
        echo "📝 Manual command (enter password when prompted):"
        echo "ssh -L $LOCAL_GRAFANA_PORT:localhost:$REMOTE_GRAFANA_PORT $REMOTE_HOST -N &"
        ssh -L $LOCAL_GRAFANA_PORT:localhost:$REMOTE_GRAFANA_PORT "$REMOTE_HOST" -N &
    fi
    
    sleep 2
    echo "✅ SSH tunnel started"
}

# Function to test connectivity
test_connectivity() {
    echo "🧪 Testing Grafana connectivity..."
    
    local response=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$LOCAL_GRAFANA_PORT 2>/dev/null || echo "000")
    
    if [[ "$response" == "302" || "$response" == "200" ]]; then
        echo "✅ Grafana is accessible (HTTP $response)"
        return 0
    else
        echo "❌ Grafana is not accessible (HTTP $response)"
        return 1
    fi
}

# Main execution
echo ""
echo "📊 Step 1: Starting remote port forwarding..."
start_remote_port_forward

echo ""
echo "📊 Step 2: Starting local SSH tunnel..."
start_local_tunnel

echo ""
echo "📊 Step 3: Testing connectivity..."
test_connectivity

echo ""
echo "🌐 Access Information:"
echo "   Grafana URL: http://localhost:$LOCAL_GRAFANA_PORT"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "🔍 Status Commands:"
echo "   Check local tunnel: lsof -i :$LOCAL_GRAFANA_PORT"
echo "   Check remote forward: ssh $REMOTE_HOST \"ps aux | grep 'kubectl port-forward'\""
echo ""
echo "🛑 Stop Commands:"
echo "   Kill local tunnel: pkill -f 'ssh.*-L.*$LOCAL_GRAFANA_PORT'"
echo "   Kill remote forward: ssh $REMOTE_HOST \"pkill -f 'kubectl port-forward'\""
echo ""
echo "✅ Connection setup complete!"
echo "📱 Open browser: http://localhost:$LOCAL_GRAFANA_PORT"