# Headless ececution - 50 users, 5/sec ramp-up, 2-minute test, CSV export.

#!/bin/bash
kubectl port-forward svc/triton-infer 8000:8000 -n triton &
PORT_PID=$!
sleep 5

locust -f locustfile.py --headless -u 50 -r 5 -t 2m --host=http://localhost:8000 --csv=results

kill $PORT_PID
