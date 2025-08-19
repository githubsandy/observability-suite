#!/bin/bash

# Quick scan script to see what monitoring resources already exist
# Run this BEFORE cleanup to see what will be removed

echo "🔍 MONITORING RESOURCES SCAN"
echo "==========================="
echo ""

# Function to check resources in namespace
check_namespace() {
    local namespace=$1
    echo "📂 Namespace: $namespace"
    
    # Check if namespace exists
    if ! kubectl get namespace "$namespace" >/dev/null 2>&1; then
        echo "   ❌ Namespace does not exist"
        return
    fi
    
    # Grafana resources
    local grafana_count=$(kubectl get all -n "$namespace" -l app=grafana --no-headers 2>/dev/null | wc -l)
    if [[ $grafana_count -gt 0 ]]; then
        echo "   📊 Grafana resources: $grafana_count found"
        kubectl get all -n "$namespace" -l app=grafana --no-headers 2>/dev/null | sed 's/^/      /'
    else
        echo "   📊 Grafana resources: None"
    fi
    
    # Prometheus resources  
    local prometheus_count=$(kubectl get all -n "$namespace" -l app=prometheus --no-headers 2>/dev/null | wc -l)
    if [[ $prometheus_count -gt 0 ]]; then
        echo "   📈 Prometheus resources: $prometheus_count found"
        kubectl get all -n "$namespace" -l app=prometheus --no-headers 2>/dev/null | sed 's/^/      /'
    else
        echo "   📈 Prometheus resources: None"
    fi
    
    # Node Exporter resources
    local node_exporter_count=$(kubectl get all -n "$namespace" -l app=node-exporter --no-headers 2>/dev/null | wc -l)
    if [[ $node_exporter_count -gt 0 ]]; then
        echo "   📋 Node Exporter resources: $node_exporter_count found"
        kubectl get all -n "$namespace" -l app=node-exporter --no-headers 2>/dev/null | sed 's/^/      /'
    else
        echo "   📋 Node Exporter resources: None"
    fi
    
    # ConfigMaps
    local configmaps=$(kubectl get configmaps -n "$namespace" --no-headers 2>/dev/null | grep -E "(grafana|prometheus)" || echo "")
    if [[ -n "$configmaps" ]]; then
        echo "   🗂️  ConfigMaps:"
        echo "$configmaps" | sed 's/^/      /'
    fi
    
    echo ""
}

# Check common namespaces
NAMESPACES=("default" "ao" "monitoring" "kube-system" "prometheus" "grafana")

for ns in "${NAMESPACES[@]}"; do
    check_namespace "$ns"
done

# Check cluster-wide resources
echo "🌐 CLUSTER-WIDE RESOURCES"
echo "========================"

echo "🔐 RBAC Resources:"
kubectl get clusterroles | grep -E "(grafana|prometheus)" || echo "   No monitoring ClusterRoles"
kubectl get clusterrolebindings | grep -E "(grafana|prometheus)" || echo "   No monitoring ClusterRoleBindings"

echo ""
echo "📊 Summary:"
total_grafana=$(kubectl get all --all-namespaces -l app=grafana --no-headers 2>/dev/null | wc -l)
total_prometheus=$(kubectl get all --all-namespaces -l app=prometheus --no-headers 2>/dev/null | wc -l)
total_node_exporter=$(kubectl get all --all-namespaces -l app=node-exporter --no-headers 2>/dev/null | wc -l)

echo "   📊 Total Grafana resources: $total_grafana"
echo "   📈 Total Prometheus resources: $total_prometheus"  
echo "   📋 Total Node Exporter resources: $total_node_exporter"

total_monitoring=$((total_grafana + total_prometheus + total_node_exporter))
echo "   🎯 Total monitoring resources: $total_monitoring"

echo ""
if [[ $total_monitoring -gt 0 ]]; then
    echo "⚠️  Found existing monitoring resources!"
    echo "🧹 Run cleanup script: ./cleanup-existing-monitoring.sh"
else
    echo "✅ No existing monitoring resources found"
    echo "🚀 Ready for fresh deployment: ./deployGrafana-ao.sh"
fi