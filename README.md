# MCP Suite for Unraid

Complete Model Context Protocol (MCP) suite deployment for Unraid with 6 MCP servers and a full-featured development container.

## 🚀 Quick Start

This repository contains everything needed to deploy:
- **6 MCP Servers** (GitHub, OpenAI, Gmail, Google Drive, Memory, Playwright)
- **mcp-proxy** for STDIO-to-HTTP/SSE conversion
- **Development Container** with Jupyter Lab, Python tools, and Docker access

### Prerequisites

- Unraid server with Docker
- Dockge (recommended) or Docker Compose
- API keys for GitHub and OpenAI
- Google Cloud OAuth credentials (for Gmail/Drive)

## 📦 What's Included

### MCP Servers

| Server | Port | Transport | Status |
|--------|------|-----------|--------|
| GitHub | 3006 | SSE (via proxy) | ✓ |
| OpenAI | 3001 | SSE (via proxy) | ✓ |
| Gmail | 3102 | SSE (via proxy) | ⚠ OAuth pending |
| Google Drive | 3004 | SSE (via proxy) | ⚠ OAuth pending |
| Memory | 3107 | SSE (via proxy) | ✓ |
| Playwright | 3008 | SSE (native) | ✓ |

### Development Container

- **Jupyter Lab** on port 8888
- Full Python data science stack (pandas, numpy, scikit-learn)
- Web frameworks (FastAPI, Flask, Django)
- Build tools (gcc, make, cmake)
- Docker + Docker Compose access
- All MCP servers pre-configured

## 🏗️ Architecture

### Stack 1: mcp-proxy (5 services)
Converts STDIO-only MCP servers to HTTP/SSE endpoints:
- `github-mcp-proxy`
- `openai-mcp-proxy`
- `gmail-mcp-proxy`
- `gdrive-mcp-proxy`
- `memory-mcp-proxy`

### Stack 2: playwright-mcp (1 service)
Native HTTP/SSE support:
- `playwright-mcp`

### Stack 3: dev-container (1 service)
Development environment:
- `dev-container` with Jupyter Lab

## 📁 Repository Structure

```
mcp-suite-unraid/
├── mcp-proxy/
│   ├── compose.yaml
│   └── .env.example
├── playwright-mcp/
│   └── compose.yaml
├── dev-container/
│   ├── compose.yaml
│   └── .env.example
├── docs/
│   ├── SETUP.md
│   ├── OAUTH_SETUP.md
│   └── TROUBLESHOOTING.md
└── README.md
```

## 🚦 Installation

### Step 1: Clone Repository

```bash
cd /mnt/user/appdata/dockge/stacks/
git clone https://github.com/Twine2546/mcp-suite-unraid.git
```

### Step 2: Set Up Directory Structure

```bash
mkdir -p /mnt/user/appdata/mcp-suite/{gmail,gdrive,memory,openai-python}/credentials
mkdir -p /mnt/user/appdata/dev-container/{workspace,config,ssh}
```

### Step 3: Configure Environment Variables

```bash
# MCP Proxy stack
cd mcp-suite-unraid/mcp-proxy
cp .env.example .env
nano .env  # Add your API keys

# Dev Container stack
cd ../dev-container
cp .env.example .env
```

### Step 4: Add OAuth Credentials

Place your `gcp-oauth.keys.json` file in:
- `/mnt/user/appdata/mcp-suite/gmail/credentials/`
- `/mnt/user/appdata/mcp-suite/gdrive/credentials/`

### Step 5: Start Services

Using Dockge:
1. Open Dockge at `http://YOUR-SERVER-IP:5001`
2. Import each stack from the repository
3. Start stacks in order:
   - `mcp-proxy`
   - `playwright-mcp`
   - `dev-container` (optional)

Using Docker Compose:
```bash
# Start MCP proxy stack
cd mcp-proxy
docker compose up -d

# Start Playwright stack
cd ../playwright-mcp
docker compose up -d

# Start dev container (optional)
cd ../dev-container
docker compose up -d
```

### Step 6: Complete OAuth Setup (Gmail/Drive)

See [docs/OAUTH_SETUP.md](docs/OAUTH_SETUP.md) for detailed instructions.

## 🔗 MCP Endpoints

Once running, MCP servers are available at:

- **GitHub:** `http://YOUR-SERVER-IP:3006/sse`
- **OpenAI:** `http://YOUR-SERVER-IP:3001/sse`
- **Gmail:** `http://YOUR-SERVER-IP:3102/sse`
- **Drive:** `http://YOUR-SERVER-IP:3004/sse`
- **Memory:** `http://YOUR-SERVER-IP:3107/sse`
- **Playwright:** `http://YOUR-SERVER-IP:3008/sse`

## 🧪 Testing

Test each MCP endpoint:

```bash
curl -I http://YOUR-SERVER-IP:3006/sse  # Should return 200 OK
curl -I http://YOUR-SERVER-IP:3001/sse
curl -I http://YOUR-SERVER-IP:3102/sse
curl -I http://YOUR-SERVER-IP:3004/sse
curl -I http://YOUR-SERVER-IP:3107/sse
curl -I http://YOUR-SERVER-IP:3008/sse
```

View logs:
```bash
docker logs github-mcp-proxy
docker logs openai-mcp-proxy
docker logs gmail-mcp-proxy
docker logs gdrive-mcp-proxy
docker logs memory-mcp-proxy
docker logs playwright-mcp
```

## 📖 Documentation

- **[Setup Guide](docs/SETUP.md)** - Detailed installation instructions
- **[OAuth Setup](docs/OAUTH_SETUP.md)** - Gmail and Google Drive OAuth configuration
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Google Doc](https://docs.google.com/document/d/1RQcprMsYwFI6FUI5A4RPYpnF_3GagbP83tM1Bj41HQ8/edit?usp=drivesdk)** - Complete reference documentation

## 🔧 Development Container Features

The included development container provides:

### Python Environment
- Jupyter Lab (port 8888)
- pandas, numpy, scipy
- matplotlib, seaborn
- scikit-learn

### Web Frameworks
- FastAPI + uvicorn
- Flask
- Django
- SQLAlchemy

### Build Tools
- gcc, g++, make, cmake
- Docker + Docker Compose (host access)
- git, vim, nano

### MCP Integration
All 6 MCP server URLs pre-configured as environment variables.

## 🐛 Troubleshooting

### Container Won't Start
- Check API keys in `.env` files
- Verify credentials files exist
- Review logs: `docker logs CONTAINER_NAME`

### MCP Not Responding
- Ensure all stacks are running
- Test endpoint with curl
- Check firewall/network settings

### OAuth Issues
- Update redirect URIs in Google Cloud Console
- Visit OAuth callback URLs to authorize
- See [OAuth Setup Guide](docs/OAUTH_SETUP.md)

For more issues, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 🎯 Use Cases

### AI Development
- Test MCP integrations with multiple AI services
- Prototype AI-powered applications
- Experiment with knowledge graphs

### Automation
- Automate Gmail workflows
- Manage Google Drive programmatically
- Browser automation with Playwright

### Data Science
- Jupyter notebooks with MCP access
- AI-assisted data analysis
- Integration with OpenAI models

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- [Model Context Protocol](https://modelcontextprotocol.io)
- [mcp-proxy](https://github.com/modelcontextprotocol/mcp-proxy)
- MCP server maintainers:
  - [@modelcontextprotocol/server-github](https://github.com/modelcontextprotocol/servers)
  - [@gongrzhe/server-gmail-autoauth-mcp](https://github.com/gongrzhe/server-gmail-autoauth-mcp)
  - [@piotr-agier/google-drive-mcp](https://github.com/piotr-agier/google-drive-mcp)
  - [@modelcontextprotocol/server-memory](https://github.com/modelcontextprotocol/servers)
  - [@playwright/mcp](https://github.com/playwright/playwright)

## 📊 Project Status

- ✅ All MCP servers operational
- ✅ Development container ready
- ⚠️ Gmail OAuth pending user authorization
- ⚠️ Google Drive OAuth pending user authorization

## 🔗 Links

- **Documentation:** [Google Doc](https://docs.google.com/document/d/1RQcprMsYwFI6FUI5A4RPYpnF_3GagbP83tM1Bj41HQ8/edit?usp=drivesdk)
- **MCP Protocol:** https://modelcontextprotocol.io
- **Issues:** [GitHub Issues](https://github.com/Twine2546/mcp-suite-unraid/issues)

---

**Created:** October 22, 2025  
**Deployment:** Unraid Server  
**Total Services:** 7 containers (6 MCP + 1 dev)
