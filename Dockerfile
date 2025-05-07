FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

RUN mkdir /app
WORKDIR /app

RUN pip install "huggingface_hub[hf_transfer]"
ENV HF_HUB_ENABLE_HF_TRANSFER=1
RUN --mount=type=secret,id=HF_TOKEN \
    huggingface-cli download --token $(cat /run/secrets/HF_TOKEN) sarpba/F5-TTS_V1_hun model_965000.pt \
    && huggingface-cli download --token $(cat /run/secrets/HF_TOKEN) sarpba/F5-TTS_V1_hun vocab.txt

COPY requirements.txt pyproject.toml /app/
RUN pip install -r requirements.txt -e . && pip uninstall -y f5_tts
COPY . /app/
RUN pip install -e .
RUN python -c 'import f5_tts.infer.infer_gradio'

EXPOSE 8080
CMD f5-tts_infer-gradio --host 0.0.0.0 --port 8080
