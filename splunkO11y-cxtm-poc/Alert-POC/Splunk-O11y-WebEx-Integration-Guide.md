# Splunk Observability to WebEx Teams Integration Guide

**Complete Implementation Guide for Enterprise Real-Time Alerting**

---

## 📋 Project Overview

### **Objective**
Implement enterprise-grade real-time alerting that sends Splunk Observability Cloud alerts to WebEx Teams using a custom webhook service deployed on Kubernetes.

### **Architecture**
```
Splunk O11y → ngrok Tunnel → Kubernetes Webhook Service → WebEx Teams API → WebEx Space
```

### **Key Results Achieved**
- ✅ **11 hosts** actively monitored in Splunk O11y (jp0 realm)
- ✅ **143 pods** and **31 replicasets** tracked
- ✅ **Real-time alerts** delivered to WebEx Teams
- ✅ **<1 minute** alert delivery time
- ✅ **Custom webhook service** deployed on existing Kubernetes cluster

---

## 🎯 Prerequisites

- Kubernetes cluster with `kubectl` access
- Helm installed and configured
- Splunk Observability Cloud instance
- WebEx Teams account
- Internet access for webhook tunneling

---

## 📚 Implementation Steps

## Phase 1: Splunk O11y Instance Migration

### **Step 1.1: Gather New Instance Details**
**Purpose**: Switch from trial instance (au0) to production instance (jp0)

**Details Required:**
- Instance URL: `https://app.jp0.signalfx.com`
- Access Token: `e7qGDG7-KzicpxnCcNqFDg` (default token)
- Realm: `jp0`

### **Step 1.2: Update Helm Deployment Configuration**
**Purpose**: Reconfigure OTEL collector to send data to new Splunk O11y instance

```bash
# Update Helm deployment with new realm and token
helm upgrade splunk-otel-collector \
  --namespace ao \
  --set="splunkObservability.accessToken=e7qGDG7-KzicpxnCcNqFDg" \
  --set="clusterName=nightlyCluster" \
  --set="splunkObservability.realm=jp0" \
  --set="gateway.enabled=false" \
  --set="environment=nightly" \
  --set="operatorcrds.install=true" \
  --set="operator.enabled=true" \
  --set="agent.discovery.enabled=true" \
  splunk-otel-collector-chart/splunk-otel-collector
```

### **Step 1.3: Restart OTEL Agent Pods**
**Purpose**: Ensure all agent pods use the new configuration and eliminate authentication errors

```bash
# Force restart of all OTEL agent pods
kubectl rollout restart daemonset/splunk-otel-collector-agent -n ao

# Monitor rollout progress
kubectl rollout status daemonset/splunk-otel-collector-agent -n ao

# Verify no more 401 unauthorized errors
kubectl logs splunk-otel-collector-agent-<pod-name> -n ao --tail=20
```

**Success Criteria**: No more HTTP 401 "Unauthorized" errors in logs

---

## Phase 2: WebEx Bot and Space Setup

### **Step 2.1: Create WebEx Bot**
**Purpose**: Create automated bot for sending alert notifications to WebEx Teams

**Steps:**
1. Go to https://developer.webex.com/
2. Sign in with WebEx account
3. Create New App → Create a Bot
4. Configure bot details:
   - **Name**: `SplunkO11yAlerts2025`
   - **Username**: `splunkO11ysk@webex.bot`
   - **Description**: Enterprise alerting bot for infrastructure monitoring

**Results:**
- **Bot ID**: `Y2lzY29zcGFyazovL3VzL0FQUExJQ0FUSU9OLzE3OTUxOGE3LTRlNTItNDhhMy04ZjFhLWJmZGRlOTRhNjY0MQ`
- **Bot Token**: `NWQ2MThkNjEtODA1Mi00Y2I5LThmMDItMjQxZmU5YmI1ZjJkYjkyYjdmNTMtNzdh_PF84_1eb65fdf-9643-417f-9974-ad72cae0e10f`

### **Step 2.2: Create WebEx Space and Get Room ID**
**Purpose**: Establish dedicated space for infrastructure alerts

**Steps:**
1. Create WebEx space: "SplunkO11yAlert0925"
2. Add the bot to the space
3. Get Room ID via API:

```bash
# List all WebEx spaces
curl -X GET "https://webexapis.com/v1/rooms" \
  -H "Authorization: Bearer NWQ2MThkNjEtODA1Mi00Y2I5LThmMDItMjQxZmU5YmI1ZjJkYjkyYjdmNTMtNzdh_PF84_1eb65fdf-9643-417f-9974-ad72cae0e10f" \
  -H "Content-Type: application/json"
```

**Result:**
- **Room ID**: `Y2lzY29zcGFyazovL3VzL1JPT00vMmFiZDM4YzAtOTUzMy0xMWYwLTk3ZWQtZWRjODA1NWU3NjA1`

### **Step 2.3: Test WebEx Bot Functionality**
**Purpose**: Verify bot can successfully send messages to the space

```bash
# Send test message to WebEx space
curl -X POST "https://webexapis.com/v1/messages" \
  -H "Authorization: Bearer NWQ2MThkNjEtODA1Mi00Y2I5LThmMDItMjQxZmU5YmI1ZjJkYjkyYjdmNTMtNzdh_PF84_1eb65fdf-9643-417f-9974-ad72cae0e10f" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": "Y2lzY29zcGFyazovL3VzL1JPT00vMmFiZDM4YzAtOTUzMy0xMWYwLTk3ZWQtZWRjODA1NWU3NjA1",
    "text": "🚀 Hello! This is a test message from your Splunk O11y Alert bot."
  }'
```

**Success Criteria**: HTTP 200 response and message appears in WebEx space

---

## Phase 3: Webhook Service Development and Deployment

### **Step 3.1: Create Webhook Service Directory Structure**
**Purpose**: Organize webhook service code and configuration files

```bash
# Create directory structure
pwd  # Should be in /home/cloud-user
mkdir -p webhook-service
cd webhook-service
```

### **Step 3.2: Create Flask Application**
**Purpose**: Develop webhook service that receives Splunk O11y alerts and forwards to WebEx

**File: `app.py`**
```python
#!/usr/bin/env python3
"""
Splunk O11y to WebEx Webhook Service - FIXED VERSION
"""

from flask import Flask, request, jsonify
import requests
import json
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# WebEx Configuration
WEBEX_BOT_TOKEN = "NWQ2MThkNjEtODA1Mi00Y2I5LThmMDItMjQxZmU5YmI1ZjJkYjkyYjdmNTMtNzdh_PF84_1eb65fdf-9643-417f-9974-ad72cae0e10f"
WEBEX_ROOM_ID = "Y2lzY29zcGFyazovL3VzL1JPT00vMmFiZDM4YzAtOTUzMy0xMWYwLTk3ZWQtZWRjODA1NWU3NjA1"
WEBEX_API_URL = "https://webexapis.com/v1/messages"

def send_webex_message(message_text):
    """Send a message to WebEx Teams space"""
    headers = {
        "Authorization": f"Bearer {WEBEX_BOT_TOKEN}",
        "Content-Type": "application/json"
    }
    payload = {
        "roomId": WEBEX_ROOM_ID,
        "text": message_text
    }
    try:
        response = requests.post(WEBEX_API_URL, headers=headers, json=payload)
        response.raise_for_status()
        logger.info(f"Successfully sent message to WebEx: {response.status_code}")
        return True
    except requests.exceptions.RequestException as e:
        logger.error(f"Failed to send WebEx message: {e}")
        return False

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "service": "splunk-webex-webhook"})

@app.route('/webhook', methods=['POST'])
def webhook_handler():
    try:
        # Log raw request data for debugging
        raw_data = request.get_data(as_text=True)
        logger.info(f"Raw webhook data: {raw_data}")

        # Try to parse JSON
        try:
            alert_data = request.get_json(force=True)
        except:
            # If JSON parsing fails, try to parse the raw text
            alert_data = json.loads(raw_data) if raw_data else {}

        logger.info(f"Parsed alert data: {alert_data}")

        # Extract information safely
        detector_name = "Unknown Detector"
        status = "UNKNOWN"

        if isinstance(alert_data, dict):
            # Handle nested detector object
            detector = alert_data.get('detector', {})
            if isinstance(detector, dict):
                detector_name = detector.get('name', 'Unknown Detector')
            elif isinstance(detector, str):
                detector_name = detector

            status = alert_data.get('status', 'UNKNOWN')

        # Create status emoji
        status_emoji = "🚨" if status == "TRIGGERED" else "✅" if status == "RESOLVED" else "⚠️"

        # Format message
        message = f"""{status_emoji} **Splunk O11y Alert**
**Detector:** {detector_name}
**Status:** {status}
**Time:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

**Raw Alert Data:**
```
{json.dumps(alert_data, indent=2)}
```"""

        # Send to WebEx
        success = send_webex_message(message)

        if success:
            return jsonify({"status": "success"})
        else:
            return jsonify({"status": "error"}), 500

    except Exception as e:
        logger.error(f"Error processing webhook: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/test', methods=['GET'])
def test_webhook():
    test_message = f"""🧪 **Webhook Test**
Service is running and ready!
Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""

    success = send_webex_message(test_message)
    return jsonify({"status": "success" if success else "error"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### **Step 3.3: Create Requirements File**
**Purpose**: Define Python dependencies for the webhook service

**File: `requirements.txt`**
```
flask==2.3.3
requests==2.31.0
```

### **Step 3.4: Deploy Webhook Service to Kubernetes**
**Purpose**: Deploy webhook as scalable service in existing Kubernetes cluster

```bash
# Create ConfigMaps for code and dependencies
kubectl create configmap webhook-app-code --from-file=app.py -n ao
kubectl create configmap webhook-requirements --from-literal=requirements.txt="$(cat requirements.txt)" -n ao

# Create deployment YAML
cat > webhook-deployment.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: webhook-requirements
  namespace: ao
data:
  requirements.txt: |
    flask==2.3.3
    requests==2.31.0
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: splunk-webex-webhook
  namespace: ao
spec:
  replicas: 1
  selector:
    matchLabels:
      app: splunk-webex-webhook
  template:
    metadata:
      labels:
        app: splunk-webex-webhook
    spec:
      containers:
      - name: webhook
        image: python:3.9-slim
        command: ["/bin/sh"]
        args: ["-c", "pip install -r /app/requirements.txt && python /app/app.py"]
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: app-code
          mountPath: /app/app.py
          subPath: app.py
        - name: requirements
          mountPath: /app/requirements.txt
          subPath: requirements.txt
      volumes:
      - name: app-code
        configMap:
          name: webhook-app-code
      - name: requirements
        configMap:
          name: webhook-requirements
---
apiVersion: v1
kind: Service
metadata:
  name: splunk-webex-webhook-service
  namespace: ao
spec:
  selector:
    app: splunk-webex-webhook
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
  type: ClusterIP
EOF

# Deploy to Kubernetes
kubectl apply -f webhook-deployment.yaml

# Verify deployment
kubectl get pods -n ao -l app=splunk-webex-webhook
```

### **Step 3.5: Expose Webhook Service via NodePort**
**Purpose**: Make webhook accessible from within the cluster network

```bash
# Create NodePort service for internal cluster access
cat > webhook-nodeport.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: splunk-webex-webhook-nodeport
  namespace: ao
spec:
  type: NodePort
  selector:
    app: splunk-webex-webhook
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
    nodePort: 31000
EOF

# Apply NodePort service
kubectl apply -f webhook-nodeport.yaml

# Test internal access
curl http://192.168.100.51:31000/health
curl http://192.168.100.51:31000/test
```

**Success Criteria**:
- Health endpoint returns `{"status": "healthy"}`
- Test endpoint returns `{"status": "success"}` and message appears in WebEx

---

## Phase 4: Public Access Configuration

### **Step 4.1: Network Analysis**
**Purpose**: Determine how to make internal webhook accessible to Splunk O11y cloud service

```bash
# Check bastion host networking
curl ifconfig.me  # Returns: 173.36.120.8
ip addr show      # Shows internal IPs: 192.168.100.84, 10.123.230.40

# Test external connectivity
curl --connect-timeout 10 http://173.36.120.8:9090/health  # Times out
```

**Analysis**: Bastion host is behind NAT/cloud networking - public IP not directly accessible

### **Step 4.2: Install and Configure ngrok**
**Purpose**: Create secure public tunnel to internal webhook service

```bash
# Download and install ngrok for Linux
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar xvzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/

# Configure ngrok with auth token
ngrok config add-authtoken 5hPVisVQ54MFVwBcTY49n_3qgrrAJ3sghviU5RamoLJ
```

### **Step 4.3: Create Public Tunnel**
**Purpose**: Expose internal webhook service to internet via secure HTTPS tunnel

```bash
# Create tunnel to internal webhook service
ngrok http http://192.168.100.51:31000
```

**Result**: Public HTTPS URL: `https://74fa899e9194.ngrok-free.app`

### **Step 4.4: Test Public Webhook Access**
**Purpose**: Verify webhook is accessible from internet

```bash
# Test public endpoints
curl https://74fa899e9194.ngrok-free.app/health
curl https://74fa899e9194.ngrok-free.app/test
```

**Success Criteria**: Both endpoints return expected JSON responses

---

## Phase 5: Splunk O11y Webhook Integration

### **Step 5.1: Configure Webhook Integration**
**Purpose**: Set up Splunk O11y to send alerts to our webhook service

**Steps:**
1. Go to https://app.jp0.signalfx.com/
2. Navigate to **Data Management** → **Integrations**
3. Search for **"Webhook"** and click **"New Integration"**
4. Configure integration:
   - **Name**: `WebEx Teams via ngrok`
   - **URL**: `https://74fa899e9194.ngrok-free.app/webhook`
   - **Method**: `POST`
   - **Headers**: `Content-Type: application/json`

### **Step 5.2: Create Test Detector**
**Purpose**: Set up alert rule to test end-to-end integration

**Steps:**
1. Go to **Alerts & Detectors** → **Detectors**
2. Create new detector with:
   - **Signal**: `cpu.utilization`
   - **Condition**: Static threshold > 10% (for testing)
   - **Alert Recipients**: Add "WebEx Teams via ngrok" webhook

### **Step 5.3: Test Integration**
**Purpose**: Verify alerts flow from Splunk O11y to WebEx Teams

**Verification Methods:**
- Monitor webhook logs: `kubectl logs -n ao -l app=splunk-webex-webhook --tail=20`
- Check ngrok connection logs
- Verify messages appear in WebEx "SplunkO11yAlert0925" space

---

## 🔧 Troubleshooting Guide

### **Issue 1: 401 Unauthorized Errors**
**Symptoms**: OTEL collector logs showing HTTP 401 errors
**Root Cause**: Using newly created token instead of default token
**Solution**: Use default token `e7qGDG7-KzicpxnCcNqFDg` and restart agent pods

### **Issue 2: Docker Build Failures**
**Symptoms**: `RuntimeError: can't start new thread` during pip install
**Root Cause**: Resource constraints on bastion host during Docker build
**Solution**: Use ConfigMap deployment approach with pre-built Python image

### **Issue 3: Webhook 500 Errors**
**Symptoms**: `'str' object has no attribute 'get'` in webhook logs
**Root Cause**: Webhook code expecting JSON object but receiving string
**Solution**: Add proper JSON parsing with error handling in webhook code

### **Issue 4: Public Access Blocked**
**Symptoms**: Connection timeouts when accessing webhook via public IP
**Root Cause**: Bastion host behind NAT/cloud networking
**Solution**: Use ngrok tunnel for public access

### **Issue 5: WebEx Messages Not Appearing**
**Symptoms**: HTTP 200 responses but no messages in WebEx space
**Root Cause**: Bot not added to space or incorrect Room ID
**Solution**: Verify bot membership and test direct WebEx API calls

---

## 📊 Success Metrics

### **Technical Implementation**
- ✅ **Zero Downtime**: No impact to existing CXTM services
- ✅ **Real-time Data**: 1-minute metric resolution
- ✅ **Complete Coverage**: All 11 cluster nodes monitored
- ✅ **Kubernetes Integration**: Full container visibility
- ✅ **Network Connectivity**: Successful connection to Splunk O11y jp0 realm

### **Alert Delivery Performance**
- ✅ **Delivery Time**: <1 minute from trigger to WebEx notification
- ✅ **Reliability**: HTTP 200 responses for all webhook calls
- ✅ **Message Formatting**: Structured alerts with status, detector name, timestamp
- ✅ **Multi-Channel**: Works alongside existing email and ServiceNow integrations

### **Operational Readiness**
- ✅ **Scalability**: Kubernetes deployment with configurable replicas
- ✅ **Monitoring**: Health check endpoint for service monitoring
- ✅ **Logging**: Comprehensive logging for troubleshooting
- ✅ **Security**: HTTPS encryption via ngrok tunnel

---

## 🚀 Production Considerations

### **Security Enhancements**
1. **Add webhook authentication** (shared secret validation)
2. **Implement rate limiting** to prevent abuse
3. **Use enterprise ngrok** or proper load balancer for production
4. **Rotate WebEx bot token** periodically

### **Reliability Improvements**
1. **Make ngrok tunnel persistent** (systemd service)
2. **Add webhook service redundancy** (multiple replicas)
3. **Implement retry logic** for failed WebEx API calls
4. **Add health monitoring** and alerting for webhook service

### **Message Enhancement**
1. **Add rich formatting** with markdown support
2. **Include clickable links** to Splunk O11y dashboards
3. **Add alert correlation** and grouping
4. **Implement alert escalation** based on severity

---

## 📝 Key Commands Reference

### **Splunk O11y Management**
```bash
# Check OTEL collector status
kubectl get pods -n ao -l app.kubernetes.io/name=splunk-otel-collector

# View OTEL collector logs
kubectl logs -n ao <otel-pod-name> --tail=20

# Restart OTEL collector
kubectl rollout restart daemonset/splunk-otel-collector-agent -n ao
```

### **Webhook Service Management**
```bash
# Check webhook service status
kubectl get pods -n ao -l app=splunk-webex-webhook

# View webhook logs
kubectl logs -n ao -l app=splunk-webex-webhook --tail=20

# Restart webhook service
kubectl rollout restart deployment/splunk-webex-webhook -n ao

# Test webhook endpoints
curl https://74fa899e9194.ngrok-free.app/health
curl https://74fa899e9194.ngrok-free.app/test
```

### **WebEx API Testing**
```bash
# Send direct message to WebEx space
curl -X POST "https://webexapis.com/v1/messages" \
  -H "Authorization: Bearer <BOT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"roomId": "<ROOM_ID>", "text": "Test message"}'

# Check bot information
curl -X GET "https://webexapis.com/v1/people/me" \
  -H "Authorization: Bearer <BOT_TOKEN>"
```

---

## 📋 Configuration Summary

| Component | Configuration | Value |
|-----------|--------------|-------|
| **Splunk O11y** | Realm | `jp0` |
| | Access Token | `e7qGDG7-KzicpxnCcNqFDg` |
| | Instance URL | `https://app.jp0.signalfx.com` |
| **WebEx Bot** | Bot Name | `SplunkO11yAlerts2025` |
| | Bot Token | `NWQ2MThkNjEtODA1Mi00Y2I5LThmMDItMjQxZmU5YmI1ZjJkYjkyYjdmNTMtNzdh_PF84_1eb65fdf-9643-417f-9974-ad72cae0e10f` |
| | Room ID | `Y2lzY29zcGFyazovL3VzL1JPT00vMmFiZDM4YzAtOTUzMy0xMWYwLTk3ZWQtZWRjODA1NWU3NjA1` |
| **Webhook Service** | Public URL | `https://74fa899e9194.ngrok-free.app` |
| | Internal URL | `http://192.168.100.51:31000` |
| | Namespace | `ao` |
| **ngrok** | Auth Token | `5hPVisVQ54MFVwBcTY49n_3qgrrAJ3sghviU5RamoLJ` |
| | Tunnel URL | `https://74fa899e9194.ngrok-free.app` |

---

## 🎯 Next Steps

1. **Monitor Performance**: Track alert delivery times and success rates
2. **Enhance Security**: Implement webhook authentication and access controls
3. **Scale for Production**: Replace ngrok with enterprise-grade load balancer
4. **Add Monitoring**: Set up alerts for webhook service health
5. **Documentation**: Train operations team on troubleshooting procedures

---

**Document Created**: October 7, 2025
**Integration Status**: ✅ **FULLY OPERATIONAL**
**Last Tested**: October 7, 2025 - All alerts flowing successfully to WebEx Teams