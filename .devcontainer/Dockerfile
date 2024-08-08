FROM mcr.microsoft.com/devcontainers/base:1

ARG DEBIAN_FRONTEND=noninteractive

# Upgrade and install OS packages.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    direnv postgresql-client shfmt && \
    rm -rf /var/lib/apt/lists/*

# Install nats CLI.
RUN curl -sf https://binaries.nats.dev/nats-io/natscli/nats | \
    PREFIX=/usr/local/bin sh
