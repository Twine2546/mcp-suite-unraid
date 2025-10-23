# Playwright MCP Server with noVNC

A Playwright MCP (Model Context Protocol) server with noVNC support for browser automation with visual access and manual CAPTCHA solving.

## Features

- **Browser Automation** - Chromium browser control via Playwright MCP
- **noVNC Web Interface** - View and interact with browser in your web browser
- **VNC Access** - Optional VNC client support for desktop applications
- **Manual Intervention** - Solve CAPTCHAs manually when automation encounters them
- **Fast Restarts** - First-time setup caching for quick subsequent starts
- **Version Compatibility** - Automatic symlinks for browser version matching

## Quick Start

### First Time Setup

1. **Deploy with Dockge** - Use the provided `compose.yaml`
2. **Wait for installation** - First start takes ~5-10 minutes
3. **Access MCP Server** - Configure in Claude Code at `http://playwright-mcp:3008/sse`
4. **View Browser** - Navigate to `http://<YOUR_SERVER_IP>:6080/vnc.html`

### Subsequent Restarts

- Container starts in ~5-10 seconds
- All tools and browsers remain installed
- No reinstallation needed

## Access Points

### MCP Server (for Claude Code)
- **URL**: `http://playwright-mcp:3008/sse`
- **Type**: SSE (Server-Sent Events)
- Use this in Claude Code's MCP configuration

### noVNC Web Interface
- **URL**: `http://<YOUR_SERVER_IP>:6080/vnc.html`
- **Purpose**: View browser in your web browser
- **Use Case**: Watch automation, solve CAPTCHAs manually

### VNC Client (Optional)
- **Host**: `<YOUR_SERVER_IP>`
- **Port**: `5900`
- **Password**: None (no password required)
- **Clients**: RealVNC, TigerVNC, etc.

## What Persists Between Restarts

### ✅ Saved (in `/root` volume)

- Browser binaries (`/root/.cache/ms-playwright`)
- npm cache (`/root/.npm`)
- Setup completion marker (`/root/.setup_done`)
- All installed packages and tools

### ⚠️ Installed Once (via setup marker)

- System packages (nodejs, npm, xvfb, x11vnc, fluxbox, novnc)
- Python packages (mcp-proxy)
- Playwright browsers (Chromium)
- Browser dependencies

These are installed once and persist because the setup script skips reinstallation on subsequent starts.

## Container Restart Behavior

### Normal Restart
```bash
# Via Dockge: Stop → Start
# OR via CLI:
docker restart playwright-mcp
```
- Takes ~5-10 seconds
- Skips installation (checks for `.setup_done` marker)
- All services start immediately

### Force Reinstall
```bash
# Remove setup marker
docker exec playwright-mcp rm /root/.setup_done

# Restart container via Dockge or:
docker restart playwright-mcp
```
- Takes ~5-10 minutes
- Runs full installation
- Gets latest package versions

## Installed Components

### System Tools
- **Display Server**: Xvfb (virtual framebuffer)
- **VNC Server**: x11vnc (for remote access)
- **Window Manager**: fluxbox (lightweight GUI)
- **Web VNC**: noVNC, websockify (browser-based access)
- **Node.js**: Runtime for Playwright
- **Process Tools**: procps (for monitoring)

### Playwright Stack
- **Browser**: Chromium (version 1194 with 1179 compatibility symlinks)
- **Automation**: Playwright Node.js library
- **MCP Server**: @executeautomation/playwright-mcp-server
- **Proxy**: mcp-proxy (STDIO to SSE conversion)

## Using the Playwright MCP

### From Claude Code

1. **Configure MCP Server**:
   Add to your `.claude.json`:
   ```json
   {
     "mcpServers": {
       "playwright": {
         "type": "sse",
         "url": "http://playwright-mcp:3008/sse"
       }
     }
   }
   ```

2. **Use in Claude Code**:
   ```
   > /mcp
   # Available tools will include Playwright browser automation
   ```

3. **Example Tasks**:
   - Navigate to websites
   - Take screenshots
   - Fill out forms
   - Extract data from pages
   - Test web applications

### Manual CAPTCHA Solving

When automation encounters a CAPTCHA:

1. **Open noVNC**: Navigate to `http://<YOUR_IP>:6080/vnc.html`
2. **Click Connect**: You'll see the desktop with Chromium
3. **Find Browser**: Chromium will be visible on the screen
4. **Solve CAPTCHA**: Click and interact with the browser window
5. **Continue**: Automation resumes after CAPTCHA is solved

## Browser Version Compatibility

The container creates symlinks to handle version mismatches:
- `chromium-1179 → chromium-1194`
- `chromium_headless_shell-1179 → chromium_headless_shell-1194`

This ensures the MCP server (which expects version 1179) can use the installed version 1194.

## Environment Variables

### Set in compose.yaml
- `DEBIAN_FRONTEND=noninteractive` - Prevents apt prompts
- `DISPLAY=:99` - Virtual display for browser
- `PLAYWRIGHT_HEADLESS=false` - Run browser with GUI (for noVNC)

## Ports

- **3008** - MCP server (SSE)
- **6080** - noVNC web interface
- **5900** - VNC server

## Volumes

### Host Locations (Unraid)
- **Data**: `/mnt/user/appdata/mcp-suite/playwright/data`
- **Root**: `/mnt/user/appdata/mcp-suite/playwright/root`
- **npm Cache**: `/mnt/user/appdata/mcp-suite/playwright/npm-cache`

### Container Locations
- **Data**: `/data`
- **Root**: `/root`
- **npm Cache**: `/root/.npm`
- **Browsers**: `/root/.cache/ms-playwright`

## Networks

The container connects to:
- **mcp_network** - For MCP server communication

## Troubleshooting

### Browser Not Found Error

**Problem**: `Executable doesn't exist at /root/.cache/ms-playwright/chromium-1179/chrome-linux/chrome`

**Solution**: Symlinks may be missing
```bash
docker exec playwright-mcp sh -c "cd /root/.cache/ms-playwright && ln -sf chromium-1194 chromium-1179 && ln -sf chromium_headless_shell-1194 chromium_headless_shell-1179"
docker restart playwright-mcp
```

### noVNC Not Working

**Problem**: Can't access `http://<IP>:6080`

**Solutions**:
1. Check if port 6080 is exposed: `docker port playwright-mcp`
2. Check firewall rules on Unraid
3. Verify websockify is running: `docker exec playwright-mcp ps aux | grep websockify`

### Black Screen in noVNC

**Problem**: noVNC connects but shows black screen

**Solutions**:
1. Check if Xvfb is running: `docker exec playwright-mcp ps aux | grep Xvfb`
2. Check if fluxbox started: `docker exec playwright-mcp ps aux | grep fluxbox`
3. Restart container to reinitialize display server

### MCP Server Not Responding

**Problem**: Claude Code can't connect to MCP server

**Solutions**:
1. Check if mcp-proxy is running: `docker exec playwright-mcp ps aux | grep mcp-proxy`
2. Check container logs: `docker logs playwright-mcp`
3. Verify network connectivity: `curl http://playwright-mcp:3008/sse`

### Slow Startup

**Problem**: Container takes 5-10 minutes to start

**Solution**: This is normal for first start. Check if setup marker exists:
```bash
docker exec playwright-mcp ls -la /root/.setup_done
# If file exists, restart should be fast
# If missing, it's running first-time setup
```

### Want Fresh Installation

**Problem**: Need to reinstall all packages

**Solution**: Remove setup marker and restart
```bash
docker exec playwright-mcp rm /root/.setup_done
docker restart playwright-mcp
```

## Security Notes

- Container runs as root (required for display server and browser)
- No VNC password (secured by network isolation)
- Browser runs with full permissions
- Suitable for trusted internal networks only

## Performance Tips

1. **First Start**: Be patient - full installation takes time
2. **Subsequent Starts**: Should be fast if `.setup_done` exists
3. **Browser Performance**: Increase `shm_size` if needed (default: 2gb)
4. **Network**: Use Docker networks for MCP communication (faster than host network)

## Advanced Configuration

### Change Display Resolution

Edit `compose.yaml`:
```yaml
command: >
  sh -c "
    ...
    Xvfb :99 -screen 0 2560x1440x24 > /dev/null 2>&1 &
    ...
  "
```

### Enable Headless Mode

If you don't need noVNC access, set:
```yaml
environment:
  - PLAYWRIGHT_HEADLESS=true
```

And remove the display server commands from the startup script.

### Add More Browsers

Install Firefox or Webkit:
```bash
docker exec playwright-mcp npx playwright install firefox webkit
docker exec playwright-mcp npx playwright install-deps firefox webkit
```

## Support

For issues:
1. Check container logs: `docker logs playwright-mcp`
2. Verify setup completed: `docker exec playwright-mcp ls -la /root/.setup_done`
3. Check browser installation: `docker exec playwright-mcp ls -la /root/.cache/ms-playwright/`
4. Try force reinstall: `docker exec playwright-mcp rm /root/.setup_done && docker restart playwright-mcp`
5. Check GitHub issues: [mcp-suite-unraid](https://github.com/Twine2546/mcp-suite-unraid)

## What's New

### Latest Changes (fix/claude-code-installation)

- ✅ Fixed browser version compatibility with symlinks (1194→1179)
- ✅ Added noVNC web interface for browser visibility
- ✅ Added Xvfb virtual display server
- ✅ Added x11vnc for VNC access
- ✅ Added fluxbox window manager
- ✅ Enabled headed mode for manual CAPTCHA solving
- ✅ Setup marker for fast restarts
- ✅ Switched to python:3.11-slim base image
