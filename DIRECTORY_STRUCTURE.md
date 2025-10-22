# Directory Structure Guide

Complete directory structure for MCP Suite on Unraid.

## Overview

The MCP Suite uses two main directory trees:
1. **Dockge Stacks** - Docker Compose configurations
2. **App Data** - Persistent data, credentials, and workspaces

## Complete Directory Tree

```
/mnt/user/appdata/
├── dockge/
│   └── stacks/
│       └── mcp-suite-unraid/              # Repository root
│           ├── README.md
│           ├── DIRECTORY_STRUCTURE.md
│           ├── LICENSE
│           ├── mcp-proxy/                 # Stack 1: MCP Proxy (5 services)
│           │   ├── compose.yaml
│           │   ├── .env                   # Your API keys (gitignored)
│           │   └── .env.example
│           ├── playwright-mcp/            # Stack 2: Playwright (1 service)
│           │   └── compose.yaml
│           ├── dev-container/             # Stack 3: Development (1 service)
│           │   ├── compose.yaml
│           │   ├── .env                   # Your config (gitignored)
│           │   └── .env.example
│           └── docs/
│               ├── SETUP.md
│               ├── OAUTH_SETUP.md
│               └── TROUBLESHOOTING.md
│
├── mcp-suite/                             # MCP persistent data
│   ├── gmail/
│   │   ├── credentials/
│   │   │   ├── gcp-oauth.keys.json       # OAuth credentials
│   │   │   └── tokens.json               # OAuth tokens (auto-generated)
│   │   └── data/                          # Gmail data cache
│   ├── gdrive/
│   │   ├── credentials/
│   │   │   ├── gcp-oauth.keys.json       # OAuth credentials
│   │   │   └── tokens.json               # OAuth tokens (auto-generated)
│   │   └── data/                          # Drive data cache
│   ├── memory/
│   │   └── data/                          # Knowledge graph data
│   │       └── graph.db                   # Graph database
│   └── openai-python/
│       └── openai-custom-env/
│           └── openai_mcp_server.py       # Custom OpenAI server (optional)
│
└── dev-container/                         # Development container data
    ├── workspace/                         # Your projects (persistent)
    │   ├── notebooks/                     # Jupyter notebooks
    │   ├── projects/                      # Development projects
    │   └── data/                          # Data files
    ├── config/                            # Configuration files
    │   ├── jupyter/                       # Jupyter config
    │   └── git/                           # Git config
    └── ssh/                               # SSH keys (optional)
        ├── id_rsa
        ├── id_rsa.pub
        └── known_hosts
```

## Directory Details

### Dockge Stacks (`/mnt/user/appdata/dockge/stacks/mcp-suite-unraid/`)

Repository root containing all Docker Compose configurations.

#### Files
- `README.md` - Main documentation
- `DIRECTORY_STRUCTURE.md` - This file
- `LICENSE` - License information

#### `mcp-proxy/`
Docker Compose stack for 5 STDIO-based MCP servers.

**Files:**
- `compose.yaml` - Docker Compose configuration
- `.env` - Your API keys (create from .env.example)
- `.env.example` - Template for environment variables

**Required Environment Variables:**
```bash
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
OPENAI_API_KEY=sk-...
```

#### `playwright-mcp/`
Docker Compose stack for Playwright MCP (native HTTP/SSE).

**Files:**
- `compose.yaml` - Docker Compose configuration

**No environment variables required.**

#### `dev-container/`
Docker Compose stack for development container with Jupyter Lab.

**Files:**
- `compose.yaml` - Docker Compose configuration
- `.env` - Your MCP URLs (create from .env.example)
- `.env.example` - Template for MCP server URLs

**Optional Environment Variables:**
```bash
MCP_GITHUB_URL=http://YOUR-SERVER-IP:3006
MCP_OPENAI_URL=http://YOUR-SERVER-IP:3001
# ... etc
```

#### `docs/`
Documentation files.

- `SETUP.md` - Detailed installation guide
- `OAUTH_SETUP.md` - OAuth configuration for Gmail/Drive
- `TROUBLESHOOTING.md` - Common issues and solutions

### MCP Suite Data (`/mnt/user/appdata/mcp-suite/`)

Persistent data for MCP servers.

#### `gmail/`
Gmail MCP data.

**Structure:**
```
gmail/
├── credentials/
│   ├── gcp-oauth.keys.json     # OAuth credentials (you provide)
│   └── tokens.json             # OAuth tokens (auto-generated)
└── data/                        # Email cache (auto-generated)
```

**Setup:**
1. Create credentials directory
2. Copy `gcp-oauth.keys.json` from Google Cloud Console
3. Complete OAuth flow (tokens.json created automatically)

#### `gdrive/`
Google Drive MCP data.

**Structure:**
```
gdrive/
├── credentials/
│   ├── gcp-oauth.keys.json     # OAuth credentials (you provide)
│   └── tokens.json             # OAuth tokens (auto-generated)
└── data/                        # Drive cache (auto-generated)
```

**Setup:**
Same as Gmail (can use same credentials file).

#### `memory/`
Memory MCP knowledge graph storage.

**Structure:**
```
memory/
└── data/
    └── graph.db                # Knowledge graph database
```

**Setup:**
Directory created automatically. No configuration needed.

#### `openai-python/`
Optional custom OpenAI MCP server.

**Structure:**
```
openai-python/
└── openai-custom-env/
    └── openai_mcp_server.py    # Your custom server code
```

**Setup:**
Only needed if using custom OpenAI server. Otherwise, use standard server.

### Dev Container Data (`/mnt/user/appdata/dev-container/`)

Development container persistent storage.

#### `workspace/`
Your persistent workspace (maps to `/workspace` in container).

**Suggested Structure:**
```
workspace/
├── notebooks/              # Jupyter notebooks
│   ├── analysis.ipynb
│   └── experiments.ipynb
├── projects/               # Development projects
│   ├── project1/
│   └── project2/
└── data/                   # Data files
    ├── datasets/
    └── results/
```

**Important:** Only files in `/workspace` persist across container restarts.

#### `config/`
Configuration files.

**Suggested Structure:**
```
config/
├── jupyter/
│   └── jupyter_notebook_config.py
└── git/
    └── .gitconfig
```

**Optional:** Container uses defaults if not provided.

#### `ssh/`
SSH keys for Git operations.

**Structure:**
```
ssh/
├── id_rsa              # Private key (chmod 600)
├── id_rsa.pub          # Public key (chmod 644)
├── known_hosts         # Known SSH hosts
└── config              # SSH config
```

**Setup:**
```bash
# Copy your existing keys
cp ~/.ssh/id_rsa /mnt/user/appdata/dev-container/ssh/
cp ~/.ssh/id_rsa.pub /mnt/user/appdata/dev-container/ssh/

# Set permissions
chmod 700 /mnt/user/appdata/dev-container/ssh
chmod 600 /mnt/user/appdata/dev-container/ssh/id_rsa
chmod 644 /mnt/user/appdata/dev-container/ssh/id_rsa.pub
```

## Setup Commands

### Create All Directories

```bash
# Dockge stacks (created by git clone)
cd /mnt/user/appdata/dockge/stacks/
git clone https://github.com/Twine2546/mcp-suite-unraid.git

# MCP data directories
mkdir -p /mnt/user/appdata/mcp-suite/gmail/credentials
mkdir -p /mnt/user/appdata/mcp-suite/gmail/data
mkdir -p /mnt/user/appdata/mcp-suite/gdrive/credentials
mkdir -p /mnt/user/appdata/mcp-suite/gdrive/data
mkdir -p /mnt/user/appdata/mcp-suite/memory/data
mkdir -p /mnt/user/appdata/mcp-suite/openai-python/openai-custom-env

# Dev container directories
mkdir -p /mnt/user/appdata/dev-container/workspace/{notebooks,projects,data}
mkdir -p /mnt/user/appdata/dev-container/config/{jupyter,git}
mkdir -p /mnt/user/appdata/dev-container/ssh
```

### Set Permissions

```bash
# Make credentials directories writable
chmod 755 /mnt/user/appdata/mcp-suite/*/credentials

# SSH directory permissions
chmod 700 /mnt/user/appdata/dev-container/ssh

# Workspace permissions (if needed)
chown -R nobody:users /mnt/user/appdata/dev-container/workspace
```

## File Permissions

### Recommended Permissions

```
# Credentials
chmod 644 gcp-oauth.keys.json

# SSH keys
chmod 700 ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Workspace
chmod 755 workspace/
chmod 644 workspace/*.py
```

## Volume Mounts

### Container to Host Mapping

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/credentials` (gmail) | `/mnt/user/appdata/mcp-suite/gmail/credentials` | Gmail OAuth |
| `/credentials` (gdrive) | `/mnt/user/appdata/mcp-suite/gdrive/credentials` | Drive OAuth |
| `/data` (memory) | `/mnt/user/appdata/mcp-suite/memory/data` | Knowledge graph |
| `/mcp` (openai) | `/mnt/user/appdata/mcp-suite/openai-python` | Custom server |
| `/workspace` | `/mnt/user/appdata/dev-container/workspace` | Projects |
| `/root/.config` | `/mnt/user/appdata/dev-container/config` | Config files |
| `/root/.ssh` | `/mnt/user/appdata/dev-container/ssh` | SSH keys |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker access |

## Backup Strategy

### What to Backup

**Critical (backup regularly):**
- `/mnt/user/appdata/mcp-suite/gmail/credentials/`
- `/mnt/user/appdata/mcp-suite/gdrive/credentials/`
- `/mnt/user/appdata/dev-container/workspace/`
- `/mnt/user/appdata/dev-container/ssh/`
- `/mnt/user/appdata/dockge/stacks/mcp-suite-unraid/.env` files

**Optional (can regenerate):**
- `/mnt/user/appdata/mcp-suite/memory/data/` (if valuable data)
- `/mnt/user/appdata/dev-container/config/`

**Don't backup (auto-generated):**
- OAuth tokens.json files
- Docker images and containers
- Cache directories

### Backup Commands

```bash
# Backup critical data
tar -czf mcp-suite-backup-$(date +%Y%m%d).tar.gz \
  /mnt/user/appdata/mcp-suite/*/credentials/ \
  /mnt/user/appdata/dev-container/workspace/ \
  /mnt/user/appdata/dev-container/ssh/ \
  /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/*/.env

# Restore
tar -xzf mcp-suite-backup-YYYYMMDD.tar.gz -C /
```

## Cleanup

### Safe to Delete

When troubleshooting, these can be safely deleted (will regenerate):

```bash
# OAuth tokens (will require re-authorization)
rm /mnt/user/appdata/mcp-suite/gmail/credentials/tokens.json
rm /mnt/user/appdata/mcp-suite/gdrive/credentials/tokens.json

# Cache directories
rm -rf /mnt/user/appdata/mcp-suite/*/data/*

# Config (will use defaults)
rm -rf /mnt/user/appdata/dev-container/config/*
```

### Never Delete

**Keep these:**
- `gcp-oauth.keys.json` (OAuth credentials)
- `.env` files (API keys)
- `workspace/` contents (your work!)
- SSH keys (unless you have backups)

## Disk Space

### Expected Usage

| Component | Initial | After Use |
|-----------|---------|-----------|
| Docker images | ~2-3 GB | ~2-3 GB |
| MCP data | ~10 MB | ~100 MB - 1 GB |
| Dev workspace | 0 | Varies |
| Total | ~3 GB | ~5-10 GB |

### Monitor Usage

```bash
# Check directory sizes
du -sh /mnt/user/appdata/mcp-suite/
du -sh /mnt/user/appdata/dev-container/

# Check Docker usage
docker system df
```

## Troubleshooting

### Directory Doesn't Exist

**Error:** Container fails with "no such file or directory"

**Solution:**
```bash
# Recreate missing directories
mkdir -p /mnt/user/appdata/mcp-suite/{gmail,gdrive,memory,openai-python}/credentials
```

### Permission Denied

**Error:** Container can't write to mounted directory

**Solution:**
```bash
# Fix ownership
chown -R nobody:users /mnt/user/appdata/mcp-suite/
chmod -R 755 /mnt/user/appdata/mcp-suite/
```

### Credentials Not Found

**Error:** OAuth credentials file not found

**Solution:**
1. Verify file exists:
   ```bash
   ls -la /mnt/user/appdata/mcp-suite/gmail/credentials/
   ```

2. Check filename is exactly:
   - `gcp-oauth.keys.json` (not `credentials.json`)

3. Verify JSON syntax:
   ```bash
   cat gcp-oauth.keys.json | python -m json.tool
   ```

## See Also

- [Setup Guide](docs/SETUP.md) - Installation instructions
- [OAuth Setup](docs/OAUTH_SETUP.md) - OAuth configuration
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues
