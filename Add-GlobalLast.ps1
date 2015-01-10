#requires -version 2.0

[CmdletBinding()]
param
(
    [switch] $Install
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

trap { throw $Error[0] }

if ($Install)
{
    if (-not (Test-Path $PROFILE))
    {
        New-Item -Path $PROFILE -ItemType File -Force
    }

    $profileDir = $PROFILE | Split-Path

    Copy-Item -Path "$(PSScriptRoot)\Add-GlobalLast.ps1" -Destination $profileDir -Force

    $installLine = ". `"$profileDir\Add-GlobalLast.ps1`""

    if (-not (Get-Content -Path $PROFILE | Where-Object -FilterScrip{ $_ -eq $installLine }))
    {
        Add-Content -Path $PROFILE -Value $installLine
    }

    . $PROFILE

    return
}

function Generate-CmdletWrapper
{
    param
    (
        [string] $CmdletName,
        [ScriptBlock] $Begin,
        [ScriptBlock] $Process,
        [ScriptBlock] $End
    )

    $command = Get-Command -Name $CmdletName -CommandType Cmdlet
    $metadata = New-Object -TypeName System.Management.Automation.CommandMetaData -ArgumentList @($command)

    $functionText = [System.Management.Automation.ProxyCommand]::Create($metadata)
    $functionText = $functionText -replace "begin\s*\{\s*try\s*\{", ("`$0`n" + ("$Begin" -replace '\$', '$$$$'))
    $functionText = $functionText -replace "process\s*\{\s*try\s*\{", ("`$0`n" + ("$Process" -replace '\$', '$$$$'))
    $functionText = $functionText -replace "end\s*\{\s*try\s*\{", ("`$0`n" + ("$End" -replace '\$', '$$$$'))

    Set-Item -Path "Function:Global:$CmdletName" -Value $functionText
}

Get-Command -Verb Format -Module Microsoft.PowerShell.Utility | `
    Select -ExpandProperty Name | `
    ForEach-Object -Process `
        {
            Generate-CmdletWrapper `
                -CmdletName $_ `
                -Begin `
                    {
                        $tempLast = @()
                    } `
                -Process `
                    {
                        $tempLast += @(, $_)
                    } `
                -End `
                    {
                        if ($tempLast.Length -eq 1)
                        {
                            $Global:LastResult = $tempLast[0]
                        }
                        else
                        {
                            $Global:LastResult = $tempLast
                        }

                        $Global:LastResultCmdletWasFormat = $true
                    }
        }

Generate-CmdletWrapper `
    -CmdletName Out-Default `
    -Begin `
        {
            $tempLast = @()
        } `
    -Process `
        {
            $tempLast += @(, $_)
        } `
    -End `
        {
            if ((Test-Path Variable:Global:LastResultCmdletWasFormat) -and ($Global:LastResultCmdletWasFormat))
            {
                $Global:LastResultCmdletWasFormat = $false
            }
            elseif ($tempLast.Length -eq 1)
            {
                $Global:LastResult = $tempLast[0]
            }
            else
            {
                $Global:LastResult = $tempLast
            }
        }