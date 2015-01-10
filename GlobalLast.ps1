#requires -version 2.0

[CmdletBinding()]
param
(
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

trap { throw $Error[0] }

# Add Out-Default function to $PROFILE script

function Format-List
{
[CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113302')]
param(
    [Parameter(ValueFromPipeline=$true)]
    [psobject]
    ${InputObject},

    [Parameter(Position=0)]
    [System.Object[]]
    ${Property},

    [System.Object]
    ${GroupBy},

    [string]
    ${View},

    [switch]
    ${ShowError},

    [switch]
    ${DisplayError},

    [switch]
    ${Force},

    [ValidateSet('CoreOnly','EnumOnly','Both')]
    [string]
    ${Expand})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Format-List', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
        $tempLast = @()
    } catch {
        throw
    }
}

process
{
    try {
        $tempLast += @(, $_)
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
        if ($tempLast.Length -eq 1)
        {
            $Global:LastResult = $tempLast[0]
        }
        else
        {
            $Global:LastResult = $tempLast
        }

        $Global:LastResultCmdletWasFormat = $true

    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Format-List
.ForwardHelpCategory Cmdlet

#>


}

function Out-Default
{
    [CmdletBinding(ConfirmImpact = "Medium")]
    param
    (
       [Parameter(ValueFromPipeline = $true)]
       [System.Management.Automation.PSObject] $InputObject
    )

    begin
    {
        $wrappedCmdlet = $ExecutionContext.InvokeCommand.GetCmdlet("Out-Default")
        $scriptBlock = { & $wrappedCmdlet @PSBoundParameters }
        $steppablePipeline = $scriptBlock.GetSteppablePipeline()
        $steppablePipeline.Begin($PScmdlet)
        $tempLast = @()

    }
    process
    {
        $tempLast += @(, $_)
        $steppablePipeline.Process($_)
    }
    end
    {
        $steppablePipeline.End()

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
}