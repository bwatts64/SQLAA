Import-Module -Name (Join-Path -Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) `
        -ChildPath 'SqlServerDscHelper.psm1') `
    -Force

<#
    .SYNOPSIS
        Gets the SQL Reporting Services initialization status.

    .PARAMETER InstanceName
        Name of the SQL Server Reporting Services instance to be configured.

    .PARAMETER DatabaseServerName
        Name of the SQL Server to host the Reporting Service database.

    .PARAMETER DatabaseInstanceName
        Name of the SQL Server instance to host the Reporting Service database.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseServerName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseInstanceName
    )

    $reportingServicesData = Get-ReportingServicesData -InstanceName $InstanceName

    if ( $null -ne $reportingServicesData.Configuration )
    {
        if ( $reportingServicesData.Configuration.DatabaseServerName.Contains('\') )
        {
            $DatabaseServerName = $reportingServicesData.Configuration.DatabaseServerName.Split('\')[0]
            $DatabaseInstanceName = $reportingServicesData.Configuration.DatabaseServerName.Split('\')[1]
        }
        else
        {
            $DatabaseServerName = $reportingServicesData.Configuration.DatabaseServerName
            $DatabaseInstanceName = 'MSSQLSERVER'
        }

        $isInitialized = $reportingServicesData.Configuration.IsInitialized

        if ( $isInitialized )
        {
            $reportServerVirtualDirectory = $reportingServicesData.Configuration.VirtualDirectoryReportServer
            $reportsVirtualDirectory = $reportingServicesData.Configuration.VirtualDirectoryReportManager

            $reservedUrls = $reportingServicesData.Configuration.ListReservedUrls()

            $reportServerReservedUrl = @()
            $reportsReservedUrl = @()

            for ( $i = 0; $i -lt $reservedUrls.Application.Count; ++$i )
            {
                if ( $reservedUrls.Application[$i] -eq 'ReportServerWebService' )
                {
                    $reportServerReservedUrl += $reservedUrls.UrlString[$i]
                }

                if ( $reservedUrls.Application[$i] -eq $reportingServicesData.ReportsApplicationName )
                {
                    $reportsReservedUrl += $reservedUrls.UrlString[$i]
                }
            }
        }
        else
        {
            <#
                Make sure the value returned is false, if the value returned was
                either empty, $null or $false. Fic for issue #822.
            #>
            [System.Boolean] $isInitialized = $false
        }
    }
    else
    {
        throw New-TerminatingError -ErrorType SSRSNotFound -FormatArgs @($InstanceName) -ErrorCategory ObjectNotFound
    }

    return @{
        InstanceName                 = $InstanceName
        DatabaseServerName           = $DatabaseServerName
        DatabaseInstanceName         = $DatabaseInstanceName
        ReportServerVirtualDirectory = $reportServerVirtualDirectory
        ReportsVirtualDirectory      = $reportsVirtualDirectory
        ReportServerReservedUrl      = $reportServerReservedUrl
        ReportsReservedUrl           = $reportsReservedUrl
        IsInitialized                = $isInitialized
    }
}

<#
    .SYNOPSIS
        Initializes SQL Reporting Services.

    .PARAMETER InstanceName
        Name of the SQL Server Reporting Services instance to be configured.

    .PARAMETER DatabaseServerName
        Name of the SQL Server to host the Reporting Service database.

    .PARAMETER DatabaseInstanceName
        Name of the SQL Server instance to host the Reporting Service database.

    .PARAMETER ReportServerVirtualDirectory
        Report Server Web Service virtual directory. Optional.

    .PARAMETER ReportsVirtualDirectory
        Report Manager/Report Web App virtual directory name. Optional.

    .PARAMETER ReportServerReservedUrl
        Report Server URL reservations. Optional. If not specified, 'http://+:80' URL reservation will be used.

    .PARAMETER ReportsReservedUrl
        Report Manager/Report Web App URL reservations. Optional. If not specified, 'http://+:80' URL reservation will be used.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseServerName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseInstanceName,

        [Parameter()]
        [System.String]
        $ReportServerVirtualDirectory,

        [Parameter()]
        [System.String]
        $ReportsVirtualDirectory,

        [Parameter()]
        [System.String[]]
        $ReportServerReservedUrl,

        [Parameter()]
        [System.String[]]
        $ReportsReservedUrl
    )

    $reportingServicesData = Get-ReportingServicesData -InstanceName $InstanceName

    if ( $null -ne $reportingServicesData.Configuration )
    {
        if ( $InstanceName -eq 'MSSQLSERVER' )
        {
            if ( [string]::IsNullOrEmpty($ReportServerVirtualDirectory) )
            {
                $ReportServerVirtualDirectory = 'ReportServer'
            }

            if ( [string]::IsNullOrEmpty($ReportsVirtualDirectory) )
            {
                $ReportsVirtualDirectory = 'Reports'
            }

            $reportingServicesServiceName = 'ReportServer'
            $reportingServicesDatabaseName = 'ReportServer'
        }
        else
        {
            if ( [string]::IsNullOrEmpty($ReportServerVirtualDirectory) )
            {
                $ReportServerVirtualDirectory = "ReportServer_$InstanceName"
            }

            if ( [string]::IsNullOrEmpty($ReportsVirtualDirectory) )
            {
                $ReportsVirtualDirectory = "Reports_$InstanceName"
            }

            $reportingServicesServiceName = "ReportServer`$$InstanceName"
            $reportingServicesDatabaseName = "ReportServer`$$InstanceName"
        }

        if ( $DatabaseInstanceName -eq 'MSSQLSERVER' )
        {
            $reportingServicesConnection = $DatabaseServerName
        }
        else
        {
            $reportingServicesConnection = "$DatabaseServerName\$DatabaseInstanceName"
        }

        $wmiOperatingSystem = Get-WMIObject -Class Win32_OperatingSystem -Namespace 'root/cimv2' -ErrorAction SilentlyContinue
        if ( $null -eq $wmiOperatingSystem )
        {
            throw 'Unable to find WMI object Win32_OperatingSystem.'
        }

        $language = $wmiOperatingSystem.OSLanguage

        if ( -not $reportingServicesData.Configuration.IsInitialized )
        {
            New-VerboseMessage -Message "Initializing Reporting Services on $DatabaseServerName\$DatabaseInstanceName."

            # If no Report Server reserved URLs have been specified, use the default one.
            if ( $null -eq $ReportServerReservedUrl )
            {
                $ReportServerReservedUrl = @('http://+:80')
            }

            # If no Report Manager/Report Web App reserved URLs have been specified, use the default one.
            if ( $null -eq $ReportsReservedUrl )
            {
                $ReportsReservedUrl = @('http://+:80')
            }

            if ( $reportingServicesData.Configuration.VirtualDirectoryReportServer -ne $ReportServerVirtualDirectory )
            {
                New-VerboseMessage -Message "Setting report server virtual directory on $DatabaseServerName\$DatabaseInstanceName to $ReportServerVirtualDirectory."
                $null = $reportingServicesData.Configuration.SetVirtualDirectory('ReportServerWebService', $ReportServerVirtualDirectory, $language)
                $ReportServerReservedUrl | ForEach-Object -Process {
                    New-VerboseMessage -Message "Adding report server URL reservation on $DatabaseServerName\$DatabaseInstanceName`: $_."
                    $null = $reportingServicesData.Configuration.ReserveURL('ReportServerWebService', $_, $language)
                }
            }

            if ( $reportingServicesData.Configuration.VirtualDirectoryReportManager -ne $ReportsVirtualDirectory )
            {
                New-VerboseMessage -Message "Setting reports virtual directory on $DatabaseServerName\$DatabaseInstanceName to $ReportServerVirtualDirectory."
                $null = $reportingServicesData.Configuration.SetVirtualDirectory($reportingServicesData.ReportsApplicationName, $ReportsVirtualDirectory, $language)
                $ReportsReservedUrl | ForEach-Object -Process {
                    New-VerboseMessage -Message "Adding reports URL reservation on $DatabaseServerName\$DatabaseInstanceName`: $_."
                    $null = $reportingServicesData.Configuration.ReserveURL($reportingServicesData.ReportsApplicationName, $_, $language)
                }
            }

            $reportingServicesDatabaseScript = $reportingServicesData.Configuration.GenerateDatabaseCreationScript($reportingServicesDatabaseName, $language, $false)

            # Determine RS service account
            $reportingServicesServiceAccountUserName = (Get-WmiObject -Class Win32_Service | Where-Object -FilterScript {
                    $_.Name -eq $reportingServicesServiceName
                }).StartName
            $reportingServicesDatabaseRightsScript = $reportingServicesData.Configuration.GenerateDatabaseRightsScript($reportingServicesServiceAccountUserName, $reportingServicesDatabaseName, $false, $true)

            <#
                Import-SQLPSModule cmdlet will import SQLPS (SQL 2012/14) or SqlServer module (SQL 2016),
                and if importing SQLPS, change directory back to the original one, since SQLPS changes the
                current directory to SQLSERVER:\ on import.
            #>
            Import-SQLPSModule
            Invoke-Sqlcmd -ServerInstance $reportingServicesConnection -Query $reportingServicesDatabaseScript.Script
            Invoke-Sqlcmd -ServerInstance $reportingServicesConnection -Query $reportingServicesDatabaseRightsScript.Script

            $null = $reportingServicesData.Configuration.SetDatabaseConnection($reportingServicesConnection, $reportingServicesDatabaseName, 2, '', '')
            $null = $reportingServicesData.Configuration.InitializeReportServer($reportingServicesData.Configuration.InstallationID)

            Restart-ReportingServicesService -SQLInstanceName $InstanceName
        }
        else
        {
            $getTargetResourceParameters = @{
                InstanceName         = $InstanceName
                DatabaseServerName   = $DatabaseServerName
                DatabaseInstanceName = $DatabaseInstanceName
            }

            $currentConfig = Get-TargetResource @getTargetResourceParameters

            <#
                SQL Server Reporting Services virtual directories (both
                Report Server and Report Manager/Report Web App) are a
                part of SQL Server Reporting Services URL reservations.

                The default SQL Server Reporting Services URL reservations are:
                http://+:80/ReportServer/ (for Report Server)
                and
                http://+:80/Reports/ (for Report Manager/Report Web App)

                You can get them by running 'netsh http show urlacl' from
                command line.

                In order to change a virtual directory, we first need to remove
                existing URL reservations, change the appropriate virtual directory
                setting and re-add URL reservations, which will then contain the
                new virtual directory.
            #>

            if ( -not [string]::IsNullOrEmpty($ReportServerVirtualDirectory) -and ($ReportServerVirtualDirectory -ne $currentConfig.ReportServerVirtualDirectory) )
            {
                New-VerboseMessage -Message "Setting report server virtual directory on $DatabaseServerName\$DatabaseInstanceName to $ReportServerVirtualDirectory."

                $currentConfig.ReportServerReservedUrl | ForEach-Object -Process {
                    $null = $reportingServicesData.Configuration.RemoveURL('ReportServerWebService', $_, $language)
                }

                $reportingServicesData.Configuration.SetVirtualDirectory('ReportServerWebService', $ReportServerVirtualDirectory, $language)

                $currentConfig.ReportServerReservedUrl | ForEach-Object -Process {
                    $null = $reportingServicesData.Configuration.ReserveURL('ReportServerWebService', $_, $language)
                }
            }

            if ( -not [string]::IsNullOrEmpty($ReportsVirtualDirectory) -and ($ReportsVirtualDirectory -ne $currentConfig.ReportsVirtualDirectory) )
            {
                New-VerboseMessage -Message "Setting reports virtual directory on $DatabaseServerName\$DatabaseInstanceName to $ReportServerVirtualDirectory."

                $currentConfig.ReportsReservedUrl | ForEach-Object -Process {
                    $null = $reportingServicesData.Configuration.RemoveURL($reportingServicesData.ReportsApplicationName, $_, $language)
                }

                $reportingServicesData.Configuration.SetVirtualDirectory($reportingServicesData.ReportsApplicationName, $ReportsVirtualDirectory, $language)

                $currentConfig.ReportsReservedUrl | ForEach-Object -Process {
                    $null = $reportingServicesData.Configuration.ReserveURL($reportingServicesData.ReportsApplicationName, $_, $language)
                }
            }

            $compareParameters = @{
                ReferenceObject  = $currentConfig.ReportServerReservedUrl
                DifferenceObject = $ReportServerReservedUrl
            }

            if ( ($null -ne $ReportServerReservedUrl) -and ($null -ne (Compare-Object @compareParameters)) )
            {
                $currentConfig.ReportServerReservedUrl | ForEach-Object -Process {
                    $null = $reportingServicesData.Configuration.RemoveURL('ReportServerWebService', $_, $language)
                }

                $ReportServerReservedUrl | ForEach-Object -Process {
                    New-VerboseMessage -Message "Adding report server URL reservation on $DatabaseServerName\$DatabaseInstanceName`: $_."
                    $null = $reportingServicesData.Configuration.ReserveURL('ReportServerWebService', $_, $language)
                }
            }

            $compareParameters = @{
                ReferenceObject  = $currentConfig.ReportsReservedUrl
                DifferenceObject = $ReportsReservedUrl
            }

            if ( ($null -ne $ReportsReservedUrl) -and ($null -ne (Compare-Object @compareParameters)) )
            {
                $currentConfig.ReportsReservedUrl | ForEach-Object -Process {
                    $null = $reportingServicesData.Configuration.RemoveURL($reportingServicesData.ReportsApplicationName, $_, $language)
                }

                $ReportsReservedUrl | ForEach-Object -Process {
                    New-VerboseMessage -Message "Adding reports URL reservation on $DatabaseServerName\$DatabaseInstanceName`: $_."
                    $null = $reportingServicesData.Configuration.ReserveURL($reportingServicesData.ReportsApplicationName, $_, $language)
                }
            }
        }
    }

    if ( -not (Test-TargetResource @PSBoundParameters) )
    {
        throw New-TerminatingError -ErrorType TestFailedAfterSet -ErrorCategory InvalidResult
    }
}

<#
    .SYNOPSIS
        Tests the SQL Reporting Services initialization status.

    .PARAMETER InstanceName
        Name of the SQL Server Reporting Services instance to be configured.

    .PARAMETER DatabaseServerName
        Name of the SQL Server to host the Reporting Service database.

    .PARAMETER DatabaseInstanceName
        Name of the SQL Server instance to host the Reporting Service database.

    .PARAMETER ReportServerVirtualDirectory
        Report Server Web Service virtual directory. Optional.

    .PARAMETER ReportsVirtualDirectory
        Report Manager/Report Web App virtual directory name. Optional.

    .PARAMETER ReportServerReservedUrl
        Report Server URL reservations. Optional. If not specified, 'http://+:80' URL reservation will be used.

    .PARAMETER ReportsReservedUrl
        Report Manager/Report Web App URL reservations. Optional. If not specified, 'http://+:80' URL reservation will be used.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseServerName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseInstanceName,

        [Parameter()]
        [System.String]
        $ReportServerVirtualDirectory,

        [Parameter()]
        [System.String]
        $ReportsVirtualDirectory,

        [Parameter()]
        [System.String[]]
        $ReportServerReservedUrl,

        [Parameter()]
        [System.String[]]
        $ReportsReservedUrl
    )

    $result = $true

    $getTargetResourceParameters = @{
        InstanceName         = $InstanceName
        DatabaseServerName   = $DatabaseServerName
        DatabaseInstanceName = $DatabaseInstanceName
    }

    $currentConfig = Get-TargetResource @getTargetResourceParameters

    if ( -not $currentConfig.IsInitialized )
    {
        New-VerboseMessage -Message "Reporting services $DatabaseServerName\$DatabaseInstanceName are not initialized."
        $result = $false
    }

    if ( -not [string]::IsNullOrEmpty($ReportServerVirtualDirectory) -and ($ReportServerVirtualDirectory -ne $currentConfig.ReportServerVirtualDirectory) )
    {
        New-VerboseMessage -Message "Report server virtual directory on $DatabaseServerName\$DatabaseInstanceName is $($currentConfig.ReportServerVirtualDir), should be $ReportServerVirtualDirectory."
        $result = $false
    }

    if ( -not [string]::IsNullOrEmpty($ReportsVirtualDirectory) -and ($ReportsVirtualDirectory -ne $currentConfig.ReportsVirtualDirectory) )
    {
        New-VerboseMessage -Message "Reports virtual directory on $DatabaseServerName\$DatabaseInstanceName is $($currentConfig.ReportsVirtualDir), should be $ReportsVirtualDirectory."
        $result = $false
    }

    $compareParameters = @{
        ReferenceObject  = $currentConfig.ReportServerReservedUrl
        DifferenceObject = $ReportServerReservedUrl
    }

    if ( ($null -ne $ReportServerReservedUrl) -and ($null -ne (Compare-Object @compareParameters)) )
    {
        New-VerboseMessage -Message "Report server reserved URLs on $DatabaseServerName\$DatabaseInstanceName are $($currentConfig.ReportServerReservedUrl -join ', '), should be $($ReportServerReservedUrl -join ', ')."
        $result = $false
    }

    $compareParameters = @{
        ReferenceObject  = $currentConfig.ReportsReservedUrl
        DifferenceObject = $ReportsReservedUrl
    }

    if ( ($null -ne $ReportsReservedUrl) -and ($null -ne (Compare-Object @compareParameters)) )
    {
        New-VerboseMessage -Message "Reports reserved URLs on $DatabaseServerName\$DatabaseInstanceName are $($currentConfig.ReportsReservedUrl -join ', ')), should be $($ReportsReservedUrl -join ', ')."
        $result = $false
    }

    $result
}

<#
    .SYNOPSIS
        Returns SQL Reporting Services data: configuration object used to initialize and configure
        SQL Reporting Services and the name of the Reports Web application name (changed in SQL 2016)

    .PARAMETER InstanceName
        Name of the SQL Server Reporting Services instance for which the data is being retrieved.
#>
function Get-ReportingServicesData
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $instanceNamesRegistryKey = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS'

    if ( Get-ItemProperty -Path $instanceNamesRegistryKey -Name $InstanceName -ErrorAction SilentlyContinue )
    {
        $instanceId = (Get-ItemProperty -Path $instanceNamesRegistryKey -Name $InstanceName).$InstanceName
        $sqlVersion = [System.Int32]((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceId\Setup" -Name 'Version').Version).Split('.')[0]
        $reportingServicesConfiguration = Get-WmiObject -Class MSReportServer_ConfigurationSetting -Namespace "root\Microsoft\SQLServer\ReportServer\RS_$InstanceName\v$sqlVersion\Admin"
        $reportingServicesConfiguration = $reportingServicesConfiguration | Where-Object -FilterScript {
            $_.InstanceName -eq $InstanceName
        }
        <#
            SSRS Web Portal application name changed in SQL Server 2016
            https://docs.microsoft.com/en-us/sql/reporting-services/breaking-changes-in-sql-server-reporting-services-in-sql-server-2016
        #>
        if ( $sqlVersion -ge 13 )
        {
            $reportsApplicationName = 'ReportServerWebApp'
        }
        else
        {
            $reportsApplicationName = 'ReportManager'
        }
    }

    @{
        Configuration          = $reportingServicesConfiguration
        ReportsApplicationName = $reportsApplicationName
    }
}

Export-ModuleMember -Function *-TargetResource
