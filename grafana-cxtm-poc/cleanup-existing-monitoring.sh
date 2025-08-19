#!/bin/bash

# Comprehensive cleanup script for existing Grafana & Prometheus deployments
# This script will remove all existing monitoring components before fresh deployment

echo "🧹 COMPREHENSIVE MONITORING CLEANUP"
echo "=================================="
echo "⚠️  This will remove ALL existing Grafana and Prometheus deployments!"
echo ""

# Function to confirm cleanup
confirm_cleanup() {
    read -p "🤔 Are you sure you want to proceed? (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) echo "❌ Cleanup cancelled"; exit 1 ;;
    esac
}

# Function to cleanup resources in a specific namespace
cleanup_namespace() {
    local namespace=$1
    echo "🔍 Cleaning up namespace: $namespace"
    
    # Remove Grafana resources
    echo "   🗑️  Removing Grafana deployments..."
    kubectl delete deployment grafana -n "$namespace" --ignore-not-found=true
    kubectl delete service grafana -n "$namespace" --ignore-not-found=true
    kubectl delete configmap grafana-config grafana-datasources grafana-dashboards -n "$namespace" --ignore-not-found=true
    kubectl delete pvc grafana-storage -n "$namespace" --ignore-not-found=true
    kubectl delete secret grafana-secret -n "$namespace" --ignore-not-found=true
    
    # Remove Prometheus resources
    echo "   🗑️  Removing Prometheus deployments..."
    kubectl delete deployment prometheus -n "$namespace" --ignore-not-found=true
    kubectl delete service prometheus -n "$namespace" --ignore-not-found=true
    kubectl delete configmap prometheus-config prometheus-rules -n "$namespace" --ignore-not-found=true
    kubectl delete pvc prometheus-storage -n "$namespace" --ignore-not-found=true
    kubectl delete serviceaccount prometheus -n "$namespace" --ignore-not-found=true
    
    # Remove Node Exporter resources
    echo "   🗑️  Removing Node Exporter resources..."
    kubectl delete daemonset node-exporter -n "$namespace" --ignore-not-found=true
    kubectl delete service node-exporter -n "$namespace" --ignore-not-found=true
    
    # Remove any remaining monitoring-related resources
    echo "   🗑️  Removing other monitoring resources..."
    kubectl delete all -l app=grafana -n "$namespace" --ignore-not-found=true
    kubectl delete all -l app=prometheus -n "$namespace" --ignore-not-found=true
    kubectl delete all -l app=node-exporter -n "$namespace" --ignore-not-found=true
    kubectl delete all -l app.kubernetes.io/name=grafana -n "$namespace" --ignore-not-found=true
    kubectl delete all -l app.kubernetes.io/name=prometheus -n "$namespace" --ignore-not-found=true
}

# Function to cleanup cluster-wide resources
cleanup_cluster_resources() {
    echo "🌐 Cleaning up cluster-wide resources..."
    
    # Remove RBAC resources
    kubectl delete clusterrole prometheus prometheus-kube-state-metrics --ignore-not-found=true
    kubectl delete clusterrolebinding prometheus prometheus-kube-state-metrics --ignore-not-found=true
    
    # Remove any monitoring-related CRDs (be careful with this)
    # kubectl delete crd prometheusrules.monitoring.coreos.com --ignore-not-found=true
    # kubectl delete crd servicemonitors.monitoring.coreos.com --ignore-not-found=true
}

# Function to find and display existing monitoring resources
scan_existing_resources() {
    echo "🔍 Scanning for existing monitoring resources..."
    echo ""
    
    echo "📊 Grafana resources found:"
    kubectl get all --all-namespaces -l app=grafana --no-headers 2>/dev/null || echo "   No Grafana resources found"
    kubectl get all --all-namespaces -l app.kubernetes.io/name=grafana --no-headers 2>/dev/null || true
    
    echo ""
    echo "📈 Prometheus resources found:"
    kubectl get all --all-namespaces -l app=prometheus --no-headers 2>/dev/null || echo "   No Prometheus resources found"
    kubectl get all --all-namespaces -l app.kubernetes.io/name=prometheus --no-headers 2>/dev/null || true
    
    echo ""
    echo "📋 Node Exporter resources found:"
    kubectl get all --all-namespaces -l app=node-exporter --no-headers 2>/dev/null || echo "   No Node Exporter resources found"
    
    echo ""
    echo "🗂️  ConfigMaps and Secrets:"
    kubectl get configmaps --all-namespaces | grep -E "(grafana|prometheus)" || echo "   No monitoring ConfigMaps found"
    kubectl get secrets --all-namespaces | grep -E "(grafana|prometheus)" || echo "   No monitoring Secrets found"
    
    echo ""
}

# Main execution
echo "🔍 Step 1: Scanning existing monitoring resources..."
scan_existing_resources

echo "⚠️  WARNING: This will delete all the resources shown above!"
confirm_cleanup

echo ""
echo "🚀 Step 2: Starting cleanup process..."

# Clean up common namespaces where monitoring might be deployed
NAMESPACES_TO_CHECK=("default" "ao" "monitoring" "kube-system" "prometheus" "grafana")

for ns in "${NAMESPACES_TO_CHECK[@]}"; do
    if kubectl get namespace "$ns" >/dev/null 2>&1; then
        cleanup_namespace "$ns"
    else
        echo "⏭️  Namespace $ns does not exist, skipping..."
    fi
done

echo ""
echo "🌐 Step 3: Cleaning up cluster-wide resources..."
cleanup_cluster_resources

echo ""
echo "🔍 Step 4: Verifying cleanup..."
echo "Remaining monitoring resources:"
kubectl get all --all-namespaces -l app=grafana,app=prometheus,app=node-exporter 2>/dev/null || echo "✅ No monitoring resources found"

echo ""
echo "📋 Final verification - checking specific resources:"
echo "Deployments:"
kubectl get deployments --all-namespaces | grep -E "(grafana|prometheus)" || echo "   ✅ No monitoring deployments"
echo "Services:"
kubectl get services --all-namespaces | grep -E "(grafana|prometheus)" || echo "   ✅ No monitoring services"
echo "ConfigMaps:"
kubectl get configmaps --all-namespaces | grep -E "(grafana|prometheus)" | head -5 || echo "   ✅ No monitoring configmaps"

echo ""
echo "✅ CLEANUP COMPLETED!"
echo ""
echo "🚀 Next steps:"
echo "   1. Deploy fresh Grafana: ./deployGrafana-ao.sh"
echo "   2. Verify deployment: kubectl get all -n ao"
echo "   3. Connect from local: ./connectGrafana-ao.sh"