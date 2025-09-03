#!/bin/bash

# Enhanced Observability Stack Installation Verifier
# Supports dynamic configuration and comprehensive checks

# Configuration
DEFAULT_NAMESPACE="ao"
DEFAULT_RELEASE_NAME="observability-stack"

RELEASE_NAME="${1:-$DEFAULT_RELEASE_NAME}"
NAMESPACE="${2:-$DEFAULT_NAMESPACE}"

echo "🔍 Enhanced Observability Stack Installation Verification"
echo "========================================================"
echo "🏷️  Release Name: $RELEASE_NAME"
echo "📦 Namespace: $NAMESPACE"
echo "========================================================"
echo

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    # Check if Helm is installed
    if ! command -v helm &> /dev/null; then
        echo "❌ Helm is not installed"
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl is not installed"
        exit 1
    fi
    
    # Check if Kubernetes cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ Cannot access Kubernetes cluster"
        exit 1
    fi
    
    echo "✅ Prerequisites check passed"
    echo
}

# Check if Helm release exists
check_helm_release() {
    echo "📦 Checking Helm release..."
    if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
        echo "✅ Helm release '$RELEASE_NAME' found in namespace '$NAMESPACE'"
        
        # Get release info
        echo
        echo "📊 Release Status:"
        helm status $RELEASE_NAME -n $NAMESPACE
        echo
    else
        echo "❌ Helm release '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
        echo
        echo "Available releases:"
        helm list -A
        echo
        echo "💡 To install the stack:"
        echo "   ./install-observability-stack.sh $RELEASE_NAME $NAMESPACE"
        exit 1
    fi
}

# Check Kubernetes resources
check_kubernetes_resources() {
    echo "🔍 Checking Kubernetes Resources..."
    echo
    
    # Check namespace
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        echo "✅ Namespace '$NAMESPACE' exists"
    else
        echo "❌ Namespace '$NAMESPACE' not found"
        return 1
    fi
    
    echo
    echo "📊 Resource Status:"
    echo "=================="
    
    # Check deployments
    echo
    echo "🚀 Deployments:"
    kubectl get deployments -n $NAMESPACE -o wide 2>/dev/null
    
    echo
    echo "🔧 Services:"
    kubectl get services -n $NAMESPACE 2>/dev/null
    
    echo
    echo "💾 Persistent Volume Claims:"
    kubectl get pvc -n $NAMESPACE 2>/dev/null
    
    echo
    echo "🏃 Pod Status:"
    kubectl get pods -n $NAMESPACE -o wide 2>/dev/null
}

# Enhanced pod analysis
analyze_pods() {
    echo
    echo "📈 Enhanced Pod Analysis:"
    echo "========================"
    
    # Count pods by status
    local total_pods=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
    local running_pods=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | grep Running | wc -l)
    local pending_pods=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | grep Pending | wc -l)
    local failed_pods=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | grep -E "Failed|Error|CrashLoopBackOff" | wc -l)
    
    echo "   📊 Total Pods: $total_pods"
    echo "   ✅ Running: $running_pods"
    echo "   ⏳ Pending: $pending_pods"
    echo "   ❌ Failed: $failed_pods"
    
    # Overall health assessment
    if [ $total_pods -eq 0 ]; then
        echo
        echo "⚠️  No pods found. The installation may not have completed."
        echo "💡 Try running: ./install-observability-stack.sh $RELEASE_NAME $NAMESPACE"
        return 1
    elif [ $running_pods -eq $total_pods ]; then
        echo
        echo "🎉 All pods are running successfully!"
        echo
        echo "🚀 Ready to start services:"
        echo "   ./start-portForwarding-allService.sh $NAMESPACE"
        echo
        echo "🔍 Check service health:"
        echo "   ./check-services.sh $NAMESPACE"
        echo
        echo "🌟 Access Grafana:"
        echo "   http://localhost:3000 (admin/admin)"
    elif [ $pending_pods -gt 0 ]; then
        echo
        echo "⏳ Some pods are still starting up..."
        echo "💡 Wait a few minutes for images to download and containers to start"
        echo "🔍 Monitor progress: kubectl get pods -n $NAMESPACE -w"
    else
        echo
        echo "⚠️  Some pods have issues. Troubleshooting:"
        echo "🔍 Check failed pods: kubectl get pods -n $NAMESPACE | grep -v Running"
        echo "📋 Check events: kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp"
        echo "📝 Check logs: kubectl logs -n $NAMESPACE <pod-name>"
    fi
}

# Main execution
main() {
    check_prerequisites
    check_helm_release
    
    if check_kubernetes_resources; then
        analyze_pods
    fi
    
    echo
    echo "==============================================="
    echo "🛠️  Useful Commands:"
    echo "==============================================="
    echo "   Helm Status:     helm status $RELEASE_NAME -n $NAMESPACE"
    echo "   All Resources:   kubectl get all -n $NAMESPACE"
    echo "   Watch Pods:      kubectl get pods -n $NAMESPACE -w"
    echo "   Grafana Logs:    kubectl logs -n $NAMESPACE -l app=grafana"
    echo "   Prometheus Logs: kubectl logs -n $NAMESPACE -l app=prometheus"
    echo "   Uninstall:       helm uninstall $RELEASE_NAME -n $NAMESPACE"
    echo
    echo "🚀 Next Steps:"
    echo "   1. ./start-portForwarding-allService.sh $NAMESPACE"
    echo "   2. ./check-services.sh $NAMESPACE"  
    echo "   3. Open http://localhost:3000 (admin/admin)"
    echo "==============================================="
}

# Help function
show_help() {
    echo "Enhanced Observability Stack Installation Verifier"
    echo
    echo "Usage: $0 [RELEASE_NAME] [NAMESPACE]"
    echo
    echo "Arguments:"
    echo "  RELEASE_NAME    Helm release name (default: $DEFAULT_RELEASE_NAME)"
    echo "  NAMESPACE       Kubernetes namespace (default: $DEFAULT_NAMESPACE)"
    echo
    echo "Examples:"
    echo "  $0                           # Use defaults (ao namespace)"
    echo "  $0 obs-stack ao              # Custom release, ao namespace"
    echo "  $0 monitoring observability  # Custom release and namespace"
}

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Execute main function
main