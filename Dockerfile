FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
   PIP_PREFER_BINARY=1 \
   PYTHONUNBUFFERED=1 \
   CMAKE_BUILD_PARALLEL_LEVEL=8 \
   PIP_DISABLE_PIP_VERSION_CHECK=1 \
   PIP_NO_INPUT=1

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-venv python3-dev python3-pip \
    curl wget aria2 git git-lfs vim unzip jq \
    ffmpeg ninja-build build-essential libgl1 libglib2.0-0 gcc cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install packaging setuptools wheel

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 \
    --index-url https://download.pytorch.org/whl/cu128

COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
    /usr/bin/yes | comfy --workspace /ComfyUI install

WORKDIR /src

COPY src/tools/ /usr/local/bin/

# Listed separately to utilize layer caching
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/rgthree/rgthree-comfy.git
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/kijai/ComfyUI-KJNodes.git
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/yolain/ComfyUI-Easy-Use.git
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/WASasquatch/was-node-suite-comfyui.git
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/giriss/comfy-image-saver.git
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/city96/ComfyUI-GGUF.git
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes.git
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git
RUN --mount=type=cache,target=/root/.cache/pip install_custom_node https://github.com/orssorbit/ComfyUI-wanBlockswap.git

COPY src/ .

EXPOSE 8188 8888

CMD ["./entrypoint.sh"]