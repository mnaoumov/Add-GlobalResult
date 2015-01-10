﻿#requires -version 2.0

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

# should write to host immediately
# don't know how to test it
1..10 | % { sleep 1; $_ } | Out-Default

Get-Process -Name explorer | Out-Default
if ($Global:LAST -isnot [System.Diagnostics.Process])
{
    throw "`$Global:LAST extected to be System.Diagnostics.Process, actual: $($Global:LAST.GetType())"
}

$null | Out-Default

if ($Global:LAST -ne $null)
{
    throw "`$Global:LAST extected to be null, actual: $$Global:LAST"
}

@() | Out-Default

if ($Global:LAST -ne @())
{
    throw "`$Global:LAST extected to be @(), actual: $$Global:LAST"
}