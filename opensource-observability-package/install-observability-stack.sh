#!/bin/bash

# Enhanced Observability Stack Installer
# Infrastructure-Agnostic Deployment Script

echo "🚀 Enhanced Observability Stack Installer"
echo "=========================================="
echo "🌟 Infrastructure-Agnostic • Complete Observability • Zero External Dependencies"
echo "=========================================="
echo

# Configuration
DEFAULT_RELEASE_NAME="observability-stack"
DEFAULT_NAMESPACE="ao"
DEFAULT_ENVIRONMENT="calo-lab"
HELM_CHART_PATH="./helm-kube-observability-stack"

# Parse command line arguments
RELEASE_NAME="${1:-$DEFAULT_RELEASE_NAME}"
NAMESPACE="${2:-$DEFAULT_NAMESPACE}"
ENVIRONMENT="${3:-$DEFAULT_ENVIRONMENT}"

# Display configuration
echo "📋 Deployment Configuration:"
echo "   🏷️  Release Name: $RELEASE_NAME"
echo "   📦 Namespace: $NAMESPACE"
echo "   🌍 Environment: $ENVIRONMENT"
echo "   📂 Chart Path: $HELM_CHART_PATH"
echo

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    # Check if Helm is installed
    if ! command -v helm &> /dev/null; then
        echo "❌ Helm is not installed. Please install Helm first."
        echo "   📖 Visit: https://helm.sh/docs/intro/install/"
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl is not installed. Please install kubectl first."
        echo "   📖 Visit: https://kubernetes.io/docs/tasks/tools/install-kubectl/"
        exit 1
    fi
    
    # Check if Kubernetes cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ Cannot access Kubernetes cluster. Please check your kubeconfig."
        echo "   💡 Try: kubectl config current-context"
        exit 1
    fi
    
    # Check if Helm chart directory exists
    if [ ! -d "$HELM_CHART_PATH" ]; then
        echo "❌ Helm chart directory not found: $HELM_CHART_PATH"
        echo "   💡 Make sure you're running this script from the correct directory"
        exit 1
    fi
    
    # Get cluster info
    CLUSTER_CONTEXT=$(kubectl config current-context)
    CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    
    echo "✅ Prerequisites check passed"
    echo "   🔗 Cluster: $CLUSTER_CONTEXT"
    echo "   🌐 Server: $CLUSTER_SERVER"
    echo
}

# Function to detect environment and suggest configuration
detect_environment() {
    echo "🔍 Environment Detection:"
    
    # Check if we're in CALO lab environment
    if kubectl get nodes --no-headers 2>/dev/null | grep -q "uta-k8s"; then
        echo "   🎯 Detected: CALO Lab environment"
        echo "   📦 Suggested namespace: ao"
        echo "   🏷️  Suggested environment: calo-lab"
        DETECTED_ENV="calo-lab"
    else
        echo "   🌐 Detected: Generic Kubernetes environment"
        echo "   📦 Using default namespace: $NAMESPACE"
        DETECTED_ENV="generic"
    fi
    echo
}

# Function to validate namespace
validate_namespace() {
    echo "🔍 Validating namespace: $NAMESPACE"
    
    # Check if namespace exists
    if kubectl get namespace "$NAMESPACE" &>/dev/null; then
        echo "   ✅ Namespace '$NAMESPACE' exists"
    else
        echo "   📦 Namespace '$NAMESPACE' will be created"
    fi
    echo
}

# Function to install the stack
install_stack() {
    echo "🚀 Installing Enhanced Observability Stack..."
    echo
    
    # Prepare values override
    VALUES_OVERRIDE="--set environment.namespace=$NAMESPACE --set environment.name=$ENVIRONMENT"
    
    # Default enhanced components (always enabled)
    VALUES_OVERRIDE="$VALUES_OVERRIDE --set components.enhanced.cadvisor=true"
    VALUES_OVERRIDE="$VALUES_OVERRIDE --set security.rbac.create=true"
    
    # Environment-specific overrides
    if [ "$ENVIRONMENT" = "calo-lab" ]; then
        VALUES_OVERRIDE="$VALUES_OVERRIDE --set environment.cluster.nodeSelector.enabled=true"
        VALUES_OVERRIDE="$VALUES_OVERRIDE --set environment.cluster.nodeSelector.strategy=labels"
        VALUES_OVERRIDE="$VALUES_OVERRIDE --set environment.cluster.nodeSelector.nodeLabels.ao-node=observability"
        VALUES_OVERRIDE="$VALUES_OVERRIDE --set environment.cluster.storage.storageClass=longhorn-single"
        VALUES_OVERRIDE="$VALUES_OVERRIDE --set components.databases.redis=true"
        VALUES_OVERRIDE="$VALUES_OVERRIDE --set components.databases.mariadb=true"
    fi
    
    echo "📋 Installation Command:"
    echo "   helm install $RELEASE_NAME $HELM_CHART_PATH \\"
    echo "     --namespace $NAMESPACE --create-namespace \\"
    echo "     $VALUES_OVERRIDE"
    echo
    
    # Execute installation
    helm install "$RELEASE_NAME" "$HELM_CHART_PATH" \
        --namespace "$NAMESPACE" \
        --create-namespace \
        $VALUES_OVERRIDE
    
    return $?
}

# Function to wait for deployment
wait_for_deployment() {
    echo "⏳ Waiting for deployment to be ready..."
    echo "   This may take a few minutes as container images are downloaded..."
    echo
    
    # Wait for core services to be ready
    echo "   Waiting for core services..."
    kubectl wait --for=condition=available --timeout=300s deployment/grafana -n "$NAMESPACE" 2>/dev/null
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n "$NAMESPACE" 2>/dev/null
    kubectl wait --for=condition=available --timeout=300s deployment/loki -n "$NAMESPACE" 2>/dev/null
    
    # Check overall pod status
    local total_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    local running_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | grep Running | wc -l)
    
    echo "   📊 Pod Status: $running_pods/$total_pods running"
    
    if [ "$running_pods" -gt 0 ]; then
        echo "   ✅ Core services are starting up"
    else
        echo "   ⚠️  Services are still initializing"
    fi
    echo
}

# Function to display next steps
display_next_steps() {
    echo "=========================================="
    echo "✅ Installation Completed Successfully!"
    echo "=========================================="
    echo
    echo "📋 Next Steps:"
    echo
    echo "1️⃣  Wait for all pods to be ready (if needed):"
    echo "   kubectl get pods -n $NAMESPACE -w"
    echo
    echo "2️⃣  Start port forwarding for all services:"
    echo "   chmod +x start-portForwarding-allService.sh"
    echo "   ./start-portForwarding-allService.sh $NAMESPACE"
    echo
    echo "3️⃣  Check service health status:"
    echo "   chmod +x check-services.sh"
    echo "   ./check-services.sh $NAMESPACE"
    echo
    echo "4️⃣  Access the observability stack:"
    echo "   🎨 Grafana Dashboard:  http://localhost:3000 (admin/admin)"
    echo "   📊 Prometheus Metrics: http://localhost:9090"
    echo "   🔍 Grafana Tempo:      http://localhost:3200"
    echo "   🚨 AlertManager:       http://localhost:9093"
    echo
    echo "🎯 What You Get:"
    echo "   ✅ Complete Logs + Metrics + Traces"
    echo "   ✅ Container-Level Metrics (cAdvisor via kubelet)"
    echo "   ✅ Network Path Analysis (MTR + Smokeping)"
    echo "   ✅ Auto-Discovery of CXTAF/CXTM Services"
    echo "   ✅ Enhanced Blackbox Monitoring"
    echo "   ✅ Production-Ready Alerting"
    echo "   ✅ Zero External Dependencies"
    echo
    echo "🛠️  Useful Commands:"
    echo "   helm status $RELEASE_NAME -n $NAMESPACE"
    echo "   kubectl get all -n $NAMESPACE"
    echo "   kubectl logs -n $NAMESPACE -l app=grafana"
    echo
    echo "📖 For advanced configuration, see values.yaml"
    echo "🔧 To uninstall: helm uninstall $RELEASE_NAME -n $NAMESPACE"
    echo
    echo "=========================================="
}

# Function to handle installation failure
handle_failure() {
    echo
    echo "❌ Installation failed!"
    echo
    echo "🔍 Troubleshooting steps:"
    echo "1. Check Helm status: helm status $RELEASE_NAME -n $NAMESPACE"
    echo "2. Check pod logs: kubectl get pods -n $NAMESPACE"
    echo "3. Check events: kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp"
    echo "4. Clean up: helm uninstall $RELEASE_NAME -n $NAMESPACE"
    echo
    echo "💬 For support, check the logs above for specific error messages"
    exit 1
}

# Main execution
main() {
    check_prerequisites
    detect_environment
    validate_namespace
    
    if install_stack; then
        wait_for_deployment
        display_next_steps
    else
        handle_failure
    fi
}

# Help function
show_help() {
    echo "Enhanced Observability Stack Installer"
    echo
    echo "Usage: $0 [RELEASE_NAME] [NAMESPACE] [ENVIRONMENT]"
    echo
    echo "Arguments:"
    echo "  RELEASE_NAME    Helm release name (default: $DEFAULT_RELEASE_NAME)"
    echo "  NAMESPACE       Kubernetes namespace (default: $DEFAULT_NAMESPACE)"
    echo "  ENVIRONMENT     Environment identifier (default: $DEFAULT_ENVIRONMENT)"
    echo
    echo "Examples:"
    echo "  $0                                    # CALO Lab deployment"
    echo "  $0 obs-stack ao calo-lab             # CALO Lab with custom release name"
    echo "  $0 monitoring observability aws-prod # AWS production deployment"
    echo
    echo "Environment-specific features:"
    echo "  calo-lab: Targets ao-nodes, enables CXTAF/CXTM monitoring"
    echo "  generic:  Standard deployment for any Kubernetes cluster"
}

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Execute main function
main