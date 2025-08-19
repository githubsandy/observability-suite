#!/bin/bash

# Test Splunk O11y connection
TOKEN="oksFxD-9HYcsCHBqvwh9mg"
REALM="us1"

echo "Testing Splunk O11y connection..."

curl -H "X-SF-Token: $TOKEN" https://api.$REALM.signalfx.com/v2/organization

if [ $? -eq 0 ]; then
    echo "Connection successful"
else
    echo "Connection failed"
fi