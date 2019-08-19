<#
.EXAMPLE
    This example shows how to do the following:

    1. Ensure that the database role named ReportViewer is present in the AdventureWorks database on instance
       sqltest.company.local\DSC
    2. Ensure that users CONTOSO\Barbara and CONTOSO\Fred will always be members of the role
    3. Ensure that the user CONSOSO\Intern1 will never be a member of the role
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
        SqlDatabaseRole ReportViewer_IncludeAndExcludeRoleMembers
        {
            ServerName           = 'sqltest.company.local'
            InstanceName         = 'DSC'
            Database             = 'AdventureWorks'
            Name                 = 'ReportViewer'
            MembersToInclude     = @('CONTOSO\Barbara', 'CONTOSO\Fred')
            MembersToExclude     = @('CONTOSO\Intern1')
            Ensure               = 'Present'
            PsDscRunAsCredential = $SqlAdministratorCredential
        }
    }
}
