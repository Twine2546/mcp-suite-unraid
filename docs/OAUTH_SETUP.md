# OAuth Setup for Gmail and Google Drive MCPs

This guide walks you through setting up OAuth authentication for Gmail and Google Drive MCP servers.

## Prerequisites

- Google Cloud Platform account
- Gmail and Google Drive MCPs running (containers started)
- Access to Google Cloud Console

## Step 1: Create Google Cloud Project (If Not Already Done)

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click "Select a project" → "New Project"
3. Enter project name (e.g., "mcp-suite")
4. Click "Create"
5. Note your Project ID

## Step 2: Enable Required APIs

1. In Google Cloud Console, select your project
2. Navigate to **APIs & Services** → **Library**
3. Search and enable:
   - **Gmail API**
   - **Google Drive API**

## Step 3: Create OAuth 2.0 Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. If prompted, configure OAuth consent screen:
   - User Type: **External**
   - App name: "MCP Suite"
   - User support email: Your email
   - Developer contact: Your email
   - Click **Save and Continue**
4. Add scopes (optional for testing): Skip
5. Add test users:
   - Click **+ ADD USERS**
   - Enter your Gmail address
   - Click **Save and Continue**
6. Return to **Credentials** → **+ CREATE CREDENTIALS** → **OAuth client ID**
7. Application type: **Web application**
8. Name: "MCP Suite OAuth"

## Step 4: Configure Authorized Redirect URIs

**IMPORTANT:** Add all three redirect URIs:

1. In the OAuth client configuration, under **Authorized redirect URIs**, add:
   ```
   http://localhost
   http://YOUR-SERVER-IP:3003/oauth2callback
   http://YOUR-SERVER-IP:3005/oauth2callback
   ```
   
   Replace `YOUR-SERVER-IP` with your Unraid server's IP address.
   
   Example:
   ```
   http://localhost
   http://192.168.1.100:3003/oauth2callback
   http://192.168.1.100:3005/oauth2callback
   ```

2. Click **Create**

## Step 5: Download OAuth Credentials

1. Click the download icon (⬇) next to your newly created OAuth client
2. Save the file as `gcp-oauth.keys.json`
3. The file should look like:

```json
{
  "installed": {
    "client_id": "YOUR-CLIENT-ID.apps.googleusercontent.com",
    "project_id": "your-project-id",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_secret": "YOUR-CLIENT-SECRET",
    "redirect_uris": ["http://localhost"]
  }
}
```

## Step 6: Install OAuth Credentials

Copy the credentials file to both MCP server directories:

```bash
# For Gmail MCP
cp gcp-oauth.keys.json /mnt/user/appdata/mcp-suite/gmail/credentials/

# For Google Drive MCP
cp gcp-oauth.keys.json /mnt/user/appdata/mcp-suite/gdrive/credentials/
```

## Step 7: Restart MCP Containers

Restart the containers to pick up the credentials:

```bash
docker restart gmail-mcp-proxy
docker restart gdrive-mcp-proxy
```

Wait 30 seconds for containers to fully start.

## Step 8: Complete Gmail OAuth Flow

1. Open your web browser
2. Navigate to: `http://YOUR-SERVER-IP:3003`
3. You should see an OAuth consent screen
4. Click **Continue** or **Advanced** → **Go to MCP Suite (unsafe)**
   - This warning appears because the app is in testing mode
5. Select your Google account
6. Review permissions:
   - Read, compose, send, and permanently delete email from Gmail
7. Click **Allow**
8. You should see a success message or be redirected

### Verify Gmail OAuth

```bash
docker logs gmail-mcp-proxy | tail -20
```

Look for messages indicating successful authentication.

## Step 9: Complete Google Drive OAuth Flow

1. Open your web browser
2. Navigate to: `http://YOUR-SERVER-IP:3005`
3. You should see an OAuth consent screen
4. Click **Continue** or **Advanced** → **Go to MCP Suite (unsafe)**
5. Select your Google account
6. Review permissions:
   - See, edit, create, and delete all Google Drive files
7. Click **Allow**
8. You should see a success message or be redirected

### Verify Google Drive OAuth

```bash
docker logs gdrive-mcp-proxy | tail -20
```

Look for messages indicating successful authentication.

## Testing OAuth

### Test Gmail MCP

Once OAuth is complete, the Gmail MCP should be able to access your Gmail:

```bash
# The endpoint should return 200 OK
curl -I http://YOUR-SERVER-IP:3102/sse
```

### Test Google Drive MCP

```bash
# The endpoint should return 200 OK
curl -I http://YOUR-SERVER-IP:3004/sse
```

## Troubleshooting

### "Redirect URI mismatch" Error

**Problem:** OAuth callback fails with redirect URI mismatch.

**Solution:**
1. Go to Google Cloud Console → Credentials
2. Edit your OAuth client
3. Verify all three redirect URIs are added:
   - `http://localhost`
   - `http://YOUR-SERVER-IP:3003/oauth2callback`
   - `http://YOUR-SERVER-IP:3005/oauth2callback`
4. Save and wait 5 minutes for changes to propagate
5. Retry OAuth flow

### "This app isn't verified" Warning

**Problem:** Google shows "This app isn't verified" warning.

**Solution:**
- This is normal for apps in testing mode
- Click **Advanced** → **Go to MCP Suite (unsafe)**
- To remove warning, publish your OAuth consent screen (requires verification)

### OAuth Tokens Not Persisting

**Problem:** OAuth tokens are lost on container restart.

**Solution:**
- Tokens are stored in the container filesystem
- Add volume mounts for token persistence:

```yaml
volumes:
  - /mnt/user/appdata/mcp-suite/gmail/tokens:/root/.gmail-mcp/tokens
  - /mnt/user/appdata/mcp-suite/gdrive/tokens:/root/.gdrive-mcp/tokens
```

### Container Won't Start After Adding Credentials

**Problem:** Container exits immediately after adding OAuth credentials.

**Solution:**
1. Check file permissions:
   ```bash
   chmod 644 /mnt/user/appdata/mcp-suite/gmail/credentials/gcp-oauth.keys.json
   chmod 644 /mnt/user/appdata/mcp-suite/gdrive/credentials/gcp-oauth.keys.json
   ```
2. Verify JSON syntax:
   ```bash
   cat /mnt/user/appdata/mcp-suite/gmail/credentials/gcp-oauth.keys.json | python -m json.tool
   ```
3. Check container logs:
   ```bash
   docker logs gmail-mcp-proxy
   ```

### "credentials.json not found" Error

**Problem:** MCP server can't find credentials file.

**Solution:**
- Ensure filename is exactly `gcp-oauth.keys.json`
- Check the file is in the correct directory
- Verify volume mount in compose file
- Restart container after adding file

### OAuth Flow Redirects to Wrong URL

**Problem:** After OAuth consent, redirected to wrong URL.

**Solution:**
1. Check that redirect URIs in Google Cloud Console match your server IP
2. Ensure containers are listening on OAuth callback ports (3003, 3005)
3. Check firewall rules allow access to these ports

## OAuth Scopes

### Gmail MCP Scopes
- `https://www.googleapis.com/auth/gmail.modify`
- `https://www.googleapis.com/auth/gmail.send`

### Google Drive MCP Scopes
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`

## Security Notes

1. **Keep credentials secure:** Never commit `gcp-oauth.keys.json` to version control
2. **Use test users:** Add only trusted users to the OAuth consent screen test users list
3. **Rotate secrets:** Periodically regenerate OAuth client secrets
4. **Monitor usage:** Check Google Cloud Console for API usage

## Publishing Your App (Optional)

To remove the "unverified app" warning:

1. Go to **APIs & Services** → **OAuth consent screen**
2. Click **PUBLISH APP**
3. Submit for verification (requires domain ownership)
4. Wait for Google approval (can take weeks)

**Note:** For personal use, staying in testing mode is fine.

## Next Steps

Once OAuth is complete:
1. Test Gmail MCP: Search emails, send messages
2. Test Drive MCP: List files, create documents
3. Integrate MCPs with your applications

## Support

- **Google OAuth Documentation:** https://developers.google.com/identity/protocols/oauth2
- **Gmail API:** https://developers.google.com/gmail/api
- **Drive API:** https://developers.google.com/drive/api
- **GitHub Issues:** https://github.com/Twine2546/mcp-suite-unraid/issues
