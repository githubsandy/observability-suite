#!/bin/bash

# CXTM AO Environment Status Checker
# Quick status check without making any changes

# Configuration
REMOTE_HOST="administrator@10.122.28.111"
REMOTE_PASSWORD="C1sco123="
NAMESPACE="ao"

echo "📊 CXTM AO Environment - Status Check"
echo "====================================="
echo ""

# Function to check if sshpass is available
check_sshpass() {
    if command -v sshpass &> /dev/null; then
        return 0
    fi
    return 1
}

# Function to check local SSH tunnels
check_local_status() {
    echo "🖥️  Local SSH Tunnels:"
    
    if lsof -i :3000 >/dev/null 2>&1; then
        local process_info=$(lsof -i :3000 | grep ssh | head -1 | awk '{print $2}')
        if [[ -n "$process_info" ]]; then
            echo "   ✅ Port 3000: Active (PID: $process_info)"
        else
            echo "   ⚠️  Port 3000: In use by non-SSH process"
        fi
    else
        echo "   ❌ Port 3000: Not active"
    fi
}

# Function to check remote status
check_remote_status() {
    echo ""
    echo "🌐 Remote Environment Status:"
    
    if check_sshpass; then
        echo "   🔍 Checking Kubernetes pods in ao namespace..."
        sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "kubectl get pods -n $NAMESPACE 2>/dev/null || echo '   ❌ Cannot access Kubernetes cluster'"
        
        echo "   🔍 Checking port forwarding processes..."
        if sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "pgrep -f 'kubectl port-forward'" >/dev/null 2>&1; then
            echo "   ✅ kubectl port-forward processes found"
            sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "ps aux | grep 'kubectl port-forward' | grep -v grep"
        else
            echo "   ❌ No kubectl port-forward processes found"
        fi
    else
        echo "   📝 Manual check required (sshpass not available)"
        echo "   Run: ssh $REMOTE_HOST \"kubectl get pods -n $NAMESPACE\""
    fi
}

# Function to test connectivity
test_connectivity() {
    echo ""
    echo "🧪 Connectivity Tests:"
    
    # Test Grafana
    local grafana_response=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000 2>/dev/null || echo "000")
    if [[ "$grafana_response" == "302" || "$grafana_response" == "200" ]]; then
        echo "   ✅ Grafana: Accessible (HTTP $grafana_response)"
    else
        echo "   ❌ Grafana: Not accessible (HTTP $grafana_response)"
    fi
}

# Function to show node information
check_ao_nodes() {
    echo ""
    echo "☸️  AO Nodes Status:"
    
    if check_sshpass; then
        sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "kubectl get nodes | grep -E '(NAME|ao)' 2>/dev/null || echo '   ❌ Cannot check nodes'"
    else
        echo "   📝 Manual check: ssh $REMOTE_HOST \"kubectl get nodes | grep ao\""
    fi
}

# Main status checks
check_local_status
check_remote_status
check_ao_nodes
test_connectivity

echo ""
echo "🎯 Quick Actions:"
echo "   Connect:     ./connect-ao.sh"
echo "   Deploy:      ./deploy-ao.sh (on remote)"
echo "   Manual SSH:  ssh $REMOTE_HOST"
echo ""
echo "🌐 Expected Access URL:"
echo "   Grafana: http://localhost:3000 (admin/admin123)"