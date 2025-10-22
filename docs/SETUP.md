# MCP Suite Setup Guide

Complete installation guide for the MCP Suite on Unraid.

## Prerequisites

### Required
- Unraid server with Docker support
- Dockge installed (recommended) or Docker Compose CLI
- Minimum 10GB free disk space
- Network access to pull Docker images

### API Keys & Credentials

1. **GitHub Personal Access Token**
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes: `repo`, `read:org`, `read:user`
   - Copy the token

2. **OpenAI API Key**
   - Go to: https://platform.openai.com/api-keys
   - Click "Create new secret key"
   - Copy the key

3. **Google Cloud OAuth Credentials** (for Gmail & Drive)
   - See [OAUTH_SETUP.md](OAUTH_SETUP.md) for detailed instructions

## Installation Steps

### 1. Clone Repository

```bash
cd /mnt/user/appdata/dockge/stacks/
git clone https://github.com/Twine2546/mcp-suite-unraid.git
cd mcp-suite-unraid
```

### 2. Create Directory Structure

```bash
# Create MCP data directories
mkdir -p /mnt/user/appdata/mcp-suite/gmail/credentials
mkdir -p /mnt/user/appdata/mcp-suite/gdrive/credentials
mkdir -p /mnt/user/appdata/mcp-suite/memory/data
mkdir -p /mnt/user/appdata/mcp-suite/openai-python/openai-custom-env

# Create dev container directories
mkdir -p /mnt/user/appdata/dev-container/workspace
mkdir -p /mnt/user/appdata/dev-container/config
mkdir -p /mnt/user/appdata/dev-container/ssh
```

### 3. Configure MCP Proxy Stack

```bash
cd /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/mcp-proxy
cp .env.example .env
nano .env
```

Add your credentials:
```bash
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token_here
OPENAI_API_KEY=sk-your_key_here
```

### 4. Add Google OAuth Credentials

Place your `gcp-oauth.keys.json` file in both locations:

```bash
# For Gmail
cp /path/to/your/gcp-oauth.keys.json /mnt/user/appdata/mcp-suite/gmail/credentials/

# For Google Drive
cp /path/to/your/gcp-oauth.keys.json /mnt/user/appdata/mcp-suite/gdrive/credentials/
```

### 5. Set Up OpenAI MCP Server (Optional Custom Server)

If you have a custom OpenAI MCP server:

```bash
# Place your custom server code
cp /path/to/openai_mcp_server.py /mnt/user/appdata/mcp-suite/openai-python/openai-custom-env/
```

Or use the default OpenAI MCP by modifying the compose file.

### 6. Configure Dev Container (Optional)

```bash
cd /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/dev-container
cp .env.example .env
nano .env
```

Replace `YOUR-SERVER-IP` with your Unraid server's IP address.

### 7. Start Services

#### Using Dockge (Recommended)

1. Open Dockge: `http://YOUR-SERVER-IP:5001`
2. Click "Compose" → "Import"
3. Import each stack:
   - `/mnt/user/appdata/dockge/stacks/mcp-suite-unraid/mcp-proxy`
   - `/mnt/user/appdata/dockge/stacks/mcp-suite-unraid/playwright-mcp`
   - `/mnt/user/appdata/dockge/stacks/mcp-suite-unraid/dev-container` (optional)
4. Start stacks in order:
   - Start `mcp-proxy` first
   - Then start `playwright-mcp`
   - Finally start `dev-container` (if desired)

#### Using Docker Compose CLI

```bash
# Start MCP proxy stack (5 services)
cd /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/mcp-proxy
docker compose up -d

# Start Playwright stack
cd ../playwright-mcp
docker compose up -d

# Start dev container (optional)
cd ../dev-container
docker compose up -d
```

### 8. Verify Installation

Check that all containers are running:

```bash
docker ps --filter name=mcp
```

You should see:
- `github-mcp-proxy`
- `openai-mcp-proxy`
- `gmail-mcp-proxy`
- `gdrive-mcp-proxy`
- `memory-mcp-proxy`
- `playwright-mcp`
- `dev-container` (if started)

### 9. Test MCP Endpoints

```bash
# Test each endpoint (should return HTTP 200)
curl -I http://YOUR-SERVER-IP:3006/sse  # GitHub
curl -I http://YOUR-SERVER-IP:3001/sse  # OpenAI
curl -I http://YOUR-SERVER-IP:3102/sse  # Gmail
curl -I http://YOUR-SERVER-IP:3004/sse  # Drive
curl -I http://YOUR-SERVER-IP:3107/sse  # Memory
curl -I http://YOUR-SERVER-IP:3008/sse  # Playwright
```

### 10. Complete OAuth Setup (Gmail & Drive)

See [OAUTH_SETUP.md](OAUTH_SETUP.md) for:
- Updating redirect URIs in Google Cloud Console
- Completing OAuth authorization flows
- Troubleshooting OAuth issues

## Post-Installation

### Access Jupyter Lab

If you started the dev-container:

1. Open browser: `http://YOUR-SERVER-IP:8888`
2. Jupyter Lab will open (no password required)
3. Create a new notebook
4. Test MCP access via environment variables:

```python
import os

print("GitHub MCP:", os.getenv('MCP_GITHUB_URL'))
print("OpenAI MCP:", os.getenv('MCP_OPENAI_URL'))
# ... etc
```

### View Logs

```bash
# View logs for specific service
docker logs -f github-mcp-proxy
docker logs -f gmail-mcp-proxy

# View last 100 lines
docker logs --tail 100 memory-mcp-proxy
```

### Restart Services

```bash
# Restart specific service
docker restart gmail-mcp-proxy

# Restart all mcp-proxy services
cd /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/mcp-proxy
docker compose restart
```

### Stop Services

```bash
# Stop all services in a stack
cd /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/mcp-proxy
docker compose down

# Stop specific service
docker stop gmail-mcp-proxy
```

## Updating

### Update Repository

```bash
cd /mnt/user/appdata/dockge/stacks/mcp-suite-unraid
git pull
```

### Update Containers

```bash
# Pull latest images
cd mcp-proxy
docker compose pull
docker compose up -d

cd ../playwright-mcp
docker compose pull
docker compose up -d
```

## Backup & Restore

### Backup Important Data

```bash
# Backup MCP data
tar -czf mcp-suite-backup.tar.gz /mnt/user/appdata/mcp-suite/

# Backup dev container workspace
tar -czf dev-container-backup.tar.gz /mnt/user/appdata/dev-container/workspace/
```

### Restore

```bash
# Restore MCP data
tar -xzf mcp-suite-backup.tar.gz -C /

# Restore workspace
tar -xzf dev-container-backup.tar.gz -C /
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.

## Next Steps

1. Complete OAuth setup for Gmail and Google Drive
2. Test each MCP server with a client
3. Explore Jupyter Lab if using dev-container
4. Build your first MCP-powered application!

## Support

- **GitHub Issues:** https://github.com/Twine2546/mcp-suite-unraid/issues
- **MCP Documentation:** https://modelcontextprotocol.io
- **Complete Guide:** [Google Doc](https://docs.google.com/document/d/1RQcprMsYwFI6FUI5A4RPYpnF_3GagbP83tM1Bj41HQ8/edit?usp=drivesdk)
