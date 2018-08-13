#Requires -RunAsAdministrator
$solrHost = "dockersolr"
$solrName = "solr-6.6.2"
$staticIp = "172.16.238.10"

Write-Host "Creating & trusting an new SSL Cert for $solrHost"

# Generate a cert
# https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=win10-ps
$cert = New-SelfSignedCertificate -FriendlyName "$solrName" -DnsName "$solrHost" -CertStoreLocation "cert:\LocalMachine" -NotAfter (Get-Date).AddYears(10)

# Trust the cert
# https://stackoverflow.com/questions/8815145/how-to-trust-a-certificate-in-windows-powershell
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root","LocalMachine"
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

$pass = ConvertTo-SecureString -String "secret" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -Password $pass -FilePath .\solr-ssl.keystore.pfx -Force

# remove the untrusted copy of the cert
$cert | Remove-Item

$hostsPath = "$env:windir\System32\drivers\etc\hosts"
Add-Content -Path $hostsPath -Value "$staticIp  $solrHost"

Write-Host "Solr will be running at https://$($solrHost):8983 once docker-compose completes." -ForegroundColor Green

docker-compose up --build