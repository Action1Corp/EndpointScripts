# Name: LatestAdobeUpdate.ps1
# Description: Scrape the Adobe update site to get the latest package for updating. 

# Documentation: https://github.com/Action1Corp/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

function Get-LatestAdobeVersion{
        $data = Invoke-WebRequest -UseBasicParsing -Uri "https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html" `
        -Headers @{
        "authority"="www.adobe.com"
          "method"="GET"
          "path"="/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html"
          "scheme"="https"
          "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
          "accept-encoding"="gzip, deflate, br"
          "accept-language"="en-US,en;q=0.9"
          "cache-control"="no-cache"
          "pragma"="no-cache"
          "sec-ch-ua"="`"Not_A Brand`";v=`"8`", `"Chromium`";v=`"120`", `"Google Chrome`";v=`"120`""
          "sec-ch-ua-mobile"="?0"
          "sec-ch-ua-platform"="`"Windows`""
          "sec-fetch-dest"="document"
          "sec-fetch-mode"="navigate"
          "sec-fetch-site"="none"
          "sec-fetch-user"="?1"
          "upgrade-insecure-requests"="1"
        }

    $cv = [regex]::Match(($data.Links -match "<a href=`"continuous.*title=`"").title,'\b\d{2}\.\d{3}\.\d{5}\b')[0]
    if($cv.Success){
        $cv=$cv.Value
           return $cv
        }else{
            Write-Host "error retrieving current version informaiton."
            return $null
        }
}

function Get-AdobeDownloadURL {
      param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("x86", "x64")]
        [string]$Architecture
      )
  $A=''
  if($Architecture -eq 'x64'){$A='x64'}
  $v = Get-LatestAdobeVersion
  Write-Host ("Lastest version is: {0}" -f $v)
  if ($v){
    return "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/{1}/AcrobatDC{0}Upd{1}.msp" -f $A, $v.Replace('.','')
  }
}

function Get-LatestAdobePackage {
      param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [ValidateSet("x86", "x64")]
        [string]$Architecture
        )
        Try {
            Invoke-WebRequest -Uri (Get-AdobeDownloadURL -Architecture $Architecture) -OutFile $Path
            Write-Host ("Complete, saved as: {0}" -f $Path)
            return $true
        }
        Catch{
            Write-Host ("Error retrieving package: {0}" -f $_.Message)
            return $false
        }
}