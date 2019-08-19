<#
.EXAMPLE
    This example will remove an Availability Group listener with a different name than cluster role VCO.
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
        SqlAGListener RemoveAvailabilityGroupListenerWithDifferentNameAsVCO
        {
            Ensure               = 'Absent'
            ServerName           = 'SQLNODE01.company.local'
            InstanceName         = 'MSSQLSERVER'
            AvailabilityGroup    = 'AvailabilityGroup-01'
            Name                 = 'AG-01'

            PsDscRunAsCredential = $SqlAdministratorCredential
        }
    }
}
