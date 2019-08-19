<#
.EXAMPLE
    This example shows how to ensure the SQL Server service
    on TestServer is running under a user account.
#>

Configuration Example
{
    param(
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $ServiceAccountCredential
    )

    Import-DscResource -ModuleName SqlServerDsc

    Node localhost {
        SqlServiceAccount SetServiceAcccount_User
        {
            ServerName     = 'TestServer'
            InstanceName   = 'MSSQLSERVER'
            ServiceType    = 'DatabaseEngine'
            ServiceAccount = $ServiceAccountCredential
            RestartService = $true
        }
    }
}
