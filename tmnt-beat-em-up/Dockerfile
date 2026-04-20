# Dockerfile — Reproducible Godot 4 build environment
FROM barichello/godot-ci:4.3
LABEL maintainer="tmnt-dev-team"
LABEL version="1.0"
LABEL description="TMNT Beat-em-Up build environment"
# Install Python 3.12 + uv for build orchestration
RUN apt-get update && apt-get install -y \
curl python3.12 python3-pip git && \
curl -LsSf https://astral.sh/uv/install.sh | sh && \
rm -rf /var/lib/apt/lists/*
ENV PATH="/root/.cargo/bin:$PATH"
WORKDIR /workspace
# Layer cache: install Python deps first
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen
COPY . .
# Default: export Linux build
ENTRYPOINT ["uv", "run", "python", "scripts/export.py"]