# Cursor Agent for Java Hello World

First steps to understand how to use AI Agent to generate Java Hello World

## Quick Start

### 1. Get Your API Key

- Go to [Cursor Settings](https://cursor.com/settings) → API section
- Copy your API key

### 2. Run with Docker Compose

```bash
# Set your API key and prompt
export CURSOR_API_KEY="your_actual_api_key_here"
export CURSOR_PROMPT="Create a Java Hello World program and verify the results compiling and executing"

# Optional: Specify model (default is Auto)
export CURSOR_MODEL="sonnet-4"

# Build and run
docker-compose up --build
```

### 3. Access Generated Files
Files are created in the `workspace/` directory:
```bash
ls workspace/
```
