FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install required dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        bash \
        ca-certificates \
        nodejs \
        npm \
    && rm -rf /var/lib/apt/lists/*

# Install cursor-agent
RUN set -eux; \
    curl https://cursor.com/install -fsS | bash; \
    export PATH="$HOME/.local/bin:$PATH"; \
    if [ -f "$HOME/.local/bin/cursor-agent" ]; then \
        install -m 0755 "$HOME/.local/bin/cursor-agent" /usr/local/bin/cursor-agent; \
    fi; \
    command -v cursor-agent; \
    cursor-agent --help >/dev/null 2>&1 || true

# Add cursor-agent to PATH for all users
ENV PATH="/usr/local/bin:$PATH"

# Set working directory
WORKDIR /workspace

# Default command
CMD ["bash"]
