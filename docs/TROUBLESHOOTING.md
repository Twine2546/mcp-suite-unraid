# Troubleshooting Guide

Common issues and solutions for MCP Suite on Unraid.

## Container Issues

### Container Exits Immediately

**Symptoms:**
- Container shows "Exited (1)" status
- Container restarts in a loop

**Solutions:**

1. Check container logs:
   ```bash
   docker logs CONTAINER_NAME
   ```

2. Common causes:
   - **Missing environment variables:** Verify `.env` file exists and has required keys
   - **Invalid credentials:** Check API keys are correct
   - **Missing files:** Ensure OAuth credentials exist for Gmail/Drive
   - **Port conflicts:** Another service using the same port

3. Verify environment variables:
   ```bash
   docker exec CONTAINER_NAME env | grep -E 'GITHUB|OPENAI|GOOGLE'
   ```

### Container Won't Start

**Symptoms:**
- Container fails to start in Dockge
- "Failed to create container" error

**Solutions:**

1. Check Docker disk space:
   ```bash
   docker system df
   ```

2. Clean up if needed:
   ```bash
   docker system prune -a
   docker volume prune
   ```

3. Verify compose file syntax:
   ```bash
   cd /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/mcp-proxy
   docker compose config
   ```

4. Check for port conflicts:
   ```bash
   netstat -tulpn | grep -E '3001|3003|3004|3005|3006|3008|3102|3107'
   ```

### dpkg Errors (Debian Package Manager)

**Symptoms:**
- Container logs show dpkg errors
- "dpkg was interrupted" message

**Solutions:**

The compose files already include fixes:
```bash
dpkg --configure -a
apt-get install -y -f
```

If errors persist:
1. Remove container and volumes
2. Recreate from compose file

## MCP Server Issues

### MCP Endpoint Returns 404

**Symptoms:**
- `curl http://SERVER-IP:PORT/sse` returns 404
- MCP client can't connect

**Solutions:**

1. Verify container is running:
   ```bash
   docker ps | grep mcp
   ```

2. Check if mcp-proxy is listening:
   ```bash
   docker logs CONTAINER_NAME | grep "Uvicorn running"
   ```

3. Test with verbose curl:
   ```bash
   curl -v http://SERVER-IP:PORT/sse
   ```

### MCP Endpoint Returns 500

**Symptoms:**
- `curl` returns HTTP 500 Internal Server Error
- Container logs show errors

**Solutions:**

1. Check API credentials:
   - GitHub: Verify token has required scopes
   - OpenAI: Verify API key is active
   - Gmail/Drive: Complete OAuth flow

2. View detailed logs:
   ```bash
   docker logs -f CONTAINER_NAME
   ```

3. Restart container:
   ```bash
   docker restart CONTAINER_NAME
   ```

### GitHub MCP "Bad Credentials"

**Symptoms:**
- GitHub MCP returns authentication errors
- Logs show "401 Unauthorized"

**Solutions:**

1. Generate new GitHub token:
   - Go to https://github.com/settings/tokens
   - Create new token with `repo`, `read:org`, `read:user` scopes

2. Update `.env` file:
   ```bash
   nano /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/mcp-proxy/.env
   ```

3. Restart container:
   ```bash
   docker restart github-mcp-proxy
   ```

### OpenAI MCP "Invalid API Key"

**Symptoms:**
- OpenAI MCP returns 401 errors
- Logs show "Invalid API key"

**Solutions:**

1. Verify API key:
   - Go to https://platform.openai.com/api-keys
   - Check key is active
   - Regenerate if needed

2. Update `.env` file:
   ```bash
   nano /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/mcp-proxy/.env
   ```

3. Restart container:
   ```bash
   docker restart openai-mcp-proxy
   ```

## OAuth Issues

### Gmail/Drive OAuth Not Working

See [OAUTH_SETUP.md](OAUTH_SETUP.md) for detailed OAuth troubleshooting.

Quick checks:

1. Verify redirect URIs in Google Cloud Console
2. Ensure OAuth credentials file exists:
   ```bash
   ls -la /mnt/user/appdata/mcp-suite/gmail/credentials/gcp-oauth.keys.json
   ls -la /mnt/user/appdata/mcp-suite/gdrive/credentials/gcp-oauth.keys.json
   ```

3. Check file permissions:
   ```bash
   chmod 644 /mnt/user/appdata/mcp-suite/*/credentials/gcp-oauth.keys.json
   ```

### "Redirect URI Mismatch"

**Solutions:**

1. Add correct redirect URIs in Google Cloud Console:
   - `http://localhost`
   - `http://YOUR-SERVER-IP:3003/oauth2callback` (Gmail)
   - `http://YOUR-SERVER-IP:3005/oauth2callback` (Drive)

2. Wait 5 minutes for changes to propagate

3. Clear browser cookies and retry

## Network Issues

### Can't Access MCP Endpoints from Other Machines

**Symptoms:**
- MCPs work from Unraid server but not from other devices
- Connection timeout errors

**Solutions:**

1. Check Unraid firewall:
   - Go to Unraid Settings → Network Settings
   - Ensure firewall allows ports 3001-3008, 3102, 3107

2. Verify containers are listening on 0.0.0.0:
   ```bash
   docker exec CONTAINER_NAME netstat -tulpn | grep LISTEN
   ```

3. Test from Unraid server first:
   ```bash
   curl http://localhost:3006/sse
   ```

4. Then test from another machine:
   ```bash
   curl http://UNRAID-IP:3006/sse
   ```

### Port Already in Use

**Symptoms:**
- "port is already allocated" error
- Container fails to bind to port

**Solutions:**

1. Find process using port:
   ```bash
   netstat -tulpn | grep :3006
   ```

2. Stop conflicting service or change port in compose file

## Development Container Issues

### Jupyter Lab Won't Start

**Symptoms:**
- Can't access Jupyter Lab on port 8888
- Container logs show errors

**Solutions:**

1. Check container is running:
   ```bash
   docker ps | grep dev-container
   ```

2. View logs:
   ```bash
   docker logs dev-container | tail -50
   ```

3. Common issues:
   - Installation still in progress (wait 3-5 minutes on first start)
   - Port 8888 already in use
   - Out of disk space

### Docker Commands Don't Work Inside Container

**Symptoms:**
- `docker: command not found`
- `permission denied` when running docker

**Solutions:**

1. Verify Docker socket is mounted:
   ```bash
   docker inspect dev-container | grep -A 5 Mounts
   ```

2. Check socket permissions:
   ```bash
   ls -la /var/run/docker.sock
   ```

3. If using rootless Docker, adjust socket path in compose file

### Workspace Files Not Persisting

**Symptoms:**
- Files disappear after container restart
- Can't find previously created files

**Solutions:**

1. Verify volume mount:
   ```bash
   docker inspect dev-container | grep -A 10 Mounts
   ```

2. Ensure you're working in `/workspace`:
   ```bash
   docker exec dev-container pwd
   ```

3. Check host directory exists:
   ```bash
   ls -la /mnt/user/appdata/dev-container/workspace
   ```

## Performance Issues

### Slow Container Startup

**Causes:**
- Installing packages on first start
- Slow network pulling Docker images
- Limited Unraid resources

**Solutions:**

1. First startup takes 3-5 minutes (normal)
2. Subsequent startups faster (packages cached)
3. Monitor resource usage:
   ```bash
   docker stats
   ```

### High Memory Usage

**Solutions:**

1. Check which container is using memory:
   ```bash
   docker stats --no-stream
   ```

2. Playwright uses most memory (chromium instances)
   - Reduce `shm_size` if needed
   - Monitor with `docker stats playwright-mcp`

3. Set memory limits in compose file:
   ```yaml
   deploy:
     resources:
       limits:
         memory: 2G
   ```

## Disk Space Issues

### Out of Disk Space

**Symptoms:**
- "no space left on device"
- Containers won't start

**Solutions:**

1. Check Docker disk usage:
   ```bash
   docker system df
   ```

2. Clean up:
   ```bash
   # Remove unused images
   docker image prune -a
   
   # Remove build cache
   docker builder prune -af
   
   # Remove stopped containers
   docker container prune
   
   # Remove unused volumes
   docker volume prune
   ```

3. Increase Docker vDisk size:
   - Go to Unraid Settings → Docker
   - Increase vDisk size
   - Restart Docker service

## Log Analysis

### Viewing Logs

```bash
# Real-time logs
docker logs -f CONTAINER_NAME

# Last 100 lines
docker logs --tail 100 CONTAINER_NAME

# Logs since timestamp
docker logs --since 2025-10-22T00:00:00 CONTAINER_NAME

# Save logs to file
docker logs CONTAINER_NAME > /mnt/user/logs/CONTAINER_NAME.log 2>&1
```

### Common Log Messages

**Normal:**
- `Uvicorn running on http://0.0.0.0:PORT`
- `Configured default server: npx @...`
- `Application startup complete`

**Errors:**
- `ModuleNotFoundError`: Package missing, reinstall container
- `Connection refused`: Upstream service not available
- `401 Unauthorized`: Invalid credentials
- `404 Not Found`: Endpoint doesn't exist

## Getting Help

### Information to Provide

When asking for help, include:

1. Container logs:
   ```bash
   docker logs CONTAINER_NAME > logs.txt
   ```

2. Compose file (remove sensitive data):
   ```bash
   cat compose.yaml
   ```

3. Container status:
   ```bash
   docker ps -a | grep mcp
   ```

4. System information:
   ```bash
   uname -a
   docker version
   docker compose version
   ```

### Support Channels

- **GitHub Issues:** https://github.com/Twine2546/mcp-suite-unraid/issues
- **MCP Documentation:** https://modelcontextprotocol.io
- **Unraid Forums:** https://forums.unraid.net

## Advanced Troubleshooting

### Enter Container Shell

```bash
# Start bash shell
docker exec -it CONTAINER_NAME bash

# Or sh if bash not available
docker exec -it CONTAINER_NAME sh
```

### Inspect Container

```bash
# Full container details
docker inspect CONTAINER_NAME

# Network settings
docker inspect CONTAINER_NAME | grep -A 20 NetworkSettings

# Environment variables
docker inspect CONTAINER_NAME | grep -A 50 Env
```

### Test Network Connectivity

```bash
# From host to container
curl http://localhost:PORT/sse

# From container to host
docker exec CONTAINER_NAME curl http://host.docker.internal:PORT

# DNS resolution
docker exec CONTAINER_NAME nslookup google.com
```

### Rebuild Container

```bash
cd /mnt/user/appdata/dockge/stacks/mcp-suite-unraid/STACK_NAME
docker compose down
docker compose pull
docker compose up -d
```

## Prevention

### Regular Maintenance

1. **Weekly:**
   - Check container logs for errors
   - Verify all endpoints responding
   - Monitor disk space

2. **Monthly:**
   - Update containers to latest versions
   - Clean up unused Docker resources
   - Rotate API keys (if needed)

3. **Quarterly:**
   - Review and update OAuth credentials
   - Audit access logs
   - Backup important data

### Monitoring

Set up monitoring for:
- Container health status
- Endpoint availability
- Disk space usage
- API rate limits

Consider using:
- Uptime Kuma
- Prometheus + Grafana
- Portainer
