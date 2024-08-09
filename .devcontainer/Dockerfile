FROM --platform=$BUILDPLATFORM rust:1-bookworm as rust-builder

ARG TARGETPLATFORM
RUN --mount=type=bind,target=/usr/sbin/cargo_cross_install,source=cargo_cross_install.sh \
    APT_DEPENDENCIES='libmariadb-dev libpq-dev libsqlite3-dev' \
    cargo_cross_install --root /opt diesel_cli

# -------------------------------------------------------------------------

FROM mcr.microsoft.com/devcontainers/base:1-bookworm

ARG DEBIAN_FRONTEND=noninteractive
ARG GOPATH=/usr/local

# Upgrade and install OS packages.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    direnv postgresql-client python3 shfmt \
    libmariadb3 libpq5 libsqlite3-0

# Install tools from GitHub.
RUN --mount=type=bind,target=/usr/sbin/install_from_github,source=install_from_github.sh \
    install_from_github authzed zed && \
    install_from_github bufbuild buf && \
    install_from_github nats-io natscli && \
    install_from_github nats-io nats-top && \
    install_from_github nats-io nkeys && \
    install_from_github nats-io nsc

# Install Rust binaries
COPY --from=rust-builder /opt/bin/* /usr/local/bin/
