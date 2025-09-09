# Cursor Agent Pipeline Demo

Docker setup with real Cursor Agent for AI-powered code generation.

## Quick Start

### 1. Get Your API Key

- Go to [Cursor Settings](https://cursor.com/settings) → API section
- Copy your API key

### 2. Run with Docker Compose

```bash
# Set your API key and prompt
export CURSOR_API_KEY="your_actual_api_key_here"
export CURSOR_PROMPT="Create a Java Hello World program"

# Build and run
docker-compose up --build
```
