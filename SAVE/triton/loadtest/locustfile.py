#This simulates realistic traffic with randomized wait times.

from locust import HttpUser, task, between
import json

with open("input.json") as f:
    payload = json.load(f)

class TritonUser(HttpUser):
    wait_time = between(0.5, 1.5)

    @task
    def infer(self):
        self.client.post("/v2/models/resnet50/infer", json=payload)
