#!/bin/bash

echo "🚀 Kubernetes Observability Stack Installer"
echo "============================================="
echo

# Default values
RELEASE_NAME="observability-stack"
NAMESPACE="kube-observability-stack"
PACKAGE_FILE="kube-observability-stack-1.0.0.tgz"

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

# Check if package file exists
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "❌ Package file $PACKAGE_FILE not found."
    echo "   Please make sure you have the Helm package in the current directory."
    exit 1
fi

echo "📦 Found package: $PACKAGE_FILE"
echo

# Install the Helm chart
echo "🚀 Installing Observability Stack..."
echo "   Release Name: $RELEASE_NAME"
echo "   Namespace: $NAMESPACE"
echo

helm install $RELEASE_NAME ./$PACKAGE_FILE --namespace $NAMESPACE --create-namespace

if [ $? -eq 0 ]; then
    echo
    echo "✅ Installation completed successfully!"
    echo
    echo "📋 Next Steps:"
    echo "1. Wait for all pods to be ready:"
    echo "   kubectl get pods -n $NAMESPACE -w"
    echo
    echo "2. Start port forwarding:"
    echo "   chmod +x start-observability.sh"
    echo "   ./start-observability.sh"
    echo
    echo "3. Check service status:"
    echo "   chmod +x check-services.sh"
    echo "   ./check-services.sh"
    echo
    echo "4. Access Grafana:"
    echo "   URL: http://localhost:3000"
    echo "   Username: admin"
    echo "   Password: admin"
    echo
    echo "🔗 For detailed setup guide, see: HELM_PACKAGE_GUIDE.md"
else
    echo "❌ Installation failed. Check the error messages above."
    exit 1
fi