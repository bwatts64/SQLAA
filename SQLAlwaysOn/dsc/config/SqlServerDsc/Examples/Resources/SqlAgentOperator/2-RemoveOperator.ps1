<#
    .EXAMPLE
        This example shows how to ensure that the SQL Agent Operator
        DbaTeam does not exist.
#>

Configuration Example
{

    Import-DscResource -ModuleName SqlServerDsc

    node localhost {
        SqlAgentOperator Remove_DbaTeam {
            Ensure               = 'Absent'
            Name                 = 'DbaTeam'
            ServerName           = 'TestServer'
            InstanceName         = 'MSSQLServer'
        }
    }
}
