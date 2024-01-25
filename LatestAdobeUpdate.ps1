# Name: LatestAdobeUpdate
# Description: Scrape the Adobe update site to get the latest package for updating. 
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://github.com/Action1Corp/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# LIMITATION OF LIABILITY. IN NO EVENT SHALL ACTION1 OR ITS SUPPLIERS, OR THEIR RESPECTIVE 
# OFFICERS, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE WITH RESPECT TO THE WEBSITE OR
# THE COMPONENTS OR THE SERVICES UNDER ANY CONTRACT, NEGLIGENCE, TORT, STRICT 
# LIABILITY OR OTHER LEGAL OR EQUITABLE THEORY (I)FOR ANY AMOUNT IN THE AGGREGATE IN
# EXCESS OF THE GREATER OF FEES PAID BY YOU THEREFOR OR $100; (II) FOR ANY INDIRECT,
# INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY KIND WHATSOEVER; (III) FOR
# DATA LOSS OR COST OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; OR (IV) FOR ANY
# MATTER BEYOND ACTION1'S REASONABLE CONTROL. SOME STATES DO NOT ALLOW THE
# EXCLUSION OR LIMITATION OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE
# LIMITATIONS AND EXCLUSIONS MAY NOT APPLY TO YOU.

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