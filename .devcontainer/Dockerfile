FROM mcr.microsoft.com/devcontainers/base:1

ARG DEBIAN_FRONTEND=noninteractive
ARG GOPATH=/usr/local

# Upgrade and install OS packages.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    direnv golang postgresql-client python3 shfmt

# Install NATS tools.
RUN --mount=type=bind,target=/usr/sbin/install_from_github,source=install_from_github.sh \
    install_from_github nats-io natscli && \
    install_from_github nats-io nats-top && \
    install_from_github nats-io nkeys && \
    install_from_github nats-io nsc
