ARG STABLE_DIFFUSION_WEBUI_VERSION=1.2.1

FROM python:3.10.6 as builder

ARG STABLE_DIFFUSION_WEBUI_VERSION

RUN apt update \
    && apt install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/stable-diffusion-webui-${STABLE_DIFFUSION_WEBUI_VERSION}.tar.gz https://github.com/AUTOMATIC1111/stable-diffusion-webui/archive/refs/tags/v${STABLE_DIFFUSION_WEBUI_VERSION}.tar.gz \
    && cd /tmp \
    && tar -xzf /tmp/stable-diffusion-webui-${STABLE_DIFFUSION_WEBUI_VERSION}.tar.gz

FROM python:3.10.6

ARG STABLE_DIFFUSION_WEBUI_VERSION

ENV NVIDIA_VISIBLE_DEVICES=all


RUN apt update \
    && apt install -y --no-install-recommends \
        libgl1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --home /app -M app -s /bin/bash \
    && mkdir /app

COPY --from=builder /tmp/stable-diffusion-webui-${STABLE_DIFFUSION_WEBUI_VERSION} /app/stable-diffusion-webui

RUN chown -R app:app /app

USER app

RUN cd /app/stable-diffusion-webui && COMMANDLINE_ARGS="--skip-torch-cuda-test" python3 -c 'import launch; launch.prepare_environment()'

WORKDIR /app/stable-diffusion-webui

EXPOSE 7860/tcp

CMD ["python3","launch.py","--listen"]
