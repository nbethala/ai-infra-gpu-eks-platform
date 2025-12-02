FROM nvcr.io/nvidia/tritonserver:23.10-py3

COPY models/ /models

CMD ["tritonserver", "--model-repository=/models"]
