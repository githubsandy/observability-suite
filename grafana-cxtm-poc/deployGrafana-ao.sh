#!/bin/bash

set -e

echo "🚀 Deploying Grafana to AO Namespace (CXTM Environment)..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

echo "📋 Checking Kubernetes cluster status..."
kubectl cluster-info

echo "📂 Checking if ao namespace exists..."
if kubectl get namespace ao >/dev/null 2>&1; then
    echo "✅ ao namespace exists"
else
    echo "❌ ao namespace does not exist. Creating..."
    kubectl create namespace ao
fi

echo "🔧 Applying Grafana configuration..."
kubectl apply -f grafana-config.yaml

echo "🚀 Deploying Grafana..."
kubectl apply -f grafana-deployment.yaml

echo "⏳ Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n ao

echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Deployment Status:"
kubectl get pods,svc -n ao | grep grafana
echo ""
echo "🌐 Access Information:"
echo "   Grafana NodePort: 30300"
echo "   Grafana URL: http://10.122.28.111:30300/ (if directly accessible)"
echo "   Or use SSH tunnel: ./connect-ao.sh"
echo ""
echo "🔑 Grafana credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "📊 Check deployment status:"
echo "   kubectl get pods -n ao"
echo "   kubectl get svc -n ao"
echo "   kubectl logs -n ao deployment/grafana"