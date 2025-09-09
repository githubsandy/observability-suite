#!/bin/bash

echo "🔍 Verifying Observability Stack Installation"
echo "============================================"
echo

NAMESPACE="kube-observability-stack"
RELEASE_NAME="observability-stack"

# Check if Helm release exists
echo "📦 Checking Helm release..."
if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo "✅ Helm release '$RELEASE_NAME' found in namespace '$NAMESPACE'"
    
    # Get release info
    echo
    helm status $RELEASE_NAME -n $NAMESPACE
else
    echo "❌ Helm release '$RELEASE_NAME' not found"
    echo "Available releases:"
    helm list -A
    exit 1
fi

echo
echo "🔍 Checking Kubernetes Resources..."
echo

# Check namespace
if kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "✅ Namespace '$NAMESPACE' exists"
else
    echo "❌ Namespace '$NAMESPACE' not found"
fi

# Check deployments
echo
echo "📊 Deployment Status:"
kubectl get deployments -n $NAMESPACE -o wide

echo
echo "🔧 Service Status:"
kubectl get services -n $NAMESPACE

echo
echo "💾 Storage Status:"
kubectl get pvc -n $NAMESPACE

echo
echo "🏃 Pod Status:"
kubectl get pods -n $NAMESPACE -o wide

# Count running pods
TOTAL_PODS=$(kubectl get pods -n $NAMESPACE --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods -n $NAMESPACE --no-headers | grep Running | wc -l)

echo
echo "📈 Summary:"
echo "   Total Pods: $TOTAL_PODS"
echo "   Running Pods: $RUNNING_PODS"

if [ $RUNNING_PODS -eq $TOTAL_PODS ] && [ $TOTAL_PODS -gt 0 ]; then
    echo "✅ All pods are running successfully!"
    echo
    echo "🚀 Ready to start port forwarding:"
    echo "   ./start-observability.sh"
    echo
    echo "🔗 Then access Grafana at: http://localhost:3000 (admin/admin)"
else
    echo "⚠️  Some pods are not running. Check pod logs:"
    echo "   kubectl logs -n $NAMESPACE <pod-name>"
fi

echo
echo "🛠️  Useful Commands:"
echo "   helm status $RELEASE_NAME -n $NAMESPACE"
echo "   kubectl get all -n $NAMESPACE"
echo "   kubectl logs -n $NAMESPACE -l app=grafana"
echo "   helm uninstall $RELEASE_NAME -n $NAMESPACE"