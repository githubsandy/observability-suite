#!/bin/bash

set -e

echo "🚀 Deploying Prometheus to AO Namespace (CXTM Environment)..."

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

echo "🔧 Deploying Prometheus..."
kubectl apply -f prometheus-deployment.yaml

echo "⏳ Waiting for Prometheus to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n ao

echo "✅ Prometheus deployment completed successfully!"
echo ""
echo "📊 Deployment Status:"
kubectl get pods,svc -n ao | grep prometheus
echo ""
echo "🌐 Access Information:"
echo "   Prometheus NodePort: 30090"
echo "   Prometheus URL: http://10.122.28.111:30090/"
echo ""
echo "📊 Verify Prometheus is running:"
echo "   kubectl get pods -n ao | grep prometheus"
echo "   kubectl logs -n ao deployment/prometheus --tail=20"
echo ""
echo "🔗 Next step: Update Grafana data sources"
echo "   kubectl apply -f grafana-config.yaml"
echo "   kubectl rollout restart deployment/grafana -n ao"