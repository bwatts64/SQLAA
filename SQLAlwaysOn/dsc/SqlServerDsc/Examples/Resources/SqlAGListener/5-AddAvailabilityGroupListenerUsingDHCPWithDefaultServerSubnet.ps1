<#
.EXAMPLE
    This example will add an Availability Group listener using DHCP on the default server subnet.
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
        SqlAGListener AvailabilityGroupListenerWithSameNameAsVCO
        {
            Ensure               = 'Present'
            ServerName           = 'SQLNODE01.company.local'
            InstanceName         = 'MSSQLSERVER'
            AvailabilityGroup    = 'AG-01'
            Name                 = 'AG-01'
            DHCP                 = $true    # Also not specifying parameter DHCP will default to using DHCP with the default server subnet.
            Port                 = 5301

            PsDscRunAsCredential = $SqlAdministratorCredential
        }
    }
}
