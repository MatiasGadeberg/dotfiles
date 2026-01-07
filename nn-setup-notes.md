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
