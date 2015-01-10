# Add Out-Default function to $PROFILE script

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
        if ($tempLast.Length -eq 1)
        {
            $Global:LAST = $tempLast[0]
        }
        else
        {
            $Global:LAST = $tempLast
        }
    }
}