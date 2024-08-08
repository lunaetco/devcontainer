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
RUN curl -sf https://binaries.nats.dev/nats-io/natscli/nats | \
    PREFIX=/usr/local/bin sh
RUN curl -sfL https://raw.githubusercontent.com/nats-io/nsc/master/install.py | \
    python3
RUN --mount=type=cache,target=/root/.cache/go-build \
    go install github.com/nats-io/nkeys/nk@latest && \
    go install github.com/nats-io/nats-top@latest
