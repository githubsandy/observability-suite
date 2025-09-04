# Kubernetes Master-Worker Architecture & Helm Deployment Guide

## 🎯 **Document Purpose**
This document explains how Kubernetes master-worker architecture works and what happens behind the scenes when we deploy our Splunk OpenTelemetry solution using Helm.

---

## 🏗️ **Kubernetes Cluster Architecture Overview**

### **Your Current Environment**
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

---

## 🎭 **Roles & Responsibilities**

### **Control Plane (Master) - "The Brain"**
| Component | Purpose | What It Does |
|-----------|---------|--------------|
| **API Server** | Central communication hub | Receives all kubectl/helm commands |
| **etcd** | Cluster database | Stores desired state of all resources |
| **Scheduler** | Pod placement decision maker | Decides which worker node runs each pod |
| **Controller Manager** | State reconciliation | Ensures actual state matches desired state |

**Your Role:** You SSH here and run management commands (kubectl, helm)

### **Worker Nodes - "The Muscle"**
| Component | Purpose | What It Does |
|-----------|---------|--------------|
| **kubelet** | Node agent | Communicates with control plane, manages pods |
| **Container Runtime** | Pod execution | Actually runs containers (containerd in your case) |
| **kube-proxy** | Networking | Handles service networking and load balancing |

**Their Role:** Execute actual workloads, run your CXTM applications and OTEL collectors

---

## 🚀 **Helm Deployment Process - Step by Step**

### **What Happens When You Run `./deploy-helm-otel.sh`**

#### **Phase 1: Command Execution (Control Plane)**
```
You (SSH to control plane) → Execute ./deploy-helm-otel.sh
                           ↓
                    Helm client starts
```

#### **Phase 2: Helm Processing (Control Plane)**
```
1. Helm reads helm-values.yaml
2. Helm downloads Splunk OTEL chart from repository
3. Helm renders Kubernetes YAML manifests
4. Helm sends manifests to API Server
```

#### **Phase 3: API Server Processing (Control Plane)**
```
API Server receives requests → Validates manifests → Stores in etcd
                            ↓
                    Creates resource objects:
                    • Namespace: splunk-monitoring
                    • Deployment: opentelemetry-operator
                    • DaemonSet: splunk-otel-collector-agent
                    • ConfigMaps, Services, etc.
```

#### **Phase 4: Scheduler Decision Making (Control Plane)**
```
Scheduler watches for unscheduled pods → Analyzes resource requirements
                                       ↓
                            Decides placement based on:
                            • Node capacity (CPU, memory)
                            • Node selectors/taints
                            • Anti-affinity rules
                            • Resource constraints
```

#### **Phase 5: Pod Creation (Worker Nodes)**
```
kubelet on selected worker nodes → Receives pod specifications
                                 ↓
                          Pulls container images
                                 ↓
                          Creates and starts containers
```

---

## 📊 **Deployment Distribution Across Nodes**

### **What Gets Deployed WHERE**

#### **OpenTelemetry Operator (Deployment)**
- **Type**: Single pod deployment
- **Placement**: Scheduler picks ONE worker node
- **Purpose**: Manages auto-instrumentation for applications
- **Resource**: Lightweight (usually < 100MB)

```
Control Plane Decision:
"Deploy operator on worker-03 (has available resources)"
```

#### **OpenTelemetry Collector (DaemonSet)**
- **Type**: One pod per worker node
- **Placement**: ALL worker nodes (16 pods total)
- **Purpose**: Collect traces/metrics from applications on each node
- **Resource**: ~200MB per node

```
Control Plane Decision:
"Deploy collector pod on EVERY worker node"

Result:
uta-k8s-ao-01      → splunk-otel-collector-agent-xxxxx
uta-k8s-ao-02      → splunk-otel-collector-agent-xxxxx
uta-k8s-worker-01  → splunk-otel-collector-agent-xxxxx
uta-k8s-worker-02  → splunk-otel-collector-agent-xxxxx
... (and so on for all 16 nodes)
```

#### **CXTM Applications (Already Running)**
- **Current State**: Distributed across worker nodes
- **After Instrumentation**: Same nodes, but with added init containers

```
Current Distribution:
uta-k8s-worker-01  → cxtm-web-xxx
uta-k8s-worker-03  → cxtm-scheduler-xxx  
uta-k8s-worker-07  → cxtm-zipservice-xxx
... (existing placement)
```

---

## 🔄 **Communication Flow During Runtime**

### **Trace Collection Flow**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CXTM App      │────│  OTEL Collector │────│   Splunk O11y   │
│ (worker-01)     │    │  (worker-01)    │    │     Cloud       │
│                 │    │                 │    │                 │
│ Flask app       │    │ Same node       │    │ External SaaS   │
│ generates       │    │ collects &      │    │ displays APM    │
│ trace spans     │    │ forwards        │    │ data            │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │ HTTP/gRPC            │ HTTPS                 │
         │ localhost:4318       │ ingest.us1.signalfx.com
         │                      │                       │
    In-node communication    Internet communication
```

### **Management Flow**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   You (SSH)     │────│  Control Plane  │────│  Worker Nodes   │
│ kubectl/helm    │    │  API Server     │    │  kubelet        │
│ commands        │    │                 │    │                 │
│                 │    │ Processes       │    │ Executes        │
│                 │    │ requests        │    │ instructions    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │ API calls            │ Instructions          │
         │ Port 6443            │ Various protocols     │
```

---

## 🎯 **Key Concepts Explained**

### **Why DaemonSet for OTEL Collector?**
- **Goal**: Collect metrics/traces from ALL nodes
- **Solution**: DaemonSet ensures one collector per node
- **Benefit**: Local collection (low latency, no network overhead)

### **Why Deployment for Operator?**
- **Goal**: Manage instrumentation across cluster
- **Solution**: Single operator can manage all nodes
- **Benefit**: Centralized control, resource efficient

### **Why Init Containers for Instrumentation?**  
- **Problem**: Runtime pip install was unreliable
- **Solution**: Init container pre-installs libraries
- **Benefit**: Libraries ready before application starts

---

## 🔍 **Monitoring & Troubleshooting**

### **Commands You Run (Control Plane)**
```bash
# Check what's deployed where
kubectl get pods -o wide -n splunk-monitoring

# See which node runs which pod
kubectl get pods -n cxtm -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName

# Check logs from any worker node
kubectl logs -l app.kubernetes.io/name=splunk-otel-collector -n splunk-monitoring

# Describe resources on any node
kubectl describe pod <pod-name> -n splunk-monitoring
```

### **What Happens Behind the Scenes**
1. **kubectl** sends API request to control plane
2. **API Server** retrieves information from etcd
3. **If logs requested**: API Server fetches from kubelet on worker node
4. **Response** flows back through control plane to your terminal

---

## 💡 **Advantages of This Architecture**

### **Scalability**
- **Control Plane**: Handles cluster management for any number of nodes
- **Worker Nodes**: Can add more nodes without changing control plane

### **Reliability** 
- **Control Plane**: Can be made highly available (3 masters in your case)
- **Worker Nodes**: If one fails, workloads can be rescheduled to others

### **Security**
- **Control Plane**: Centralized access control and authentication
- **Worker Nodes**: Isolated workload execution

### **Observability**
- **Control Plane**: Central monitoring and logging of cluster state
- **Worker Nodes**: Distributed data collection (OTEL collectors)

---

## 🚨 **Common Misconceptions Clarified**

### **❌ Misconception**: "I need to SSH to worker nodes to deploy"
**✅ Reality**: You only SSH to control plane. Kubernetes handles worker node operations.

### **❌ Misconception**: "Applications run on control plane"  
**✅ Reality**: Applications run on worker nodes. Control plane only manages them.

### **❌ Misconception**: "Each node needs separate configuration"
**✅ Reality**: One configuration applies to all nodes via Kubernetes controllers.

### **❌ Misconception**: "I need to manually start services on each node"
**✅ Reality**: Kubernetes automatically ensures desired state across all nodes.

---

## 🎯 **Practical Example: Your CXTM Deployment**

### **Before Helm Deployment**
```
Control Plane: You manage cluster, CXTM apps run on workers
Worker Nodes:  cxtm-web, cxtm-scheduler, etc. (no observability)
```

### **During Helm Deployment**  
```
Control Plane: Processes Helm charts, schedules new pods
Worker Nodes:  Kubernetes starts OTEL collectors and operator
```

### **After Helm Deployment**
```
Control Plane: Monitors health, manages configurations
Worker Nodes:  CXTM apps + OTEL collectors collecting traces
Splunk O11y:   Receives and displays application performance data
```

---

## 🔄 **Summary: Your Role vs Kubernetes Role**

### **Your Role (Control Plane)**
- ✅ Execute deployment commands
- ✅ Monitor cluster health  
- ✅ Troubleshoot issues
- ✅ Configure resources

### **Kubernetes Role (Automated)**
- ✅ Schedule pods to appropriate nodes
- ✅ Ensure desired state is maintained
- ✅ Handle pod restarts and failures
- ✅ Manage networking and storage

### **Worker Nodes Role (Automated)**
- ✅ Run assigned workloads
- ✅ Collect and forward observability data
- ✅ Report status back to control plane
- ✅ Execute container operations

---

This architecture ensures that your **single command execution** on the control plane results in **coordinated deployment across all 16 worker nodes**, with **automatic management and monitoring** of the entire observability pipeline! 🚀