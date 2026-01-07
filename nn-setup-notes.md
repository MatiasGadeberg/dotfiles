# Exporting Zscaler root certificate and setting in WSL distro
Export the zscaler certificate, which we need to transfer to Ubuntu:

```powershell
$cert = Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object {$_.Subject -like "*Zscaler*"}

Export-Certificate -Cert $cert -FilePath "C:\tmp-wsl-install\ZscalerRootCertificate.crt" -Type CERT
```

Now import and update in Ubuntu WSL

```bash
sudo mkdir -p /usr/local/share/ca-certificates

sudo cp /mnt/c/tmp-wsl-install/ZscalerRootCertificate.crt /usr/local/share/ca-certificates/ZscalerRootCertificate.crt

sudo openssl x509 -in /usr/local/share/ca-certificates/ZscalerRootCertificate.crt -out /usr/local/share/ca-certificates/ZscalerRootCertificate.crt -outform PEM

sudo update-ca-certificates
```

Cleanup in powershell:
```powershell
rm C:\tmp-wsl-install
```

# Setup Claude code integration:
Setup script installs claude code already - just need to add this to ~/.claude/settings.json:

```json
{
  "env": {
      "ANTHROPIC_AUTH_TOKEN": "<Add your token>",
      "ANTHROPIC_BASE_URL": "https://api.marketplace.novo-genai.com",
      "ANTHROPIC_MODEL": "anthropic_claude_sonnet_4_v1_0",
      "ANTHROPIC_SMALL_FAST_MODEL": "anthropic_claude_haiku_4_5_v1_0",
      "ANTHROPIC_DEFAULT_OPUS_MODEL": "anthropic_claude_opus_4_v1_0",
      "ANTHROPIC_DEFAULT_SONNET_MODEL": "anthropic_claude_sonnet_4_v1_0",
      "ANTHROPIC_DEFAULT_HAIKU_MODEL": "anthropic_claude_haiku_4_5_v1_0",
      "CLAUDE_CODE_SUBAGENT_MODEL": "anthropic_claude_sonnet_4_v1_0",
      "DISABLE_TELEMETRY": "1"
  },
      "companyAnnouncements": [
       "▄▖▄▖  ▖  ▖    ▌   ▗   ▜       \n▌▌▐   ▛▖▞▌▀▌▛▘▙▘█▌▜▘▛▌▐ ▀▌▛▘█▌\n▛▌▟▖  ▌▝ ▌█▌▌ ▛▖▙▖▐▖▙▌▐▖█▌▙▖▙▖\n                    ▌         \nWelcome to the AI Marketplace Claude Code integration!\nYou are using safe, internally approved models in this session.\nRemember to update to our latest models! Check for news at:\nhttps://marketplace.novo-genai.com/model/model-cards/"
   ]
}
```

