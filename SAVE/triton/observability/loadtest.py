import requests, json

with open("input.json") as f:
    payload = json.load(f)

for i in range(100):
    r = requests.post("http://localhost:8000/v2/models/resnet50/infer", json=payload)
    print(f"Request {i+1}: {r.status_code}")
