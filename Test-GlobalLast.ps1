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

if ($Global:LAST -ne 42)
{
    throw "`$Global:LAST extected to be 42, actual: $Global:LAST"
}

1..10 | Out-Default

if (Compare-Object $Global:LAST (1..10))
{
    throw "`$Global:LAST extected to be 1..10, actual: $Global:LAST"
}

@(@(1, 2), @(3, 4)) | Out-Default

if (Compare-Object $Global:LAST @(@(1, 2), @(3, 4)))
{
    throw "`$Global:LAST extected to be @(@(1, 2), @(3, 4)), actual: $Global:LAST"
}
