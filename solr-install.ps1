Param(
    $solrVersion = "6.6.2",
    $installFolder = "c:\solr",
    $solrPort = "8983",
    $solrHost = "dockersolr",
    $solrSSL = $true,
    $nssmVersion = "2.24",
    $JREVersion = "1.8.0_91"
)

$JREPath = "C:\Java\jre$JREVersion" ## Note that if you're running 32bit java, you will need to change this path
$solrName = "solr-$solrVersion"
$solrRoot = "$installFolder\$solrName"
$solrPackage = "https://archive.apache.org/dist/lucene/solr/$solrVersion/$solrName.zip"
$downloadFolder = "~\Downloads"

## Verify elevated
## https://superuser.com/questions/749243/detect-if-powershell-is-running-as-administrator
$elevated = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
if($elevated -eq $false)
{
    throw "In order to install services, please run this script elevated."
}

function downloadAndUnzipIfRequired
{
    Param(
        [string]$toolName,
        [string]$toolFolder,
        [string]$toolZip,
        [string]$toolSourceFile,
        [string]$installRoot
    )

    if(!(Test-Path -Path $toolFolder))
    {
        if(!(Test-Path -Path $toolZip))
        {
            Write-Host "Downloading $toolName..."
            Start-BitsTransfer -Source $toolSourceFile -Destination $toolZip
        }

        Write-Host "Extracting $toolName to $toolFolder..."
        Expand-Archive $toolZip -DestinationPath $installRoot
    }
}
# download & extract the solr archive to the right folder
$solrZip = "$downloadFolder\$solrName.zip"
downloadAndUnzipIfRequired "Solr" $solrRoot $solrZip $solrPackage $installFolder

# Ensure Java environment variable
$jreVal = [Environment]::GetEnvironmentVariable("JAVA_HOME", [EnvironmentVariableTarget]::Machine)
if($jreVal -ne $JREPath)
{
    Write-Host "Setting JAVA_HOME environment variable"
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $JREPath, [EnvironmentVariableTarget]::Machine)
}

# Ensure the solr host name is in your hosts file
if($solrHost -ne "localhost")
{
    $hostFileName = "c:\\windows\system32\drivers\etc\hosts"
    $hostFile = [System.Io.File]::ReadAllText($hostFileName)
    if(!($hostFile -like "*$solrHost*"))
    {
        Write-Host "Updating host file"
        "`r`n127.0.0.1`t$solrHost" | Add-Content $hostFileName
    }
}

Write-Host "Exporting cert for Solr to use"
Copy-Item ".\solr-ssl.keystore.pfx" "$solrRoot\server\etc\solr-ssl.keystore.pfx"
$certStore = "$solrRoot\server\etc\solr-ssl.keystore.pfx"


$cfg = Get-Content "$solrRoot\bin\solr.in.cmd"
Rename-Item "$solrRoot\bin\solr.in.cmd" "$solrRoot\bin\solr.in.cmd.old"
$newCfg = $cfg | % { $_ -replace "REM set SOLR_SSL_KEY_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_KEY_STORE=$certStore" }
$newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_KEY_STORE_PASSWORD=secret", "set SOLR_SSL_KEY_STORE_PASSWORD=secret" }
$newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_TRUST_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_TRUST_STORE=$certStore" }
$newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_TRUST_STORE_PASSWORD=secret", "set SOLR_SSL_TRUST_STORE_PASSWORD=secret" }
$newCfg = $newCfg | % { $_ -replace "REM set SOLR_HOST=192.168.1.1", "set SOLR_HOST=$solrHost" }
$newCfg | Set-Content "$solrRoot\bin\solr.in.cmd"
