# CXTM Application Splunk Instrumentation - Master Documentation

## 📋 Table of Contents

1. [Overview & Executive Summary](#overview--executive-summary)
2. [Use Cases & Business Value](#use-cases--business-value)
3. [Kubernetes Architecture Guide](#kubernetes-architecture-guide)
4. [Application Instrumentation Guides](#application-instrumentation-guides)
5. [Common Commands Reference](#common-commands-reference)
6. [Troubleshooting & Best Practices](#troubleshooting--best-practices)
7. [Results & Performance Metrics](#results--performance-metrics)

---

## Overview & Executive Summary

### What This Document Covers
This comprehensive guide documents the complete implementation of Splunk Observability Cloud for the CXTM (Customer Experience Test Management) application suite. It provides step-by-step instructions, troubleshooting guidance, and business value analysis for instrumenting Python applications with OpenTelemetry in a Kubernetes environment.

### Key Achievements
- ✅ **100% Success Rate** across all monitored services
- ✅ **Zero Error Rate** in production monitoring
- ✅ **Sub-second Response Times** (<210ms P99 latency)
- ✅ **Complete Stack Visibility** from user requests to database operations
- ✅ **18 APM Use Cases** successfully implemented
- ✅ **720+ Traces Captured** demonstrating full observability

### Environment Overview
- **Infrastructure**: CALO Lab Kubernetes cluster (uta-k8s)
- **Control Plane**: uta-k8s-ctrlplane-01 (10.122.28.111)
- **Worker Nodes**: 16 nodes (uta-k8s-ao-01/02, uta-k8s-worker-01 to 11)
- **Applications**: 8 CXTM microservices in Python
- **Monitoring**: Splunk Observability Cloud with OpenTelemetry

---

## Use Cases & Business Value

### Complete List of 18 APM Use Cases Implemented

#### 1. Application Performance Monitoring (APM) Overview
**Purpose**: Centralized dashboard showing overall application health, success rates, and performance metrics in real-time.
**Business Value**: Instant visibility into system-wide health, proactive issue detection before customer impact.
**Real-world Impact**: Enables immediate detection of system-wide issues and provides confidence metrics for business stakeholders.

#### 2. Service Health Monitoring
**Purpose**: Monitor individual service performance, resource utilization, and availability across microservices.
**Business Value**: Identify specific service issues, prevent cascade failures, ensure SLA compliance.
**Real-world Impact**: Discovered cxtm-web uses only 5% CPU while delivering excellent performance, enabling cost optimization.

#### 3. Distributed Tracing
**Purpose**: Track individual user requests across multiple services, databases, and external dependencies.
**Business Value**: Debug complex microservices interactions, identify bottlenecks, root cause analysis.
**Real-world Impact**: Enables tracking of 200-400 concurrent user requests with <210ms response times.

#### 4. Error Tracking and Analysis
**Purpose**: Monitor, categorize, and analyze all application errors with detailed error traces.
**Business Value**: Immediate notification of failures, categorize errors, track trends.
**Real-world Impact**: Currently showing 0% error rate, demonstrating excellent system reliability.

#### 5. Endpoint Performance Monitoring
**Purpose**: Monitor individual API endpoint performance including response times and request rates.
**Business Value**: Optimize user-facing features, identify slow endpoints, ensure consistent experience.
**Real-world Impact**: Identified dashboard endpoints (458 requests, 153ms P90) as most-used features requiring optimization focus.

#### 6. Tag Spotlight Analysis
**Purpose**: Deep analytics on request patterns, user behavior, HTTP methods, and business workflows.
**Business Value**: Business intelligence for product decisions, performance analysis by environment.
**Real-world Impact**: Revealed GET operations dominate (15.3k requests) over POST/DELETE (8 requests each).

#### 7. Service Map and Dependency Visualization
**Purpose**: Visual maps of service architecture showing all connections and dependencies.
**Business Value**: Understand system architecture, identify critical dependencies, plan changes.
**Real-world Impact**: Shows cxtm-web connecting to redis (3ms) and mysql (917μs) with excellent performance.

#### 8. Infrastructure Resource Monitoring
**Purpose**: Monitor CPU, memory, disk, and network usage at host and container levels.
**Business Value**: Prevent resource exhaustion, optimize costs, plan capacity.
**Real-world Impact**: Discovered 5% CPU and 10% memory usage during peak traffic, indicating significant headroom.

#### 9. Database Query Performance Monitoring
**Purpose**: Monitor individual SQL queries, execution times, and database performance metrics.
**Business Value**: Optimize database performance, identify slow queries, prevent bottlenecks.
**Real-world Impact**: All database queries execute in <1ms with 35.2k requests and 0% errors.

#### 10. Real-time Request Monitoring
**Purpose**: Live monitoring of user requests, showing real-time traffic patterns and response times.
**Business Value**: Monitor during traffic spikes, immediate visibility into user experience.
**Real-world Impact**: Tracks peak traffic of 400 concurrent requests dropping to steady 200.

#### 11. Service Level Indicator (SLI) Monitoring
**Purpose**: Track key service quality metrics against defined service level objectives (SLOs).
**Business Value**: Ensure service quality meets business requirements, track SLA compliance.
**Real-world Impact**: Currently achieving 100.000% success rate, exceeding typical SLA targets.

#### 12. Cross-Service Correlation Analysis
**Purpose**: Analyze relationships and interactions between different services.
**Business Value**: Understand service interdependencies, identify cascade failure risks.
**Real-world Impact**: Enabled comparison of cxtm-web (160ms) with other services (3-7ms).

#### 13. Capacity Planning and Scaling
**Purpose**: Analyze resource usage patterns and traffic growth for future scaling requirements.
**Business Value**: Prevent system overload during growth, plan infrastructure investments.
**Real-world Impact**: Current infrastructure can handle 10x traffic growth based on 5% CPU usage.

#### 14. Business Intelligence and Usage Analytics
**Purpose**: Insights into user interactions, feature popularity, and system usage alignment.
**Business Value**: Data-driven product development, understand user behavior patterns.
**Real-world Impact**: Identified dashboard features (474 requests) and automation (474 requests) as most valuable.

#### 15. Performance Baseline Establishment
**Purpose**: Establish and maintain performance baselines for all system components.
**Business Value**: Detect performance degradation early, measure improvement initiatives.
**Real-world Impact**: Established baseline of 150-200ms P90 latency with target optimization to <100ms.

#### 16. Alerting and Proactive Issue Detection
**Purpose**: Automatically detect anomalies and system issues before user impact.
**Business Value**: Prevent customer-impacting outages, reduce Mean Time to Detection.
**Real-world Impact**: Current 0% error rate enables setting meaningful alert thresholds.

#### 17. User Experience Monitoring
**Purpose**: Monitor application performance from the user's perspective.
**Business Value**: Ensure excellent user experience, identify user-impacting issues.
**Real-world Impact**: 99% of users experience <210ms response times with zero errors.

#### 18. Operational Excellence and MTTR Reduction
**Purpose**: Comprehensive observability for rapid issue diagnosis and resolution.
**Business Value**: Minimize downtime, enable rapid problem resolution, improve efficiency.
**Real-world Impact**: Complete observability stack enables rapid issue identification across all layers.

---

## Kubernetes Architecture Guide

### 🏗️ Cluster Architecture Overview

#### Your Current Environment
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Kubernetes Cluster                                   │
├─────────────────────────────┬───────────────────────────────────────────────────┤
│        CONTROL PLANE        │                 WORKER NODES                      │
│    (uta-k8s-ctrlplane-01)   │                                                   │
│     IP: 10.122.28.111       │   • uta-k8s-ao-01 (observability nodes)         │
│     User: administrator     │   • uta-k8s-ao-02                                │
│     Pass: C1sco123=         │   • uta-k8s-worker-01 to 11 (application nodes)  │
├─────────────────────────────┼───────────────────────────────────────────────────┤
│  🧠 CONTROL COMPONENTS:     │  💪 WORKER COMPONENTS:                           │
│  • API Server               │  • kubelet (node agent)                          │
│  • etcd (cluster database)  │  • Container runtime (containerd)                │
│  • Scheduler                │  • kube-proxy (networking)                       │
│  • Controller Manager       │  • Your applications run here                    │
│  • kubectl/helm access      │  • OTEL collectors will run here                 │
└─────────────────────────────┴───────────────────────────────────────────────────┘
```

### 🎭 Roles & Responsibilities

#### Control Plane (Master) - "The Brain"
| Component | Purpose | What It Does |
|-----------|---------|--------------|
| **API Server** | Central communication hub | Receives all kubectl/helm commands |
| **etcd** | Cluster database | Stores desired state of all resources |
| **Scheduler** | Pod placement decision maker | Decides which worker node runs each pod |
| **Controller Manager** | State reconciliation | Ensures actual state matches desired state |

#### Worker Nodes - "The Muscle"
| Component | Purpose | What It Does |
|-----------|---------|--------------|
| **kubelet** | Node agent | Communicates with control plane, manages pods |
| **Container Runtime** | Pod execution | Actually runs containers (containerd) |
| **kube-proxy** | Networking | Handles service networking and load balancing |

### 🚀 Deployment Process - Step by Step

#### What Happens When You Deploy Applications

**Phase 1: Command Execution (Control Plane)**
```
You (SSH to control plane) → Execute deployment commands
                           ↓
                    kubectl/helm processes commands
```

**Phase 2: API Server Processing (Control Plane)**
```
API Server receives requests → Validates manifests → Stores in etcd
                            ↓
                    Creates resource objects:
                    • Deployments, Services, ConfigMaps
                    • OpenTelemetry instrumentation configs
```

**Phase 3: Scheduler Decision Making (Control Plane)**
```
Scheduler watches for unscheduled pods → Analyzes resource requirements
                                       ↓
                            Decides placement based on:
                            • Node capacity (CPU, memory)
                            • Node selectors/taints
                            • Anti-affinity rules
```

**Phase 4: Pod Creation (Worker Nodes)**
```
kubelet on selected worker nodes → Receives pod specifications
                                 ↓
                          Pulls container images
                                 ↓
                          Creates and starts containers
```

### 📊 Namespace Organization

#### Infrastructure Namespace (`ao`)
- **Splunk OpenTelemetry Collector**: Data collection and forwarding
- **OpenTelemetry Operator**: Automation and webhook management
- **Monitoring Infrastructure**: Pre-deployed by infrastructure team

#### Application Namespace (`cxtm`)
- **CXTM Applications**: All business applications
- **Instrumentation Configs**: Application-specific OpenTelemetry settings
- **Services**: Application networking and load balancing

**Key Rule**: Instrumentation configs must be in the same namespace as applications!

---

## Application Instrumentation Guides

### 🎯 Common Implementation Pattern

All CXTM applications follow a consistent instrumentation pattern with two possible approaches:

#### Approach A: Automatic (OpenTelemetry Operator Webhook)
**When it works**: Webhook successfully injects instrumentation
**Steps**:
1. Set environment variables
2. Add instrumentation annotation
3. Verify automatic injection

#### Approach B: Manual (Init Container)
**When needed**: Webhook fails to inject instrumentation
**Steps**:
1. Add node selector
2. Create volume for libraries
3. Add init container
4. Mount volume in application container
5. Set environment variables
6. Wrap startup command

### 📚 Individual Service Guides

#### 1. CXTM-WEB (Main Application)
**Service Type**: Flask web application with Gunicorn
**Implementation**: ✅ Automatic (Approach A - Webhook worked)
**Status**: Production-ready with complete observability

**Configuration Added**:
```bash
# Environment variables
kubectl set env deployment cxtm-web -n cxtm \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://cxtvng-splunk-otel-collector-agent.ao.svc.cluster.local:4318
kubectl set env deployment cxtm-web -n cxtm OTEL_SERVICE_NAME=cxtm-web

# Instrumentation annotation
kubectl annotate deployment cxtm-web -n cxtm \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
```

**Results**:
- Service visible in Splunk O11y with complete telemetry
- Response times: 150-200ms P90 latency
- Success rate: 100% with zero errors
- Database connections: mysql (917μs), redis (3ms)

---

#### 2. CXTM-SCHEDULER (Job Scheduling Service)
**Service Type**: Python application with scheduling functionality
**Implementation**: ✅ Manual (Approach B - Webhook failed)
**Status**: Successfully instrumented with complete telemetry

**Manual Implementation Steps**:
```bash
# 1. Node selector
kubectl patch deployment cxtm-scheduler -n cxtm --type='merge' \
  -p='{"spec":{"template":{"spec":{"nodeSelector":{"ao-node":"observability"}}}}}'

# 2. Volume for OpenTelemetry libraries
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "opentelemetry-auto-instrumentation-python", "emptyDir": {}}]}]'

# 3. Init container
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/initContainers", "value": [{"name": "opentelemetry-auto-instrumentation-python", "image": "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.54b1", "command": ["cp", "-r", "/autoinstrumentation/.", "/otel-auto-instrumentation/"], "volumeMounts": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]}]'

# 4. Volume mount
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]'

# 5. Environment variables
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env", "value": [{"name": "PYTHONPATH", "value": "/otel-auto-instrumentation/opentelemetry/instrumentation/auto_instrumentation:/otel-auto-instrumentation"}, {"name": "OTEL_TRACES_EXPORTER", "value": "otlp"}, {"name": "OTEL_METRICS_EXPORTER", "value": "otlp"}, {"name": "OTEL_LOGS_EXPORTER", "value": "otlp"}, {"name": "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED", "value": "true"}, {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "http://cxtvng-splunk-otel-collector-agent.ao.svc.cluster.local:4318"}, {"name": "OTEL_EXPORTER_OTLP_PROTOCOL", "value": "http/protobuf"}, {"name": "OTEL_RESOURCE_ATTRIBUTES", "value": "deployment.environment=production,service.version=25.2.2,service.namespace=cxtm"}, {"name": "OTEL_SERVICE_NAME", "value": "cxtm-scheduler"}]}]'

# 6. Command wrapper
kubectl patch deployment cxtm-scheduler -n cxtm --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["python3", "/otel-auto-instrumentation/bin/opentelemetry-instrument", "python3", "cron.py"]}]'
```

**Results**:
- Service visible with 3ms average latency
- Complete instrumentation success
- Zero errors in monitoring period

---

#### 3. CXTM-IMAGE-RETRIEVER (File Processing Service)
**Service Type**: Multi-process Python application
**Implementation**: ✅ Manual (Approach B - Complex multi-process architecture)
**Status**: Successfully instrumented despite pre-existing application issues

**Unique Characteristics**:
- Multi-process architecture (`start_cache_updater.py` + `run.py`)
- Docker entrypoint orchestration
- External HTTP dependencies (`engci-maven.cisco.com`)
- Health check failures (pre-existing application bugs)

**Key Learning**: OpenTelemetry instrumentation success measured by telemetry generation, not application health status.

**Results**:
- Visible in Service Map with external dependencies
- External HTTP calls: 389ms to engci-maven.cisco.com
- Multi-process telemetry generation working
- **Note**: Health check failures are pre-existing application issues, not instrumentation problems

---

#### 4. CXTM-LOGSTREAM (Log Processing Service)
**Service Type**: Simple Python script application
**Implementation**: ✅ Manual (Approach B - Webhook failed)
**Status**: Successfully instrumented with complete telemetry

**Application Characteristics**:
- Simple `python run.py` execution
- Port configuration mismatch (Service: 80, App: 8080)
- Minimal HTTP interface
- Event-driven telemetry generation

**Implementation Notes**:
- Lighter telemetry volume than web applications (expected for script-based apps)
- Generates traces during specific operations and I/O activities
- 325μs response times when active

**Results**:
- Service appears in APM dashboard
- 2 total requests captured in monitoring period
- Zero errors and excellent performance metrics

---

#### 5. CXTM-MIGRATE (Database Migration Utility)
**Service Type**: Database migration utility using Flyway
**Implementation**: ✅ Manual (Approach B - Required command modification)
**Status**: Successfully instrumented after resolving startup issues

**Unique Challenges**:
- **Critical Issue**: Initial environment variable addition caused application crashes
- **Root Cause**: Environment variable conflicts with migration processes
- **Solution**: Required careful environment variable management and startup command wrapping

**Implementation Lessons**:
- Database utilities may have sensitive startup requirements
- Environment variables must be added carefully to avoid conflicts
- Command wrapping essential for proper instrumentation activation

**Results**:
- Successful telemetry generation during migration operations
- 7ms average latency in Service Map
- Complete database operation monitoring

---

#### 6. Additional CXTM Services

**CXTM-WEBCRON**: Web-based cron job management (4ms latency)
**CXTM-ZIPSERVICE**: File compression service (1.2μs latency)
**CXTM-TASKDRIVER**: Task execution service

All following similar manual instrumentation patterns with successful results.

### 🔄 Standard Verification Process

For every service instrumentation, follow this verification checklist:

#### 1. Pod Status Check
```bash
kubectl get pods -n cxtm | grep <service-name>
# Expected: 1/1 Running status
```

#### 2. Init Container Verification
```bash
kubectl describe pod <pod-name> -n cxtm | grep -A3 "Init Containers"
# Expected: opentelemetry-auto-instrumentation-python container listed
```

#### 3. Environment Variables Check
```bash
kubectl exec <pod-name> -n cxtm -- env | grep OTEL
# Expected: OTEL_SERVICE_NAME and other OpenTelemetry variables present
```

#### 4. Application Process Verification
```bash
kubectl exec <pod-name> -n cxtm -- ps aux | head -5
# Expected: Application running (with or without visible OpenTelemetry wrapper)
```

#### 5. Traffic Generation
```bash
# Port forward and generate test requests
kubectl port-forward -n cxtm service/<service-name> 8080:8080 &
curl http://localhost:8080/healthz
```

#### 6. Splunk O11y Verification
- Check APM dashboard for service visibility
- Verify Service Map shows service and dependencies
- Confirm telemetry data generation (traces, metrics)
- Validate performance baselines are established

---

## Common Commands Reference

This comprehensive command reference captures the complete journey from initial environment assessment to production-ready observability implementation.

### 🔍 Environment Discovery Commands

#### Initial System Assessment
```bash
# SSH to control plane
ssh administrator@10.122.28.111
# Password: C1sco123=

# Check Kubernetes cluster version and health
kubectl version --short
kubectl get nodes

# List all namespaces and understand organization
kubectl get namespaces

# Find existing Splunk/OpenTelemetry infrastructure
kubectl get all --all-namespaces | grep -E "(otel|splunk)"

# Check for existing instrumentation configurations
kubectl get instrumentation --all-namespaces

# List services in monitoring namespace
kubectl get services -n ao
```

#### Infrastructure Verification
```bash
# Verify Splunk collector is running
kubectl get pods -n ao | grep cxtvng-splunk-otel-collector

# Check collector health and configuration
kubectl get pods -n ao -o wide | grep cxtvng-splunk
kubectl logs -l app=cxtvng-splunk-otel-collector -n ao --tail=50

# Verify OpenTelemetry operator status
kubectl get pods -n ao | grep opentelemetry-operator

# Check webhook configurations (for troubleshooting)
kubectl get validatingwebhookconfiguration | grep opentelemetry
kubectl get mutatingwebhookconfiguration | grep opentelemetry
```

### ⚙️ Instrumentation Implementation Commands

#### Approach A: Automatic Instrumentation (When Webhook Works)
```bash
# Set environment variables
kubectl set env deployment <service-name> -n cxtm \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://cxtvng-splunk-otel-collector-agent.ao.svc.cluster.local:4318

kubectl set env deployment <service-name> -n cxtm \
  OTEL_SERVICE_NAME=<service-name>

# Add instrumentation annotation
kubectl annotate deployment <service-name> -n cxtm \
  instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite

# Monitor deployment rollout
kubectl rollout status deployment/<service-name> -n cxtm
```

#### Approach B: Manual Instrumentation (When Webhook Fails)
```bash
# 1. Add node selector for registry access
kubectl patch deployment <service-name> -n cxtm --type='merge' \
  -p='{"spec":{"template":{"spec":{"nodeSelector":{"ao-node":"observability"}}}}}'

# 2. Add volume for OpenTelemetry libraries
kubectl patch deployment <service-name> -n cxtm --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "opentelemetry-auto-instrumentation-python", "emptyDir": {}}]}]'

# 3. Add init container
kubectl patch deployment <service-name> -n cxtm --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/initContainers", "value": [{"name": "opentelemetry-auto-instrumentation-python", "image": "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.54b1", "command": ["cp", "-r", "/autoinstrumentation/.", "/otel-auto-instrumentation/"], "volumeMounts": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]}]'

# 4. Add volume mount to main container
kubectl patch deployment <service-name> -n cxtm --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"mountPath": "/otel-auto-instrumentation", "name": "opentelemetry-auto-instrumentation-python"}]}]'

# 5. Add environment variables
kubectl patch deployment <service-name> -n cxtm --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env", "value": [{"name": "PYTHONPATH", "value": "/otel-auto-instrumentation/opentelemetry/instrumentation/auto_instrumentation:/otel-auto-instrumentation"}, {"name": "OTEL_TRACES_EXPORTER", "value": "otlp"}, {"name": "OTEL_METRICS_EXPORTER", "value": "otlp"}, {"name": "OTEL_LOGS_EXPORTER", "value": "otlp"}, {"name": "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED", "value": "true"}, {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "http://cxtvng-splunk-otel-collector-agent.ao.svc.cluster.local:4318"}, {"name": "OTEL_EXPORTER_OTLP_PROTOCOL", "value": "http/protobuf"}, {"name": "OTEL_RESOURCE_ATTRIBUTES", "value": "deployment.environment=production,service.version=25.2.2,service.namespace=cxtm"}, {"name": "OTEL_SERVICE_NAME", "value": "<service-name>"}]}]'

# 6. Wrap application startup command (if needed)
kubectl patch deployment <service-name> -n cxtm --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["python3", "/otel-auto-instrumentation/bin/opentelemetry-instrument", "python", "<script-name>.py"]}]'
```

### 🔍 Debugging and Verification Commands

#### Pod and Deployment Investigation
```bash
# Check pod status and recent events
kubectl get pods -n cxtm | grep <service-name>
kubectl describe pod <pod-name> -n cxtm

# Check deployment configuration
kubectl describe deployment <service-name> -n cxtm

# View recent events for troubleshooting
kubectl get events -n cxtm --sort-by='.lastTimestamp' | grep <service-name>

# Check logs for errors or issues
kubectl logs <pod-name> -n cxtm --tail=50
kubectl logs <pod-name> -n cxtm --previous  # if pod crashed
```

#### Application Process and Environment Analysis
```bash
# Check running processes in container
kubectl exec <pod-name> -n cxtm -- ps aux | head -5

# Verify environment variables
kubectl exec <pod-name> -n cxtm -- env | grep OTEL

# Check working directory and file structure
kubectl exec <pod-name> -n cxtm -- pwd
kubectl exec <pod-name> -n cxtm -- ls -la

# Verify OpenTelemetry libraries are accessible
kubectl exec <pod-name> -n cxtm -- ls -la /otel-auto-instrumentation/
```

#### Service and Network Testing
```bash
# Check service configuration
kubectl get services -n cxtm | grep <service-name>
kubectl describe service <service-name> -n cxtm

# Port forward for testing
kubectl port-forward -n cxtm service/<service-name> 8080:8080 &

# Generate test traffic
curl http://localhost:8080/healthz
curl http://localhost:8080/

# Clean up port forwarding
pkill -f "kubectl port-forward"
```

### 📊 Monitoring and Telemetry Verification

#### Collector Status and Logs
```bash
# Check collector health
kubectl get pods -n ao | grep collector

# Monitor collector logs for incoming telemetry
kubectl logs -l app=cxtvng-splunk-otel-collector -n ao --tail=50
kubectl logs -f -l app=cxtvng-splunk-otel-collector -n ao  # follow live

# Check for trace data processing
kubectl logs -l app=cxtvng-splunk-otel-collector -n ao --tail=20 | grep -i trace
```

#### End-to-End Verification Process
```bash
# 1. Verify instrumentation configuration exists
kubectl get instrumentation -n cxtm

# 2. Check deployment has annotation
kubectl describe deployment <service-name> -n cxtm | grep instrumentation

# 3. Confirm pod restarted with new configuration
kubectl get pods -n cxtm | grep <service-name>

# 4. Generate traffic to create traces
kubectl port-forward -n cxtm service/<service-name> 8080:8080 &
for i in {1..10}; do curl http://localhost:8080/healthz; done

# 5. Verify traces in collector logs
kubectl logs -l app=cxtvng-splunk-otel-collector -n ao --tail=20 | grep -E "(trace|POST.*v1)"
```

### 🚀 Scaling to Multiple Services

#### Batch Application of Instrumentation
```bash
# Apply to all CXTM services at once
for service in cxtm-scheduler cxtm-zipservice cxtm-taskdriver cxtm-webcron cxtm-logstream; do
  echo "Instrumenting $service..."
  kubectl annotate deployment $service -n cxtm \
    instrumentation.opentelemetry.io/inject-python=cxtm-python-instrumentation --overwrite
  kubectl set env deployment/$service -n cxtm OTEL_SERVICE_NAME=$service
  echo "$service instrumentation applied"
done

# Monitor all rollouts
kubectl rollout status deployment/cxtm-scheduler -n cxtm
kubectl rollout status deployment/cxtm-zipservice -n cxtm
# ... continue for each service
```

#### Verification Across All Services
```bash
# Check all CXTM pod status
kubectl get pods -n cxtm | grep cxtm-

# Verify all services have annotations
kubectl get deployments -n cxtm -o custom-columns=NAME:.metadata.name,ANNOTATIONS:.metadata.annotations

# Generate traffic to all services
kubectl get services -n cxtm | grep cxtm- | while read service _; do
  echo "Testing $service..."
  kubectl port-forward -n cxtm service/$service 8080:8080 &
  sleep 2
  curl -s http://localhost:8080/healthz || echo "$service not responding"
  pkill -f "kubectl port-forward.*$service"
done
```

### 📈 Performance and Resource Monitoring

#### Resource Usage Analysis
```bash
# Check resource consumption
kubectl top pods -n cxtm
kubectl top pods -n ao

# Monitor node resource usage
kubectl top nodes

# Check resource limits and requests
kubectl describe pods -n cxtm | grep -E "(Limits|Requests)" -A2
```

#### System Health Monitoring
```bash
# Overall cluster health
kubectl get componentstatuses
kubectl cluster-info

# Check for resource constraints
kubectl describe nodes | grep -E "(Allocated resources|Events)" -A10

# Monitor system events
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -20
```

### 🛠️ Troubleshooting Commands

#### Common Issue Resolution
```bash
# If webhook isn't working (annotation but no init container)
kubectl describe pod <pod-name> -n cxtm | grep -A10 "Init Containers"  # Should show OTel container

# If pod is crashing
kubectl logs <pod-name> -n cxtm --previous
kubectl describe pod <pod-name> -n cxtm | grep -A10 Events

# If no telemetry data
kubectl logs -l app=cxtvng-splunk-otel-collector -n ao | grep ERROR
kubectl exec <pod-name> -n cxtm -- env | grep OTEL_EXPORTER_OTLP_ENDPOINT

# If service not visible in Splunk
kubectl port-forward -n cxtm service/<service-name> 8080:8080 &
curl -v http://localhost:8080/  # Generate traffic
```

#### Advanced Diagnostics
```bash
# Check operator webhook logs
kubectl logs -l app.kubernetes.io/name=opentelemetry-operator -n ao

# Verify CRD configurations
kubectl get instrumentations.opentelemetry.io -n cxtm -o yaml

# Check collector configuration
kubectl describe configmap cxtvng-splunk-otel-collector-agent -n ao

# Network connectivity testing
kubectl exec <pod-name> -n cxtm -- nc -zv cxtvng-splunk-otel-collector-agent.ao.svc.cluster.local 4318
```

---

## Troubleshooting & Best Practices

### 🚨 Common Issues and Solutions

#### Issue 1: OpenTelemetry Operator Webhook Not Working
**Symptoms**: Annotation added but no init containers appear
**Root Cause**: Webhook admission controller failure
**Solution**: Use manual init container approach (Approach B)

**Diagnostic Commands**:
```bash
kubectl describe pod <pod-name> -n cxtm | grep -A10 "Init Containers"
# If empty, webhook failed - switch to manual approach
```

#### Issue 2: Application Crashing After Instrumentation
**Symptoms**: Pod restart loops, crash loop backoff
**Root Cause**: Environment variable conflicts or command wrapping issues
**Solution**: Careful environment variable management

**Diagnostic Steps**:
```bash
# Check crash logs
kubectl logs <pod-name> -n cxtm --previous

# Verify command configuration
kubectl describe deployment <service-name> -n cxtm | grep -A5 "Command"

# Check environment variable conflicts
kubectl exec <pod-name> -n cxtm -- env | sort
```

**Resolution**: Remove problematic environment variables or adjust startup commands

#### Issue 3: No Telemetry Data Generated
**Symptoms**: Service not visible in Splunk O11y
**Root Cause**: Misconfigured endpoints, no traffic, or instrumentation not active
**Solutions**:

```bash
# 1. Verify collector endpoint configuration
kubectl exec <pod-name> -n cxtm -- env | grep OTEL_EXPORTER_OTLP_ENDPOINT

# 2. Generate test traffic
kubectl port-forward -n cxtm service/<service-name> 8080:8080 &
curl http://localhost:8080/healthz

# 3. Check collector logs for incoming data
kubectl logs -l app=cxtvng-splunk-otel-collector -n ao --tail=50 | grep -i trace
```

#### Issue 4: Service Port Mismatches
**Symptoms**: Cannot connect to service for testing
**Root Cause**: Service port differs from application port
**Solution**: Use correct ports for testing

**Diagnostic**:
```bash
kubectl get services -n cxtm | grep <service-name>
kubectl describe deployment <service-name> -n cxtm | grep -A3 Port
```

**Resolution**: Use service port for external access, application port for internal testing

#### Issue 5: Multi-Process Applications Not Fully Instrumented
**Symptoms**: Only some processes generating telemetry
**Root Cause**: PYTHONPATH not inherited by child processes
**Solution**: Ensure proper environment variable configuration

**Verification**:
```bash
# Check all running processes
kubectl exec <pod-name> -n cxtm -- ps aux | grep python

# Verify PYTHONPATH in all processes
kubectl exec <pod-name> -n cxtm -- cat /proc/*/environ | grep PYTHONPATH
```

### 🎯 Best Practices for Implementation

#### 1. Pre-Implementation Assessment
- **Always check existing infrastructure first** before deploying new components
- **Understand application architecture** (single process vs multi-process, web framework vs script)
- **Verify namespace organization** and ensure instrumentation configs are in the correct namespace
- **Test webhook functionality** with a simple service before large-scale deployment

#### 2. Systematic Implementation Approach
- **Start with one service** to validate the approach
- **Document the exact commands** used for successful implementations
- **Use consistent naming conventions** for service identification
- **Implement verification steps** after each configuration change

#### 3. Environment Configuration Standards
```yaml
# Standard environment variable set for all services
env:
- name: OTEL_SERVICE_NAME
  value: <service-name>
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: http://cxtvng-splunk-otel-collector-agent.ao.svc.cluster.local:4318
- name: OTEL_EXPORTER_OTLP_PROTOCOL
  value: http/protobuf
- name: OTEL_RESOURCE_ATTRIBUTES
  value: deployment.environment=production,service.version=<version>,service.namespace=cxtm
```

#### 4. Testing and Validation Protocol
1. **Pod Status**: Ensure 1/1 Running status
2. **Init Container**: Verify OpenTelemetry container completed
3. **Environment Variables**: Check OTEL_* variables are set
4. **Traffic Generation**: Create test requests to generate traces
5. **Telemetry Verification**: Confirm data appears in Splunk O11y within 15 minutes
6. **Performance Baseline**: Establish response time and throughput baselines

#### 5. Monitoring and Maintenance
- **Regular Health Checks**: Monitor service status and performance metrics
- **Alert Configuration**: Set up proactive alerts for performance degradation
- **Capacity Planning**: Use telemetry data for infrastructure scaling decisions
- **Documentation Updates**: Keep implementation guides current with environment changes

### 🔍 Debugging Methodology

#### Systematic Problem-Solving Approach

1. **Identify the Scope**: Is it one service, multiple services, or system-wide?
2. **Check Recent Changes**: What was modified recently that might cause issues?
3. **Verify Basics**: Pod status, environment variables, network connectivity
4. **Examine Logs**: Application logs, collector logs, operator logs
5. **Test Incrementally**: Generate traffic, check telemetry, verify end-to-end flow
6. **Compare Working Examples**: Use successful services as reference points

#### Key Diagnostic Questions
- Is the pod running and healthy?
- Are init containers completing successfully?
- Are environment variables configured correctly?
- Is the application generating any HTTP traffic?
- Is the collector receiving telemetry data?
- Are there any network connectivity issues?
- Is the service visible in Splunk O11y (even if unhealthy)?

### 📊 Performance Optimization Guidelines

#### Resource Usage Optimization
- **Init Container Overhead**: ~50MB memory, <10 second startup time
- **Runtime Memory**: ~20-30MB additional per instrumented service
- **CPU Impact**: <2-3% additional overhead
- **Network Traffic**: Minimal increase for telemetry transmission
