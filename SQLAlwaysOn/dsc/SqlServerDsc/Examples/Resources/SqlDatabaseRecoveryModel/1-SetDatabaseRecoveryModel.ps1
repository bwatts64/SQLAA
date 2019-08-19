<#
.EXAMPLE
    This example shows how to set the Recovery Model
    to "Full" for SQL database "AdventureWorks".
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
        SqlDatabase Add_SqlDatabaseAdventureworks
        {
            Ensure               = 'Present'
            Name                 = 'Adventureworks'
            ServerName           = 'sqltest.company.local'
            InstanceName         = 'DSC'
            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        SqlDatabase Add_SqlDatabaseAdventureWorks2012
        {
            Ensure               = 'Present'
            Name                 = 'AdventureWorks2012'
            ServerName           = 'sqltest.company.local'
            InstanceName         = 'DSC'
            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        SqlDatabaseRecoveryModel Set_SqlDatabaseRecoveryModel_Adventureworks
        {
            Name                 = 'Adventureworks'
            RecoveryModel        = 'Full'
            ServerName           = 'sqltest.company.local'
            InstanceName         = 'DSC'
            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        SqlDatabaseRecoveryModel Set_SqlDatabaseRecoveryModel_AdventureWorks2012
        {
            Name                 = 'AdventureWorks2012'
            RecoveryModel        = 'Simple'
            ServerName           = 'sqltest.company.local'
            InstanceName         = 'DSC'
            PsDscRunAsCredential = $SqlAdministratorCredential
        }
    }
}
