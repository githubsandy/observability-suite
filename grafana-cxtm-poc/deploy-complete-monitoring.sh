#!/bin/bash

set -e

echo "🚀 Deploying Complete Monitoring Stack to AO Namespace..."
echo "   📊 Grafana (update data sources)"
echo "   📈 Prometheus (new deployment)"
echo ""

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

echo ""
echo "🎯 Step 1: Deploying Prometheus..."
kubectl apply -f prometheus-deployment.yaml

echo "⏳ Waiting for Prometheus to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n ao

echo ""
echo "🎯 Step 2: Updating Grafana with Prometheus data source..."
kubectl apply -f grafana-config.yaml

echo "🔄 Restarting Grafana to pick up new data source..."
kubectl rollout restart deployment/grafana -n ao
kubectl rollout status deployment/grafana -n ao

echo ""
echo "✅ Complete monitoring stack deployment finished!"
echo ""
echo "📊 Final Status Check:"
kubectl get pods,svc -n ao
echo ""
echo "🌐 Access Information:"
echo "   📊 Grafana: http://10.122.28.111:30300/ (admin/admin123)"
echo "   📈 Prometheus: http://10.122.28.111:30090/"
echo ""
echo "🎯 Ready to import dashboards!"
echo "   1. Go to Grafana: http://10.122.28.111:30300/"
echo "   2. Navigate to Dashboards → Import"
echo "   3. Upload JSON files from the dashboards/ folder"
echo "   4. Select 'Prometheus' as the data source"
echo ""
echo "📁 Available dashboard files:"
ls -1 dashboards/*.json | sed 's/^/   /'
echo ""
echo "🔍 Verify setup:"
echo "   kubectl get all -n ao"
echo "   kubectl logs -n ao deployment/prometheus --tail=10"
echo "   kubectl logs -n ao deployment/grafana --tail=10"