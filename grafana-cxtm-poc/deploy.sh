#!/bin/bash

set -e

echo "🚀 Deploying Prometheus and Grafana to CXTM Lab..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo " kubectl is not installed or not in PATH"
    exit 1
fi

echo "Checking Kubernetes cluster status..."
kubectl cluster-info

echo " Applying Prometheus configuration..."
kubectl apply -f prometheus-config.yaml

echo " Deploying Prometheus..."
kubectl apply -f prometheus-deployment.yaml

echo " Waiting for Prometheus to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus

echo " Deploying Node Exporter..."
kubectl apply -f node-exporter.yaml

echo " Waiting for Node Exporter to be ready..."
kubectl wait --for=condition=ready --timeout=300s pod -l app=node-exporter

echo " Applying Grafana configuration..."
kubectl apply -f grafana-config.yaml

echo " Deploying Grafana..."
kubectl apply -f grafana-deployment.yaml

echo " Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/grafana

echo " Deployment completed successfully!"
echo ""
echo " Access URLs:"
echo "   Prometheus: http://localhost:30090/"
echo "   Grafana:    http://localhost:3000/"
echo ""
echo " Grafana credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo " Check deployment status:"
echo "   kubectl get pods -l app=prometheus"
echo "   kubectl get pods -l app=node-exporter"
echo "   kubectl get pods -l app=grafana"
echo "   kubectl get svc prometheus node-exporter grafana"
echo ""
echo " Get node IP address:"
echo "   kubectl get nodes -o wide"