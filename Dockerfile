# syntax=docker/dockerfile:1
ARG BASE_IMAGE=vastai/pytorch:cuda-12.8.1-auto@sha256:b33031a5bd07fdc13d7af931ef2d7708b8e0bea5d5b83c16a5702eeae781f9fe
FROM ${BASE_IMAGE}
USER root
ARG CODEX_VERSION=0.160.1
ARG CLAUDE_VERSION=2.1.291
COPY install-cli.sh /tmp/install-cli.sh
RUN CODEX_VERSION="${CODEX_VERSION}" CLAUDE_VERSION="${CLAUDE_VERSION}" bash /tmp/install-cli.sh \
    && rm /tmp/install-cli.sh
ENV PATH="/opt/ai-cli/bin:${PATH}"
ENV DISABLE_AUTOUPDATER=1
WORKDIR /workspace
# Preserve the Vast base image ENTRYPOINT, CMD, ports and services.
