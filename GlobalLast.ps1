#requires -version 2.0

[CmdletBinding()]
param
(
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

trap { throw $Error[0] }

function Generate-FormatCmdlet
{
    param
    (
        [string] $CmdletName
    )

    $command = Get-Command -Name $CmdletName -CommandType Cmdlet
    $metadata = New-Object -TypeName System.Management.Automation.CommandMetaData -ArgumentList @($command)

    $functionText = [System.Management.Automation.ProxyCommand]::Create($metadata)
    $functionText = $functionText -replace "begin\s*\{\s*try\s*\{", ("`$0`n" +
@'
$tempLast = @()
'@)
    $functionText = $functionText -replace "process\s*\{\s*try\s*\{", ("`$0`n" +
@'
$tempLast += @(, $$_)
'@)
    $functionText = $functionText -replace "end\s*\{\s*try\s*\{", ("`$0`n" +
@'
        if ($tempLast.Length -eq 1)
        {
            $Global:LastResult = $tempLast[0]
        }
        else
        {
            $Global:LastResult = $tempLast
        }

        $Global:LastResultCmdletWasFormat = $true
'@)

    Set-Item -Path "Function:Global:$CmdletName" -Value $functionText
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

Generate-FormatCmdlet -CmdletName Format-List

