#!/bin/bash

# CXTM AO Environment Connection Cleanup Script
# Safely terminates all port forwarding and SSH tunnels

# Configuration
REMOTE_HOST="administrator@10.122.28.111" 
REMOTE_PASSWORD="C1sco123="

echo "🧹 CXTM AO Environment - Connection Cleanup"
echo "==========================================="
echo ""

# Function to check if sshpass is available
check_sshpass() {
    if command -v sshpass &> /dev/null; then
        return 0
    fi
    return 1
}

# Function to kill local SSH tunnels
cleanup_local_tunnels() {
    echo "🔌 Terminating local SSH tunnels..."
    
    # Find SSH processes with port forwarding for port 3000
    local tunnel_pids=$(lsof -i :3000 2>/dev/null | grep ssh | awk '{print $2}' | sort -u)
    
    if [[ -n "$tunnel_pids" ]]; then
        echo "   Found SSH tunnel PIDs: $tunnel_pids"
        for pid in $tunnel_pids; do
            echo "   Killing PID $pid..."
            kill "$pid" 2>/dev/null || echo "   ⚠️  Could not kill PID $pid"
        done
        
        # Wait a moment for processes to terminate
        sleep 2
        
        # Check if any are still running
        local remaining=$(lsof -i :3000 2>/dev/null | grep ssh | wc -l)
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
    
    if check_sshpass; then
        # Check if any kubectl port-forward processes exist
        if sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "pgrep -f 'kubectl port-forward'" >/dev/null 2>&1; then
            echo "   Found kubectl port-forward processes"
            sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "pkill -f 'kubectl port-forward'"
            
            # Wait a moment
            sleep 2
            
            # Check if terminated
            if sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "pgrep -f 'kubectl port-forward'" >/dev/null 2>&1; then
                echo "   ⚠️  Some port-forward processes may still be running"
            else
                echo "   ✅ All remote port forwarding terminated"
            fi
        else
            echo "   ℹ️  No remote port forwarding found"
        fi
    else
        echo "   📝 Manual cleanup required (sshpass not available)"
        echo "   Run: ssh $REMOTE_HOST \"pkill -f 'kubectl port-forward'\""
    fi
}

# Function to verify cleanup
verify_cleanup() {
    echo ""
    echo "🔍 Verification:"
    
    # Check local ports
    local local_usage=$(lsof -i :3000 2>/dev/null | grep -v COMMAND | wc -l)
    if [[ "$local_usage" -eq 0 ]]; then
        echo "   ✅ Local port 3000 is free"
    else
        echo "   ⚠️  Local port still in use:"
        lsof -i :3000 2>/dev/null | grep -v COMMAND
    fi
    
    # Check remote processes
    if check_sshpass; then
        local remote_procs=$(sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_HOST" "pgrep -f 'kubectl port-forward' | wc -l" 2>/dev/null)
        if [[ "$remote_procs" -eq 0 ]]; then
            echo "   ✅ No remote port-forward processes"
        else
            echo "   ⚠️  Remote port-forward processes still running: $remote_procs"
        fi
    else
        echo "   📝 Manual verification: ssh $REMOTE_HOST \"ps aux | grep 'kubectl port-forward'\""
    fi
}

# Main cleanup sequence
cleanup_local_tunnels
cleanup_remote_forwarding
verify_cleanup

echo ""
echo "📋 Post-Cleanup Status:"
echo "   Grafana: http://localhost:3000 (should be inaccessible)"
echo ""
echo "🚀 To reconnect: ./connect-ao.sh"
echo "📊 To check status: ./status-ao.sh"
echo ""
echo "✅ Cleanup complete!"