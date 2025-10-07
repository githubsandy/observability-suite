# Splunk O11y Enterprise Alerting & Notification Integration - Attempt Summary

**Date**: September 19, 2025
**Environment**: CaloLab Kubernetes Cluster
**Objective**: Create & Validate enterprise real-time Alerting & Notification Integration with Splunk O11y

## 🎯 Project Requirements

### Primary Goal
Implement enterprise-grade real-time alerting and notification capabilities using Splunk Observability Cloud (O11y) with:

- **Alert Configuration**: Threshold-based and anomaly-based alert rules for 2-3 key services
- **Notification Integrations**: WebEx, ServiceNow, Outlook/email integration
- **Validation**: Real-time delivery (<1 minute), ≥95% delivery success rate
- **End-to-End Testing**: Simulated alert scenarios across all integrated channels
- **Documentation**: Configuration steps and validation procedures

## 🔧 Environment Details

### Production Splunk O11y Instance
- **URL**: https://cisco-cx-observe.signalfx.com
- **Token**: oksFxD-9HYcsCHBqvwh9mg
- **Realm**: us1
- **Organization**: Cisco Systems Inc.

### CaloLab Kubernetes Cluster
- **Control Plane**: 10.122.28.111 (uta-k8s-ctrlplane-01)
- **Cluster**: 16-node production cluster
- **Existing OTEL**: cxtvng-splunk-otel-collector running in `ao` namespace
- **Target Services**: cxtm-web, cxtm-scheduler, cxtm-zipservice

## ❌ Attempt 1: Production Splunk O11y Instance

### What We Tried
1. **Accessed Production Instance**: https://cisco-cx-observe.signalfx.com
2. **Attempted Alert Configuration**: Navigate to Alerts & Detectors → New Detector
3. **Attempted Integration Setup**: Settings → Integrations for email, ServiceNow, WebEx

### Why It Failed
```
🚫 INSUFFICIENT PERMISSIONS
- No write access to create detectors/alert rules
- No administrative access to configure integrations
- Read-only access to existing production environment
- Cannot modify notification channels or create new webhooks
```

**Root Cause**: Production Splunk O11y instance has restricted permissions for non-admin users. Enterprise security policies prevent modification of alerting infrastructure without proper authorization.

## ❌ Attempt 2: Splunk O11y Free Trial Instance

### What We Tried
1. **Created Trial Instance**:
   - **Access Token**: pceyC0WC6s-0JiFsfzuWWA
   - **URL**: https://app.au0.signalfx.com/#/home
   - **Realm**: au0

2. **Attempted Data Ingestion**:
   - Deployed sample application to generate telemetry data
   - Configured OTEL collector to send metrics to trial instance
   - Multiple approaches tried for data pipeline

### Technical Challenges Encountered

#### Challenge 1: Existing OTEL Collector Conflicts
```yaml
# Existing production collector in 'ao' namespace
cxtvng-splunk-otel-collector-agent    ClusterIP   10.43.200.137   4317/TCP,4318/TCP

# Conflict with new deployment
Error: ClusterRole "splunk-otel-collector-operator-manager" exists
Error: failed calling webhook "minstrumentation.kb.io"
```

**Issue**: CaloLab cluster already had production OTEL collector infrastructure that conflicted with new trial collector deployment.

#### Challenge 2: Network Connectivity Restrictions
```bash
# Network test results
kubectl exec pod -- curl https://ingest.au0.signalfx.com
* connect to 3.104.137.75 port 443 failed: Operation timed out
* Failed to connect after 133601 ms: Could not connect to server
curl: (28) Connection timeout
```

**Issue**: CaloLab cluster network policies blocked outbound HTTPS connections to external Splunk O11y endpoints.

#### Challenge 3: Service Mesh/Proxy Configuration
```bash
# DNS resolution worked, but connectivity failed
nslookup ingest.au0.signalfx.com
# Returns: 3.104.137.75, 54.206.105.21, 13.210.200.67
# But all connection attempts timeout
```

**Issue**: Enterprise firewall/proxy configuration prevented direct internet access from pod networks.

### Attempted Solutions

#### Solution Attempt 1: Dedicated Trial Collector
```yaml
# Created separate namespace and collector
apiVersion: v1
kind: ConfigMap
metadata:
  name: trial-otel-collector-config
  namespace: splunk-trial-test
data:
  otel-collector-config.yaml: |
    exporters:
      signalfx:
        access_token: "pceyC0WC6s-0JiFsfzuWWA"
        realm: "au0"
```

**Result**: Collector deployed successfully but couldn't establish outbound connections.

#### Solution Attempt 2: Using Existing Collector as Proxy
```bash
# Attempted to route through existing collector
curl http://cxtvng-splunk-otel-collector-agent.ao.svc.cluster.local:4318/v1/metrics
```

**Result**: Data sent successfully to existing collector, but routed to production instance (us1 realm) instead of trial (au0 realm).

## 📊 Data Generation Success (Partial)

### What Worked
```bash
✅ Sample Application Deployment: Successfully deployed curl-based metrics generator
✅ Internal Networking: Pod-to-pod communication working
✅ OTEL Protocol: Successfully sent OTLP formatted metrics
✅ Metric Generation: Generated realistic CPU, memory, and application metrics
✅ Alert Simulation: Created periodic spikes for testing alert triggers

# Sample successful output:
✅ [07:35:44] Metrics sent successfully - CPU: 43.5%, Memory: 34.9%, Counter: 7
🚨 HIGH CPU SPIKE: 93.0%
✅ [07:36:14] Metrics sent successfully - CPU: 93.0%, Memory: 66.8%, Counter: 8
```

### What Didn't Reach Trial Instance
- Metrics successfully sent to internal OTEL collector
- No data appearing in trial Splunk O11y dashboard
- Unable to create meaningful alert rules without actual data

## 🚧 Infrastructure Limitations Summary

### Network Security Constraints
1. **Outbound HTTPS Blocked**: Enterprise firewall prevents direct external API calls
2. **Proxy Configuration**: No configured HTTP proxy for pod networks
3. **DNS vs Connectivity**: Can resolve external hostnames but cannot establish connections

### Existing Infrastructure Conflicts
1. **OTEL Operator Conflicts**: Existing webhook configurations prevent new operator deployment
2. **Port Conflicts**: Host ports already in use by production collectors
3. **Cluster-wide Resources**: ClusterRoles and webhooks already claimed

### Permission Boundaries
1. **Production Instance**: Read-only access, cannot create detectors or integrations
2. **Kubernetes Cluster**: Cannot modify existing production OTEL infrastructure
3. **Network Policies**: Cannot override enterprise network security controls

## 🎯 Alternative Approaches for Future Implementation

### Approach 1: Work with Infrastructure Team
```
1. Request outbound firewall exceptions for Splunk O11y endpoints
2. Configure enterprise HTTP proxy for pod networks
3. Obtain admin access to production Splunk O11y instance
4. Coordinate with existing OTEL collector management
```

### Approach 2: Hybrid Configuration
```
1. Use existing production OTEL collector for data ingestion
2. Configure collector to send duplicate stream to trial instance
3. Set up alerting rules in trial environment
4. Route notifications through enterprise-approved channels
```

### Approach 3: Standalone Environment
```
1. Deploy in isolated namespace with dedicated network policies
2. Use service mesh egress gateway for external connectivity
3. Implement custom webhook proxy for Splunk O11y API calls
4. Configure enterprise identity provider integration
```

## 📋 Lessons Learned

### Technical Insights
1. **Enterprise Observability**: Production observability platforms require careful integration planning
2. **Network Security**: Container network policies significantly impact external integrations
3. **Operator Conflicts**: Multiple OTEL operators cannot coexist in same cluster
4. **Service Mesh Complexity**: Enterprise Kubernetes clusters have complex networking layers

### Project Management Insights
1. **Permission Verification**: Validate access levels before implementation planning
2. **Network Assessment**: Test external connectivity early in project timeline
3. **Infrastructure Inventory**: Map existing observability infrastructure before deployment
4. **Enterprise Coordination**: Engage platform teams for enterprise integration projects

## 🔧 Cleanup Actions Performed

### Resources Removed
```bash
# Namespaces deleted
kubectl delete namespace splunk-trial-test
kubectl delete namespace splunk-o11y
kubectl delete namespace splunk-alert

# Helm releases cleaned up
helm uninstall splunk-collector splunk-otel-collector-alert

# Files removed
rm -f sample-app-trial-deployment.yaml trial-otel-collector.yaml
```

### Cluster State Restored
- No impact to existing production OTEL collector in `ao` namespace
- No persistent configuration changes to cluster
- All test resources successfully removed

## 📝 Recommendations for Future Attempts

### Immediate Actions
1. **Request Admin Access**: Obtain admin permissions for production Splunk O11y instance
2. **Network Exception**: Request firewall exceptions for Splunk O11y endpoints:
   - `https://ingest.au0.signalfx.com`
   - `https://api.au0.signalfx.com`
3. **Infrastructure Coordination**: Work with platform team to configure egress connectivity

### Alternative Demonstration Approach
1. **Mock Environment**: Set up local demonstration environment with simulated integrations
2. **Documentation Focus**: Create comprehensive configuration documentation and screenshots
3. **Proof of Concept**: Use public Splunk O11y demo environment for UI configuration walkthrough
4. **Enterprise Integration Planning**: Develop detailed implementation plan for production deployment

## ✅ Next Steps

Since we cannot complete the full technical implementation due to infrastructure constraints, we should:

1. **Access Trial UI Directly**: Use web interface to configure alert rules with demo/sample data
2. **Document Integration Steps**: Create step-by-step screenshots of notification configuration
3. **Simulate Alert Workflows**: Document alert acknowledgment and escalation processes
4. **Prepare Implementation Plan**: Develop detailed plan for future production deployment with proper permissions and network access

---

**Status**: Implementation blocked by infrastructure constraints
**Deliverable**: Documentation and configuration procedures for future implementation
**Timeline**: Ready for UI-based configuration and documentation phase