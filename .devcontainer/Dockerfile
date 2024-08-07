FROM mcr.microsoft.com/devcontainers/base:1

# Upgrade and install additional OS packages.
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    direnv postgresql-client shfmt && \
    rm -rf /var/lib/apt/lists/*
