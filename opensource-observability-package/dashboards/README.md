# Grafana Dashboards for Observability Stack

This directory contains **6 comprehensive dashboards** for monitoring the 14-component observability stack deployed in the CALO Lab environment.

## 📊 Dashboard Collection

### 1. **Observability Stack Overview** (`observability-stack-overview.json`)
- **Purpose**: High-level health monitoring of all 14 active components
- **Key Metrics**: 
  - Overall stack health gauge
  - Component status timeline
  - Active/failed components count
  - Total memory and CPU usage
  - Detailed component status table
- **Namespace**: `ao-os`
- **Data Source**: Prometheus

### 2. **Infrastructure Monitoring** (`infrastructure-monitoring.json`)
- **Purpose**: Node Exporter, Blackbox Exporter, and kube-state-metrics monitoring
- **Key Metrics**:
  - Node CPU and memory usage
  - Network I/O and disk usage
  - Kubernetes nodes and pods status
  - Blackbox probe success and duration
  - Infrastructure components status table
- **Data Source**: Prometheus

### 3. **Log Analytics Dashboard** (`log-analytics-dashboard.json`)
- **Purpose**: Loki-based log analysis for observability components
- **Key Metrics**:
  - Total logs count (1h window)
  - Error and warning counts (10m window) 
  - Log rate by pod
  - Error/warning rates by pod
  - Recent error and warning logs display
- **Namespace**: `ao-os`
- **Data Source**: Loki

### 4. **Database Monitoring** (`database-monitoring.json`)
- **Purpose**: MongoDB, PostgreSQL, and Redis exporters monitoring
- **Key Metrics**:
  - **MongoDB**: Status, connections, operations rate
  - **PostgreSQL**: Status, active connections, transaction rate
  - **Redis**: Status, memory usage, commands rate, connected clients
- **Data Source**: Prometheus

### 5. **Network Monitoring** (`network-monitoring.json`)
- **Purpose**: Blackbox, Smokeping, and MTR network analysis
- **Key Metrics**:
  - **Blackbox**: Endpoint status, probe duration, HTTP phases, status codes
  - **Smokeping**: Network latency and packet loss
  - **MTR**: Hop-by-hop latency and packet loss, path analysis table
- **Data Source**: Prometheus

### 6. **Distributed Tracing** (`distributed-tracing.json`)
- **Purpose**: Tempo tracing system monitoring and trace visualization
- **Key Metrics**:
  - Tempo service status
  - Trace and span ingestion rates
  - Storage usage and query response times
  - Distributor and ingester metrics
  - Recent traces visualization
- **Data Sources**: Prometheus + Tempo

## 🚀 How to Import Dashboards

### Method 1: Grafana UI Import

1. **Access Grafana**: `http://YOUR-NODE-IP:30300`
2. **Login**: admin/admin (default credentials)
3. **Import Dashboard**:
   - Click "+" → Import
   - Upload JSON file or paste JSON content
   - Configure data sources if prompted
   - Save dashboard

### Method 2: Automated Import Script

```bash
#!/bin/bash
# Import all dashboards script

GRAFANA_URL="http://YOUR-NODE-IP:30300"
GRAFANA_USER="admin"
GRAFANA_PASS="admin"

for dashboard in /path/to/dashboards/*.json; do
    curl -X POST \
        -H "Content-Type: application/json" \
        -d @"$dashboard" \
        "$GRAFANA_URL/api/dashboards/db" \
        -u "$GRAFANA_USER:$GRAFANA_PASS"
done
```

### Method 3: Helm Chart Integration

Add to your Helm values.yaml:

```yaml
grafana:
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: 'observability-dashboards'
        orgId: 1
        folder: 'Observability Stack'
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/observability
  
  dashboards:
    observability:
      observability-stack-overview:
        file: observability-stack-overview.json
      infrastructure-monitoring:
        file: infrastructure-monitoring.json
      # ... add all other dashboards
```

## 🔧 Data Source Configuration

### Required Data Sources

1. **Prometheus**
   - **Name**: `DS_PROMETHEUS` 
   - **URL**: `http://prometheus:9090`
   - **Type**: Prometheus

2. **Loki**
   - **Name**: `DS_LOKI`
   - **URL**: `http://loki:3100` 
   - **Type**: Loki

3. **Tempo**
   - **Name**: `DS_TEMPO`
   - **URL**: `http://tempo:3200`
   - **Type**: Tempo

### Auto-Configuration

If using the observability stack Helm chart, data sources are automatically configured. Otherwise, manually add them in Grafana:

```bash
# Add Prometheus data source
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus", 
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }' \
  "$GRAFANA_URL/api/datasources" \
  -u "$GRAFANA_USER:$GRAFANA_PASS"
```

## 📋 Dashboard Features

### Common Features Across All Dashboards
- **Refresh Rate**: 30 seconds auto-refresh
- **Time Range**: Last 15 minutes (configurable)
- **Dark Theme**: Optimized for dark mode
- **Responsive Design**: Works on desktop and mobile
- **Drill-Down**: Click metrics for detailed views

### Color Coding Standards
- **Green**: Healthy/Normal status
- **Yellow**: Warning thresholds 
- **Red**: Critical/Error states
- **Background Colors**: Status indication on stat panels

### Interactive Elements
- **Tooltips**: Hover for detailed metric information
- **Legends**: Click to toggle metric visibility
- **Time Selection**: Drag to zoom into time ranges
- **Table Sorting**: Click column headers to sort

## 🔍 Troubleshooting

### Dashboard Import Issues

```bash
# Check Grafana is accessible
curl -I http://YOUR-NODE-IP:30300

# Verify data sources exist
curl -u admin:admin http://YOUR-NODE-IP:30300/api/datasources
```

### Missing Data Issues

```bash
# Check Prometheus targets
curl http://YOUR-NODE-IP:30090/api/v1/targets

# Check Loki ready
curl http://YOUR-NODE-IP:30310/ready

# Check Tempo ready  
curl http://YOUR-NODE-IP:30320/ready
```

### Permission Issues

```bash
# Check Grafana pod logs
kubectl logs -n ao-os deployment/grafana

# Check service endpoints
kubectl get endpoints -n ao-os
```

## 🏷️ Tags & Organization

All dashboards include relevant tags for easy organization:
- `observability` - General observability tag
- `calo-lab` - CALO Lab specific
- `infrastructure` - Infrastructure monitoring
- `database` - Database specific
- `network` - Network monitoring
- `tracing` - Distributed tracing
- Component-specific tags (e.g., `prometheus`, `loki`, `tempo`)

---

**🎯 These dashboards provide comprehensive monitoring coverage for your 14-component observability stack!**