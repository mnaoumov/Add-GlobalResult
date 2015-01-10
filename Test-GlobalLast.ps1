#requires -version 2.0

[CmdletBinding()]
param
(
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

trap { throw $Error[0] }

if (Test-Path Function:\Out-Default)
{
    Remove-Item -Path Function:\Out-Default
}

if (Test-Path Variable:\LAST)
{
    Remove-Item -Path Variable:\LAST
}

. "$(PSScriptRoot)\GlobalLast.ps1"

42 | Out-Default

if ($Global:LastResult -ne 42)
{
    throw "`$Global:LastResult extected to be 42, actual: $Global:LastResult"
}

1..10 | Out-Default

if (Compare-Object $Global:LastResult (1..10))
{
    throw "`$Global:LastResult extected to be 1..10, actual: $Global:LastResult"
}

@(@(1, 2), @(3, 4)) | Out-Default

if (Compare-Object $Global:LastResult @(@(1, 2), @(3, 4)))
{
    throw "`$Global:LastResult extected to be @(@(1, 2), @(3, 4)), actual: $Global:LastResult"
}

# should write to host immediately
# don't know how to test it
1..10 | % { sleep 1; $_ } | Out-Default

Get-Process -Name explorer | Out-Default
if ($Global:LastResult -isnot [System.Diagnostics.Process])
{
    throw "`$Global:LastResult extected to be System.Diagnostics.Process, actual: $($Global:LastResult.GetType())"
}

$null | Out-Default

if ($Global:LastResult -ne $null)
{
    throw "`$Global:LastResult extected to be null, actual: $$Global:LastResult"
}

@() | Out-Default

if ($Global:LastResult -ne @())
{
    throw "`$Global:LastResult extected to be @(), actual: $$Global:LastResult"
}

Get-Process -Name explorer | Format-List | Out-Default
if ($Global:LastResult -isnot [System.Diagnostics.Process])
{
    throw "`$Global:LastResult extected to be System.Diagnostics.Process, actual: $($Global:LastResult.GetType())"
}

Get-Process | Format-Table | Out-Default
if (($Global:LastResult -isnot [Array]) -or ($Global:LastResult[0] -isnot [System.Diagnostics.Process]))
{
    throw "`$Global:LastResult extected to be System.Diagnostics.Process, actual: $($Global:LastResult.GetType())"
}
