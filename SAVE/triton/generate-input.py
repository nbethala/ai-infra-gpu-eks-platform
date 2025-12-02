# script usage : generates the input.json file for triton smoke test
# run : python generate-input.py

import json

payload = {
    "inputs": [
        {
            "name": "input",
            "shape": [1, 3, 224, 224],
            "datatype": "FP32",
            "data": [0.0] * (1 * 3 * 224 * 224)
        }
    ]
}

with open("input.json", "w") as f:
    json.dump(payload, f)
