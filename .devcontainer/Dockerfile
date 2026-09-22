FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04
RUN apt-get update && apt-get install -y --no-install-recommends verilator build-essential python3 python3-venv git perl ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /workspaces/course
