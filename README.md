# Cursor Agent Pipeline Demo

A Docker image with cursor-agent pre-installed for AI-powered code assistance.

## Build the Image

```bash
docker build -t cursor-agent-ubuntu .
```

## Usage

### 1. Get Your Cursor API Key
- Go to [Cursor Settings](https://cursor.com/settings)
- Navigate to the API section
- Generate or copy your API key

### 2. Run with Authentication

**Basic usage:**
```bash
docker run -it -e CURSOR_API_KEY=your_api_key_here cursor-agent-ubuntu
```

**Mount your project directory:**
```bash
docker run -it \
  -e CURSOR_API_KEY=your_api_key_here \
  -v $(pwd):/workspace \
  cursor-agent-ubuntu
```

**Using environment file:**
```bash
echo "CURSOR_API_KEY=your_api_key_here" > .env
docker run -it --env-file .env -v $(pwd):/workspace cursor-agent-ubuntu
```

### 3. Cursor Agent Commands

Once inside the container:

**Interactive Mode:**
```bash
# Start interactive session
cursor-agent

# Start with initial prompt
cursor-agent "analyze this codebase for improvements"
```

**Non-Interactive Mode:**
```bash
# Run in print mode
cursor-agent -p "find and fix performance issues"

# Review for security issues
cursor-agent -p "review code for security vulnerabilities" --output-format text
```

**Session Management:**
```bash
# List previous sessions
cursor-agent ls

# Resume latest session
cursor-agent resume
```

## Example Workflow

```bash
# Build the image
docker build -t cursor-agent-ubuntu .

# Run with your project mounted
docker run -it \
  -e CURSOR_API_KEY=your_api_key_here \
  -v $(pwd):/workspace \
  cursor-agent-ubuntu

# Inside container, analyze your code
cursor-agent "review this codebase and suggest improvements"
```