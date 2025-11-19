#!/bin/bash - smoke test on triton deployment

set -e

echo "🧪 Starting Triton smoke test..."

# Port-forward Triton service
kubectl port-forward svc/triton-infer 8000:8000 -n triton &
PORT_PID=$!
sleep 5  # Give it time to bind

# Run inference
curl -s -X POST http://localhost:8000/v2/models/resnet50/infer \
  -H "Content-Type: application/json" \
  -d @triton/input.json | jq .

# Cleanup
kill $PORT_PID
echo " Smoke test complete."
