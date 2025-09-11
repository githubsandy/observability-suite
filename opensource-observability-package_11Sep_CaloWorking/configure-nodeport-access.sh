#!/bin/bash

# NodePort Configuration Script for CALO Lab Direct Access
# Switches between ClusterIP (port-forwarding) and NodePort (direct IP access)

echo "🌐 Observability Stack - NodePort Configuration"
echo "==============================================="
echo "🎯 Configure direct access for CALO Lab environment"
echo ""

VALUES_FILE="helm-kube-observability-stack/values.yaml"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check if values.yaml exists
check_values_file() {
    if [[ ! -f "$VALUES_FILE" ]]; then
        echo "❌ values.yaml not found at: $VALUES_FILE"
        echo "💡 Make sure you're running this from the opensource-observability-package directory"
        exit 1
    fi
}

# Function to show current configuration
show_current_config() {
    echo -e "${BLUE}📋 Current Configuration:${NC}"
    echo ""
    
    local grafana_type=$(grep -A 10 "grafana:" "$VALUES_FILE" | grep -A 5 "service:" | grep "type:" | head -1 | awk '{print $2}' | tr -d '#' | xargs)
    local prometheus_type=$(grep -A 10 "prometheus:" "$VALUES_FILE" | grep -A 5 "service:" | grep "type:" | head -1 | awk '{print $2}' | tr -d '#' | xargs)
    local loki_type=$(grep -A 10 "loki:" "$VALUES_FILE" | grep -A 5 "service:" | grep "type:" | head -1 | awk '{print $2}' | tr -d '#' | xargs)
    local blackbox_type=$(grep -A 10 "blackboxExporter:" "$VALUES_FILE" | grep -A 5 "service:" | grep "type:" | head -1 | awk '{print $2}' | tr -d '#' | xargs)
    
    echo "   📊 Grafana:    $grafana_type"
    echo "   📈 Prometheus: $prometheus_type"  
    echo "   📋 Loki:      $loki_type"
    echo "   🔍 Blackbox:  $blackbox_type"
    echo ""
}

# Function to enable NodePort access
enable_nodeport() {
    echo -e "${YELLOW}🌐 Enabling NodePort access...${NC}"
    
    # Update service types to NodePort - handle both cases
    sed -i.bak 's/type: ClusterIP.*# Change to NodePort for direct access/type: NodePort            # Direct IP access enabled/' "$VALUES_FILE"
    sed -i.bak 's/type: ClusterIP$/type: NodePort            # Direct IP access enabled/' "$VALUES_FILE"
    
    echo -e "${GREEN}✅ NodePort access enabled!${NC}"
    echo ""
    echo -e "${GREEN}🌐 Direct Access URLs (after deployment):${NC}"
    echo "   📊 Grafana:     http://CALO-NODE-IP:30300/ (admin/admin)"
    echo "   📈 Prometheus:  http://CALO-NODE-IP:30090/"
    echo "   📋 Loki:       http://CALO-NODE-IP:30310/"
    echo "   🔍 Blackbox:   http://CALO-NODE-IP:30115/"
    echo ""
    echo "💡 Replace CALO-NODE-IP with your CALO lab node IP"
    echo "   Example: 10.122.28.111 or your cluster node IP"
}

# Function to disable NodePort access (back to ClusterIP)
disable_nodeport() {
    echo -e "${YELLOW}🔒 Disabling NodePort access (switching to ClusterIP)...${NC}"
    
    # Update service types back to ClusterIP - handle both cases  
    sed -i.bak 's/type: NodePort.*# Direct IP access enabled/type: ClusterIP           # Change to NodePort for direct access/' "$VALUES_FILE"
    sed -i.bak 's/type: NodePort$/type: ClusterIP           # Change to NodePort for direct access/' "$VALUES_FILE"
    
    echo -e "${GREEN}✅ Switched back to ClusterIP (port-forwarding required)${NC}"
    echo ""
    echo -e "${GREEN}🔗 Port-Forward Access (after deployment):${NC}"
    echo "   Run: ./start-observability.sh"
    echo "   Then access:"
    echo "   📊 Grafana:     http://localhost:3000 (admin/admin)"
    echo "   📈 Prometheus:  http://localhost:9090"
    echo "   📋 Loki:       http://localhost:3100"
    echo "   🔍 Blackbox:   http://localhost:9115"
}

# Function to show help
show_help() {
    echo "NodePort Configuration Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  enable    Enable NodePort for direct IP access"
    echo "  disable   Disable NodePort, switch back to ClusterIP"
    echo "  status    Show current configuration"
    echo "  --help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 enable     # Enable direct access via NodePort"
    echo "  $0 disable    # Switch back to port-forwarding"
    echo "  $0 status     # Check current configuration"
}

# Main function
main() {
    check_values_file
    
    case "${1:-interactive}" in
        "enable")
            show_current_config
            enable_nodeport
            ;;
        "disable")
            show_current_config
            disable_nodeport
            ;;
        "status")
            show_current_config
            ;;
        "--help"|"-h")
            show_help
            ;;
        "interactive")
            show_current_config
            
            echo "🤔 Choose access method:"
            echo "   1) NodePort - Direct IP access (like your POC)"
            echo "   2) ClusterIP - Port-forwarding access (default)"
            echo ""
            read -p "Enter choice (1 or 2): " choice
            
            case $choice in
                1)
                    enable_nodeport
                    ;;
                2)
                    disable_nodeport
                    ;;
                *)
                    echo "❌ Invalid choice. No changes made."
                    ;;
            esac
            ;;
        *)
            echo "❌ Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Backup reminder
echo "💾 Note: Configuration changes create a backup file (values.yaml.bak)"
echo ""

# Execute main function
main "$@"

echo ""
echo "🚀 Next steps after configuration change:"
echo "   1. Deploy/update: helm upgrade ao-observability ./helm-kube-observability-stack --namespace ao-os --create-namespace"
echo "   2. Verify: ./verify-installation.sh"
if [[ "$1" == "enable" ]] || [[ "$choice" == "1" ]]; then
    echo "   3. Access via direct URLs (no port-forwarding needed)"
    echo "      📊 Grafana:    http://YOUR-NODE-IP:30300"
    echo "      📈 Prometheus: http://YOUR-NODE-IP:30090"
    echo "      📋 Loki:      http://YOUR-NODE-IP:30310"
    echo "      🔍 Blackbox:  http://YOUR-NODE-IP:30115"
else
    echo "   3. Start port-forwarding: ./start-observability.sh"
fi
echo ""
echo "✅ Configuration complete!"