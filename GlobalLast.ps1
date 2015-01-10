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
        $sb = { & $wrappedCmdlet @PSBoundParameters }
        $__sp = $sb.GetSteppablePipeline()
        $__sp.Begin($PScmdlet)
        $tempLast = @()
    }
    process
    {
        $tempLast += @(, $_)
        $__sp.Process($_)
    }
    end
    {
        $__sp.End()
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