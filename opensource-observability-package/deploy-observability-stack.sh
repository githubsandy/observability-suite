#!/bin/bash

# ===============================================================================
# 🚀 OBSERVABILITY SUITE - COMPLETE DEPLOYMENT SCRIPT
# ===============================================================================
# ONE SCRIPT DOES EVERYTHING:
# 1. Reads customer-config.env
# 2. Applies all configurations
# 3. Enables NodePort access
# 4. Deploys with Helm
# 5. Shows access URLs
#
# Customer experience: Edit customer-config.env → Run this script → Done!
# ===============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration files
CONFIG_FILE="customer-config.env"
VALUES_FILE="helm-kube-observability-stack/values.yaml"
BACKUP_FILE="helm-kube-observability-stack/values.yaml.backup-$(date +%Y%m%d-%H%M%S)"
CHART_DIR="./helm-kube-observability-stack"
RELEASE_NAME="ao-observability"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║               🚀 OBSERVABILITY SUITE DEPLOYER                    ║${NC}"
echo -e "${BLUE}║                                                                  ║${NC}"
echo -e "${BLUE}║          Customer Config → Auto Deploy → Direct Access          ║${NC}"
echo -e "${BLUE}║                     One Script Does Everything!                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ===============================================================================
# STEP 1: VALIDATE ENVIRONMENT & PREREQUISITES
# ===============================================================================

echo -e "${PURPLE}🔍 STEP 1: VALIDATING ENVIRONMENT${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Error: $CONFIG_FILE not found!${NC}"
    echo -e "${YELLOW}Please ensure customer-config.env is in the current directory.${NC}"
    exit 1
fi

# Check if values.yaml exists
if [ ! -f "$VALUES_FILE" ]; then
    echo -e "${RED}❌ Error: $VALUES_FILE not found!${NC}"
    echo -e "${YELLOW}Please run this script from the project root directory.${NC}"
    exit 1
fi

# Check if chart directory exists
if [ ! -d "$CHART_DIR" ]; then
    echo -e "${RED}❌ Error: Chart directory $CHART_DIR not found.${NC}"
    exit 1
fi

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm is not installed. Please install Helm first.${NC}"
    echo -e "${YELLOW}   Visit: https://helm.sh/docs/intro/install/${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if Kubernetes cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot access Kubernetes cluster. Please check your kubeconfig.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Environment validation passed${NC}"
echo ""

# ===============================================================================
# STEP 2: LOAD AND VALIDATE CUSTOMER CONFIGURATION
# ===============================================================================

echo -e "${PURPLE}📋 STEP 2: LOADING CUSTOMER CONFIGURATION${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${CYAN}📋 Reading customer configuration from: $CONFIG_FILE${NC}"

# Load customer configuration
source "$CONFIG_FILE"

# Validate required fields
echo -e "${CYAN}🔍 Validating customer configuration...${NC}"

# Check Kubernetes node IP
if [ "$KUBERNETES_NODE_IP" = "YOUR_NODE_IP_HERE" ] || [ -z "$KUBERNETES_NODE_IP" ]; then
    echo -e "${RED}❌ Error: KUBERNETES_NODE_IP must be set to your actual node IP${NC}"
    echo -e "${YELLOW}💡 Update KUBERNETES_NODE_IP in customer-config.env${NC}"
    exit 1
fi

# Validate IP format (basic check)
if [[ ! $KUBERNETES_NODE_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ Error: KUBERNETES_NODE_IP format appears invalid: $KUBERNETES_NODE_IP${NC}"
    echo -e "${YELLOW}💡 Please use format like: 192.168.1.100${NC}"
    exit 1
fi

# Set default namespace if not provided
if [ -z "$KUBERNETES_NAMESPACE" ]; then
    KUBERNETES_NAMESPACE="ao-os"
    echo -e "${YELLOW}💡 Using default namespace: $KUBERNETES_NAMESPACE${NC}"
fi

# Validate ServiceNow if enabled
if [ "$SERVICENOW_ENABLED" = "true" ]; then
    if [ -z "$SERVICENOW_INSTANCE" ] || [ -z "$SERVICENOW_USERNAME" ] || [ "$SERVICENOW_INSTANCE" = "your-company.service-now.com" ]; then
        echo -e "${RED}❌ Error: SERVICENOW_ENABLED=true but ServiceNow credentials are not configured${NC}"
        echo -e "${YELLOW}💡 Update ServiceNow settings in customer-config.env${NC}"
        exit 1
    fi
fi

# Validate WebEx if enabled
if [ "$WEBEX_ENABLED" = "true" ]; then
    if [ -z "$WEBEX_BOT_TOKEN" ] || [ -z "$WEBEX_ROOM_ID" ] || [ "$WEBEX_BOT_TOKEN" = "YOUR_WEBEX_BOT_TOKEN_HERE" ]; then
        echo -e "${RED}❌ Error: WEBEX_ENABLED=true but WebEx credentials are not configured${NC}"
        echo -e "${YELLOW}💡 Update WebEx settings in customer-config.env${NC}"
        exit 1
    fi
fi

# Validate cluster profile
if [ -n "$CLUSTER_PROFILE" ]; then
    if [[ ! "$CLUSTER_PROFILE" =~ ^(small|medium|large)$ ]]; then
        echo -e "${RED}❌ Error: CLUSTER_PROFILE must be one of: small, medium, large${NC}"
        echo -e "${YELLOW}💡 Current value: $CLUSTER_PROFILE${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Configuration validation passed${NC}"
echo ""

# ===============================================================================
# STEP 3: APPLY CONFIGURATION & ENABLE NODEPORT
# ===============================================================================

echo -e "${PURPLE}⚙️ STEP 3: APPLYING CONFIGURATION${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create backup
echo -e "${YELLOW}📋 Creating backup of values.yaml...${NC}"
cp "$VALUES_FILE" "$BACKUP_FILE"
echo -e "${GREEN}✅ Backup created: $BACKUP_FILE${NC}"

# Create temporary file for processing
temp_file=$(mktemp)
cp "$VALUES_FILE" "$temp_file"

# Apply Kubernetes node IP
echo -e "${CYAN}🌐 Setting Kubernetes node IP: $KUBERNETES_NODE_IP${NC}"
sed -i.tmp "s/node_ip: \"YOUR-NODE-IP\"/node_ip: \"$KUBERNETES_NODE_IP\"/" "$temp_file"
sed -i.tmp "s/grafana_url: \"YOUR-NODE-IP:30300\"/grafana_url: \"$KUBERNETES_NODE_IP:30300\"/" "$temp_file"
sed -i.tmp "s/prometheus_url: \"YOUR-NODE-IP:30090\"/prometheus_url: \"$KUBERNETES_NODE_IP:30090\"/" "$temp_file"

# Enable NodePort access automatically
echo -e "${CYAN}🌐 Enabling NodePort access for direct IP access${NC}"
sed -i.tmp 's/type: ClusterIP.*# Change to NodePort for direct access/type: NodePort            # Direct IP access enabled/' "$temp_file"
sed -i.tmp 's/type: ClusterIP$/type: NodePort            # Direct IP access enabled/' "$temp_file"

# Enable Grafana alerting if any notifications are enabled
if [ "$SERVICENOW_ENABLED" = "true" ] || [ "$WEBEX_ENABLED" = "true" ]; then
    echo -e "${CYAN}🚨 Enabling Grafana native alerting${NC}"
    sed -i.tmp "s/enabled: false  # Set to true to enable Grafana alerting/enabled: true/" "$temp_file"
fi

# Apply ServiceNow configuration
if [ "$SERVICENOW_ENABLED" = "true" ]; then
    echo -e "${CYAN}🎫 Configuring ServiceNow integration: ${SERVICENOW_INSTANCE}${NC}"
    sed -i.tmp "/servicenow:/,/^  [a-zA-Z]/ {
        s/enabled: false  # Set to true to enable ServiceNow integration/enabled: true/
        s/instance: \"your-instance.service-now.com\"/instance: \"$SERVICENOW_INSTANCE\"/
        s/username: \"servicenow_user\"/username: \"$SERVICENOW_USERNAME\"/
        s/password: \"servicenow_password\"/password: \"$SERVICENOW_PASSWORD\"/
        s/assignment_group: \"IT Operations\"/assignment_group: \"$SERVICENOW_ASSIGNMENT_GROUP\"/
        s/caller_id: \"system.observability\"/caller_id: \"$SERVICENOW_CALLER_ID\"/
    }" "$temp_file"
else
    echo -e "${YELLOW}⏭️  ServiceNow integration: Disabled${NC}"
fi

# Apply WebEx configuration
if [ "$WEBEX_ENABLED" = "true" ]; then
    echo -e "${CYAN}💬 Configuring WebEx Teams integration${NC}"
    sed -i.tmp "/webex:/,/^  [a-zA-Z]\\|^[a-zA-Z]/ {
        s/enabled: false  # Set to true to enable WebEx integration/enabled: true/
        s/bot_token: \"YOUR_WEBEX_BOT_TOKEN_HERE\"/bot_token: \"$WEBEX_BOT_TOKEN\"/
        s/room_id: \"YOUR_WEBEX_ROOM_ID_HERE\"/room_id: \"$WEBEX_ROOM_ID\"/
    }" "$temp_file"
else
    echo -e "${YELLOW}⏭️  WebEx Teams integration: Disabled${NC}"
fi

# Apply resource sizing, storage, monitoring scope, and company information
# (All the configuration logic from apply-customer-config.sh)

# Apply resource sizing configuration
if [ -n "$CLUSTER_PROFILE" ]; then
    echo -e "${CYAN}⚙️  Setting cluster profile: $CLUSTER_PROFILE${NC}"
    case $CLUSTER_PROFILE in
        "small")
            sed -i.tmp 's/cpu: 500m/cpu: 250m/g; s/memory: 512Mi/memory: 256Mi/g' "$temp_file"
            ;;
        "medium")
            echo -e "${CYAN}   Using default medium cluster settings${NC}"
            ;;
        "large")
            sed -i.tmp 's/cpu: 500m/cpu: 1000m/g; s/memory: 512Mi/memory: 1Gi/g' "$temp_file"
            ;;
    esac
fi

# Apply storage, monitoring, and company configurations
if [ -n "$GRAFANA_STORAGE_SIZE" ]; then
    echo -e "${CYAN}💾 Setting Grafana storage: $GRAFANA_STORAGE_SIZE${NC}"
    sed -i.tmp "s/size: 10Gi/size: $GRAFANA_STORAGE_SIZE/" "$temp_file"
fi

if [ -n "$COMPANY_NAME" ] && [ "$COMPANY_NAME" != "Your Company Name" ]; then
    echo -e "${CYAN}🏢 Setting company name: $COMPANY_NAME${NC}"
fi

# Apply alert thresholds if specified
if [ -n "$ALERT_POD_CRASH_THRESHOLD" ]; then
    sed -i.tmp "s/pod_crash_threshold: 5/pod_crash_threshold: $ALERT_POD_CRASH_THRESHOLD/" "$temp_file"
fi
if [ -n "$ALERT_MEMORY_THRESHOLD" ]; then
    MEMORY_DECIMAL=$(echo "scale=2; $ALERT_MEMORY_THRESHOLD / 100" | bc -l)
    sed -i.tmp "s/memory_threshold: 0.9/memory_threshold: $MEMORY_DECIMAL/" "$temp_file"
fi

# Remove temporary sed backup files and replace original
rm -f "$temp_file.tmp"
mv "$temp_file" "$VALUES_FILE"

echo -e "${GREEN}✅ All configurations applied successfully!${NC}"
echo ""

# ===============================================================================
# STEP 4: DEPLOY WITH HELM
# ===============================================================================

echo -e "${PURPLE}🚀 STEP 4: DEPLOYING OBSERVABILITY STACK${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${CYAN}📦 Deploying observability stack...${NC}"
echo -e "${CYAN}   Release Name: $RELEASE_NAME${NC}"
echo -e "${CYAN}   Namespace: $KUBERNETES_NAMESPACE${NC}"
echo -e "${CYAN}   Chart Directory: $CHART_DIR${NC}"
echo ""

# Remove any conflicting namespace template
rm -f $CHART_DIR/templates/000_namespace.yaml

# Deploy with Helm
helm install $RELEASE_NAME $CHART_DIR --namespace $KUBERNETES_NAMESPACE --create-namespace

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
    echo ""
else
    echo -e "${RED}❌ Deployment failed. Check the error messages above.${NC}"
    exit 1
fi

# ===============================================================================
# STEP 5: SHOW RESULTS & ACCESS INFORMATION
# ===============================================================================

echo -e "${PURPLE}🎉 STEP 5: DEPLOYMENT COMPLETE - ACCESS INFORMATION${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Display configuration summary
echo -e "${BLUE}📊 DEPLOYMENT SUMMARY${NC}"
echo "────────────────────────────────────────────────────────────────────────"
echo -e "${CYAN}🌐 Kubernetes Node IP:${NC} $KUBERNETES_NODE_IP"
echo -e "${CYAN}🏗️  Namespace:${NC} $KUBERNETES_NAMESPACE"
echo -e "${CYAN}⚙️  Cluster Profile:${NC} ${CLUSTER_PROFILE:-medium}"
echo -e "${CYAN}🏢 Company Name:${NC} ${COMPANY_NAME:-Your Company Name}"
echo -e "${CYAN}🎫 ServiceNow:${NC} $([ "$SERVICENOW_ENABLED" = "true" ] && echo "✅ Enabled" || echo "❌ Disabled")"
echo -e "${CYAN}💬 WebEx Teams:${NC} $([ "$WEBEX_ENABLED" = "true" ] && echo "✅ Enabled" || echo "❌ Disabled")"
echo -e "${CYAN}🌐 Access Method:${NC} NodePort (Direct IP - No port forwarding needed)"
echo ""

# Service access URLs
echo -e "${BLUE}🌐 SERVICE ACCESS URLs (Ready to Use!)${NC}"
echo "────────────────────────────────────────────────────────────────────────"
echo -e "${GREEN}📊 Grafana (Dashboards + Alerting):${NC} http://$KUBERNETES_NODE_IP:30300"
echo -e "   └─ Login: admin / admin"
echo -e "${GREEN}📈 Prometheus (Metrics):${NC} http://$KUBERNETES_NODE_IP:30090"
echo -e "${GREEN}🔍 Tempo (Tracing):${NC} http://$KUBERNETES_NODE_IP:30320"
echo -e "${GREEN}📡 Smokeping (Network):${NC} http://$KUBERNETES_NODE_IP:30800"
echo -e "${GREEN}📋 Loki (Logs):${NC} http://$KUBERNETES_NODE_IP:30310"
echo -e "${GREEN}🔧 Blackbox (Endpoints):${NC} http://$KUBERNETES_NODE_IP:30115"

if [ "$SERVICENOW_ENABLED" = "true" ]; then
    echo -e "${GREEN}🎫 ServiceNow Webhook:${NC} http://$KUBERNETES_NODE_IP:30950"
fi
if [ "$WEBEX_ENABLED" = "true" ]; then
    echo -e "${GREEN}💬 WebEx Webhook:${NC} http://$KUBERNETES_NODE_IP:30951"
fi
echo ""

# Verification commands
echo -e "${BLUE}🔍 VERIFICATION COMMANDS${NC}"
echo "────────────────────────────────────────────────────────────────────────"
echo -e "${YELLOW}1.${NC} Check all pods are running:"
echo "   ${CYAN}kubectl get pods -n $KUBERNETES_NAMESPACE${NC}"
echo ""
echo -e "${YELLOW}2.${NC} Check deployment status:"
echo "   ${CYAN}helm status $RELEASE_NAME -n $KUBERNETES_NAMESPACE${NC}"
echo ""
echo -e "${YELLOW}3.${NC} Watch pods starting up:"
echo "   ${CYAN}kubectl get pods -n $KUBERNETES_NAMESPACE -w${NC}"
echo ""

# Test notification instructions
if [ "$SERVICENOW_ENABLED" = "true" ] || [ "$WEBEX_ENABLED" = "true" ]; then
    echo -e "${BLUE}🧪 TEST YOUR NOTIFICATIONS${NC}"
    echo "────────────────────────────────────────────────────────────────────────"
    echo -e "${YELLOW}Trigger a test alert (causes Prometheus to go down for 3 minutes):${NC}"
    echo "   ${CYAN}kubectl scale deployment prometheus --replicas=0 -n $KUBERNETES_NAMESPACE${NC}"
    echo "   ${CYAN}sleep 180  # Wait for alert to fire${NC}"
    echo "   ${CYAN}kubectl scale deployment prometheus --replicas=1 -n $KUBERNETES_NAMESPACE${NC}"
    echo ""
fi

# Backup information
echo -e "${BLUE}💾 BACKUP INFORMATION${NC}"
echo "────────────────────────────────────────────────────────────────────────"
echo -e "${CYAN}Original values.yaml backed up to:${NC} $BACKUP_FILE"
echo -e "${CYAN}Customer config file:${NC} $CONFIG_FILE"
echo ""

echo -e "${GREEN}🎉 OBSERVABILITY SUITE DEPLOYMENT COMPLETED!${NC}"
echo -e "${BLUE}✨ 16 Services deployed with Grafana-native alerting${NC}"
echo -e "${BLUE}🚀 Access your monitoring dashboard at: http://$KUBERNETES_NODE_IP:30300${NC}"
echo -e "${BLUE}👤 Login with: admin / admin${NC}"
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}    🌟 ENTERPRISE OBSERVABILITY PLATFORM READY FOR USE! 🌟${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"