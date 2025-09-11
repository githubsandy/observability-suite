#!/bin/bash

# CALO Lab Observability Stack Installer
# ======================================
# Deploys comprehensive observability stack with:
# - Prometheus, Grafana, Loki, Alertmanager, Tempo
# - Node, Blackbox, MongoDB, PostgreSQL, Redis exporters  
# - MTR network analysis and Smokeping monitoring
# - Production-ready configuration for CALO lab environment

echo "🚀 CALO Lab Observability Stack Installer"
echo "=========================================="
echo

# Default values
RELEASE_NAME="ao-observability"
NAMESPACE="ao-os"
CHART_DIR="./helm-kube-observability-stack"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first."
    echo "   Visit: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    echo "   Visit: https://kubernetes.io/docs/tasks/tools/install-kubectl/"
    exit 1
fi

# Check if Kubernetes cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot access Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo

# Check for Longhorn storage (CALO lab requirement)
echo "🔍 Checking CALO lab environment..."
if kubectl get storageclass longhorn-single &> /dev/null; then
    echo "✅ Longhorn storage class found"
else
    echo "⚠️  Warning: Longhorn storage class 'longhorn-single' not found"
    echo "   This may cause PVC mounting issues"
fi

# Check for observability node labels (optional)
NODE_COUNT=$(kubectl get nodes -l ao-node=observability --no-headers 2>/dev/null | wc -l)
if [ "$NODE_COUNT" -gt 0 ]; then
    echo "✅ Found $NODE_COUNT observability node(s)"
else
    echo "ℹ️  No dedicated observability nodes labeled (optional)"
fi
echo

# Check if chart directory exists
if [ ! -d "$CHART_DIR" ]; then
    echo "❌ Chart directory $CHART_DIR not found."
    echo "   Please make sure you have the Helm chart directory in the current location."
    exit 1
fi

echo "📦 Found chart directory: $CHART_DIR"
echo

# Prepare for installation
echo "🔧 Preparing installation..."
echo "   Removing conflicting namespace template if exists"
rm -f $CHART_DIR/templates/000_namespace.yaml

# Install the Helm chart
echo "🚀 Installing Observability Stack..."
echo "   Release Name: $RELEASE_NAME"
echo "   Namespace: $NAMESPACE"
echo "   Chart Directory: $CHART_DIR"
echo

helm install $RELEASE_NAME $CHART_DIR --namespace $NAMESPACE --create-namespace

if [ $? -eq 0 ]; then
    echo
    echo "✅ Installation completed successfully!"
    echo
    echo "📋 Next Steps:"
    echo "1. Wait for all pods to be ready:"
    echo "   kubectl get pods -n $NAMESPACE -w"
    echo
    echo "2. Check deployment status:"
    echo "   helm status $RELEASE_NAME -n $NAMESPACE"
    echo
    echo "3. Verify all services are running:"
    echo "   kubectl get all -n $NAMESPACE"
    echo
    echo "4. Access services via NodePort (replace YOUR-NODE-IP with actual cluster IP):"
    echo "   Grafana:      http://YOUR-NODE-IP:30300 (admin/admin)"
    echo "   Prometheus:   http://YOUR-NODE-IP:30090"
    echo "   Loki:         http://YOUR-NODE-IP:30310"
    echo "   Alertmanager: http://YOUR-NODE-IP:30930"
    echo "   Tempo:        http://YOUR-NODE-IP:30320"
    echo "   Blackbox:     http://YOUR-NODE-IP:30115"
    echo
    echo "5. Get cluster node IP:"
    echo "   kubectl get nodes -o wide"
    echo
    echo "🔗 For detailed setup guide, see: README.md"
else
    echo "❌ Installation failed. Check the error messages above."
    exit 1
fi