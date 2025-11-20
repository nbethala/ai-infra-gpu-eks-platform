#!/bin/bash
GRAFANA_URL=http://localhost:3000
API_KEY="Bearer your_api_key"

curl -X POST $GRAFANA_URL/api/annotations \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Load Test Start",
    "tags": ["loadtest"],
    "time": '"$(date +%s000)"'
  }'
