# Use Node.js LTS as base image
FROM node:18-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    software-properties-common \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Java 24 JDK from Adoptium (Eclipse Temurin)
# Note: Java 24 may not be available yet, so we'll try the latest available or use a direct download
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null \
    && echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update

# Try to install Java 24, fallback to latest available if not found
RUN apt-get install -y temurin-24-jdk && rm -rf /var/lib/apt/lists/*

# Dynamically set JAVA_HOME to the installed version
RUN JAVA_HOME_DIR=$(find /usr/lib/jvm -name "temurin-*-jdk*" | head -1) \
    && echo "export JAVA_HOME=$JAVA_HOME_DIR" >> /etc/environment \
    && echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/environment

# Set JAVA_HOME for current build context
ENV JAVA_HOME=/usr/lib/jvm/temurin-24-jdk-amd64
RUN [ -d "$JAVA_HOME" ] || export JAVA_HOME=$(find /usr/lib/jvm -name "temurin-*-jdk*" | head -1)
ENV PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation and show version
RUN java -version && javac -version

# Create app directory
WORKDIR /app

# Install Cursor Agent
RUN curl https://cursor.com/install -fsSL | bash

# Add cursor-agent to PATH
ENV PATH="/root/.local/bin:$PATH"

# Create directories for configuration and workspace
RUN mkdir -p /app/config /app/workspace

# Copy configuration files if they exist
COPY . /tmp/build/
RUN if [ -d "/tmp/build/config" ]; then \
        cp -r /tmp/build/config/* /app/config/; \
        echo "Config files copied"; \
    else \
        echo "No config directory found"; \
    fi && \
    rm -rf /tmp/build

# Set environment variables (these will be overridden at runtime)
ENV CURSOR_API_KEY=""
ENV CURSOR_PROMPT=""
ENV CURSOR_WORKSPACE="/app/workspace"
ENV CURSOR_MODEL=""

# Create entrypoint script
RUN cat > /app/entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# Check if API token is provided
if [ -z "$CURSOR_API_KEY" ]; then
    echo "Error: CURSOR_API_KEY environment variable is required"
    exit 1
fi

# Check if prompt is provided
if [ -z "$CURSOR_PROMPT" ]; then
    echo "Error: CURSOR_PROMPT environment variable is required"
    exit 1
fi

# Configure Cursor Agent
echo "Configuring Cursor Agent..."
echo "API Token: ${CURSOR_API_KEY:0:10}..." # Show only first 10 chars for security
echo "Prompt: $CURSOR_PROMPT"

# Start Cursor Agent with provided configuration
echo "Starting Cursor Agent..."

# Check if cursor-agent is available
if command -v cursor-agent >/dev/null 2>&1; then
    echo "Cursor Agent found at: $(which cursor-agent)"
    cursor-agent --version
    echo ""
    
    # Change to workspace directory so files are created there
    cd "$CURSOR_WORKSPACE"
    echo "Working in directory: $(pwd)"
    
    # Start cursor-agent with the provided prompt and API key
    # Use --print and --force flags for non-interactive execution
    MODEL_FLAG=""
    if [ -n "$CURSOR_MODEL" ]; then
        MODEL_FLAG="--model $CURSOR_MODEL"
        echo "Using model: $CURSOR_MODEL"
    fi
    
    exec cursor-agent --api-key "$CURSOR_API_KEY" --print --force $MODEL_FLAG "$CURSOR_PROMPT" "$@"
else
    echo "Error: cursor-agent not found in PATH"
    echo "PATH: $PATH"
    exit 1
fi
EOF

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh

# Expose any ports that Cursor Agent might use
EXPOSE 8080

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command
CMD []