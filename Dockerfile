FROM --platform=linux/amd64 python:3.10-bookworm

# Install OS dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Preload huggingface models
RUN pip install huggingface-hub hf-transfer
ENV HF_HUB_ENABLE_HF_TRANSFER=1
RUN --mount=type=secret,id=HF_TOKEN \
    huggingface-cli download --max-workers 1 --token "$(cat /run/secrets/HF_TOKEN)" charactr/vocos-mel-24khz config.yaml \
    && huggingface-cli download --max-workers 1 --token "$(cat /run/secrets/HF_TOKEN)" charactr/vocos-mel-24khz pytorch_model.bin
RUN --mount=type=secret,id=HF_TOKEN \
    huggingface-cli download --max-workers 1 --token "$(cat /run/secrets/HF_TOKEN)" SWivid/F5-TTS F5TTS_v1_Base/model_1250000.safetensors \
    && huggingface-cli download --max-workers 1 --token "$(cat /run/secrets/HF_TOKEN)" SWivid/F5-TTS F5TTS_v1_Base/vocab.txt
RUN --mount=type=secret,id=HF_TOKEN \
    huggingface-cli download --max-workers 1 --token "$(cat /run/secrets/HF_TOKEN)" sarpba/F5-TTS_V1_hun model_965000.pt \
    && huggingface-cli download --max-workers 1 --token "$(cat /run/secrets/HF_TOKEN)" sarpba/F5-TTS_V1_hun vocab.txt

# Install python dependencies before copying code
COPY requirements.txt pyproject.toml /tmp/req/
RUN pip install -r /tmp/req/requirements.txt -e /tmp/req && pip uninstall -y f5_tts

# Copy code and install
COPY . /tmp/app
RUN pip install /tmp/app

EXPOSE 8080
CMD f5-tts_infer-gradio --host 0.0.0.0 --port 8080
