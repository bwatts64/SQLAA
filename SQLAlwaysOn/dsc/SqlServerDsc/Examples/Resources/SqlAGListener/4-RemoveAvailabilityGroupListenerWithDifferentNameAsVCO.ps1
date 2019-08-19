<#
.EXAMPLE
    This example will remove an Availability Group listener with the same name as the cluster role VCO.
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
        SqlAGListener RemoveAvailabilityGroupListenerWithSameNameAsVCO
        {
            Ensure               = 'Absent'
            ServerName           = 'SQLNODE01.company.local'
            InstanceName         = 'MSSQLSERVER'
            AvailabilityGroup    = 'AG-01'
            Name                 = "AG-01"

            PsDscRunAsCredential = $SqlAdministratorCredential
        }
    }
}
