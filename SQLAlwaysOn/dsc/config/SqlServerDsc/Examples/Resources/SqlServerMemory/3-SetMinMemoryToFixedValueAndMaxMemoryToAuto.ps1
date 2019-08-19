<#
.EXAMPLE
    This example shows how to set the minimum memory to 2GB and the maximum memory
    configuration option with the automatic configuration.
#>
Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SqlAdministratorCredential
    )

    Import-DscResource -ModuleName SqlServerDsc

    node localhost
    {
        SqlServerMemory Set_SQLServerMinAndMaxMemory_ToAuto
        {
            Ensure               = 'Present'
            DynamicAlloc         = $true
            ServerName           = 'sqltest.company.local'
            InstanceName         = 'DSC'
            MinMemory            = 2048
            PsDscRunAsCredential = $SqlAdministratorCredential
        }
    }
}
