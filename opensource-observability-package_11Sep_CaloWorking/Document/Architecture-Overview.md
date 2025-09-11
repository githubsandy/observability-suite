# Enterprise Observability Stack - Architecture Overview

**Complementary Document to Technical Design Document**  
**Visual Architecture Reference**

---

## System Architecture Diagrams

### 1. High-Level Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE LAYER                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐│
│  │                    GRAFANA VISUALIZATION                            ││
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   ││
│  │  │   Metrics   │ │    Logs     │ │   Traces    │ │   Alerts    │   ││
│  │  │ Dashboards  │ │ Dashboards  │ │ Dashboards  │ │ Dashboard   │   ││
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   ││
│  └─────────────────────────────────────────────────────────────────────┘│
│                                    ↑                                   │
├────────────────────────────────────┼───────────────────────────────────┤
│                DATA SOURCES LAYER   │                                   │
├────────────────────────────────────┼───────────────────────────────────┤
│                                    │                                   │
│  ┌────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌──────────┐│
│  │   PROMETHEUS   │ │      LOKI       │ │     TEMPO       │ │ALERTMGR  ││
│  │   (Metrics)    │ │    (Logs)       │ │   (Traces)      │ │(Alerts)  ││
│  │                │ │                 │ │                 │ │          ││
│  │ ┌──────────────┤ │ ┌───────────────┤ │ ┌───────────────┤ │ ┌────────┤│
│  │ │   TSDB       │ │ │  Log Store    │ │ │  Trace Store  │ │ │ Rules  ││
│  │ │   Storage    │ │ │   (Chunks)    │ │ │   (Blocks)    │ │ │Engine  ││
│  │ └──────────────┤ │ └───────────────┤ │ └───────────────┤ │ └────────┤│
│  └────────────────┘ └─────────────────┘ └─────────────────┘ └──────────┘│
│         ↑                    ↑                    ↑              ↑     │
├─────────┼────────────────────┼────────────────────┼──────────────┼─────┤
│  COLLECTION & PROCESSING LAYER                    │              │     │
├─────────┼────────────────────┼────────────────────┼──────────────┼─────┤
│         │                    │                    │              │     │
│  ┌──────▼──────┐    ┌────────▼────────┐    ┌──────▼──────┐      │     │
│  │ EXPORTERS   │    │    PROMTAIL     │    │ EXISTING    │      │     │
│  │ ECOSYSTEM   │    │  (Log Agent)    │    │ DIRECT      │      │     │
│  │             │    │                 │    │ (Enterprise)│      │     │
│  │ • Node      │    │ ┌─────────────┐ │    │             │      │     │
│  │ • kube-state│    │ │ Tail Logs   │ │    │ ┌─────────┐ │      │     │
│  │ • Blackbox  │    │ │ Parse       │ │    │ │Universal│ │      │     │
│  │ • Custom    │    │ │ Label       │ │    │ │ Traces  │ │      │     │
│  └─────────────┘    │ └─────────────┘ │    │ │→Tempo   │ │      │     │
│                     └─────────────────┘    │ └─────────┘ │      │     │
│                                            └─────────────┘      │     │
│                                                   ↑             │     │
├───────────────────────────────────────────────────┼─────────────┼─────┤
│               ENHANCED MONITORING LAYER           │             │     │
├───────────────────────────────────────────────────┼─────────────┼─────┤
│                                                   │             │     │
│  ┌─────────────┐ ┌─────────────┐ ┌───────────────┐ │      ┌──────▼─────┐│
│  │ SMOKEPING   │ │ MTR         │ │  ENHANCED     │ │      │  ALERT     ││
│  │ (Network    │ │ (Path       │ │  BLACKBOX     │ │      │  RULES     ││
│  │ Latency)    │ │ Analysis)   │ │  (15+ Modules)│ │      │  ENGINE    ││
│  │             │ │             │ │               │ │      │            ││
│  │ • RTT       │ │ • Hop Trace │ │ • HTTP/HTTPS  │ │      │ • Infra    ││
│  │ • Loss %    │ │ • Route Map │ │ • TCP/DNS     │ │      │ • App      ││
│  │ • Graphs    │ │ • Latency   │ │ • SSL/ICMP    │ │      │ • Network  ││
│  └─────────────┘ └─────────────┘ │ • Custom      │ │      │ • Custom   ││
│                                  └───────────────┘ │      └────────────┘│
│                                                    │                    │
├────────────────────────────────────────────────────┼────────────────────┤
│                   AUTO-DISCOVERY LAYER             │                    │
├────────────────────────────────────────────────────┼────────────────────┤
│                                                    │                    │
│  ┌─────────────────────────────────────────────────▼────────────────────┐│
│  │                   KUBERNETES INTEGRATION                             ││
│  │                                                                      ││
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ││
│  │  │   SERVICE    │ │   CXTAF      │ │    CXTM      │ │  ENVIRONMENT │ ││
│  │  │  DISCOVERY   │ │ DETECTION    │ │ INTEGRATION  │ │  ADAPTATION  │ ││
│  │  │              │ │              │ │              │ │              │ ││
│  │  │ • API Watch  │ │ • Framework  │ │ • Workflows  │ │ • Node Sel.  │ ││
│  │  │ • Endpoints  │ │ • Tests      │ │ • Databases  │ │ • Storage    │ ││
│  │  │ • Config Gen │ │ • Devices    │ │ • Metrics    │ │ • Network    │ ││
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘ ││
│  └──────────────────────────────────────────────────────────────────────┘│
│                                     ↑                                    │
├─────────────────────────────────────┼────────────────────────────────────┤
│                INFRASTRUCTURE LAYER │                                    │
├─────────────────────────────────────┼────────────────────────────────────┤
│                                     │                                    │
│  ┌──────────────────────────────────▼────────────────────────────────────┐│
│  │                        KUBERNETES CLUSTER                             ││
│  │                                                                        ││
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐     ││
│  │  │   CALO LAB  │ │     AWS     │ │     GCP     │ │   ON-PREM   │     ││
│  │  │ ENVIRONMENT │ │  ENVIRONMENT│ │ ENVIRONMENT │ │ ENVIRONMENT │     ││
│  │  │             │ │             │ │             │ │             │     ││
│  │  │ • ao-nodes  │ │ • EKS       │ │ • GKE       │ │ • VMware    │     ││
│  │  │ • Longhorn  │ │ • EBS       │ │ • Disk      │ │ • Local     │     ││
│  │  │ • Internal  │ │ • VPC       │ │ • VPC       │ │ • Network   │     ││
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘     ││
│  └────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────┘
```

### 2. Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA FLOW PIPELINE                          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   APPLICATIONS  │    │  INFRASTRUCTURE │    │     NETWORK     │
│                 │    │                 │    │                 │
│ • Microservices │    │ • Kubernetes    │    │ • External APIs │
│ • CXTAF Tests   │    │ • Nodes         │    │ • Internal Svcs │
│ • CXTM Workflows│    │ • Containers    │    │ • Gateways      │
│ • Databases     │    │ • Storage       │    │ • Load Balancer │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   METRICS       │    │      LOGS       │    │    TRACES       │
│                 │    │                 │    │                 │
│ • /metrics      │    │ • stdout/stderr │    │ • OTLP          │
│ • Custom        │    │ • Log files     │    │ • Jaeger        │
│ • Health        │    │ • Audit logs    │    │ • Zipkin        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   COLLECTION    │    │   COLLECTION    │    │   COLLECTION    │
│                 │    │                 │    │                 │
│ • Prometheus    │    │ • Promtail      │    │ • Direct        │
│ • Exporters     │    │ • Fluentd/Bit   │    │ • Ingestion     │
│ • Blackbox      │    │ • Syslog        │    │ • Multi-Proto   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     STORAGE     │    │     STORAGE     │    │     STORAGE     │
│                 │    │                 │    │                 │
│ • Prometheus    │    │ • Loki          │    │ • Tempo         │
│ • TSDB          │    │ • Chunks        │    │ • Blocks        │
│ • Local/Remote  │    │ • Object Store  │    │ • Object Store  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        VISUALIZATION                                │
│                                                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐  │
│  │   GRAFANA   │ │   EXPLORE   │ │   ALERTS    │ │ DASHBOARDS  │  │
│  │             │ │             │ │             │ │             │  │
│  │ • Queries   │ │ • Ad-hoc    │ │ • Rules     │ │ • Business  │  │
│  │ • Panels    │ │ • Correlation│ │ • Routing   │ │ • Technical │  │
│  │ • Variables │ │ • Logs→Trace│ │ • Silencing │ │ • Network   │  │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### 3. Network Monitoring Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NETWORK MONITORING SUITE                         │
└─────────────────────────────────────────────────────────────────────┘

      ┌─────────────────────────────────────────────────────────────┐
      │                    TARGET ENDPOINTS                         │
      └─────────────────────────────────────────────────────────────┘
                                   │
      ┌────────────────┬────────────┼────────────┬────────────────┐
      │                │            │            │                │
      ▼                ▼            ▼            ▼                ▼
┌─────────┐   ┌─────────────┐   ┌──────┐   ┌─────────┐   ┌─────────────┐
│ CXTAF   │   │ CXTM        │   │ K8s  │   │External │   │ University  │
│ APIs    │   │ Services    │   │ Svcs │   │ APIs    │   │ Network     │
└─────────┘   └─────────────┘   └──────┘   └─────────┘   └─────────────┘
      │                │            │            │                │
      └────────────────┼────────────┼────────────┼────────────────┘
                       │            │            │
                       ▼            ▼            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   MONITORING COMPONENTS                              │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ SMOKEPING   │    │ MTR         │    │   ENHANCED BLACKBOX     │  │
│  │             │    │ ANALYZER    │    │                         │  │
│  │ Network     │    │             │    │ ┌─────────────────────┐ │  │
│  │ Latency     │    │ Path        │    │ │ HTTP/HTTPS Module   │ │  │
│  │ Monitor     │    │ Analysis    │    │ │ TCP Connect Module  │ │  │
│  │             │    │             │    │ │ DNS Lookup Module   │ │  │
│  │ • RTT       │    │ • Hops      │    │ │ SSL Cert Module     │ │  │
│  │ • Jitter    │    │ • Routes    │    │ │ ICMP Ping Module    │ │  │
│  │ • Loss %    │    │ • Latency   │    │ │ Custom API Module   │ │  │
│  │ • Graphs    │    │ • Topology  │    │ │ CXTAF Test Module   │ │  │
│  └─────────────┘    └─────────────┘    │ │ CXTM Health Module  │ │  │
│         │                   │          │ │ ... (15+ modules)   │ │  │
│         │                   │          │ └─────────────────────┘ │  │
│         │                   │          └─────────────────────────┘  │
│         │                   │                         │              │
└─────────┼───────────────────┼─────────────────────────┼──────────────┘
          │                   │                         │
          ▼                   ▼                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      METRICS EXPORT                                 │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ Smokeping   │    │ MTR         │    │ Blackbox                │  │
│  │ Metrics     │    │ Metrics     │    │ Metrics                 │  │
│  │             │    │             │    │                         │  │
│  │ • rtt_ms    │    │ • hop_count │    │ • probe_success         │  │
│  │ • loss_pct  │    │ • hop_rtt   │    │ • probe_duration        │  │
│  │ • packets   │    │ • path_mtus │    │ • probe_http_status     │  │
│  └─────────────┘    └─────────────┘    │ • probe_ssl_expiry      │  │
│                                        │ • probe_dns_lookup_time │  │
│                                        └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       PROMETHEUS                                    │
│                    (Network Metrics)                                │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        GRAFANA                                      │
│                  (Network Dashboards)                               │
└─────────────────────────────────────────────────────────────────────┘
```

### 4. Auto-Discovery Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                      AUTO-DISCOVERY ENGINE                          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ KUBERNETES  │    │   CXTAF     │    │    CXTM     │    │ ENVIRONMENT │
│   CLUSTER   │    │ FRAMEWORK   │    │ FRAMEWORK   │    │  DETECTION  │
│             │    │             │    │             │    │             │
│ • Pods      │    │ • Tests     │    │ • Workflows │    │ • CALO Lab  │
│ • Services  │    │ • Devices   │    │ • Databases │    │ • AWS       │
│ • Endpoints │    │ • APIs      │    │ • Queue     │    │ • GCP       │
│ • Ingress   │    │ • Results   │    │ • Reports   │    │ • On-Prem   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
         │                 │                 │                 │
         ▼                 ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    DISCOVERY AGENTS                                  │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ K8S API     │    │ Annotation  │    │   Configuration         │  │
│  │ WATCHER     │    │ SCANNER     │    │   GENERATOR             │  │
│  │             │    │             │    │                         │  │
│  │ • Watch     │    │ • Labels    │    │ • Prometheus Targets    │  │
│  │ • Events    │    │ • Metadata  │    │ • Grafana Datasources  │  │
│  │ • Changes   │    │ • Custom    │    │ • Alert Rules           │  │
│  │ • Resources │    │ • Patterns  │    │ • Dashboard Vars        │  │
│  └─────────────┘    └─────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   CONFIGURATION UPDATES                             │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ Prometheus  │    │ Grafana     │    │ AlertManager            │  │
│  │ Config      │    │ Config      │    │ Config                  │  │
│  │             │    │             │    │                         │  │
│  │ • Targets   │    │ • Variables │    │ • Rules                 │  │
│  │ • Jobs      │    │ • Queries   │    │ • Routes                │  │
│  │ • Rules     │    │ • Panels    │    │ • Templates             │  │
│  └─────────────┘    └─────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      DYNAMIC MONITORING                             │
│                   (Zero-Configuration)                              │
└─────────────────────────────────────────────────────────────────────┘
```

### 5. Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT PIPELINE                              │
└─────────────────────────────────────────────────────────────────────┘

                              │ USER INPUT │
                              └─────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    ENVIRONMENT DETECTION                            │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ Cluster     │    │ Storage     │    │ Network                 │  │
│  │ Analysis    │    │ Detection   │    │ Topology                │  │
│  │             │    │             │    │                         │  │
│  │ • Nodes     │    │ • Classes   │    │ • DNS                   │  │
│  │ • Version   │    │ • PV/PVC    │    │ • Ingress               │  │
│  │ • Resources │    │ • Provider  │    │ • Load Balancer         │  │
│  │ • Labels    │    │ • Features  │    │ • Security Policies     │  │
│  └─────────────┘    └─────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                 CONFIGURATION GENERATION                            │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ Values      │    │ Resource    │    │ Security                │  │
│  │ Generation  │    │ Sizing      │    │ Configuration           │  │
│  │             │    │             │    │                         │  │
│  │ • Template  │    │ • CPU/Mem   │    │ • RBAC                  │  │
│  │ • Override  │    │ • Storage   │    │ • Network Policies      │  │
│  │ • Validate  │    │ • Replicas  │    │ • Pod Security          │  │
│  └─────────────┘    └─────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      HELM DEPLOYMENT                               │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ Chart       │    │ Template    │    │ Resource                │  │
│  │ Validation  │    │ Rendering   │    │ Creation                │  │
│  │             │    │             │    │                         │  │
│  │ • Syntax    │    │ • Values    │    │ • Namespace             │  │
│  │ • Schema    │    │ • Logic     │    │ • Deployments           │  │
│  │ • Dependencies│  │ • Conditionals│  │ • Services              │  │
│  └─────────────┘    └─────────────┘    │ • ConfigMaps            │  │
│                                        │ • Secrets               │  │
│                                        └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   POST-DEPLOYMENT VALIDATION                        │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ Health      │    │ Integration │    │ Performance             │  │
│  │ Checks      │    │ Testing     │    │ Validation              │  │
│  │             │    │             │    │                         │  │
│  │ • Pod Ready │    │ • Connectivity│  │ • Resource Usage        │  │
│  │ • Services  │    │ • Data Flow │    │ • Response Times        │  │
│  │ • Endpoints │    │ • Queries   │    │ • Throughput            │  │
│  └─────────────┘    └─────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Component Interaction Diagrams

### 1. Metrics Collection Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   TARGET    │    │  EXPORTER   │    │ PROMETHEUS  │    │   GRAFANA   │
│ APPLICATION │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
      │                   │                   │                   │
      │ expose /metrics   │                   │                   │
      ├──────────────────►│                   │                   │
      │                   │                   │                   │
      │                   │ HTTP GET /metrics │                   │
      │                   │◄──────────────────┤                   │
      │                   │                   │                   │
      │                   │ metrics response  │                   │
      │                   ├──────────────────►│                   │
      │                   │                   │                   │
      │                   │                   │ store in TSDB     │
      │                   │                   ├──────────────────►│
      │                   │                   │                   │
      │                   │                   │ PromQL query      │
      │                   │                   │◄──────────────────┤
      │                   │                   │                   │
      │                   │                   │ query response    │
      │                   │                   ├──────────────────►│
      │                   │                   │                   │
```

### 2. Log Collection Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ APPLICATION │    │  PROMTAIL   │    │    LOKI     │    │   GRAFANA   │
│ CONTAINER   │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
      │                   │                   │                   │
      │ stdout/stderr     │                   │                   │
      ├──────────────────►│                   │                   │
      │                   │                   │                   │
      │                   │ tail & parse      │                   │
      │                   │ extract labels    │                   │
      │                   │                   │                   │
      │                   │ HTTP POST         │                   │
      │                   ├──────────────────►│                   │
      │                   │                   │                   │
      │                   │                   │ index & store     │
      │                   │                   │ in chunks         │
      │                   │                   │                   │
      │                   │                   │ LogQL query       │
      │                   │                   │◄──────────────────┤
      │                   │                   │                   │
      │                   │                   │ log entries       │
      │                   │                   ├──────────────────►│
      │                   │                   │                   │
```

### 3. Trace Collection Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ APPLICATION │    │ DIRECT      │    │   TEMPO     │    │   GRAFANA   │
│ (Instrumented)│  │ INGESTION   │    │             │    │             │
│               │  │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
      │                   │                   │                   │
      │ OTLP/Jaeger       │                   │                   │
      ├──────────────────►│                   │                   │
      │                   │                   │                   │
      │                   │ multi-protocol    │                   │
      │                   │ direct ingestion  │                   │
      │                   │                   │                   │
      │                   │ OTLP              │                   │
      │                   ├──────────────────►│                   │
      │                   │                   │                   │
      │                   │                   │ store in blocks   │
      │                   │                   │ generate metrics  │
      │                   │                   │                   │
      │                   │                   │ TraceQL query     │
      │                   │                   │◄──────────────────┤
      │                   │                   │                   │
      │                   │                   │ trace data        │
      │                   │                   ├──────────────────►│
      │                   │                   │                   │
```

---

## Resource Architecture

### Kubernetes Resource Hierarchy

```
Namespace: ao-os
├── Core Observability
│   ├── Prometheus
│   │   ├── Deployment: prometheus
│   │   ├── Service: prometheus
│   │   ├── ServiceAccount: prometheus
│   │   ├── ClusterRole: prometheus
│   │   ├── ConfigMap: prometheus-config
│   │   └── PVC: prometheus-storage
│   ├── Grafana
│   │   ├── Deployment: grafana
│   │   ├── Service: grafana
│   │   ├── ConfigMap: grafana-datasources
│   │   ├── Secret: grafana-admin
│   │   └── PVC: grafana-storage
│   └── Loki
│       ├── Deployment: loki
│       ├── Service: loki
│       ├── ConfigMap: loki-config
│       └── PVC: loki-storage
├── Enhanced Monitoring
│   ├── Tempo
│   │   ├── Deployment: tempo
│   │   ├── Service: tempo
│   │   ├── ConfigMap: tempo-config
│   │   └── PVC: tempo-storage
│   ├── Direct Trace Ingestion (No Dependencies)
│   │   ├── Multi-protocol support (OTLP, Jaeger, Zipkin)
│   │   ├── Direct application to Tempo communication
│   │   └── Zero external collector dependencies
│   └── AlertManager
│       ├── Deployment: alertmanager
│       ├── Service: alertmanager
│       ├── ConfigMap: alertmanager-config
│       └── Secret: alertmanager-templates
├── Network Monitoring
│   ├── Smokeping
│   │   ├── Deployment: smokeping
│   │   ├── Service: smokeping
│   │   ├── ConfigMap: smokeping-config
│   │   └── PVC: smokeping-data
│   ├── MTR Analyzer
│   │   ├── Deployment: mtr-analyzer
│   │   ├── Service: mtr-analyzer
│   │   └── ConfigMap: mtr-config
│   └── Enhanced Blackbox
│       ├── Deployment: blackbox-exporter
│       ├── Service: blackbox-exporter
│       └── ConfigMap: blackbox-config
└── Infrastructure Exporters
    ├── Node Exporter
    │   ├── DaemonSet: node-exporter
    │   ├── Service: node-exporter
    │   └── ServiceAccount: node-exporter
    ├── kube-state-metrics
    │   ├── Deployment: kube-state-metrics
    │   ├── Service: kube-state-metrics
    │   ├── ServiceAccount: kube-state-metrics
    │   └── ClusterRole: kube-state-metrics
    └── Promtail
        ├── DaemonSet: promtail
        ├── Service: promtail
        ├── ServiceAccount: promtail
        ├── ClusterRole: promtail
        └── ConfigMap: promtail-config
```

---

## Integration Points

### External System Integrations

```
Enterprise Observability Stack
            │
            ├─ CALO Lab Infrastructure
            │  ├─ CXTAF Framework
            │  │  ├─ Test Automation Services
            │  │  ├─ Device Management APIs
            │  │  └─ Results Databases
            │  ├─ CXTM Workflow Engine
            │  │  ├─ MariaDB Cluster
            │  │  ├─ Redis Cache
            │  │  └─ Queue Management
            │  └─ UTA Network Services
            │     ├─ DNS Servers
            │     ├─ NTP Servers
            │     └─ Gateway Services
            │
            ├─ Cloud Integrations
            │  ├─ AWS Services
            │  │  ├─ EKS Clusters
            │  │  ├─ S3 Storage
            │  │  └─ CloudWatch
            │  ├─ GCP Services
            │  │  ├─ GKE Clusters
            │  │  ├─ Cloud Storage
            │  │  └─ Cloud Monitoring
            │  └─ Azure Services
            │     ├─ AKS Clusters
            │     ├─ Blob Storage
            │     └─ Azure Monitor
            │
            └─ Enterprise Integrations
               ├─ Identity Providers
               │  ├─ LDAP/Active Directory
               │  ├─ OAuth/OIDC
               │  └─ SAML
               ├─ Notification Systems
               │  ├─ Slack
               │  ├─ Microsoft Teams
               │  ├─ Email (SMTP)
               │  └─ Webhooks
               └─ External Monitoring
                  ├─ APM Systems
                  ├─ SIEM Systems
                  └─ ITSM Platforms
```

---

This architecture overview provides visual representations and detailed diagrams that complement the technical design document. These diagrams help understand the system's structure, data flow, and component interactions at various levels of detail.