<#
.EXAMPLE
    This example shows how to ensure that the user account CONTOSO\SQLAdmin
    is not member of the "DeleteRole" SQL database role.
#>
Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SysAdminAccount
    )

    Import-DscResource -ModuleName SqlServerDsc

    node localhost
    {
        SqlDatabaseRole Remove_Database_Role
        {
            Ensure               = 'Absent'
            ServerName           = 'sqltest.company.local'
            InstanceName         = 'DSC'
            Name                 = 'CONTOSO\SQLAdmin'
            Role                 = 'DeleteRole'
            Database             = 'AdventureWorks'
            PsDscRunAsCredential = $SysAdminAccount
        }
    }
}
