<#
.EXAMPLE
    This example shows how to create a database with
    the database name equal to 'Contoso'.

    The second example shows how to create a database
    with a different collation.
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
        SqlDatabase Create_Database
        {
            Ensure       = 'Present'
            ServerName   = 'sqltest.company.local'
            InstanceName = 'DSC'
            Name         = 'Contoso'

            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        SqlDatabase Create_Database_with_different_collation
        {
            Ensure       = 'Present'
            ServerName   = 'sqltest.company.local'
            InstanceName = 'DSC'
            Name         = 'AdventureWorks'
            Collation    = 'SQL_Latin1_General_Pref_CP850_CI_AS'

            PsDscRunAsCredential = $SqlAdministratorCredential
        }
    }
}
