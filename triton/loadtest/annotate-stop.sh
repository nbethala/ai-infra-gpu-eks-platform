curl -X POST $GRAFANA_URL/api/annotations \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Load Test Stop",
    "tags": ["loadtest"],
    "time": '"$(date +%s000)"'
  }'
