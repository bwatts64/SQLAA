# This is used to make sure the integration test run in the correct order.
[Microsoft.DscResourceKit.IntegrationTest(OrderNumber = 2)]
param()

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

# Run only for SQL 2017 integration testing.
if (Test-SkipContinuousIntegrationTask -Type 'Integration' -Category @('Integration_SQL2017'))
{
    return
}

$script:dscModuleName = 'SqlServerDsc'
$script:dscResourceFriendlyName = 'SqlRSSetup'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

#region HEADER
# Integration Test Template Version: 1.3.2
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -TestType Integration
#endregion

# Using try/finally to always cleanup.
try
{
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configFile

    # Download Microsoft SQL Server Reporting Services (October 2017) executable
    if (-not (Test-Path -Path $ConfigurationData.AllNodes.SourcePath))
    {
        # By switching to 'SilentlyContinue' should theoretically increase the download speed.
        $previousProgressPreference = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'

        $script:mockSourceMediaDisplayName = 'Microsoft SQL Server Reporting Services (October 2017)'
        $script:mockSourceMediaUrl = 'https://download.microsoft.com/download/E/6/4/E6477A2A-9B58-40F7-8AD6-62BB8491EA78/SQLServerReportingServices.exe'

        Write-Info -Message ('Start downloading the {1} executable at {0}.' -f (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'), $script:mockSourceMediaDisplayName) -Verbose

        Invoke-WebRequest -Uri $script:mockSourceMediaUrl -OutFile $ConfigurationData.AllNodes.SourcePath

        Write-Info -Message ('{1} executable file has SHA1 hash ''{0}''.' -f (Get-FileHash -Path $ConfigurationData.AllNodes.SourcePath -Algorithm 'SHA1').Hash, $script:mockSourceMediaDisplayName) -Verbose

        $ProgressPreference = $previousProgressPreference

        # Double check that the Microsoft SQL Server Reporting Services (October 2017) was downloaded.
        if (-not (Test-Path -Path $ConfigurationData.AllNodes.SourcePath))
        {
            Write-Warning -Message ('{0} executable could not be downloaded, can not run the integration test.' -f $script:mockSourceMediaDisplayName)
            return
        }
        else
        {
            Write-Info -Message ('Finished downloading the {1} executable at {0}.' -f (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'), $script:mockSourceMediaDisplayName) -Verbose
        }
    }
    else
    {
        Write-Info -Message ('{0} executable is already downloaded' -f $script:mockSourceMediaDisplayName) -Verbose
    }

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }

        $configurationName = "$($script:dscResourceName)_InstallReportingServicesAsUser_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath                       = $TestDrive
                        # The variable $ConfigurationData was dot-sourced above.
                        ConfigurationData                = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.InstanceName       | Should -Be $ConfigurationData.AllNodes.InstanceName
                $resourceCurrentState.InstallFolder      | Should -Be 'C:\Program Files\Microsoft SQL Server Reporting Services'
                $resourceCurrentState.ServiceName        | Should -Be 'SQLServerReportingServices'
                $resourceCurrentState.ErrorDumpDirectory | Should -Be 'C:\Program Files\Microsoft SQL Server Reporting Services\SSRS\LogFiles'
                $resourceCurrentState.CurrentVersion     | Should -BeGreaterThan ([System.Version] '14.0.0.0')
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_StopReportingServicesInstance_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        # The variable $ConfigurationData was dot-sourced above.
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
