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
        $__sp.Begin($pscmdlet)
    }
    process
    {
        $do_process = $true
        if ($_ -is [System.Management.Automation.ErrorRecord])
        {
            if ($_.Exception -is [System.Management.Automation.CommandNotFoundException])
            {
                $__command = $_.Exception.CommandName
                if (Test-Path -Path $__command -PathType container)
                {
                    Set-Location $__command
                    $do_process = $false
                }
                elseif ($__command -match '^http://|\.(com|org|net|edu)$')
                {
                    if ($matches[0] -ne "http://")
                    {
                        $__command = "HTTP://" + $__command
                    }

                    [System.Diagnostics.Process]::Start($__command)
                    $do_process = $false
                }
            }
        }
        if ($do_process)
        {
            $global:LAST = $_;
            $__sp.Process($_)
        }
    }
    end
    {
        $__sp.End()
    }
}