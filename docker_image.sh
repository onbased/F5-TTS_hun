#!/usr/bin/env bash

if [[ -z $HF_TOKEN ]]; then
    echo "HF_TOKEN is not set. Run the script with HF_TOKEN=<your_huggingface_token> $0"
    exit 1
fi

if git status --porcelain | grep -q .; then
    echo "Please commit your changes before building the docker image."
    exit 1
fi

commit=$(git rev-parse HEAD)

set -ex
docker build -t blacksalt/sarpba-f5-tts-hun:latest --secret id=HF_TOKEN --label git-commit=$commit .

docker push blacksalt/sarpba-f5-tts-hun:latest
