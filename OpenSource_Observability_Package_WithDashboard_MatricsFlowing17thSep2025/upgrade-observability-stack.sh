#!/bin/bash

# ===============================================================================
# 🔄 OBSERVABILITY SUITE - HELM UPGRADE SCRIPT
# ===============================================================================
# Simple script to upgrade existing deployment with current values.yaml
# Use after running deploy-observability-stack.sh to apply configuration changes
# ===============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="customer-config.env"
CHART_DIR="./helm-kube-observability-stack"
RELEASE_NAME="ao-observability"

echo -e "${BLUE}🔄 Observability Suite - Helm Upgrade${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check if config file exists to get namespace
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Error: $CONFIG_FILE not found!${NC}"
    exit 1
fi

# Load configuration to get namespace
source "$CONFIG_FILE"
KUBERNETES_NAMESPACE=${KUBERNETES_NAMESPACE:-ao-os}

echo -e "${CYAN}📦 Release: $RELEASE_NAME${NC}"
echo -e "${CYAN}🏗️  Namespace: $KUBERNETES_NAMESPACE${NC}"
echo -e "${CYAN}📁 Chart: $CHART_DIR${NC}"
echo ""

# Check if deployment exists
if ! helm status $RELEASE_NAME -n $KUBERNETES_NAMESPACE &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: No existing deployment found.${NC}"
    echo -e "${YELLOW}💡 Use ./deploy-observability-stack.sh for initial deployment${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Running Helm upgrade...${NC}"
helm upgrade $RELEASE_NAME $CHART_DIR --namespace $KUBERNETES_NAMESPACE

# Optional: Force restart pods to pick up ConfigMap changes
# Uncomment the lines below if you want to ensure ALL config changes are applied
# echo -e "${CYAN}♻️  Restarting pods to pick up config changes...${NC}"
# kubectl rollout restart deployment -n $KUBERNETES_NAMESPACE

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Helm upgrade completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}🔍 Check status: helm status $RELEASE_NAME -n $KUBERNETES_NAMESPACE${NC}"
    echo -e "${CYAN}👀 Watch pods: kubectl get pods -n $KUBERNETES_NAMESPACE -w${NC}"
    echo ""
    if [ -n "$KUBERNETES_NODE_IP" ]; then
        echo -e "${BLUE}🌐 Access Grafana: http://$KUBERNETES_NODE_IP:30300${NC}"
    fi
else
    echo -e "${RED}❌ Helm upgrade failed. Check the error messages above.${NC}"
    exit 1
fi