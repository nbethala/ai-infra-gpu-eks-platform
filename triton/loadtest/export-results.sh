# Optional - You can also use Grafana’s snapshot API for visual exports.
curl -X GET "$GRAFANA_URL/api/dashboards/uid/<dashboard_uid>" \
  -H "Authorization: Bearer $API_KEY" \
  -o loadtest-dashboard.json
