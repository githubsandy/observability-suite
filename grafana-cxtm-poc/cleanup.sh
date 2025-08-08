#!/bin/bash

# CXTM Grafana/Prometheus Connection Cleanup Script
# Safely terminates all port forwarding and SSH tunnels

# Configuration
SSH_KEY="/Users/skumark5/Downloads/id_rsa_nightly"
REMOTE_HOST="cloud-user@10.123.230.40"

echo "🧹 CXTM Monitoring Connection Cleanup"
echo "====================================="
echo ""

# Function to kill local SSH tunnels
cleanup_local_tunnels() {
    echo "🔌 Terminating local SSH tunnels..."
    
    # Find SSH processes with port forwarding
    local tunnel_pids=$(lsof -i :3000,9090 2>/dev/null | grep ssh | awk '{print $2}' | sort -u)
    
    if [[ -n "$tunnel_pids" ]]; then
        echo "   Found SSH tunnel PIDs: $tunnel_pids"
        for pid in $tunnel_pids; do
            echo "   Killing PID $pid..."
            kill "$pid" 2>/dev/null || echo "   ⚠️  Could not kill PID $pid"
        done
        
        # Wait a moment for processes to terminate
        sleep 2
        
        # Check if any are still running
        local remaining=$(lsof -i :3000,9090 2>/dev/null | grep ssh | wc -l)
        if [[ "$remaining" -eq 0 ]]; then
            echo "   ✅ All local SSH tunnels terminated"
        else
            echo "   ⚠️  Some tunnels may still be running"
        fi
    else
        echo "   ℹ️  No local SSH tunnels found"
    fi
}

# Function to kill remote port forwarding
cleanup_remote_forwarding() {
    echo ""
    echo "🌐 Terminating remote port forwarding..."
    
    # Check if any kubectl port-forward processes exist
    if ssh -i "$SSH_KEY" "$REMOTE_HOST" "pgrep -f 'kubectl port-forward'" >/dev/null 2>&1; then
        echo "   Found kubectl port-forward processes"
        ssh -i "$SSH_KEY" "$REMOTE_HOST" "pkill -f 'kubectl port-forward'"
        
        # Wait a moment
        sleep 2
        
        # Check if terminated
        if ssh -i "$SSH_KEY" "$REMOTE_HOST" "pgrep -f 'kubectl port-forward'" >/dev/null 2>&1; then
            echo "   ⚠️  Some port-forward processes may still be running"
        else
            echo "   ✅ All remote port forwarding terminated"
        fi
    else
        echo "   ℹ️  No remote port forwarding found"
    fi
}

# Function to verify cleanup
verify_cleanup() {
    echo ""
    echo "🔍 Verification:"
    
    # Check local ports
    local local_usage=$(lsof -i :3000,9090 2>/dev/null | grep -v COMMAND | wc -l)
    if [[ "$local_usage" -eq 0 ]]; then
        echo "   ✅ Local ports 3000,9090 are free"
    else
        echo "   ⚠️  Local ports still in use:"
        lsof -i :3000,9090 2>/dev/null | grep -v COMMAND
    fi
    
    # Check remote processes
    local remote_procs=$(ssh -i "$SSH_KEY" "$REMOTE_HOST" "pgrep -f 'kubectl port-forward' | wc -l" 2>/dev/null)
    if [[ "$remote_procs" -eq 0 ]]; then
        echo "   ✅ No remote port-forward processes"
    else
        echo "   ⚠️  Remote port-forward processes still running: $remote_procs"
    fi
}

# Main cleanup sequence
cleanup_local_tunnels
cleanup_remote_forwarding
verify_cleanup

echo ""
echo "📋 Post-Cleanup Status:"
echo "   Grafana:    http://localhost:3000 (should be inaccessible)"
echo "   Prometheus: http://localhost:9090 (should be inaccessible)"
echo ""
echo "🚀 To reconnect: ./reconnect.sh"
echo "📊 To check status: ./check-status.sh"
echo ""
echo "✅ Cleanup complete!"