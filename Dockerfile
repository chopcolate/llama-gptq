FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir data
WORKDIR /data

# Install Python dependencies (Worker Template)
RUN pip install --upgrade pip && \
    pip install safetensors==0.3.1 sentencepiece huggingface_hub \
        git+https://github.com/winglian/runpod-python.git@fix-generator-check ninja==1.11.1
RUN pip install huggingface-hub
RUN mkdir Llama-2-13B-chat-GPTQ 
RUN huggingface-cli download TheBloke/Llama-2-13B-chat-GPTQ  --local-dir Llama-2-13B-chat-GPTQ  --local-dir-use-symlinks False
RUN git clone https://github.com/turboderp/exllama
RUN pip install -r exllama/requirements.txt

COPY handler.py /data/handler.py
COPY __init.py__ /data/__init__.py

ENV PYTHONPATH=/data/exllama
ENV MODEL_REPO=""
ENV PROMPT_PREFIX=""
ENV PROMPT_SUFFIX=""
ENV HUGGINGFACE_HUB_CACHE="/runpod-volume/huggingface-cache/hub"
ENV TRANSFORMERS_CACHE="/runpod-volume/huggingface-cache/hub"

CMD [ "python", "-m", "handler" ]


# docker build -t llama-13b-gptq .
# docker tag llama-13b-gptq robusttechhouse/rth-llama-runpod:latest
# docker push robusttechhouse/rth-llama-runpod:latest