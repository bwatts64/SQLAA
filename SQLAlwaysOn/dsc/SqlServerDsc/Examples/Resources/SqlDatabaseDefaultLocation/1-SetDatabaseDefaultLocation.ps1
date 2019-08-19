<#
.EXAMPLE
    This example shows how to manage database default locations for Data, Logs, and Backups for SQL Server.

    In the event this is applied to a Failover Cluster Instance (FCI), the
    ProcessOnlyOnActiveNode property will tell the Test-TargetResource function
    to evaluate if any changes are needed if the node is actively hosting the
    SQL Server Instance.
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
        SqlDatabaseDefaultLocation Set_SqlDatabaseDefaultDirectory_Data
        {
            ServerName              = 'sqltest.company.local'
            InstanceName            = 'DSC'
            ProcessOnlyOnActiveNode = $true
            Type                    = 'Data'
            Path                    = 'C:\Program Files\Microsoft SQL Server'
            PsDscRunAsCredential    = $SqlAdministratorCredential
        }

        SqlDatabaseDefaultLocation Set_SqlDatabaseDefaultDirectory_Log
        {
            ServerName              = 'sqltest.company.local'
            InstanceName            = 'DSC'
            ProcessOnlyOnActiveNode = $true
            Type                    = 'Log'
            Path                    = 'C:\Program Files\Microsoft SQL Server'
            PsDscRunAsCredential    = $SqlAdministratorCredential
        }

        SqlDatabaseDefaultLocation Set_SqlDatabaseDefaultDirectory_Backup
        {
            ServerName              = 'sqltest.company.local'
            InstanceName            = 'DSC'
            ProcessOnlyOnActiveNode = $true
            Type                    = 'Backup'
            Path                    = 'C:\Program Files\Microsoft SQL Server'
            PsDscRunAsCredential    = $SqlAdministratorCredential
        }
    }
}
