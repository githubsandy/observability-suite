#!/bin/bash

# CXTM Grafana/Prometheus Status Checker
# Quick status check without making any changes

# Configuration
SSH_KEY="/Users/skumark5/Downloads/id_rsa_nightly"
REMOTE_HOST="cloud-user@10.123.230.40"

echo "📊 CXTM Monitoring Status Check"
echo "==============================="
echo ""

# Function to check local SSH tunnels
check_local_status() {
    echo "🖥️  Local SSH Tunnels:"
    
    for port in 3000 9090; do
        if lsof -i :$port >/dev/null 2>&1; then
            local process_info=$(lsof -i :$port | grep ssh | head -1 | awk '{print $2}')
            if [[ -n "$process_info" ]]; then
                echo "   ✅ Port $port: Active (PID: $process_info)"
            else
                echo "   ⚠️  Port $port: In use by non-SSH process"
            fi
        else
            echo "   ❌ Port $port: Not active"
        fi
    done
}

# Function to check remote port forwarding
check_remote_status() {
    echo ""
    echo "🌐 Remote Port Forwarding:"
    
    if ssh -i "$SSH_KEY" "$REMOTE_HOST" "netstat -tulpn 2>/dev/null | grep kubectl" >/dev/null 2>&1; then
        echo "   ✅ kubectl port-forward processes found:"
        ssh -i "$SSH_KEY" "$REMOTE_HOST" "netstat -tulpn 2>/dev/null | grep kubectl | while read line; do echo \"      \$line\"; done"
    else
        echo "   ❌ No kubectl port-forward processes found"
    fi
}

# Function to check Kubernetes services
check_k8s_services() {
    echo ""
    echo "☸️  Kubernetes Services:"
    
    ssh -i "$SSH_KEY" "$REMOTE_HOST" "kubectl get pods,svc | grep -E '(prometheus|grafana|node-exporter)'" 2>/dev/null || echo "   ❌ Unable to check Kubernetes services"
}

# Function to test connectivity
test_connectivity() {
    echo ""
    echo "🧪 Connectivity Tests:"
    
    # Test Grafana
    local grafana_response=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000 2>/dev/null || echo "000")
    if [[ "$grafana_response" == "302" ]]; then
        echo "   ✅ Grafana: Accessible (HTTP $grafana_response)"
    else
        echo "   ❌ Grafana: Not accessible (HTTP $grafana_response)"
    fi
    
    # Test Prometheus
    local prometheus_response=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:9090 2>/dev/null || echo "000")
    if [[ "$prometheus_response" == "200" || "$prometheus_response" == "405" ]]; then
        echo "   ✅ Prometheus: Accessible (HTTP $prometheus_response)"
    else
        echo "   ❌ Prometheus: Not accessible (HTTP $prometheus_response)"
    fi
}

# Main status checks
check_local_status
check_remote_status
check_k8s_services
test_connectivity

echo ""
echo "🎯 Quick Actions:"
echo "   Full reconnect: ./reconnect.sh"
echo "   Kill all:       pkill -f 'ssh.*-L'; ssh -i \"$SSH_KEY\" \"$REMOTE_HOST\" \"pkill -f 'kubectl port-forward'\""
echo "   Manual tunnel:  ssh -i \"$SSH_KEY\" -L 3000:localhost:3000 \"$REMOTE_HOST\" -N &"
echo ""
echo "🌐 Access URLs (if active):"
echo "   Grafana:    http://localhost:3000 (admin/admin123)"
echo "   Prometheus: http://localhost:9090"