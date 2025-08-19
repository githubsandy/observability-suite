#!/bin/bash

set -e

echo "Deploying Complete Monitoring Stack to AO Namespace..."

# Check prerequisites
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check cluster connectivity
kubectl cluster-info

# Create namespace if needed
if kubectl get namespace ao >/dev/null 2>&1; then
    echo "Namespace ao exists"
else
    echo "Creating ao namespace..."
    kubectl create namespace ao
fi

# Deploy Prometheus
echo "Deploying Prometheus..."
kubectl apply -f prometheus-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n ao

# Deploy/Update Grafana with data source
echo "Updating Grafana configuration..."
kubectl apply -f grafana-config.yaml
kubectl apply -f grafana-deployment.yaml

# Restart Grafana to pick up changes
echo "Restarting Grafana..."
kubectl rollout restart deployment/grafana -n ao
kubectl rollout status deployment/grafana -n ao

# Show final status
echo ""
echo "Deployment completed successfully!"
echo ""
echo "Status:"
kubectl get pods,svc -n ao

echo ""
echo "Access URLs:"
echo "  Grafana: http://10.122.28.111:30300/ (admin/admin123)"
echo "  Prometheus: http://10.122.28.111:30090/"

echo ""
echo "Dashboard Import:"
echo "  1. Go to Grafana URL above"
echo "  2. Navigate to Dashboards -> Import"
echo "  3. Upload JSON files from dashboards/ folder"
echo "  4. Select 'Prometheus' as data source"

echo ""
echo "Verify deployment:"
echo "  kubectl get all -n ao"
echo "  kubectl logs -n ao deployment/grafana"
echo "  kubectl logs -n ao deployment/prometheus"