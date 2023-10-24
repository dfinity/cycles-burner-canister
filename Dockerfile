# Dockerfile: Canister Build Environment
#
# This Dockerfile prepares an environment to build and verify the integrity of 
# these specific WebAssembly canisters:
#  - cycles-burner-canister
#
# Canister is built, compressed, and checksum-verified, ensuring 
# reproducibility and consistency of builds within this isolated setup.
#
# Use the following commands:
#
# docker build -t canisters .
#
# docker run --rm --entrypoint cat canisters /cycles-burner-canister.wasm.gz > cycles-burner-canister.wasm.gz
#
# sha256sum cycles-burner-canister.wasm.gz

# The docker image. To update, run `docker pull ubuntu` locally, and update the
# sha256:... accordingly.
FROM ubuntu@sha256:2b7412e6465c3c7fc5bb21d3e6f1917c167358449fecac8176c6e496e5c1f05f

# NOTE: if this version is updated, then the version in rust-toolchain.toml
# should be updated as well.
ARG rust_version=1.68.0

# Setting the timezone and installing the necessary dependencies
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt -yq update && \
    apt -yqq install --no-install-recommends curl ca-certificates \
    build-essential pkg-config libssl-dev llvm-dev liblmdb-dev clang cmake \
    git && \
    # Package cleanup to reduce image size.
    rm -rf /var/lib/apt/lists/*

# Install Rust and Cargo in /opt
ENV RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    PATH=/opt/cargo/bin:$PATH

RUN curl --fail https://sh.rustup.rs -sSf \
    | sh -s -- -y --default-toolchain ${rust_version}-x86_64-unknown-linux-gnu --no-modify-path && \
    rustup default ${rust_version}-x86_64-unknown-linux-gnu && \
    rustup target add wasm32-unknown-unknown

ENV PATH=/cargo/bin:$PATH

# Copy the current directory (containing source code and build scripts) into the Docker image.
COPY . .

RUN \
    # Building cycles-burner-canister...
    scripts/build-canister.sh cycles-burner-canister && \
    cp target/wasm32-unknown-unknown/release/cycles-burner-canister.wasm.gz cycles-burner-canister.wasm.gz && \
    sha256sum cycles-burner-canister.wasm.gz