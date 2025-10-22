# VSCode Server Development Container

A fully-featured VSCode Server container with development tools, Claude Code CLI, and MCP server integration.

## Features

- **Web-based VSCode** - Access via browser at `http://100.78.183.119:8090`
- **Development Tools** - Python, Node.js, Docker, build tools
- **Claude Code CLI** - AI-powered coding assistant
- **MCP Server Integration** - GitHub, OpenAI, Gmail, Google Drive, Memory, Playwright
- **Data Science Stack** - Jupyter, pandas, numpy, matplotlib, scikit-learn
- **Fast Restarts** - First-time setup caching for quick subsequent starts

## Quick Start

### First Time Setup

1. **Deploy with Dockge** - Use the provided `compose.yaml`
2. **Wait for installation** - First start takes ~5-10 minutes
3. **Access VSCode** - Navigate to `http://100.78.183.119:8090`
4. **Open terminal** - Inside VSCode, open a new terminal
5. **Run Claude Code** - Type `claude` to start

### Subsequent Restarts

- Container starts in ~5-10 seconds
- All tools remain installed
- VS Code extensions persist
- Workspace files persist

## What Persists Between Restarts

### ✅ Saved (in `/config` volume)

- VS Code settings and configuration
- VS Code extensions/plugins
- Workspace files (`/config/workspace`)
- Bash history and `.bashrc` customizations
- Setup completion marker (`.setup-complete`)

### ⚠️ Installed but Cached (via first-time setup)

- System packages (apt)
- Python packages (pip)
- Node.js packages (npm)
- Claude Code CLI
- Development tools

These are installed once and "persist" because the setup script skips reinstallation on subsequent starts.

## Container Restart Behavior

### Normal Restart
```bash
# Via Dockge: Stop → Start
# OR via CLI:
docker restart vscode-server
```
- Takes ~5-10 seconds
- Skips installation (checks for `.setup-complete` marker)
- All tools immediately available

### Force Reinstall
```bash
# Remove setup marker
rm /mnt/user/appdata/vscode-server/config/.setup-complete

# Restart container via Dockge or:
docker restart vscode-server
```
- Takes ~5-10 minutes
- Runs full installation
- Gets latest package versions

## Installed Development Tools

### System Tools
- **Shell**: bash, zsh compatibility
- **Version Control**: git, git-lfs
- **Editors**: vim, nano
- **Build Tools**: gcc, g++, make, cmake, autoconf, libtool
- **Utilities**: curl, wget, jq, yq, tree, htop

### Python Stack
- **Core**: Python 3.12, pip, venv
- **Notebooks**: Jupyter, JupyterLab, IPython
- **Data Science**: pandas, numpy, scipy, matplotlib, seaborn, scikit-learn
- **Web**: requests, httpx, aiohttp, FastAPI, uvicorn, Flask, Django
- **Database**: SQLAlchemy, psycopg2
- **Testing**: pytest, pytest-cov
- **Linting**: black, flake8, mypy, pylint
- **Package Management**: poetry, pipenv, virtualenv

### Node.js Stack
- **Runtime**: Node.js 18, npm
- **Languages**: TypeScript, ts-node
- **Formatting**: Prettier, ESLint
- **Package Managers**: yarn, pnpm
- **AI Tools**: Claude Code CLI

### Docker
- **Tools**: docker, docker-compose
- **Access**: Docker socket mounted for container management

## MCP Server URLs

The container has environment variables configured for all MCP servers:

```bash
MCP_GITHUB_URL=http://github-mcp-proxy:3006/sse
MCP_OPENAI_URL=http://openai-mcp-proxy:3001/sse
MCP_GMAIL_URL=http://gmail-mcp-proxy:3102/sse
MCP_GDRIVE_URL=http://gdrive-mcp-proxy:3004/sse
MCP_MEMORY_URL=http://memory-mcp-proxy:3107/sse
MCP_PLAYWRIGHT_URL=http://playwright-mcp:3008/sse
```

## Using Claude Code

### Basic Usage
```bash
# Open terminal in VSCode
abc@container:~/workspace$ claude

# Claude Code will start and you can interact with it
```

### Update Claude Code
```bash
# Method 1: Force reinstall (gets latest version)
rm /config/.setup-complete
# Then restart container via Dockge

# Method 2: Manual update (lost on restart)
npm install -g claude-code@latest
```

## Troubleshooting

### Claude Code Not Found
**Problem**: `bash: claude: command not found`

**Solution**: The container needs to be restarted to use the updated compose.yaml
```bash
# Stop and start container in Dockge
# First start will install Claude Code properly
```

### Slow Startup
**Problem**: Container takes 5-10 minutes to start

**Solution**: This is normal for first start. Check if setup marker exists:
```bash
# Check if already installed
ls /mnt/user/appdata/vscode-server/config/.setup-complete

# If file exists, restart should be fast
# If missing, it's running first-time setup
```

### Want Fresh Installation
**Problem**: Need to reinstall all packages

**Solution**: Remove setup marker and restart
```bash
rm /mnt/user/appdata/vscode-server/config/.setup-complete
# Restart container via Dockge
```

### VS Code Extensions Lost
**Problem**: Extensions disappear after restart

**Solution**: This shouldn't happen - extensions are stored in `/config`. If it does:
1. Check volume mount: `/mnt/user/appdata/vscode-server/config:/config`
2. Ensure proper permissions on host directory
3. Reinstall extensions (they will persist)

## Networks

The container is connected to two networks:

1. **mcp_network** - For MCP server communication
2. **my_internal_network** - Custom internal network

## Environment Variables

### Required
- `PUID` - User ID (typically 1000)
- `PGID` - Group ID (typically 1000)
- `TZ` - Timezone
- `PASSWORD` - VSCode access password
- `SUDO_PASSWORD` - Sudo password for user `abc`

### MCP Server URLs (optional)
All MCP server URL variables are pre-configured but can be customized.

## File Locations

### On Host (Unraid)
- **Config**: `/mnt/user/appdata/vscode-server/config`
- **Workspace**: `/mnt/user/appdata/vscode-server/workspace`
- **Setup Marker**: `/mnt/user/appdata/vscode-server/config/.setup-complete`

### In Container
- **Config**: `/config`
- **Workspace**: `/config/workspace`
- **User Home**: `/config` (user: abc, UID: 1000)

## Advanced Configuration

### Customize Installations

Edit `compose.yaml` and modify the installation commands within the setup check:

```yaml
if [ ! -f /config/.setup-complete ]; then
  # Add your custom installations here
  pip3 install --break-system-packages your-package
  npm install -g your-global-package
  
  touch /config/.setup-complete
fi
```

### Change Restart Policy

Currently set to `restart: "no"` for debugging. To enable auto-restart:

```yaml
restart: unless-stopped
```

## Performance Tips

1. **First Start**: Be patient - full installation takes time
2. **Subsequent Starts**: Should be fast if `.setup-complete` exists
3. **Extensions**: Install via VS Code UI, they persist automatically
4. **Large Files**: Store in `/config/workspace` for persistence

## Security Notes

- Container runs as user `abc` (UID 1000, GID 1000)
- Docker socket is mounted (allows container management)
- Password protected access
- No restart policy (manual control)

## Support

For issues:
1. Check container logs: `docker logs vscode-server`
2. Verify setup marker exists: `ls /config/.setup-complete`
3. Try force reinstall: `rm /config/.setup-complete && restart`
4. Check GitHub issues: [mcp-suite-unraid](https://github.com/Twine2546/mcp-suite-unraid)
