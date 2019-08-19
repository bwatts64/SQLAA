<#
    .SYNOPSIS
        Automated unit test for helper functions in module SqlServerDsc.Common.

    .NOTES
        To run this script locally, please make sure to first run the bootstrap
        script. Read more at
        https://github.com/PowerShell/SqlServerDsc/blob/dev/CONTRIBUTING.md#bootstrap-script-assert-testenvironment
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

if (Test-SkipContinuousIntegrationTask -Type 'Unit')
{
    return
}

# Import the SqlServerDsc.Common module to test
$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules\SqlServerDsc.Common'

Import-Module -Name (Join-Path -Path $script:modulesFolderPath -ChildPath 'SqlServerDsc.Common.psm1') -Force

# Loading mocked classes
Add-Type -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs') -ChildPath 'SMO.cs')
Add-Type -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs') -ChildPath 'SqlPowerShellSqlExecutionException.cs')

# Importing SQLPS stubs
Import-Module -Name (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs') -ChildPath 'SQLPSStub.psm1') -Force -Global

InModuleScope 'SqlServerDsc.Common' {
    Describe 'SqlServerDsc.Common\Test-DscParameterState' -Tag 'TestDscParameterState' {
        Context -Name 'When passing values' -Fixture {
            It 'Should return true for two identical tables' {
                $mockDesiredValues = @{ Example = 'test' }

                $testParameters = @{
                    CurrentValues = $mockDesiredValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $true
            }

            It 'Should return false when a value is different for [System.String]' {
                $mockCurrentValues = @{ Example = [System.String] 'something' }
                $mockDesiredValues = @{ Example = [System.String] 'test' }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return false when a value is different for [System.Int32]' {
                $mockCurrentValues = @{ Example = [System.Int32] 1 }
                $mockDesiredValues = @{ Example = [System.Int32] 2 }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return false when a value is different for [Int16]' {
                $mockCurrentValues = @{ Example = [System.Int16] 1 }
                $mockDesiredValues = @{ Example = [System.Int16] 2 }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return false when a value is different for [UInt16]' {
                $mockCurrentValues = @{ Example = [System.UInt16] 1 }
                $mockDesiredValues = @{ Example = [System.UInt16] 2 }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return false when a value is different for [Boolean]' {
                $mockCurrentValues = @{ Example = [System.Boolean] $true }
                $mockDesiredValues = @{ Example = [System.Boolean] $false }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return false when a value is missing' {
                $mockCurrentValues = @{ }
                $mockDesiredValues = @{ Example = 'test' }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return true when only a specified value matches, but other non-listed values do not' {
                $mockCurrentValues = @{ Example = 'test'; SecondExample = 'true' }
                $mockDesiredValues = @{ Example = 'test'; SecondExample = 'false'  }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                    ValuesToCheck = @('Example')
                }

                Test-DscParameterState @testParameters | Should -Be $true
            }

            It 'Should return false when only specified values do not match, but other non-listed values do ' {
                $mockCurrentValues = @{ Example = 'test'; SecondExample = 'true' }
                $mockDesiredValues = @{ Example = 'test'; SecondExample = 'false'  }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                    ValuesToCheck = @('SecondExample')
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return false when an empty hash table is used in the current values' {
                $mockCurrentValues = @{ }
                $mockDesiredValues = @{ Example = 'test'; SecondExample = 'false'  }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return true when evaluating a table against a CimInstance' {
                $mockCurrentValues = @{ Handle = '0'; ProcessId = '1000'  }

                $mockWin32ProcessProperties = @{
                    Handle = 0
                    ProcessId = 1000
                }

                $mockNewCimInstanceParameters = @{
                    ClassName = 'Win32_Process'
                    Property = $mockWin32ProcessProperties
                    Key = 'Handle'
                    ClientOnly = $true
                }

                $mockDesiredValues = New-CimInstance @mockNewCimInstanceParameters

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                    ValuesToCheck = @('Handle','ProcessId')
                }

                Test-DscParameterState @testParameters | Should -Be $true
            }

            It 'Should return false when evaluating a table against a CimInstance and a value is wrong' {
                $mockCurrentValues = @{ Handle = '1'; ProcessId = '1000'  }

                $mockWin32ProcessProperties = @{
                    Handle = 0
                    ProcessId = 1000
                }

                $mockNewCimInstanceParameters = @{
                    ClassName = 'Win32_Process'
                    Property = $mockWin32ProcessProperties
                    Key = 'Handle'
                    ClientOnly = $true
                }

                $mockDesiredValues = New-CimInstance @mockNewCimInstanceParameters

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                    ValuesToCheck = @('Handle','ProcessId')
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return true when evaluating a hash table containing an array' {
                $mockCurrentValues = @{ Example = 'test'; SecondExample = @('1','2') }
                $mockDesiredValues = @{ Example = 'test'; SecondExample = @('1','2')  }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $true
            }

            It 'Should return false when evaluating a hash table containing an array with wrong values' {
                $mockCurrentValues = @{ Example = 'test'; SecondExample = @('A','B') }
                $mockDesiredValues = @{ Example = 'test'; SecondExample = @('1','2')  }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return false when evaluating a hash table containing an array, but the CurrentValues are missing an array' {
                $mockCurrentValues = @{ Example = 'test' }
                $mockDesiredValues = @{ Example = 'test'; SecondExample = @('1','2')  }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }

            It 'Should return false when evaluating a hash table containing an array, but the property i CurrentValues is $null' {
                $mockCurrentValues = @{ Example = 'test'; SecondExample = $null }
                $mockDesiredValues = @{ Example = 'test'; SecondExample = @('1','2')  }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false
            }
        }

        Context -Name 'When passing invalid types for DesiredValues' -Fixture {
            It 'Should throw the correct error when DesiredValues is of wrong type' {
                $mockCurrentValues = @{ Example = 'something' }
                $mockDesiredValues = 'NotHashTable'

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                $mockCorrectErrorMessage = ($script:localizedData.PropertyTypeInvalidForDesiredValues -f $testParameters.DesiredValues.GetType().Name)
                { Test-DscParameterState @testParameters } | Should -Throw $mockCorrectErrorMessage
            }

            It 'Should write a warning when DesiredValues contain an unsupported type' {
                Mock -CommandName Write-Warning -Verifiable

                # This is a dummy type to test with a type that could never be a correct one.
                class MockUnknownType
                {
                    [ValidateNotNullOrEmpty()]
                    [System.String]
                    $Property1

                    [ValidateNotNullOrEmpty()]
                    [System.String]
                    $Property2

                    MockUnknownType()
                    {
                    }
                }

                $mockCurrentValues = @{ Example = New-Object -TypeName MockUnknownType }
                $mockDesiredValues = @{ Example = New-Object -TypeName MockUnknownType }

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                }

                Test-DscParameterState @testParameters | Should -Be $false

                Assert-MockCalled -CommandName Write-Warning -Exactly -Times 1
            }
        }

        Context -Name 'When passing an CimInstance as DesiredValue and ValuesToCheck is $null' -Fixture {
            It 'Should throw the correct error' {
                $mockCurrentValues = @{ Example = 'something' }

                $mockWin32ProcessProperties = @{
                    Handle = 0
                    ProcessId = 1000
                }

                $mockNewCimInstanceParameters = @{
                    ClassName = 'Win32_Process'
                    Property = $mockWin32ProcessProperties
                    Key = 'Handle'
                    ClientOnly = $true
                }

                $mockDesiredValues = New-CimInstance @mockNewCimInstanceParameters

                $testParameters = @{
                    CurrentValues = $mockCurrentValues
                    DesiredValues = $mockDesiredValues
                    ValuesToCheck = $null
                }

                $mockCorrectErrorMessage = $script:localizedData.PropertyTypeInvalidForValuesToCheck
                { Test-DscParameterState @testParameters } | Should -Throw $mockCorrectErrorMessage
            }
        }

        Assert-VerifiableMock
    }

    Describe 'SqlServerDsc.Common\Get-RegistryPropertyValue' -Tag 'GetRegistryPropertyValue' {
        BeforeAll {
            $mockWrongRegistryPath = 'HKLM:\SOFTWARE\AnyPath'
            $mockCorrectRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS'
            $mockPropertyName = 'InstanceName'
            $mockPropertyValue = 'AnyValue'
        }

        Context 'When there are no property in the registry' {
            BeforeAll {
                Mock -CommandName Get-ItemProperty -MockWith {
                    return @{
                        'UnknownProperty' = $mockPropertyValue
                    }
                }
            }

            It 'Should return $null' {
                $result = Get-RegistryPropertyValue -Path $mockWrongRegistryPath -Name $mockPropertyName
                $result | Should -BeNullOrEmpty

                Assert-MockCalled -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the call to Get-ItemProperty throws an error (i.e. when the path does not exist)' {
            BeforeAll {
                Mock -CommandName Get-ItemProperty -MockWith {
                    throw 'mocked error'
                }
            }

            It 'Should not throw an error, but return $null' {
                $result = Get-RegistryPropertyValue -Path $mockWrongRegistryPath -Name $mockPropertyName
                $result | Should -BeNullOrEmpty

                Assert-MockCalled -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It
            }
        }

        Context 'When there are a property in the registry' {
            BeforeAll {
                $mockGetItemProperty_InstanceName = {
                    return @{
                        $mockPropertyName = $mockPropertyValue
                    }
                }

                $mockGetItemProperty_InstanceName_ParameterFilter = {
                    $Path -eq $mockCorrectRegistryPath `
                    -and $Name -eq $mockPropertyName
                }

                Mock -CommandName Get-ItemProperty `
                    -MockWith $mockGetItemProperty_InstanceName `
                    -ParameterFilter $mockGetItemProperty_InstanceName_ParameterFilter
            }

            It 'Should return the correct value' {
                $result = Get-RegistryPropertyValue -Path $mockCorrectRegistryPath -Name $mockPropertyName
                $result | Should -Be $mockPropertyValue

                Assert-MockCalled -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It
            }
        }
    }

    Describe 'SqlServerDsc.Common\Format-Path' -Tag 'FormatPath' {
        BeforeAll {
            $mockCorrectPath = 'C:\Correct\Path'
            $mockPathWithTrailingBackslash = 'C:\Correct\Path\'
            $mockPathWithOnlyQualifier = 'M:'
            $mockCorrectQualifierPath = 'M:\'
        }

        Context 'When there is a path that is wrongly formatted, but now formatting was requested' {
            It 'Should return the same wrongly formatted path' {
                $result = Format-Path -Path $mockPathWithTrailingBackslash
                $result | Should -BeExactly $mockPathWithTrailingBackslash
            }
        }

        Context 'When there is a path that is formatted correctly, and using TrailingSlash' {
            It 'Should return the same path' {
                $result = Format-Path -Path $mockCorrectPath -TrailingSlash
                $result | Should -BeExactly $mockCorrectPath
            }
        }

        Context 'When there is a path that has a trailing backslash, and using TrailingSlash' {
            It 'Should return the path without trailing backslash' {
                $result = Format-Path -Path $mockPathWithTrailingBackslash -TrailingSlash
                $result | Should -BeExactly $mockCorrectPath
            }
        }

        Context 'When there is a path that has only a qualifier, and using TrailingSlash' {
            It 'Should return the path with trailing backslash after the qualifier' {
                $result = Format-Path -Path $mockPathWithOnlyQualifier -TrailingSlash
                $result | Should -BeExactly $mockCorrectQualifierPath
            }
        }
    }

    # Tests only the parts of the code that does not already get tested thru the other tests.
    Describe 'SqlServerDsc.Common\Copy-ItemWithRobocopy' -Tag 'CopyItemWithRobocopy' {
        BeforeAll {
            $mockRobocopyExecutableName = 'Robocopy.exe'
            $mockRobocopyExecutableVersionWithoutUnbufferedIO = '6.2.9200.00000'
            $mockRobocopyExecutableVersionWithUnbufferedIO = '6.3.9600.16384'
            $mockRobocopyExecutableVersion = ''     # Set dynamically during runtime
            $mockRobocopyArgumentSilent = '/njh /njs /ndl /nc /ns /nfl'
            $mockRobocopyArgumentCopySubDirectoriesIncludingEmpty = '/e'
            $mockRobocopyArgumentDeletesDestinationFilesAndDirectoriesNotExistAtSource = '/purge'
            $mockRobocopyArgumentUseUnbufferedIO = '/J'
            $mockRobocopyArgumentSourcePath = 'C:\Source\SQL2016'
            $mockRobocopyArgumentDestinationPath = 'D:\Temp'
            $mockRobocopyArgumentSourcePathWithSpaces = 'C:\Source\SQL2016 STD SP1'
            $mockRobocopyArgumentDestinationPathWithSpaces = 'D:\Temp\DSC SQL2016'

            $mockGetCommand = {
                return @(
                    (
                        New-Object -TypeName Object |
                            Add-Member -MemberType NoteProperty -Name 'Name' -Value $mockRobocopyExecutableName -PassThru |
                            Add-Member -MemberType ScriptProperty -Name FileVersionInfo -Value {
                                return @( ( New-Object -TypeName Object |
                                        Add-Member -MemberType NoteProperty -Name 'ProductVersion' -Value $mockRobocopyExecutableVersion -PassThru -Force
                                    ) )
                            } -PassThru -Force
                    )
                )
            }

            $mockStartSqlSetupProcessExpectedArgument = ''  # Set dynamically during runtime
            $mockStartSqlSetupProcessExitCode = 0  # Set dynamically during runtime

            $mockStartSqlSetupProcess_Robocopy = {
                if ( $ArgumentList -cne $mockStartSqlSetupProcessExpectedArgument )
                {
                    throw "Expected arguments was not the same as the arguments in the function call.`nExpected: '$mockStartSqlSetupProcessExpectedArgument' `n But was: '$ArgumentList'"
                }

                return New-Object -TypeName Object |
                            Add-Member -MemberType NoteProperty -Name 'ExitCode' -Value 0 -PassThru -Force
            }

            $mockStartSqlSetupProcess_Robocopy_WithExitCode = {
                return New-Object -TypeName Object |
                            Add-Member -MemberType NoteProperty -Name 'ExitCode' -Value $mockStartSqlSetupProcessExitCode -PassThru -Force
            }
        }

        Context 'When Copy-ItemWithRobocopy is called it should return the correct arguments' {
            BeforeEach {
                Mock -CommandName Get-Command -MockWith $mockGetCommand -Verifiable
                Mock -CommandName Start-Process -MockWith $mockStartSqlSetupProcess_Robocopy -Verifiable
                $mockRobocopyArgumentSourcePathQuoted = '"{0}"' -f $mockRobocopyArgumentSourcePath
                $mockRobocopyArgumentDestinationPathQuoted = '"{0}"' -f $mockRobocopyArgumentDestinationPath
            }


            It 'Should use Unbuffered IO when copying' {
                $mockRobocopyExecutableVersion = $mockRobocopyExecutableVersionWithUnbufferedIO

                $mockStartSqlSetupProcessExpectedArgument =
                    $mockRobocopyArgumentSourcePathQuoted,
                    $mockRobocopyArgumentDestinationPathQuoted,
                    $mockRobocopyArgumentCopySubDirectoriesIncludingEmpty,
                    $mockRobocopyArgumentDeletesDestinationFilesAndDirectoriesNotExistAtSource,
                    $mockRobocopyArgumentUseUnbufferedIO,
                    $mockRobocopyArgumentSilent -join ' '

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePath
                    DestinationPath = $mockRobocopyArgumentDestinationPath
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process  -Exactly -Times 1 -Scope It
            }

            It 'Should not use Unbuffered IO when copying' {
                $mockRobocopyExecutableVersion = $mockRobocopyExecutableVersionWithoutUnbufferedIO

                $mockStartSqlSetupProcessExpectedArgument =
                    $mockRobocopyArgumentSourcePathQuoted,
                    $mockRobocopyArgumentDestinationPathQuoted,
                    $mockRobocopyArgumentCopySubDirectoriesIncludingEmpty,
                    $mockRobocopyArgumentDeletesDestinationFilesAndDirectoriesNotExistAtSource,
                    '',
                    $mockRobocopyArgumentSilent -join ' '

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePath
                    DestinationPath = $mockRobocopyArgumentDestinationPath
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process -Exactly -Times 1 -Scope It
            }
        }

        Context 'When Copy-ItemWithRobocopy throws an exception it should return the correct error messages' {
            BeforeEach {
                $mockRobocopyExecutableVersion = $mockRobocopyExecutableVersionWithUnbufferedIO

                Mock -CommandName Get-Command -MockWith $mockGetCommand -Verifiable
                Mock -CommandName Start-Process -MockWith $mockStartSqlSetupProcess_Robocopy_WithExitCode -Verifiable
            }

            It 'Should throw the correct error message when error code is 8' {
                $mockStartSqlSetupProcessExitCode = 8

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePath
                    DestinationPath = $mockRobocopyArgumentDestinationPath
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Throw "Robocopy reported errors when copying files. Error code: $mockStartSqlSetupProcessExitCode."

                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process -Exactly -Times 1 -Scope It
            }

            It 'Should throw the correct error message when error code is 16' {
                $mockStartSqlSetupProcessExitCode = 16

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePath
                    DestinationPath = $mockRobocopyArgumentDestinationPath
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Throw "Robocopy reported errors when copying files. Error code: $mockStartSqlSetupProcessExitCode."

                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process -Exactly -Times 1 -Scope It
            }

            It 'Should throw the correct error message when error code is greater than 7 (but not 8 or 16)' {
                $mockStartSqlSetupProcessExitCode = 9

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePath
                    DestinationPath = $mockRobocopyArgumentDestinationPath
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Throw "Robocopy reported that failures occurred when copying files. Error code: $mockStartSqlSetupProcessExitCode."

                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process -Exactly -Times 1 -Scope It
            }
        }

        Context 'When Copy-ItemWithRobocopy is called and finishes successfully it should return the correct exit code' {
            BeforeEach {
                $mockRobocopyExecutableVersion = $mockRobocopyExecutableVersionWithUnbufferedIO

                Mock -CommandName Get-Command -MockWith $mockGetCommand -Verifiable
                Mock -CommandName Start-Process -MockWith $mockStartSqlSetupProcess_Robocopy_WithExitCode -Verifiable
            }

            AfterEach {
                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process -Exactly -Times 1 -Scope It
            }

            It 'Should finish successfully with exit code 1' {
                $mockStartSqlSetupProcessExitCode = 1

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePath
                    DestinationPath = $mockRobocopyArgumentDestinationPath
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process -Exactly -Times 1 -Scope It
            }

            It 'Should finish successfully with exit code 2' {
                $mockStartSqlSetupProcessExitCode = 2

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePath
                    DestinationPath = $mockRobocopyArgumentDestinationPath
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process -Exactly -Times 1 -Scope It
            }

            It 'Should finish successfully with exit code 3' {
                $mockStartSqlSetupProcessExitCode = 3

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePath
                    DestinationPath = $mockRobocopyArgumentDestinationPath
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Not -Throw
            }
        }

        Context 'When Copy-ItemWithRobocopy is called with spaces in paths and finishes successfully it should return the correct exit code' {
            BeforeEach {
                $mockRobocopyExecutableVersion = $mockRobocopyExecutableVersionWithUnbufferedIO

                Mock -CommandName Get-Command -MockWith $mockGetCommand -Verifiable
                Mock -CommandName Start-Process -MockWith $mockStartSqlSetupProcess_Robocopy_WithExitCode -Verifiable
            }

            AfterEach {
                Assert-MockCalled -CommandName Get-Command -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Start-Process -Exactly -Times 1 -Scope It
            }

            It 'Should finish successfully with exit code 1' {
                $mockStartSqlSetupProcessExitCode = 1

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePathWithSpaces
                    DestinationPath = $mockRobocopyArgumentDestinationPathWithSpaces
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Not -Throw

            }

            It 'Should finish successfully with exit code 2' {
                $mockStartSqlSetupProcessExitCode = 2

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePathWithSpaces
                    DestinationPath = $mockRobocopyArgumentDestinationPathWithSpaces
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Not -Throw

            }

            It 'Should finish successfully with exit code 3' {
                $mockStartSqlSetupProcessExitCode = 3

                $copyItemWithRobocopyParameter = @{
                    Path = $mockRobocopyArgumentSourcePathWithSpaces
                    DestinationPath = $mockRobocopyArgumentDestinationPathWithSpaces
                }

                { Copy-ItemWithRobocopy @copyItemWithRobocopyParameter } | Should -Not -Throw
            }
        }
    }

    Describe 'SqlServerDsc.Common\Get-TemporaryFolder' -Tag 'GetTemporaryFolder' {
        BeforeAll {
            $mockExpectedTempPath = [IO.Path]::GetTempPath()
        }

        Context 'When using Get-TemporaryFolder' {
            It 'Should return the correct temporary path' {
                Get-TemporaryFolder | Should -BeExactly $mockExpectedTempPath
            }
        }
    }

    Describe 'SqlServerDsc.Common\Invoke-InstallationMediaCopy' -Tag 'InvokeInstallationMediaCopy' {
        BeforeAll {
            $mockSourcePathUNC = '\\server\share'
            $mockSourcePathUNCWithLeaf = '\\server\share\leaf'
            $mockSourcePathGuid = 'cc719562-0f46-4a16-8605-9f8a47c70402'
            $mockDestinationPath = 'TestDrive:\'

            $mockShareCredentialUserName = 'COMPANY\SqlAdmin'
            $mockShareCredentialPassword = 'dummyPassW0rd'
            $mockShareCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @(
                $mockShareCredentialUserName,
                ($mockShareCredentialPassword | ConvertTo-SecureString -AsPlainText -Force)
            )

            $mockGetTemporaryFolder = {
                return $mockDestinationPath
            }

            $mockNewGuid = {
                return New-Object -TypeName Object |
                            Add-Member -MemberType NoteProperty -Name 'Guid' -Value $mockSourcePathGuid -PassThru -Force
            }

            Mock -CommandName Connect-UncPath
            Mock -CommandName Disconnect-UncPath
            Mock -CommandName Copy-ItemWithRobocopy
            Mock -CommandName Get-TemporaryFolder -MockWith $mockGetTemporaryFolder
            Mock -CommandName New-Guid -MockWith $mockNewGuid
        }

        Context 'When invoking installation media copy, using SourcePath containing leaf' {
            It 'Should call the correct mocks' {
                {
                    $invokeInstallationMediaCopyParameters = @{
                        SourcePath = $mockSourcePathUNCWithLeaf
                        SourceCredential = $mockShareCredential
                    }

                    Invoke-InstallationMediaCopy @invokeInstallationMediaCopyParameters
                } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-UncPath -Exactly -Times 1 -Scope 'It'
                Assert-MockCalled -CommandName New-Guid -Exactly -Times 0 -Scope 'It'
                Assert-MockCalled -CommandName Get-TemporaryFolder -Exactly -Times 1 -Scope 'It'
                Assert-MockCalled -CommandName Copy-ItemWithRobocopy -Exactly -Times 1 -Scope 'It'
                Assert-MockCalled -CommandName Disconnect-UncPath -Exactly -Times 1 -Scope 'It'
            }

            It 'Should return the correct destination path' {
                $invokeInstallationMediaCopyParameters = @{
                    SourcePath = $mockSourcePathUNCWithLeaf
                    SourceCredential = $mockShareCredential
                    PassThru = $true
                }

                $invokeInstallationMediaCopyResult = Invoke-InstallationMediaCopy @invokeInstallationMediaCopyParameters

                $invokeInstallationMediaCopyResult | Should -Be ('{0}leaf' -f $mockDestinationPath)
            }
        }

        Context 'When invoking installation media copy, using SourcePath without a leaf' {
            It 'Should call the correct mocks' {
                {
                    $invokeInstallationMediaCopyParameters = @{
                        SourcePath = $mockSourcePathUNC
                        SourceCredential = $mockShareCredential
                    }

                    Invoke-InstallationMediaCopy @invokeInstallationMediaCopyParameters
                } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-UncPath -Exactly -Times 1 -Scope 'It'
                Assert-MockCalled -CommandName New-Guid -Exactly -Times 1 -Scope 'It'
                Assert-MockCalled -CommandName Get-TemporaryFolder -Exactly -Times 1 -Scope 'It'
                Assert-MockCalled -CommandName Copy-ItemWithRobocopy -Exactly -Times 1 -Scope 'It'
                Assert-MockCalled -CommandName Disconnect-UncPath -Exactly -Times 1 -Scope 'It'
            }

            It 'Should return the correct destination path' {
                $invokeInstallationMediaCopyParameters = @{
                    SourcePath = $mockSourcePathUNC
                    SourceCredential = $mockShareCredential
                    PassThru = $true
                }

                $invokeInstallationMediaCopyResult = Invoke-InstallationMediaCopy @invokeInstallationMediaCopyParameters
                $invokeInstallationMediaCopyResult | Should -Be ('{0}{1}' -f $mockDestinationPath, $mockSourcePathGuid)
            }
        }
    }

    Describe 'SqlServerDsc.Common\Connect-UncPath' -Tag 'ConnectUncPath' {
        BeforeAll {
            $mockSourcePathUNC = '\\server\share'

            $mockShareCredentialUserName = 'COMPANY\SqlAdmin'
            $mockShareCredentialPassword = 'dummyPassW0rd'
            $mockShareCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @(
                $mockShareCredentialUserName,
                ($mockShareCredentialPassword | ConvertTo-SecureString -AsPlainText -Force)
            )

            Mock -CommandName New-SmbMapping -MockWith {
                return @{
                    RemotePath = $mockSourcePathUNC
                }
            }
        }

        Context 'When connecting to a UNC path without credentials (using current credentials)' {
            It 'Should call the correct mocks' {
                {
                    $connectUncPathParameters = @{
                        RemotePath = $mockSourcePathUNC
                    }

                    Connect-UncPath @connectUncPathParameters
                } | Should -Not -Throw

                Assert-MockCalled -CommandName New-SmbMapping -ParameterFilter {
                    $RemotePath -eq $mockSourcePathUNC `
                    -and $PSBoundParameters.ContainsKey('UserName') -eq $false
                } -Exactly -Times 1 -Scope 'It'
            }
        }

        Context 'When connecting to a UNC path with specific credentials' {
            It 'Should call the correct mocks' {
                {
                    $connectUncPathParameters = @{
                        RemotePath = $mockSourcePathUNC
                        SourceCredential = $mockShareCredential
                    }

                    Connect-UncPath @connectUncPathParameters
                } | Should -Not -Throw

                Assert-MockCalled -CommandName New-SmbMapping -ParameterFilter {
                    $RemotePath -eq $mockSourcePathUNC `
                    -and $UserName -eq $mockShareCredentialUserName
                } -Exactly -Times 1 -Scope 'It'
            }
        }

        Context 'When connecting to a UNC path and using parameter PassThru' {
            It 'Should return the correct MSFT_SmbMapping object' {
                $connectUncPathParameters = @{
                    RemotePath = $mockSourcePathUNC
                    SourceCredential = $mockShareCredential
                    PassThru = $true
                }

                $connectUncPathResult = Connect-UncPath @connectUncPathParameters
                $connectUncPathResult.RemotePath | Should -Be $mockSourcePathUNC
            }
        }
    }

    Describe 'SqlServerDsc.Common\Disconnect-UncPath' -Tag 'DisconnectUncPath' {
        BeforeAll {
            $mockSourcePathUNC = '\\server\share'

            Mock -CommandName Remove-SmbMapping
        }

        Context 'When disconnecting from an UNC path' {
            It 'Should call the correct mocks' {
                {
                    $disconnectUncPathParameters = @{
                        RemotePath = $mockSourcePathUNC
                    }

                    Disconnect-UncPath @disconnectUncPathParameters
                } | Should -Not -Throw

                Assert-MockCalled -CommandName Remove-SmbMapping -Exactly -Times 1 -Scope 'It'
            }
        }
    }

    Describe 'SqlServerDsc.Common\Test-PendingRestart' -Tag 'TestPendingRestart' {
        Context 'When there is a pending reboot' {
            BeforeAll {
                Mock -CommandName Get-RegistryPropertyValue -MockWith {
                    return 'AnyValue'
                }
            }

            It 'Should return $true' {
                $testPendingRestartResult = Test-PendingRestart
                $testPendingRestartResult | Should -BeTrue

                Assert-MockCalled -CommandName Get-RegistryPropertyValue -Exactly -Times 1 -Scope 'It'
            }
        }

        Context 'When there are no pending reboot' {
            BeforeAll {
                Mock -CommandName Get-RegistryPropertyValue
            }

            It 'Should return $true' {
                $testPendingRestartResult = Test-PendingRestart
                $testPendingRestartResult | Should -BeFalse

                Assert-MockCalled -CommandName Get-RegistryPropertyValue -Exactly -Times 1 -Scope 'It'
            }
        }
    }

    Describe 'SqlServerDsc.Common\Start-SqlSetupProcess' -Tag 'StartSqlSetupProcess' {
        Context 'When starting a process successfully' {
            It 'Should return exit code 0' {
                $startSqlSetupProcessParameters = @{
                    FilePath = 'powershell.exe'
                    ArgumentList = '-Command &{Start-Sleep -Seconds 2}'
                    Timeout = 30
                }

                $processExitCode = Start-SqlSetupProcess @startSqlSetupProcessParameters
                $processExitCode | Should -BeExactly 0
            }
        }

        Context 'When starting a process and the process does not finish before the timeout period' {
            It 'Should throw an error message' {
                $startSqlSetupProcessParameters = @{
                    FilePath = 'powershell.exe'
                    ArgumentList = '-Command &{Start-Sleep -Seconds 4}'
                    Timeout = 2
                }

                { Start-SqlSetupProcess @startSqlSetupProcessParameters } | Should -Throw -ErrorId 'ProcessNotTerminated,Microsoft.PowerShell.Commands.WaitProcessCommand'
            }
        }
    }

    Describe 'SqlServerDsc.Common\Restart-SqlService' -Tag 'RestartSqlService' {
        Context 'Restart-SqlService standalone instance' {
            BeforeEach {
                Mock -CommandName Connect-SQL -MockWith {
                    return @{
                        Name = 'MSSQLSERVER'
                        InstanceName = ''
                        ServiceName = 'MSSQLSERVER'
                        Status = $mockDynamicStatus
                        IsClustered = $false
                    }
                } -Verifiable -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }

                Mock -CommandName Connect-SQL -MockWith {
                    return @{
                        Name = 'NOCLUSTERCHECK'
                        InstanceName = 'NOCLUSTERCHECK'
                        ServiceName = 'NOCLUSTERCHECK'
                        Status = $mockDynamicStatus
                        IsClustered = $true
                    }
                } -Verifiable -ParameterFilter { $InstanceName -eq 'NOCLUSTERCHECK' }

                Mock -CommandName Connect-SQL -MockWith {
                    return @{
                        Name = 'NOCONNECT'
                        InstanceName = 'NOCONNECT'
                        ServiceName = 'NOCONNECT'
                        Status = $mockDynamicStatus
                        IsClustered = $true
                    }
                } -Verifiable -ParameterFilter { $InstanceName -eq 'NOCONNECT' }

                Mock -CommandName Connect-SQL -MockWith {
                    return @{
                        Name = 'NOAGENT'
                        InstanceName = 'NOAGENT'
                        ServiceName = 'NOAGENT'
                        Status = $mockDynamicStatus
                    }
                } -Verifiable -ParameterFilter { $InstanceName -eq 'NOAGENT' }

                Mock -CommandName Connect-SQL -MockWith {
                    return @{
                        Name = 'STOPPEDAGENT'
                        InstanceName = 'STOPPEDAGENT'
                        ServiceName = 'STOPPEDAGENT'
                        Status = $mockDynamicStatus
                    }
                } -Verifiable -ParameterFilter { $InstanceName -eq 'STOPPEDAGENT' }
            }

            BeforeAll {
                ## SQL instance with running SQL Agent Service
                Mock -CommandName Get-Service -MockWith {
                    return @{
                        Name = 'MSSQLSERVER'
                        DisplayName = 'Microsoft SQL Server (MSSQLSERVER)'
                        DependentServices = @(
                            @{
                                Name = 'SQLSERVERAGENT'
                                DisplayName = 'SQL Server Agent (MSSQLSERVER)'
                                Status = 'Running'
                                DependentServices = @()
                            }
                        )
                    }
                } -Verifiable -ParameterFilter { $Name -eq 'MSSQLSERVER' }

                ## SQL instance with no installed SQL Agent Service
                Mock -CommandName Get-Service -MockWith {
                    return @{
                        Name = 'MSSQL$NOAGENT'
                        DisplayName = 'Microsoft SQL Server (NOAGENT)'
                        DependentServices = @()
                    }
                } -Verifiable -ParameterFilter { $Name -eq 'MSSQL$NOAGENT' }

                ## SQL instance with no installed SQL Agent Service
                Mock -CommandName Get-Service -MockWith {
                    return @{
                        Name = 'MSSQL$NOCLUSTERCHECK'
                        DisplayName = 'Microsoft SQL Server (NOCLUSTERCHECK)'
                        DependentServices = @()
                    }
                } -Verifiable -ParameterFilter { $Name -eq 'MSSQL$NOCLUSTERCHECK' }

                ## SQL instance with no installed SQL Agent Service
                Mock -CommandName Get-Service -MockWith {
                    return @{
                        Name = 'MSSQL$NOCONNECT'
                        DisplayName = 'Microsoft SQL Server (NOCONNECT)'
                        DependentServices = @()
                    }
                } -Verifiable -ParameterFilter { $Name -eq 'MSSQL$NOCONNECT' }

                ## SQL instance with stopped SQL Agent Service
                Mock -CommandName Get-Service -MockWith {
                    return @{
                        Name = 'MSSQL$STOPPEDAGENT'
                        DisplayName = 'Microsoft SQL Server (STOPPEDAGENT)'
                        DependentServices = @(
                            @{
                                Name = 'SQLAGENT$STOPPEDAGENT'
                                DisplayName = 'SQL Server Agent (STOPPEDAGENT)'
                                Status = 'Stopped'
                                DependentServices = @()
                            }
                        )
                    }
                } -Verifiable -ParameterFilter { $Name -eq 'MSSQL$STOPPEDAGENT' }

                Mock -CommandName Restart-Service -Verifiable
                Mock -CommandName Start-Service -Verifiable
            }

            $mockDynamicStatus = 'Online'

            It 'Should restart SQL Service and running SQL Agent service' {
                { Restart-SqlService -ServerName $env:ComputerName -InstanceName 'MSSQLSERVER' } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL -ParameterFilter {
                    $PSBoundParameters.ContainsKey('ErrorAction') -eq $false
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Restart-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 1
            }

            It 'Should restart SQL Service, and not do cluster cluster check' {
                Mock -CommandName Get-CimInstance

                { Restart-SqlService -ServerName $env:ComputerName -InstanceName 'NOCLUSTERCHECK' -SkipClusterCheck } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Restart-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 0
                Assert-MockCalled -CommandName Get-CimInstance -Scope It -Exactly -Times 0
            }

            It 'Should restart SQL Service, and not do cluster cluster check nor check online status' {
                Mock -CommandName Get-CimInstance

                { Restart-SqlService -ServerName $env:ComputerName -InstanceName 'NOCONNECT' -SkipClusterCheck -SkipWaitForOnline } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Restart-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Connect-SQL -Scope It -Exactly -Times 0
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 0
                Assert-MockCalled -CommandName Get-CimInstance -Scope It -Exactly -Times 0
            }

            It 'Should restart SQL Service and not try to restart missing SQL Agent service' {
                { Restart-SqlService -ServerName $env:ComputerName -InstanceName 'NOAGENT' } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL {
                    $PSBoundParameters.ContainsKey('ErrorAction') -eq $false
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Restart-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 0
            }

            It 'Should restart SQL Service and not try to restart stopped SQL Agent service' {
                { Restart-SqlService -ServerName $env:ComputerName -InstanceName 'STOPPEDAGENT' } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL {
                    $PSBoundParameters.ContainsKey('ErrorAction') -eq $false
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Restart-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 0
            }

            Context 'When it fails to connect to the instance within the timeout period' {
                BeforeEach {
                    Mock -CommandName Connect-SQL -MockWith {
                        return @{
                            Name = 'MSSQLSERVER'
                            InstanceName = ''
                            ServiceName = 'MSSQLSERVER'
                            Status = $mockDynamicStatus
                        }
                    } -Verifiable -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }

                $mockDynamicStatus = 'Offline'

                It 'Should wait for timeout before throwing error message' {
                    $errorMessage = $localizedData.FailedToConnectToInstanceTimeout -f $env:ComputerName, 'MSSQLSERVER', 4

                    {
                        Restart-SqlService -ServerName $env:ComputerName -InstanceName 'MSSQLSERVER' -Timeout 4
                    } | Should -Throw $errorMessage

                    Assert-MockCalled -CommandName Connect-SQL -ParameterFilter {
                        $PSBoundParameters.ContainsKey('ErrorAction') -eq $false
                    } -Scope It -Exactly -Times 1

                    Assert-MockCalled -CommandName Connect-SQL -ParameterFilter {
                        $PSBoundParameters.ContainsKey('ErrorAction') -eq $true
                    } -Scope It -Exactly -Times 2
                }
            }
        }

        Context 'Restart-SqlService clustered instance' {
            BeforeEach {
                Mock -CommandName Connect-SQL -MockWith {
                    return @{
                        Name = 'MSSQLSERVER'
                        InstanceName = ''
                        ServiceName = 'MSSQLSERVER'
                        IsClustered = $true
                        Status = $mockDynamicStatus
                    }
                } -Verifiable -ParameterFilter { ($ServerName -eq 'CLU01') -and ($InstanceName -eq 'MSSQLSERVER') }

                Mock -CommandName Connect-SQL -MockWith {
                    return @{
                        Name = 'NAMEDINSTANCE'
                        InstanceName = 'NAMEDINSTANCE'
                        ServiceName = 'NAMEDINSTANCE'
                        IsClustered = $true
                        Status = $mockDynamicStatus
                    }
                } -Verifiable -ParameterFilter { ($ServerName -eq 'CLU01') -and ($InstanceName -eq 'NAMEDINSTANCE') }

                Mock -CommandName Connect-SQL -MockWith {
                    return @{
                        Name = 'STOPPEDAGENT'
                        InstanceName = 'STOPPEDAGENT'
                        ServiceName = 'STOPPEDAGENT'
                        IsClustered = $true
                        Status = $mockDynamicStatus
                    }
                } -Verifiable -ParameterFilter { ($ServerName -eq 'CLU01') -and ($InstanceName -eq 'STOPPEDAGENT') }
            }

            BeforeAll {
                Mock -CommandName Get-CimInstance -MockWith {
                    @('MSSQLSERVER','NAMEDINSTANCE','STOPPEDAGENT') | ForEach-Object {
                        $mock = New-Object -TypeName Microsoft.Management.Infrastructure.CimInstance -ArgumentList 'MSCluster_Resource','root/MSCluster'

                        $mock | Add-Member -MemberType NoteProperty -Name 'Name' -Value "SQL Server ($($_))" -TypeName 'String'
                        $mock | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'SQL Server' -TypeName 'String'
                        $mock | Add-Member -MemberType NoteProperty -Name 'PrivateProperties' -Value @{ InstanceName = $_ }

                        return $mock
                    }
                } -Verifiable -ParameterFilter { ($ClassName -eq 'MSCluster_Resource') -and ($Filter -eq "Type = 'SQL Server'") }

                Mock -CommandName Get-CimAssociatedInstance -MockWith {
                    $mock = New-Object -TypeName Microsoft.Management.Infrastructure.CimInstance -ArgumentList 'MSCluster_Resource','root/MSCluster'

                    $mock | Add-Member -MemberType NoteProperty -Name 'Name' -Value "SQL Server Agent ($($InputObject.PrivateProperties.InstanceName))" -TypeName 'String'
                    $mock | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'SQL Server Agent' -TypeName 'String'
                    $mock | Add-Member -MemberType NoteProperty -Name 'State' -Value (@{ $true = 3; $false = 2 }[($InputObject.PrivateProperties.InstanceName -eq 'STOPPEDAGENT')]) -TypeName 'Int32'

                    return $mock
                } -Verifiable -ParameterFilter { $ResultClassName -eq 'MSCluster_Resource' }

                Mock -CommandName Invoke-CimMethod -ParameterFilter { $MethodName -eq 'TakeOffline' } -Verifiable
                Mock -CommandName Invoke-CimMethod -ParameterFilter { $MethodName -eq 'BringOnline' } -Verifiable
            }

            $mockDynamicStatus = 'Online'

            It 'Should restart SQL Server and SQL Agent resources for a clustered default instance' {
                { Restart-SqlService -ServerName 'CLU01' } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL {
                    $PSBoundParameters.ContainsKey('ErrorAction') -eq $false
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CimInstance -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CimAssociatedInstance -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Invoke-CimMethod -ParameterFilter { $MethodName -eq 'TakeOffline' } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Invoke-CimMethod -ParameterFilter { $MethodName -eq 'BringOnline' } -Scope It -Exactly -Times 2
            }

            It 'Should restart SQL Server and SQL Agent resources for a clustered named instance' {
                { Restart-SqlService -ServerName 'CLU01' -InstanceName 'NAMEDINSTANCE' } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL {
                    $PSBoundParameters.ContainsKey('ErrorAction') -eq $false
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CimInstance -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CimAssociatedInstance -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Invoke-CimMethod -ParameterFilter { $MethodName -eq 'TakeOffline' } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Invoke-CimMethod -ParameterFilter { $MethodName -eq 'BringOnline' } -Scope It -Exactly -Times 2
            }

            It 'Should not try to restart a SQL Agent resource that is not online' {
                { Restart-SqlService -ServerName 'CLU01' -InstanceName 'STOPPEDAGENT' } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL {
                    $PSBoundParameters.ContainsKey('ErrorAction') -eq $false
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CimInstance -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Get-CimAssociatedInstance -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Invoke-CimMethod -ParameterFilter { $MethodName -eq 'TakeOffline' } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Invoke-CimMethod -ParameterFilter { $MethodName -eq 'BringOnline' } -Scope It -Exactly -Times 1
            }
        }
    }

    Describe 'SqlServerDsc.Common\Connect-SQLAnalysis' -Tag 'ConnectSQLAnalysis' {
        BeforeAll {
            $mockInstanceName = 'TEST'

            $mockNewObject_MicrosoftAnalysisServicesServer = {
                return New-Object -TypeName Object |
                            Add-Member -MemberType ScriptMethod -Name Connect -Value {
                                param(
                                    [Parameter(Mandatory = $true)]
                                    [ValidateNotNullOrEmpty()]
                                    [System.String]
                                    $dataSource
                                )

                                if ($dataSource -ne $mockExpectedDataSource)
                                {
                                    throw ("Datasource was expected to be '{0}', but was '{1}'." -f $mockExpectedDataSource,$dataSource)
                                }

                                if ($mockThrowInvalidOperation)
                                {
                                    throw 'Unable to connect.'
                                }
                            } -PassThru -Force
            }

            $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter = {
                $TypeName -eq 'Microsoft.AnalysisServices.Server'
            }

            $mockThrowLocalizedMessage = {
                throw $Message
            }

            $mockSqlCredentialUserName = 'TestUserName12345'
            $mockSqlCredentialPassword = 'StrongOne7.'
            $mockSqlCredentialSecurePassword = ConvertTo-SecureString -String $mockSqlCredentialPassword -AsPlainText -Force
            $mockSqlCredential = New-Object -TypeName PSCredential -ArgumentList ($mockSqlCredentialUserName, $mockSqlCredentialSecurePassword)
        }

        BeforeEach {
            Mock -CommandName New-InvalidOperationException -MockWith $mockThrowLocalizedMessage -Verifiable
            Mock -CommandName New-Object `
                -MockWith $mockNewObject_MicrosoftAnalysisServicesServer `
                -ParameterFilter $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter `
                -Verifiable
        }

        Context 'When connecting to the default instance using Windows Authentication' {
            It 'Should not throw when connecting' {
                $mockExpectedDataSource = "Data Source=$env:COMPUTERNAME"

                { Connect-SQLAnalysis } | Should -Not -Throw

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter
            }
        }

        Context 'When connecting to the named instance using Windows Authentication' {
            It 'Should not throw when connecting' {
                $mockExpectedDataSource = "Data Source=$env:COMPUTERNAME\$mockInstanceName"

                { Connect-SQLAnalysis -InstanceName $mockInstanceName } | Should -Not -Throw

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter
            }
        }

        Context 'When connecting to the named instance using Windows Authentication impersonation' {
            It 'Should not throw when connecting' {
                $mockExpectedDataSource = "Data Source=$env:COMPUTERNAME\$mockInstanceName;User ID=$mockSqlCredentialUserName;Password=$mockSqlCredentialPassword"

                { Connect-SQLAnalysis -InstanceName $mockInstanceName -SetupCredential $mockSqlCredential } | Should -Not -Throw

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter
            }
        }

        Context 'When connecting to the default instance using the correct service instance but does not return a correct Analysis Service object' {
            It 'Should throw the correct error' {
                $mockExpectedDataSource = ''

                Mock -CommandName New-Object `
                    -ParameterFilter $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter `
                    -Verifiable

                $mockCorrectErrorMessage = ($script:localizedData.FailedToConnectToAnalysisServicesInstance -f $env:COMPUTERNAME)
                { Connect-SQLAnalysis } | Should -Throw $mockCorrectErrorMessage

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter
            }
        }

        Context 'When connecting to the default instance using a Analysis Service instance that does not exist' {
            It 'Should throw the correct error' {
                $mockExpectedDataSource = "Data Source=$env:COMPUTERNAME"

                # Force the mock of Connect() method to throw 'Unable to connect.'
                $mockThrowInvalidOperation = $true

                $mockCorrectErrorMessage = ($script:localizedData.FailedToConnectToAnalysisServicesInstance -f $env:COMPUTERNAME)
                { Connect-SQLAnalysis } | Should -Throw $mockCorrectErrorMessage

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter

                # Setting it back to the default so it does not disturb other tests.
                $mockThrowInvalidOperation = $false
            }
        }

        # This test is to test the mock so that it throws correct when data source is not the expected data source
        Context 'When connecting to the named instance using another data source then expected' {
            It 'Should throw the correct error' {
                $mockExpectedDataSource = "Force wrong data source"

                $testParameters = @{
                    ServerName = 'DummyHost'
                    InstanceName = $mockInstanceName
                }

                $mockCorrectErrorMessage = ($script:localizedData.FailedToConnectToAnalysisServicesInstance -f "$($testParameters.ServerName)\$($testParameters.InstanceName)")
                { Connect-SQLAnalysis @testParameters } | Should -Throw $mockCorrectErrorMessage

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftAnalysisServicesServer_ParameterFilter
            }
        }

        Assert-VerifiableMock
    }

    Describe 'SqlServerDsc.Common\Invoke-Query' -Tag 'InvokeQuery' {
        BeforeAll {
            $mockExpectedQuery = ''

            $mockSqlCredentialUserName = 'TestUserName12345'
            $mockSqlCredentialPassword = 'StrongOne7.'
            $mockSqlCredentialSecurePassword = ConvertTo-SecureString -String $mockSqlCredentialPassword -AsPlainText -Force
            $mockSqlCredential = New-Object -TypeName PSCredential -ArgumentList ($mockSqlCredentialUserName, $mockSqlCredentialSecurePassword)

            $masterDatabaseObject = New-Object -TypeName PSObject
            $masterDatabaseObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value 'master'
            $masterDatabaseObject | Add-Member -MemberType ScriptMethod -Name 'ExecuteNonQuery' -Value {
                param
                (
                    [Parameter()]
                    [System.String]
                    $sqlCommand
                )

                if ( $sqlCommand -ne $mockExpectedQuery )
                {
                    throw
                }
            }

            $masterDatabaseObject | Add-Member -MemberType ScriptMethod -Name 'ExecuteWithResults' -Value {
                param
                (
                    [Parameter()]
                    [System.String]
                    $sqlCommand
                )

                if ( $sqlCommand -ne $mockExpectedQuery )
                {
                    throw
                }

                return New-Object -TypeName System.Data.DataSet
            }

            $databasesObject = New-Object -TypeName PSObject
            $databasesObject | Add-Member -MemberType NoteProperty -Name 'Databases' -Value @{
                'master' = $masterDatabaseObject
            }

            $mockSMOServer = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.Server'
            $mockSMOServer | Add-Member -MemberType NoteProperty -Name 'Databases' -Value @{
                'master' = $masterDatabaseObject
            } -Force

            $mockConnectSql = {
                return @($databasesObject)
            }

            $mockThrowLocalizedMessage = {
                throw $Message
            }
        }

        BeforeEach {
            Mock -CommandName Connect-SQL -MockWith $mockConnectSql -ModuleName $script:dscResourceName -Verifiable
            Mock -CommandName New-InvalidOperationException -MockWith $mockThrowLocalizedMessage -Verifiable
        }

        $queryParameters = @{
            ServerName         = 'Server1'
            InstanceName       = 'MSSQLSERVER'
            Database           = 'master'
            Query              = ''
            DatabaseCredential = $mockSqlCredential
        }

        $queryParametersWithSMO = @{
            Query              = ''
            SqlServerObject    = $mockSMOServer
            Database           = 'master'
        }

        Context 'When executing a query with no results' {
            AfterEach {
                Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 1 -Exactly
            }

            It 'Should execute the query silently' {
                $queryParameters.Query = "EXEC sp_configure 'show advanced option', '1'"
                $mockExpectedQuery = $queryParameters.Query.Clone()

                { Invoke-Query @queryParameters } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL -ParameterFilter {
                    # Should not be called with a login type.
                    $PSBoundParameters.ContainsKey('LoginType') -eq $false
                } -Scope It -Times 1 -Exactly
            }

            It 'Should throw the correct error, ExecuteNonQueryFailed, when executing the query fails' {
                $queryParameters.Query = 'BadQuery'

                { Invoke-Query @queryParameters } | Should -Throw (
                    $script:localizedData.ExecuteNonQueryFailed -f $queryParameters.Database
                )
            }

            Context 'When text should be redacted' {
                BeforeAll {
                    Mock -CommandName Write-Verbose -ParameterFilter {
                        $Message -eq (
                            $script:localizedData.ExecuteNonQuery -f
                                "select * from MyTable where password = '*******' and password = '*******'"
                        )
                    } -MockWith {
                        <#
                            MUST return another message than the parameter filter
                            is looking for, otherwise we get into a endless loop.
                            We returning the to show in the output how the verbose
                            message was redacted.
                        #>
                        Write-Verbose -Message ('MOCK OUTPUT: {0}' -f $Message) -Verbose
                    }
                }

                It 'Should execute the query silently and redact text in the verbose output' {
                    $queryParameters.Query = "select * from MyTable where password = 'Pa\ssw0rd1' and password = 'secret passphrase'"
                    $mockExpectedQuery = $queryParameters.Query.Clone()

                    # The `Secret PassPhrase` is using the casing like this to test case-insensitive replace.
                    { Invoke-Query @queryParameters -RedactText @('Pa\sSw0rd1','Secret PassPhrase') } | Should -Not -Throw
                }
            }
        }

        Context 'When executing a query with no results using Windows impersonation' {
            It 'Should execute the query silently' {
                $testParameters = $queryParameters.Clone()
                $testParameters.LoginType = 'WindowsUser'
                $testParameters.Query = "EXEC sp_configure 'show advanced option', '1'"
                $mockExpectedQuery = $testParameters.Query.Clone()

                { Invoke-Query @testParameters } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL -ParameterFilter {
                    $LoginType -eq 'WindowsUser'
                } -Scope It -Times 1 -Exactly
            }
        }

        Context 'when executing a query with no results using SQL impersonation' {
            It 'Should execute the query silently' {
                $testParameters = $queryParameters.Clone()
                $testParameters.LoginType = 'SqlLogin'
                $testParameters.Query = "EXEC sp_configure 'show advanced option', '1'"
                $mockExpectedQuery = $testParameters.Query.Clone()

                { Invoke-Query @testParameters } | Should -Not -Throw

                Assert-MockCalled -CommandName Connect-SQL -ParameterFilter {
                    $LoginType -eq 'SqlLogin'
                } -Scope It -Times 1 -Exactly
            }
        }

        Context 'when executing a query with results' {
            It 'Should execute the query and return a result set' {
                $queryParameters.Query = 'SELECT name FROM sys.databases'
                $mockExpectedQuery = $queryParameters.Query.Clone()

                Invoke-Query @queryParameters -WithResults | Should -Not -BeNullOrEmpty

                Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 1 -Exactly
            }

            It 'Should throw the correct error, ExecuteQueryWithResultsFailed, when executing the query fails' {
                $queryParameters.Query = 'BadQuery'

                { Invoke-Query @queryParameters -WithResults } | Should -Throw (
                    $script:localizedData.ExecuteQueryWithResultsFailed -f $queryParameters.Database
                )

                Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 1 -Exactly
            }

            Context 'When text should be redacted' {
                BeforeAll {
                    Mock -CommandName Write-Verbose -ParameterFilter {
                        $Message -eq (
                            $script:localizedData.ExecuteQueryWithResults -f
                                "select * from MyTable where password = '*******' and password = '*******'"
                        )
                    } -MockWith {
                        <#
                            MUST return another message than the parameter filter
                            is looking for, otherwise we get into a endless loop.
                            We returning the to show in the output how the verbose
                            message was redacted.
                        #>
                        Write-Verbose -Message ('MOCK OUTPUT: {0}' -f $Message) -Verbose
                    }
                }

                It 'Should execute the query silently and redact text in the verbose output' {
                    $queryParameters.Query = "select * from MyTable where password = 'Pa\ssw0rd1' and password = 'secret passphrase'"
                    $mockExpectedQuery = $queryParameters.Query.Clone()

                    # The `Secret PassPhrase` is using the casing like this to test case-insensitive replace.
                    { Invoke-Query @queryParameters -RedactText @('Pa\sSw0rd1','Secret PassPhrase') -WithResults } | Should -Not -Throw
                }
            }
        }

        Context 'When passing in an SMO Server Object' {
            Context 'Execute a query with no results' {
                It 'Should execute the query silently' {
                    $queryParametersWithSMO.Query = "EXEC sp_configure 'show advanced option', '1'"
                    $mockExpectedQuery = $queryParametersWithSMO.Query.Clone()

                    { Invoke-Query @queryParametersWithSMO } | Should -Not -Throw

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 0 -Exactly
                }

                It 'Should throw the correct error, ExecuteNonQueryFailed, when executing the query fails' {
                    $queryParametersWithSMO.Query = 'BadQuery'

                    { Invoke-Query @queryParametersWithSMO } | Should -Throw (
                        $script:localizedData.ExecuteNonQueryFailed -f $queryParameters.Database
                    )

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 0 -Exactly
                }
            }

            Context 'When executing a query with results' {
                It 'Should execute the query and return a result set' {
                    $queryParametersWithSMO.Query = 'SELECT name FROM sys.databases'
                    $mockExpectedQuery = $queryParametersWithSMO.Query.Clone()

                    Invoke-Query @queryParametersWithSMO -WithResults | Should -Not -BeNullOrEmpty

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 0 -Exactly
                }

                It 'Should throw the correct error, ExecuteQueryWithResultsFailed, when executing the query fails' {
                    $queryParametersWithSMO.Query = 'BadQuery'

                    { Invoke-Query @queryParametersWithSMO -WithResults } | Should -Throw (
                        $script:localizedData.ExecuteQueryWithResultsFailed -f $queryParameters.Database
                    )

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 0 -Exactly
                }
            }

            Context 'When executing a query with piped SMO server object' {
                It 'Should execute the query and return a result set' {
                    $mockQuery = 'SELECT name FROM sys.databases'
                    $mockExpectedQuery = $mockQuery

                    $mockSMOServer | Invoke-Query -Query $mockQuery -Database master -WithResults |
                        Should -Not -BeNullOrEmpty

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 0 -Exactly
                }

                It 'Should throw the correct error, ExecuteQueryWithResultsFailed, when executing the query fails' {
                    $mockQuery = 'BadQuery'

                    { $mockSMOServer | Invoke-Query -Query $mockQuery -Database master -WithResults } |
                        Should -Throw (
                            $script:localizedData.ExecuteQueryWithResultsFailed -f $queryParameters.Database
                        )

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 0 -Exactly
                }
            }
        }
    }

    Describe 'SqlServerDsc.Common\Update-AvailabilityGroupReplica' -Tag 'UpdateAvailabilityGroupReplica' {
        Context 'When the Availability Group Replica is altered' {
            It 'Should silently alter the Availability Group Replica' {
                $availabilityReplica = New-Object -TypeName Microsoft.SqlServer.Management.Smo.AvailabilityReplica

                { Update-AvailabilityGroupReplica -AvailabilityGroupReplica $availabilityReplica } | Should -Not -Throw

            }

            It 'Should throw the correct error, AlterAvailabilityGroupReplicaFailed, when altering the Availability Group Replica fails' {
                $availabilityReplica = New-Object -TypeName Microsoft.SqlServer.Management.Smo.AvailabilityReplica
                $availabilityReplica.Name = 'AlterFailed'

                { Update-AvailabilityGroupReplica -AvailabilityGroupReplica $availabilityReplica } | Should -Throw ($script:localizedData.AlterAvailabilityGroupReplicaFailed -f $availabilityReplica.Name)
            }
        }
    }

    Describe 'SqlServerDsc.Common\Test-LoginEffectivePermissions' -Tag 'TestLoginEffectivePermissions' {

        $mockAllServerPermissionsPresent = @(
            'Connect SQL',
            'Alter Any Availability Group',
            'View Server State'
        )

        $mockServerPermissionsMissing = @(
            'Connect SQL',
            'View Server State'
        )

        $mockAllLoginPermissionsPresent = @(
            'View Definition',
            'Impersonate'
        )

        $mockLoginPermissionsMissing = @(
            'View Definition'
        )

        $mockInvokeQueryPermissionsSet = @() # Will be set dynamically in the check

        $mockInvokeQueryPermissionsResult = {
            return New-Object -TypeName PSObject -Property @{
                Tables = @{
                    Rows = @{
                        permission_name = $mockInvokeQueryPermissionsSet
                    }
                }
            }
        }

        $testLoginEffectiveServerPermissionsParams = @{
            ServerName = 'Server1'
            InstanceName = 'MSSQLSERVER'
            Login = 'NT SERVICE\ClusSvc'
            Permissions = @()
        }

        $testLoginEffectiveLoginPermissionsParams = @{
            ServerName = 'Server1'
            InstanceName = 'MSSQLSERVER'
            Login = 'NT SERVICE\ClusSvc'
            Permissions = @()
            SecurableClass = 'LOGIN'
            SecurableName = 'Login1'
        }

        BeforeEach {
            Mock -CommandName Invoke-Query -MockWith $mockInvokeQueryPermissionsResult -Verifiable
        }

        Context 'When all of the permissions are present' {
            It 'Should return $true when the desired server permissions are present' {
                $mockInvokeQueryPermissionsSet = $mockAllServerPermissionsPresent.Clone()
                $testLoginEffectiveServerPermissionsParams.Permissions = $mockAllServerPermissionsPresent.Clone()

                Test-LoginEffectivePermissions @testLoginEffectiveServerPermissionsParams | Should -Be $true

                Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 1 -Exactly
            }

            It 'Should return $true when the desired login permissions are present' {
                $mockInvokeQueryPermissionsSet = $mockAllLoginPermissionsPresent.Clone()
                $testLoginEffectiveLoginPermissionsParams.Permissions = $mockAllLoginPermissionsPresent.Clone()

                Test-LoginEffectivePermissions @testLoginEffectiveLoginPermissionsParams | Should -Be $true

                Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 1 -Exactly
            }
        }

        Context 'When a permission is missing' {
            It 'Should return $false when the desired server permissions are not present' {
                $mockInvokeQueryPermissionsSet = $mockServerPermissionsMissing.Clone()
                $testLoginEffectiveServerPermissionsParams.Permissions = $mockAllServerPermissionsPresent.Clone()

                Test-LoginEffectivePermissions @testLoginEffectiveServerPermissionsParams | Should -Be $false

                Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 1 -Exactly
            }

            It 'Should return $false when the specified login has no server permissions assigned' {
                $mockInvokeQueryPermissionsSet = @()
                $testLoginEffectiveServerPermissionsParams.Permissions = $mockAllServerPermissionsPresent.Clone()

                Test-LoginEffectivePermissions @testLoginEffectiveServerPermissionsParams | Should -Be $false

                Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 1 -Exactly
            }

            It 'Should return $false when the desired login permissions are not present' {
                $mockInvokeQueryPermissionsSet = $mockLoginPermissionsMissing.Clone()
                $testLoginEffectiveLoginPermissionsParams.Permissions = $mockAllLoginPermissionsPresent.Clone()

                Test-LoginEffectivePermissions @testLoginEffectiveLoginPermissionsParams | Should -Be $false

                Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 1 -Exactly
            }

            It 'Should return $false when the specified login has no login permissions assigned' {
                $mockInvokeQueryPermissionsSet = @()
                $testLoginEffectiveLoginPermissionsParams.Permissions = $mockAllLoginPermissionsPresent.Clone()

                Test-LoginEffectivePermissions @testLoginEffectiveLoginPermissionsParams | Should -Be $false

                Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 1 -Exactly
            }
        }
    }

    Describe 'SqlServerDsc.Common\Import-SQLPSModule' -Tag 'ImportSQLPSModule' {
        BeforeAll {
            <#
                This is the path to the latest version of SQLPS, to test that only the
                newest SQLPS module is returned.
            #>
            $sqlPsLatestModulePath = 'C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS\Sqlps.ps1'

            <#
                For SQLPS module this should be the root of the module.
                The .psd1 file is parsed from the module full path in the code.
            #>
            $sqlPsExpectedModulePath = Split-Path -Path $sqlPsLatestModulePath -Parent


            $mockImportModule = {
                if ($Name -ne $mockExpectedModuleNameToImport)
                {
                    throw ('Wrong module was loaded. Expected {0}, but was {1}.' -f $mockExpectedModuleNameToImport, $Name[0])
                }

                switch ($Name)
                {
                    'SqlServer'
                    {
                        $importModuleResult = @{
                                ModuleType = 'Script'
                                Version = '21.0.17279'
                                Name = $Name
                            }
                    }

                    $sqlPsExpectedModulePath
                    {
                        # Can not use $Name because that contain the path to the module manifest.
                        $importModuleResult = @(
                            @{
                                ModuleType = 'Script'
                                Version = '0.0'
                                # Intentionally formatted to correctly mimic a real run.
                                Name = 'Sqlps'
                                Path = $sqlPsLatestModulePath
                            }
                            @{
                                ModuleType = 'Manifest'
                                Version = '1.0'
                                # Intentionally formatted to correctly mimic a real run.
                                Name = 'sqlps'
                                Path = $sqlPsLatestModulePath
                            }
                        )
                    }
                }

                return $importModuleResult
            }

            $mockGetModuleSqlServer = {
                # Return an array to test so that the latest version is only imported.
                return @(
                    New-Object -TypeName PSObject -Property @{
                        Name = 'SqlServer'
                        Version = [Version] '1.0'
                    }

                    New-Object -TypeName PSObject -Property @{
                        Name = 'SqlServer'
                        Version = [Version] '2.0'
                    }
                )
            }

            $mockGetModuleSqlPs = {
                # Return an array to test so that the latest version is only imported.
                return @(
                    New-Object -TypeName PSObject -Property @{
                        Name = 'SQLPS'
                        # This is a path to an older version of SQL PS than $sqlPsLatestModulePath.
                        Path = 'C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS\Sqlps.ps1'
                    }

                    New-Object -TypeName PSObject -Property @{
                        Name = 'SQLPS'
                        Path = $sqlPsLatestModulePath
                    }
                )
            }

            $mockGetModule_SqlServer_ParameterFilter = {
                $FullyQualifiedName.Name -eq 'SqlServer' -and $ListAvailable -eq $true
            }

            $mockGetModule_SQLPS_ParameterFilter = {
                $FullyQualifiedName.Name -eq 'SQLPS' -and $ListAvailable -eq $true
            }

            $mockThrowLocalizedMessage = {
                throw $Message
            }
        }

        BeforeEach {
            Mock -CommandName Push-Location -Verifiable
            Mock -CommandName Pop-Location -Verifiable
            Mock -CommandName Import-Module -MockWith $mockImportModule -Verifiable
            Mock -CommandName New-InvalidOperationException -MockWith $mockThrowLocalizedMessage -Verifiable
        }

        Context 'When module SqlServer is already loaded into the session' {
            BeforeAll {
                Mock -CommandName Get-Module -MockWith {
                    return @{
                        Name = 'SqlServer'
                    }
                }
            }

            It 'Should use the already loaded module and not call Import-Module' {
                { Import-SQLPSModule } | Should -Not -Throw

                Assert-MockCalled -CommandName Import-Module -Exactly -Times 0 -Scope It
            }
        }

        Context 'When module SQLPS is already loaded into the session' {
            BeforeAll {
                Mock -CommandName Get-Module -MockWith {
                    return @{
                        Name = 'SQLPS'
                    }
                }
            }

            It 'Should use the already loaded module and not call Import-Module' {
                { Import-SQLPSModule } | Should -Not -Throw

                Assert-MockCalled -CommandName Import-Module -Exactly -Times 0 -Scope It
            }
        }

        Context 'When module SqlServer exists, but not loaded into the session' {
            BeforeAll {
                Mock -CommandName Get-Module -ParameterFilter {
                    $PSBoundParameters.ContainsKey('Name') -eq $true
                }

                $mockExpectedModuleNameToImport = 'SqlServer'
            }

            It 'Should import the SqlServer module without throwing' {
                Mock -CommandName Get-Module -MockWith $mockGetModuleSqlServer -ParameterFilter $mockGetModule_SqlServer_ParameterFilter -Verifiable

                { Import-SQLPSModule } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Module -ParameterFilter $mockGetModule_SqlServer_ParameterFilter -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Push-Location -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Pop-Location -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Import-Module -Exactly -Times 1 -Scope It
            }
        }

        Context 'When only module SQLPS exists, but not loaded into the session, and using -Force' {
            BeforeAll {
                Mock -CommandName Remove-Module
                Mock -CommandName Get-Module -ParameterFilter {
                    $PSBoundParameters.ContainsKey('Name') -eq $true
                }

                $mockExpectedModuleNameToImport = $sqlPsExpectedModulePath
            }

            It 'Should import the SqlServer module without throwing' {
                Mock -CommandName Get-Module -MockWith $mockGetModuleSqlPs -ParameterFilter $mockGetModule_SQLPS_ParameterFilter -Verifiable
                Mock -CommandName Get-Module -MockWith {
                    return $null
                } -ParameterFilter $mockGetModule_SqlServer_ParameterFilter -Verifiable

                { Import-SQLPSModule -Force } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Module -ParameterFilter $mockGetModule_SqlServer_ParameterFilter -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Get-Module -ParameterFilter $mockGetModule_SQLPS_ParameterFilter -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Push-Location -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Pop-Location -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Remove-Module -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Import-Module -Exactly -Times 1 -Scope It
            }
        }

        Context 'When neither SqlServer or SQLPS exists' {
            $mockExpectedModuleNameToImport = $sqlPsExpectedModulePath

            It 'Should throw the correct error message' {
                Mock -CommandName Get-Module

                { Import-SQLPSModule } | Should -Throw $script:localizedData.PowerShellSqlModuleNotFound

                Assert-MockCalled -CommandName Get-Module -ParameterFilter $mockGetModule_SqlServer_ParameterFilter -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Get-Module -ParameterFilter $mockGetModule_SQLPS_ParameterFilter -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Push-Location -Exactly -Times 0 -Scope It
                Assert-MockCalled -CommandName Pop-Location -Exactly -Times 0 -Scope It
                Assert-MockCalled -CommandName Import-Module -Exactly -Times 0 -Scope It
            }
        }

        Context 'When Import-Module fails to load the module' {
            $mockExpectedModuleNameToImport = 'SqlServer'

            It 'Should throw the correct error message' {
                $errorMessage = 'Mock Import-Module throwing a mocked error.'
                Mock -CommandName Get-Module -MockWith $mockGetModuleSqlServer -ParameterFilter $mockGetModule_SqlServer_ParameterFilter -Verifiable
                Mock -CommandName Import-Module -MockWith {
                    throw $errorMessage
                }

                { Import-SQLPSModule } | Should -Throw ($script:localizedData.FailedToImportPowerShellSqlModule -f $mockExpectedModuleNameToImport)

                Assert-MockCalled -CommandName Get-Module -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Push-Location -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Pop-Location -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Import-Module -Exactly -Times 1 -Scope It
            }
        }

        # This is to test the tests (so the mock throws correctly)
        Context 'When mock Import-Module is called with wrong module name' {
            $mockExpectedModuleNameToImport = 'UnknownModule'

            It 'Should throw the correct error message' {
                Mock -CommandName Get-Module -MockWith $mockGetModuleSqlServer -ParameterFilter $mockGetModule_SqlServer_ParameterFilter -Verifiable

                { Import-SQLPSModule } | Should -Throw ($script:localizedData.FailedToImportPowerShellSqlModule -f 'SqlServer')

                Assert-MockCalled -CommandName Get-Module -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Push-Location -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Pop-Location -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Import-Module -Exactly -Times 1 -Scope It
            }
        }

        Assert-VerifiableMock
    }

    Describe 'SqlServerDsc.Common\Get-SqlInstanceMajorVersion' -Tag 'GetSqlInstanceMajorVersion' {
        BeforeAll {
            $mockSqlMajorVersion = 13
            $mockInstanceName = 'TEST'

            $mockGetItemProperty_MicrosoftSQLServer_InstanceNames_SQL = {
                return @(
                    (
                        New-Object -TypeName Object |
                            Add-Member -MemberType NoteProperty -Name $mockInstanceName -Value $mockInstance_InstanceId -PassThru -Force
                    )
                )
            }

            $mockGetItemProperty_MicrosoftSQLServer_FullInstanceId_Setup = {
                return @(
                    (
                        New-Object -TypeName Object |
                            Add-Member -MemberType NoteProperty -Name 'Version' -Value "$($mockSqlMajorVersion).0.4001.0" -PassThru -Force
                    )
                )
            }

            $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_InstanceNames_SQL = {
                $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'
            }

            $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_FullInstanceId_Setup = {
                $Path -eq "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$mockInstance_InstanceId\Setup"
            }
        }

        BeforeEach {
            Mock -CommandName Get-ItemProperty `
                -ParameterFilter $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_InstanceNames_SQL `
                -MockWith $mockGetItemProperty_MicrosoftSQLServer_InstanceNames_SQL `
                -Verifiable

            Mock -CommandName Get-ItemProperty `
                -ParameterFilter $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_FullInstanceId_Setup `
                -MockWith $mockGetItemProperty_MicrosoftSQLServer_FullInstanceId_Setup `
                -Verifiable
        }

        $mockInstance_InstanceId = "MSSQL$($mockSqlMajorVersion).$($mockInstanceName)"

        Context 'When calling Get-SqlInstanceMajorVersion' {
            It 'Should return the correct major SQL version number' {
                $result = Get-SqlInstanceMajorVersion -InstanceName $mockInstanceName
                $result | Should -Be $mockSqlMajorVersion

                Assert-MockCalled -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_InstanceNames_SQL

                Assert-MockCalled -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_FullInstanceId_Setup
            }
        }

        Context 'When calling Get-SqlInstanceMajorVersion and nothing is returned' {
            It 'Should throw the correct error' {
                Mock -CommandName Get-ItemProperty `
                    -ParameterFilter $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_FullInstanceId_Setup `
                    -MockWith {
                        return New-Object -TypeName Object
                    } -Verifiable

                $mockCorrectErrorMessage = ($script:localizedData.SqlServerVersionIsInvalid -f $mockInstanceName)
                { Get-SqlInstanceMajorVersion -InstanceName $mockInstanceName } | Should -Throw $mockCorrectErrorMessage

                Assert-MockCalled -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_InstanceNames_SQL

                Assert-MockCalled -CommandName Get-ItemProperty -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockGetItemProperty_ParameterFilter_MicrosoftSQLServer_FullInstanceId_Setup
            }
        }

        Assert-VerifiableMock
    }

    Describe 'SqlServerDsc.Common\Get-PrimaryReplicaServerObject' -Tag 'GetPrimaryReplicaServerObject' {
        BeforeEach {
            $mockServerObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server
            $mockServerObject.DomainInstanceName = 'Server1'

            $mockAvailabilityGroup = New-Object -TypeName Microsoft.SqlServer.Management.Smo.AvailabilityGroup
            $mockAvailabilityGroup.PrimaryReplicaServerName = 'Server1'
        }

        $mockConnectSql = {
            Param
            (
                [Parameter()]
                [System.String]
                $ServerName,

                [Parameter()]
                [System.String]
                $InstanceName
            )

            $mock = @(
                (
                    New-Object -TypeName Object |
                        Add-Member -MemberType NoteProperty -Name 'DomainInstanceName' -Value $ServerName -PassThru
                )
            )

            # Type the mock as a server object
            $mock.PSObject.TypeNames.Insert(0,'Microsoft.SqlServer.Management.Smo.Server')

            return $mock
        }

        Mock -CommandName Connect-SQL -MockWith $mockConnectSql -Verifiable

        Context 'When the supplied server object is the primary replica' {
            It 'Should return the same server object that was supplied' {
                $result = Get-PrimaryReplicaServerObject -ServerObject $mockServerObject -AvailabilityGroup $mockAvailabilityGroup

                $result.DomainInstanceName | Should -Be $mockServerObject.DomainInstanceName
                $result.DomainInstanceName | Should -Be $mockAvailabilityGroup.PrimaryReplicaServerName

                Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 0 -Exactly
            }

            It 'Should return the same server object that was supplied when the PrimaryReplicaServerNameProperty is empty' {
                $mockAvailabilityGroup.PrimaryReplicaServerName = ''

                $result = Get-PrimaryReplicaServerObject -ServerObject $mockServerObject -AvailabilityGroup $mockAvailabilityGroup

                $result.DomainInstanceName | Should -Be $mockServerObject.DomainInstanceName
                $result.DomainInstanceName | Should -Not -Be $mockAvailabilityGroup.PrimaryReplicaServerName

                Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 0 -Exactly
            }
        }

        Context 'When the supplied server object is not the primary replica' {
            It 'Should the server object of the primary replica' {
                $mockAvailabilityGroup.PrimaryReplicaServerName = 'Server2'

                $result = Get-PrimaryReplicaServerObject -ServerObject $mockServerObject -AvailabilityGroup $mockAvailabilityGroup

                $result.DomainInstanceName | Should -Not -Be $mockServerObject.DomainInstanceName
                $result.DomainInstanceName | Should -Be $mockAvailabilityGroup.PrimaryReplicaServerName

                Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 1 -Exactly
            }
        }
    }

    Describe 'SqlServerDsc.Common\Test-AvailabilityReplicaSeedingModeAutomatic' -Tag 'TestAvailabilityReplicaSeedingModeAutomatic' {

        BeforeEach {
            $mockSqlVersion = 13
            $mockConnectSql = {
                Param
                (
                    [Parameter()]
                    [System.String]
                    $ServerName,

                    [Parameter()]
                    [System.String]
                    $InstanceName
                )

                $mock = @(
                    (
                        New-Object -TypeName Object |
                            Add-Member -MemberType NoteProperty -Name 'Version' -Value $mockSqlVersion -PassThru
                    )
                )

                # Type the mock as a server object
                $mock.PSObject.TypeNames.Insert(0,'Microsoft.SqlServer.Management.Smo.Server')

                return $mock
            }

            $mockSeedingMode = 'Manual'
            $mockInvokeQuery = {
                return @{
                    Tables = @{
                        Rows = @{
                            seeding_mode_desc = $mockSeedingMode
                        }
                    }
                }
            }

            Mock -CommandName Connect-SQL -MockWith $mockConnectSql -Verifiable
            Mock -CommandName Invoke-Query -MockWith $mockInvokeQuery -Verifiable
        }

        $testAvailabilityReplicaSeedingModeAutomaticParams = @{
            ServerName              = 'Server1'
            InstanceName            = 'MSSQLSERVER'
            AvailabilityGroupName   = 'Group1'
            AvailabilityReplicaName = 'Replica2'
        }

        Context 'When the replica seeding mode is manual' {
            # Test SQL 2012 and 2014. Not testing earlier versions because Availability Groups were introduced in SQL 2012.
            foreach ( $instanceVersion in @(11,12) )
            {
                It ( 'Should return $false when the instance version is {0}' -f $instanceVersion ) {
                    $mockSqlVersion = $instanceVersion

                    Test-AvailabilityReplicaSeedingModeAutomatic @testAvailabilityReplicaSeedingModeAutomaticParams | Should -Be $false

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 1 -Exactly
                    Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 0 -Exactly
                }
            }

            # Test SQL 2016 and later
            foreach ( $instanceVersion in @(13,14) )
            {
                It ( 'Should return $false when the instance version is {0} and the replica seeding mode is manual' -f $instanceVersion ) {
                    $mockSqlVersion = $instanceVersion

                    Test-AvailabilityReplicaSeedingModeAutomatic @testAvailabilityReplicaSeedingModeAutomaticParams | Should -Be $false

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 1 -Exactly
                    Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 1 -Exactly
                }
            }
        }

        Context 'When the replica seeding mode is automatic' {
            # Test SQL 2016 and later
            foreach ( $instanceVersion in @(13,14) )
            {
                It ( 'Should return $true when the instance version is {0} and the replica seeding mode is automatic' -f $instanceVersion ) {
                    $mockSqlVersion = $instanceVersion
                    $mockSeedingMode = 'Automatic'

                    Test-AvailabilityReplicaSeedingModeAutomatic @testAvailabilityReplicaSeedingModeAutomaticParams | Should -Be $true

                    Assert-MockCalled -CommandName Connect-SQL -Scope It -Times 1 -Exactly
                    Assert-MockCalled -CommandName Invoke-Query -Scope It -Times 1 -Exactly
                }
            }
        }
    }

    Describe 'SqlServerDsc.Common\Test-ImpersonatePermissions' -Tag 'TestImpersonatePermissions' {
        BeforeAll {
            $mockTestLoginEffectivePermissions_ImpersonateAnyLogin_ParameterFilter = {
                $Permissions -eq @('IMPERSONATE ANY LOGIN')
            }

            $mockTestLoginEffectivePermissions_ControlServer_ParameterFilter = {
                $Permissions -eq @('CONTROL SERVER')
            }

            $mockTestLoginEffectivePermissions_ImpersonateLogin_ParameterFilter = {
                $Permissions -eq @('IMPERSONATE')
            }

            $mockTestLoginEffectivePermissions_ControlLogin_ParameterFilter = {
                $Permissions -eq @('CONTROL')
            }

            $mockConnectionContextObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.ServerConnection
            $mockConnectionContextObject.TrueLogin = 'Login1'

            $mockServerObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server
            $mockServerObject.ComputerNamePhysicalNetBIOS = 'Server1'
            $mockServerObject.ServiceName = 'MSSQLSERVER'
            $mockServerObject.ConnectionContext = $mockConnectionContextObject
        }

        BeforeEach {
            Mock -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateAnyLogin_ParameterFilter -MockWith { $false } -Verifiable
            Mock -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlServer_ParameterFilter -MockWith { $false } -Verifiable
            Mock -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateLogin_ParameterFilter -MockWith { $false } -Verifiable
            Mock -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlLogin_ParameterFilter -MockWith { $false } -Verifiable
        }

        Context 'When impersonate permissions are present for the login' {
            It 'Should return true when the impersonate any login permissions are present for the login' {
                Mock -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateAnyLogin_ParameterFilter -MockWith { $true } -Verifiable
                Test-ImpersonatePermissions -ServerObject $mockServerObject | Should -Be $true

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateAnyLogin_ParameterFilter -Scope It -Times 1 -Exactly
            }

            It 'Should return true when the control server permissions are present for the login' {
                Mock -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlServer_ParameterFilter -MockWith { $true } -Verifiable
                Test-ImpersonatePermissions -ServerObject $mockServerObject | Should -Be $true

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlServer_ParameterFilter -Scope It -Times 1 -Exactly
            }

            It 'Should return true when the impersonate login permissions are present for the login' {
                Mock -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateLogin_ParameterFilter -MockWith { $true } -Verifiable
                Test-ImpersonatePermissions -ServerObject $mockServerObject -SecurableName 'Login1' | Should -Be $true

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateLogin_ParameterFilter -Scope It -Times 1 -Exactly
            }

            It 'Should return true when the control login permissions are present for the login' {
                Mock -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlLogin_ParameterFilter -MockWith { $true } -Verifiable
                Test-ImpersonatePermissions -ServerObject $mockServerObject -SecurableName 'Login1' | Should -Be $true

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlLogin_ParameterFilter -Scope It -Times 1 -Exactly
            }
        }

        Context 'When impersonate permissions are missing for the login' {
            It 'Should return false when the server permissions are missing for the login' {
                Test-ImpersonatePermissions -ServerObject $mockServerObject | Should -Be $false

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateAnyLogin_ParameterFilter -Scope It -Times 1 -Exactly
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlServer_ParameterFilter -Scope It -Times 1 -Exactly
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateLogin_ParameterFilter -Scope It -Times 0 -Exactly
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlLogin_ParameterFilter -Scope It -Times 0 -Exactly
            }

            It 'Should return false when the login permissions are missing for the login' {
                Test-ImpersonatePermissions -ServerObject $mockServerObject -SecurableName 'Login1' | Should -Be $false

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateAnyLogin_ParameterFilter -Scope It -Times 1 -Exactly
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlServer_ParameterFilter -Scope It -Times 1 -Exactly
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ImpersonateLogin_ParameterFilter -Scope It -Times 1 -Exactly
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -ParameterFilter $mockTestLoginEffectivePermissions_ControlLogin_ParameterFilter -Scope It -Times 1 -Exactly
            }
        }
    }

    Describe 'SqlServerDsc.Common\Connect-SQL' -Tag 'ConnectSql' {
        BeforeAll {
            $mockNewObject_MicrosoftDatabaseEngine = {
                <#
                    $ArgumentList[0] will contain the ServiceInstance when calling mock New-Object.
                    But since the mock New-Object will also be called without arguments, we first
                    have to evaluate if $ArgumentList contains values.
                #>
                if( $ArgumentList.Count -gt 0)
                {
                    $serverInstance = $ArgumentList[0]
                }

                return New-Object -TypeName Object |
                    Add-Member -MemberType ScriptProperty -Name Status -Value {
                        if ($mockExpectedDatabaseEngineInstance -eq 'MSSQLSERVER')
                        {
                            $mockExpectedServiceInstance = $mockExpectedDatabaseEngineServer
                        }
                        else
                        {
                            $mockExpectedServiceInstance = "$mockExpectedDatabaseEngineServer\$mockExpectedDatabaseEngineInstance"
                        }

                        if ( $this.ConnectionContext.ServerInstance -eq $mockExpectedServiceInstance )
                        {
                            return 'Online'
                        }
                        else
                        {
                            return $null
                        }
                    } -PassThru |
                    Add-Member -MemberType NoteProperty -Name ConnectionContext -Value (
                        New-Object -TypeName Object |
                            Add-Member -MemberType NoteProperty -Name ServerInstance -Value $serverInstance -PassThru |
                            Add-Member -MemberType NoteProperty -Name LoginSecure -Value $true -PassThru |
                            Add-Member -MemberType NoteProperty -Name Login -Value '' -PassThru |
                            Add-Member -MemberType NoteProperty -Name SecurePassword -Value $null -PassThru |
                            Add-Member -MemberType NoteProperty -Name ConnectAsUser -Value $false -PassThru |
                            Add-Member -MemberType NoteProperty -Name ConnectAsUserPassword -Value '' -PassThru |
                            Add-Member -MemberType NoteProperty -Name ConnectAsUserName -Value '' -PassThru |
                            Add-Member -MemberType NoteProperty -Name StatementTimeout -Value 600 -PassThru |
                            Add-Member -MemberType NoteProperty -Name ApplicationName -Value 'SqlServerDsc' -PassThru |
                            Add-Member -MemberType ScriptMethod -Name Disconnect -Value {
                                return $true
                            } -PassThru |
                            Add-Member -MemberType ScriptMethod -Name Connect -Value {
                                if ($mockExpectedDatabaseEngineInstance -eq 'MSSQLSERVER')
                                {
                                    $mockExpectedServiceInstance = $mockExpectedDatabaseEngineServer
                                }
                                else
                                {
                                    $mockExpectedServiceInstance = "$mockExpectedDatabaseEngineServer\$mockExpectedDatabaseEngineInstance"
                                }

                                if ($this.serverInstance -ne $mockExpectedServiceInstance)
                                {
                                    throw ("Mock method Connect() was expecting ServerInstance to be '{0}', but was '{1}'." -f $mockExpectedServiceInstance, $this.serverInstance )
                                }

                                if ($mockThrowInvalidOperation)
                                {
                                    throw 'Unable to connect.'
                                }
                            } -PassThru -Force
                    ) -PassThru -Force
            }

            $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter = {
                $TypeName -eq 'Microsoft.SqlServer.Management.Smo.Server'
            }

            $mockThrowLocalizedMessage = {
                throw $Message
            }

            $mockSqlCredentialUserName = 'TestUserName12345'
            $mockSqlCredentialPassword = 'StrongOne7.'
            $mockSqlCredentialSecurePassword = ConvertTo-SecureString -String $mockSqlCredentialPassword -AsPlainText -Force
            $mockSqlCredential = New-Object -TypeName PSCredential -ArgumentList ($mockSqlCredentialUserName, $mockSqlCredentialSecurePassword)

            $mockWinCredentialUserName = 'DOMAIN\TestUserName12345'
            $mockWinCredentialPassword = 'StrongerOne7.'
            $mockWinCredentialSecurePassword = ConvertTo-SecureString -String $mockWinCredentialPassword -AsPlainText -Force
            $mockWinCredential = New-Object -TypeName PSCredential -ArgumentList ($mockWinCredentialUserName, $mockWinCredentialSecurePassword)
        }

        BeforeEach {
            Mock -CommandName New-InvalidOperationException -MockWith $mockThrowLocalizedMessage -Verifiable
            Mock -CommandName Import-SQLPSModule
            Mock -CommandName New-Object `
                -MockWith $mockNewObject_MicrosoftDatabaseEngine `
                -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter `
                -Verifiable
        }

        Context 'When connecting to the default instance using integrated Windows Authentication' {
            It 'Should return the correct service instance' {
                $mockExpectedDatabaseEngineServer = 'TestServer'
                $mockExpectedDatabaseEngineInstance = 'MSSQLSERVER'

                $databaseEngineServerObject = Connect-SQL -ServerName $mockExpectedDatabaseEngineServer
                $databaseEngineServerObject.ConnectionContext.ServerInstance | Should -BeExactly $mockExpectedDatabaseEngineServer

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter
            }
        }

        Context 'When connecting to the default instance using SQL Server Authentication' {
            It 'Should return the correct service instance' {
                $mockExpectedDatabaseEngineServer = 'TestServer'
                $mockExpectedDatabaseEngineInstance = 'MSSQLSERVER'
                $mockExpectedDatabaseEngineLoginSecure = $false

                $databaseEngineServerObject = Connect-SQL -ServerName $mockExpectedDatabaseEngineServer -SetupCredential $mockSqlCredential -LoginType 'SqlLogin'
                $databaseEngineServerObject.ConnectionContext.LoginSecure | Should -Be $false
                $databaseEngineServerObject.ConnectionContext.Login | Should -Be $mockSqlCredentialUserName
                $databaseEngineServerObject.ConnectionContext.SecurePassword | Should -Be $mockSqlCredentialSecurePassword
                $databaseEngineServerObject.ConnectionContext.ServerInstance | Should -BeExactly $mockExpectedDatabaseEngineServer

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter
            }
        }

        Context 'When connecting to the named instance using integrated Windows Authentication' {
            It 'Should return the correct service instance' {
                $mockExpectedDatabaseEngineServer = $env:COMPUTERNAME
                $mockExpectedDatabaseEngineInstance = $mockInstanceName

                $databaseEngineServerObject = Connect-SQL -InstanceName $mockExpectedDatabaseEngineInstance
                $databaseEngineServerObject.ConnectionContext.ServerInstance | Should -BeExactly "$mockExpectedDatabaseEngineServer\$mockExpectedDatabaseEngineInstance"

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter
            }
        }

        Context 'When connecting to the named instance using SQL Server Authentication' {
            It 'Should return the correct service instance' {
                $mockExpectedDatabaseEngineServer = $env:COMPUTERNAME
                $mockExpectedDatabaseEngineInstance = $mockInstanceName
                $mockExpectedDatabaseEngineLoginSecure = $false

                $databaseEngineServerObject = Connect-SQL -InstanceName $mockExpectedDatabaseEngineInstance -SetupCredential $mockSqlCredential -LoginType 'SqlLogin'
                $databaseEngineServerObject.ConnectionContext.LoginSecure | Should -Be $false
                $databaseEngineServerObject.ConnectionContext.Login | Should -Be $mockSqlCredentialUserName
                $databaseEngineServerObject.ConnectionContext.SecurePassword | Should -Be $mockSqlCredentialSecurePassword
                $databaseEngineServerObject.ConnectionContext.ServerInstance | Should -BeExactly "$mockExpectedDatabaseEngineServer\$mockExpectedDatabaseEngineInstance"

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter
            }
        }

        Context 'When connecting to the named instance using integrated Windows Authentication and different server name' {
            It 'Should return the correct service instance' {
                $mockExpectedDatabaseEngineServer = 'SERVER'
                $mockExpectedDatabaseEngineInstance = $mockInstanceName

                $databaseEngineServerObject = Connect-SQL -ServerName $mockExpectedDatabaseEngineServer -InstanceName $mockExpectedDatabaseEngineInstance
                $databaseEngineServerObject.ConnectionContext.ServerInstance | Should -BeExactly "$mockExpectedDatabaseEngineServer\$mockExpectedDatabaseEngineInstance"

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter
            }
        }

        Context 'When connecting to the named instance using Windows Authentication impersonation' {
            BeforeAll {
                $mockExpectedDatabaseEngineServer = $env:COMPUTERNAME
                $mockExpectedDatabaseEngineInstance = $mockInstanceName
            }

            Context 'When using the default login type' {
                BeforeAll {
                    $testParameters = @{
                        ServerName = $mockExpectedDatabaseEngineServer
                        InstanceName = $mockExpectedDatabaseEngineInstance
                        SetupCredential = $mockWinCredential
                    }
                }

                It 'Should return the correct service instance' {
                    $databaseEngineServerObject = Connect-SQL @testParameters
                    $databaseEngineServerObject.ConnectionContext.ServerInstance | Should -BeExactly "$mockExpectedDatabaseEngineServer\$mockExpectedDatabaseEngineInstance"
                    $databaseEngineServerObject.ConnectionContext.ConnectAsUser | Should -Be $true
                    $databaseEngineServerObject.ConnectionContext.ConnectAsUserPassword | Should -BeExactly $mockWinCredential.GetNetworkCredential().Password
                    $databaseEngineServerObject.ConnectionContext.ConnectAsUserName | Should -BeExactly $mockWinCredential.GetNetworkCredential().UserName
                    $databaseEngineServerObject.ConnectionContext.ConnectAsUser | Should -Be $true
                    $databaseEngineServerObject.ConnectionContext.LoginSecure | Should -Be $true

                    Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                        -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter
                }
            }

            Context 'When using the default login type' {
                BeforeAll {
                    $testParameters = @{
                        ServerName = $mockExpectedDatabaseEngineServer
                        InstanceName = $mockExpectedDatabaseEngineInstance
                        SetupCredential = $mockWinCredential
                        LoginType = 'WindowsUser'
                    }
                }

                It 'Should return the correct service instance' {
                    $databaseEngineServerObject = Connect-SQL @testParameters
                    $databaseEngineServerObject.ConnectionContext.ServerInstance | Should -BeExactly "$mockExpectedDatabaseEngineServer\$mockExpectedDatabaseEngineInstance"
                    $databaseEngineServerObject.ConnectionContext.ConnectAsUser | Should -Be $true
                    $databaseEngineServerObject.ConnectionContext.ConnectAsUserPassword | Should -BeExactly $mockWinCredential.GetNetworkCredential().Password
                    $databaseEngineServerObject.ConnectionContext.ConnectAsUserName | Should -BeExactly $mockWinCredential.GetNetworkCredential().UserName
                    $databaseEngineServerObject.ConnectionContext.ConnectAsUser | Should -Be $true
                    $databaseEngineServerObject.ConnectionContext.LoginSecure | Should -Be $true

                    Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                        -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter
                }
            }
        }

        Context 'When connecting to the default instance using the correct service instance but does not return a correct Database Engine object' {
            It 'Should throw the correct error' {
                $mockExpectedDatabaseEngineServer = $env:COMPUTERNAME
                $mockExpectedDatabaseEngineInstance = $mockInstanceName

                Mock -CommandName New-Object `
                    -MockWith $mockNewObject_MicrosoftDatabaseEngine `
                    -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter `
                    -Verifiable

                $mockCorrectErrorMessage = ($script:localizedData.FailedToConnectToDatabaseEngineInstance -f $mockExpectedDatabaseEngineServer)
                { Connect-SQL } | Should -Throw $mockCorrectErrorMessage

                Assert-MockCalled -CommandName New-Object -Exactly -Times 1 -Scope It `
                    -ParameterFilter $mockNewObject_MicrosoftDatabaseEngine_ParameterFilter
            }
        }

        Assert-VerifiableMock
    }

    Describe 'SqlServerDsc.Common\Split-FullSqlInstanceName' {
        Context 'When the "FullSqlInstanceName" parameter is not supplied' {
            It 'Should throw when the "FullSqlInstanceName" parameter is $null' {
                { Split-FullSqlInstanceName -FullSqlInstanceName $null } | Should -Throw
            }

            It 'Should throw when the "FullSqlInstanceName" parameter is an empty string' {
                { Split-FullSqlInstanceName -FullSqlInstanceName '' } | Should -Throw
            }
        }

        Context 'When the "FullSqlInstanceName" parameter is supplied' {
            It 'Should throw when the "FullSqlInstanceName" parameter is "ServerName"' {
                $result = Split-FullSqlInstanceName -FullSqlInstanceName 'ServerName'

                $result.Count | Should -Be 2
                $result.ServerName | Should -Be 'ServerName'
                $result.InstanceName | Should -Be 'MSSQLSERVER'
            }

            It 'Should throw when the "FullSqlInstanceName" parameter is "ServerName\InstanceName"' {
                $result = Split-FullSqlInstanceName -FullSqlInstanceName 'ServerName\InstanceName'

                $result.Count | Should -Be 2
                $result.ServerName | Should -Be 'ServerName'
                $result.InstanceName | Should -Be 'InstanceName'
            }
        }
    }

    Describe 'SqlServerDsc.Common\Test-ClusterPermissions' {
        BeforeAll {
            Mock -CommandName Test-LoginEffectivePermissions -MockWith {
                $mockClusterServicePermissionsPresent
            } -Verifiable -ParameterFilter {
                $LoginName -eq $clusterServiceName
            }

            Mock -CommandName Test-LoginEffectivePermissions -MockWith {
                $mockSystemPermissionsPresent
            } -Verifiable -ParameterFilter {
                $LoginName -eq $systemAccountName
            }

            $clusterServiceName = 'NT SERVICE\ClusSvc'
            $systemAccountName= 'NT AUTHORITY\System'
        }

        BeforeEach {
            $mockServerObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server
            $mockServerObject.NetName = 'TestServer'
            $mockServerObject.ServiceName = 'MSSQLSERVER'

            $mockLogins = @{
                $clusterServiceName = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $mockServerObject,$clusterServiceName
                $systemAccountName = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $mockServerObject,$systemAccountName
            }

            $mockServerObject.Logins = $mockLogins

            $mockClusterServicePermissionsPresent = $false
            $mockSystemPermissionsPresent = $false
        }

        Context 'When the cluster does not have permissions to the instance' {
            It "Should throw the correct error when the logins '$($clusterServiceName)' or '$($systemAccountName)' are absent" {
                $mockServerObject.Logins = @{}

                { Test-ClusterPermissions -ServerObject $mockServerObject } | Should -Throw ( "The cluster does not have permissions to manage the Availability Group on '{0}\{1}'. Grant 'Connect SQL', 'Alter Any Availability Group', and 'View Server State' to either '$($clusterServiceName)' or '$($systemAccountName)'." -f $mockServerObject.NetName,$mockServerObject.ServiceName )

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -Scope It -Times 0 -Exactly -ParameterFilter {
                    $LoginName -eq $clusterServiceName
                }
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -Scope It -Times 0 -Exactly -ParameterFilter {
                    $LoginName -eq $systemAccountName
                }
            }

            It "Should throw the correct error when the logins '$($clusterServiceName)' and '$($systemAccountName)' do not have permissions to manage availability groups" {
                { Test-ClusterPermissions -ServerObject $mockServerObject } | Should -Throw ( "The cluster does not have permissions to manage the Availability Group on '{0}\{1}'. Grant 'Connect SQL', 'Alter Any Availability Group', and 'View Server State' to either '$($clusterServiceName)' or '$($systemAccountName)'." -f $mockServerObject.NetName,$mockServerObject.ServiceName )

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -Scope It -Times 1 -Exactly -ParameterFilter {
                    $LoginName -eq $clusterServiceName
                }
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -Scope It -Times 1 -Exactly -ParameterFilter {
                    $LoginName -eq $systemAccountName
                }
            }
        }

        Context 'When the cluster has permissions to the instance' {
            It "Should return NullOrEmpty when '$($clusterServiceName)' is present and has the permissions to manage availability groups" {
                $mockClusterServicePermissionsPresent = $true

                Test-ClusterPermissions -ServerObject $mockServerObject | Should -Be $true

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -Scope It -Times 1 -Exactly -ParameterFilter {
                    $LoginName -eq $clusterServiceName
                }
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -Scope It -Times 0 -Exactly -ParameterFilter {
                    $LoginName -eq $systemAccountName
                }
            }

            It "Should return NullOrEmpty when '$($systemAccountName)' is present and has the permissions to manage availability groups" {
                $mockSystemPermissionsPresent = $true

                Test-ClusterPermissions -ServerObject $mockServerObject | Should -Be $true

                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -Scope It -Times 1 -Exactly -ParameterFilter {
                    $LoginName -eq $clusterServiceName
                }
                Assert-MockCalled -CommandName Test-LoginEffectivePermissions -Scope It -Times 1 -Exactly -ParameterFilter {
                    $LoginName -eq $systemAccountName
                }
            }
        }
    }

    Describe 'SqlServerDsc.Common\Restart-ReportingServicesService' -Tag 'RestartReportingServicesService' {
        BeforeAll {
            $mockGetService = {
                return @{
                    Name = $mockDynamicServiceName
                    DisplayName = $mockDynamicServiceDisplayName
                    DependentServices = @(
                        @{
                            Name = $mockDynamicDependedServiceName
                            Status = 'Running'
                            DependentServices = @()
                        }
                    )
                }
            }

        }

        Context 'When restarting a Report Services default instance' {
            BeforeAll {
                $mockServiceName = 'ReportServer'
                $mockDependedServiceName = 'DependentService'

                $mockDynamicServiceName = $mockServiceName
                $mockDynamicDependedServiceName = $mockDependedServiceName
                $mockDynamicServiceDisplayName = 'Reporting Services (MSSQLSERVER)'

                Mock -CommandName Stop-Service -Verifiable
                Mock -CommandName Start-Service -Verifiable
                Mock -CommandName Get-Service -MockWith $mockGetService
            }

            It 'Should restart the service and dependent service' {
                { Restart-ReportingServicesService -InstanceName 'MSSQLSERVER' } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Service -ParameterFilter {
                    $Name -eq $mockServiceName
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Stop-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 2
            }
        }

        Context 'When restarting an SQL Server 2017 Report Services' {
            BeforeAll {
                $mockServiceName = 'SQLServerReportingServices'
                $mockDependedServiceName = 'DependentService'

                $mockDynamicServiceName = $mockServiceName
                $mockDynamicDependedServiceName = $mockDependedServiceName
                $mockDynamicServiceDisplayName = 'Reporting Services'

                Mock -CommandName Stop-Service -Verifiable
                Mock -CommandName Start-Service -Verifiable
                Mock -CommandName Get-Service -MockWith $mockGetService
            }

            It 'Should restart the service and dependent service' {
                { Restart-ReportingServicesService -InstanceName 'SSRS' } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Service -ParameterFilter {
                    $Name -eq $mockServiceName
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Stop-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 2
            }
        }

        Context 'When restarting a Report Services named instance' {
            BeforeAll {
                $mockServiceName = 'ReportServer$TEST'
                $mockDependedServiceName = 'DependentService'

                $mockDynamicServiceName = $mockServiceName
                $mockDynamicDependedServiceName = $mockDependedServiceName
                $mockDynamicServiceDisplayName = 'Reporting Services (TEST)'

                Mock -CommandName Stop-Service -Verifiable
                Mock -CommandName Start-Service -Verifiable
                Mock -CommandName Get-Service -MockWith $mockGetService
            }

            It 'Should restart the service and dependent service' {
                { Restart-ReportingServicesService -InstanceName 'TEST' } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Service -ParameterFilter {
                    $Name -eq $mockServiceName
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Stop-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 2
            }
        }

        Context 'When restarting a Report Services named instance using a wait timer' {
            BeforeAll {
                $mockServiceName = 'ReportServer$TEST'
                $mockDependedServiceName = 'DependentService'

                $mockDynamicServiceName = $mockServiceName
                $mockDynamicDependedServiceName = $mockDependedServiceName
                $mockDynamicServiceDisplayName = 'Reporting Services (TEST)'

                Mock -CommandName Start-Sleep -Verifiable
                Mock -CommandName Stop-Service -Verifiable
                Mock -CommandName Start-Service -Verifiable
                Mock -CommandName Get-Service -MockWith $mockGetService
            }

            It 'Should restart the service and dependent service' {
                { Restart-ReportingServicesService -InstanceName 'TEST' -WaitTime 1 } | Should -Not -Throw

                Assert-MockCalled -CommandName Get-Service -ParameterFilter {
                    $Name -eq $mockServiceName
                } -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Stop-Service -Scope It -Exactly -Times 1
                Assert-MockCalled -CommandName Start-Service -Scope It -Exactly -Times 2
                Assert-MockCalled -CommandName Start-Sleep -Scope It -Exactly -Times 1
            }
        }
    }

    Describe 'SqlServerDsc.Common\Test-ActiveNode' -Tag 'TestActiveNode' {
        BeforeAll {
            $mockServerObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server

            $failoverClusterInstanceTestCases = @(
                @{
                    ComputerNamePhysicalNetBIOS = $env:COMPUTERNAME
                    Result = $true
                },
                @{
                    ComputerNamePhysicalNetBIOS = 'AnotherNode'
                    Result = $false
                }
            )
        }

        Context 'When function is executed on a standalone instance' {
            BeforeAll {
                $mockServerObject.IsMemberOfWsfcCluster = $false
            }

            It 'Should return "$true"' {
                Test-ActiveNode -ServerObject $mockServerObject | Should Be $true
            }
        }

        Context 'When function is executed on a failover cluster instance (FCI)' {
            BeforeAll {
                $mockServerObject.IsMemberOfWsfcCluster = $true
            }

            It 'Should return "<Result>" when the node name is "<ComputerNamePhysicalNetBIOS>"' -TestCases $failoverClusterInstanceTestCases {
                param
                (
                    $ComputerNamePhysicalNetBIOS,
                    $Result
                )

                $mockServerObject.ComputerNamePhysicalNetBIOS = $ComputerNamePhysicalNetBIOS

                Test-ActiveNode -ServerObject $mockServerObject | Should Be $Result
            }
        }
    }

    Describe 'SqlServerDsc.Common\Invoke-SqlScript' -Tag 'InvokeSqlScript' {
        BeforeAll {
            $invokeScriptFileParameters = @{
                ServerInstance = $env:COMPUTERNAME
                InputFile = "set.sql"
            }

            $invokeScriptQueryParameters = @{
                ServerInstance = $env:COMPUTERNAME
                Query = "Test Query"
            }
        }

        Context 'Invoke-SqlScript fails to import SQLPS module' {
            $throwMessage = "Failed to import SQLPS module."

            Mock -CommandName Import-SQLPSModule -MockWith {
                throw $throwMessage
            }

            It 'Should throw the correct error from Import-Module' {
                { Invoke-SqlScript @invokeScriptFileParameters } | Should Throw $throwMessage
            }
        }

        Context 'Invoke-SqlScript is called with credentials' {
            BeforeAll {
                $mockPasswordPlain = 'password'
                $mockUsername = 'User'

                $password = ConvertTo-SecureString -String $mockPasswordPlain -AsPlainText -Force
                $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $mockUsername, $password

                Mock -CommandName Import-SQLPSModule -MockWith {}
                Mock -CommandName Invoke-Sqlcmd -ParameterFilter {
                    $Username -eq $mockUsername -and $Password -eq $mockPasswordPlain
                }
            }

            It 'Should call Invoke-Sqlcmd with correct File ParameterSet parameters' {
                $invokeScriptFileParameters.Add('Credential', $credential)
                $null = Invoke-SqlScript @invokeScriptFileParameters

                Assert-MockCalled -CommandName Invoke-Sqlcmd -ParameterFilter {
                    $Username -eq $mockUsername -and $Password -eq $mockPasswordPlain
                } -Times 1 -Exactly -Scope It
            }

            It 'Should call Invoke-Sqlcmd with correct Query ParameterSet parameters' {
                $invokeScriptQueryParameters.Add('Credential', $credential)
                $null = Invoke-SqlScript @invokeScriptQueryParameters

                Assert-MockCalled -CommandName Invoke-Sqlcmd -ParameterFilter {
                    $Username -eq $mockUsername -and $Password -eq $mockPasswordPlain
                } -Times 1 -Exactly -Scope It
            }
        }

        Context 'Invoke-SqlScript fails to execute the SQL scripts' {
            $errorMessage = 'Failed to run SQL Script'

            Mock -CommandName Import-SQLPSModule -MockWith {}
            Mock -CommandName Invoke-Sqlcmd -MockWith {
                throw $errorMessage
            }

            It 'Should throw the correct error from File ParameterSet Invoke-Sqlcmd' {
                { Invoke-SqlScript @invokeScriptFileParameters } | Should Throw $errorMessage
            }

            It 'Should throw the correct error from Query ParameterSet Invoke-Sqlcmd' {
                { Invoke-SqlScript @invokeScriptQueryParameters } | Should Throw $errorMessage
            }
        }
    }

    Describe 'SqlServerDsc.Common\Get-ServiceAccount' -Tag 'GetServiceAccount' {
        BeforeAll {
            $mockLocalSystemAccountUserName = 'NT AUTHORITY\SYSTEM'
            $mockLocalSystemAccountCredential = New-Object System.Management.Automation.PSCredential $mockLocalSystemAccountUserName, (ConvertTo-SecureString "Password1" -AsPlainText -Force)

            $mockManagedServiceAccountUserName = 'CONTOSO\msa$'
            $mockManagedServiceAccountCredential = New-Object System.Management.Automation.PSCredential $mockManagedServiceAccountUserName, (ConvertTo-SecureString "Password1" -AsPlainText -Force)

            $mockDomainAccountUserName = 'CONTOSO\User1'
            $mockDomainAccountCredential = New-Object System.Management.Automation.PSCredential $mockDomainAccountUserName, (ConvertTo-SecureString "Password1" -AsPlainText -Force)

            $mockLocalServiceAccountUserName = 'NT SERVICE\MyService'
            $mockLocalServiceAccountCredential = New-Object System.Management.Automation.PSCredential $mockLocalServiceAccountUserName, (ConvertTo-SecureString "Password1" -AsPlainText -Force)
        }

        Context 'When getting service account' {
            It 'Should return NT AUTHORITY\SYSTEM' {
                $returnValue = Get-ServiceAccount -ServiceAccount $mockLocalSystemAccountCredential

                $returnValue.UserName | Should -Be $mockLocalSystemAccountUserName
                $returnValue.Password | Should -BeNullOrEmpty
            }

            It 'Should return Domain Account and Password' {
                $returnValue = Get-ServiceAccount -ServiceAccount $mockDomainAccountCredential

                $returnValue.UserName | Should -Be $mockDomainAccountUserName
                $returnValue.Password | Should -Be $mockDomainAccountCredential.GetNetworkCredential().Password
            }

            It 'Should return managed service account' {
                $returnValue = Get-ServiceAccount -ServiceAccount $mockManagedServiceAccountCredential

                $returnValue.UserName | Should -Be $mockManagedServiceAccountUserName
            }

            It 'Should return local service account' {
                $returnValue= Get-ServiceAccount -ServiceAccount $mockLocalServiceAccountCredential

                $returnValue.UserName | Should -Be $mockLocalServiceAccountUserName
                $returnValue.Password | Should -BeNullOrEmpty
            }
        }
    }

    Describe 'SqlServerDsc.Common\Find-ExceptionByNumber'{
        BeforeAll {
            $mockInnerException = New-Object System.Exception "This is a mock inner excpetion object"
            $mockInnerException | Add-Member -Name 'Number' -Value 2 -MemberType NoteProperty

            $mockException = New-Object System.Exception "This is a mock exception object", $mockInnerException
            $mockException | Add-Member -Name 'Number' -Value 1 -MemberType NoteProperty
        }

        Context 'When searching Exception objects'{
            It 'Should return true for main exception' {
                Find-ExceptionByNumber -ExceptionToSearch $mockException -ErrorNumber 1 | Should -Be $true
            }

            It 'Should return true for inner exception' {
                Find-ExceptionByNumber -ExceptionToSearch $mockException -ErrorNumber 2 | Should -Be $true
            }

            It 'Should return false when message not found' {
                Find-ExceptionByNumber -ExceptionToSearch $mockException -ErrorNumber 3 | Should -Be $false
            }
        }
    }

    Describe 'DscResource.LocalizationHelper\Get-LocalizedData' {
        $mockTestPath = {
            return $mockTestPathReturnValue
        }

        $mockImportLocalizedData = {
            $BaseDirectory | Should -Be $mockExpectedLanguagePath
        }

        BeforeEach {
            Mock -CommandName Test-Path -MockWith $mockTestPath -Verifiable
            Mock -CommandName Import-LocalizedData -MockWith $mockImportLocalizedData -Verifiable
        }

        Context 'When loading localized data for Swedish' {
            $mockExpectedLanguagePath = 'sv-SE'
            $mockTestPathReturnValue = $true

            It 'Should call Import-LocalizedData with sv-SE language' {
                Mock -CommandName Join-Path -MockWith {
                    return 'sv-SE'
                } -Verifiable

                { Get-LocalizedData -ResourceName 'DummyResource' } | Should -Not -Throw

                Assert-MockCalled -CommandName Join-Path -Exactly -Times 3 -Scope It
                Assert-MockCalled -CommandName Test-Path -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Import-LocalizedData -Exactly -Times 1 -Scope It
            }

            $mockExpectedLanguagePath = 'en-US'
            $mockTestPathReturnValue = $false

            It 'Should call Import-LocalizedData and fallback to en-US if sv-SE language does not exist' {
                Mock -CommandName Join-Path -MockWith {
                    return $ChildPath
                } -Verifiable

                { Get-LocalizedData -ResourceName 'DummyResource' } | Should -Not -Throw

                Assert-MockCalled -CommandName Join-Path -Exactly -Times 4 -Scope It
                Assert-MockCalled -CommandName Test-Path -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Import-LocalizedData -Exactly -Times 1 -Scope It
            }

            Context 'When $ScriptRoot is set to a path' {
                $mockExpectedLanguagePath = 'sv-SE'
                $mockTestPathReturnValue = $true

                It 'Should call Import-LocalizedData with sv-SE language' {
                    Mock -CommandName Join-Path -MockWith {
                        return 'sv-SE'
                    } -Verifiable

                    { Get-LocalizedData -ResourceName 'DummyResource' -ScriptRoot '.' } | Should -Not -Throw

                    Assert-MockCalled -CommandName Join-Path -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Test-Path -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Import-LocalizedData -Exactly -Times 1 -Scope It
                }

                $mockExpectedLanguagePath = 'en-US'
                $mockTestPathReturnValue = $false

                It 'Should call Import-LocalizedData and fallback to en-US if sv-SE language does not exist' {
                    Mock -CommandName Join-Path -MockWith {
                        return $ChildPath
                    } -Verifiable

                    { Get-LocalizedData -ResourceName 'DummyResource' -ScriptRoot '.' } | Should -Not -Throw

                    Assert-MockCalled -CommandName Join-Path -Exactly -Times 2 -Scope It
                    Assert-MockCalled -CommandName Test-Path -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Import-LocalizedData -Exactly -Times 1 -Scope It
                }
            }
        }

        Context 'When loading localized data for English' {
            Mock -CommandName Join-Path -MockWith {
                return 'en-US'
            } -Verifiable

            $mockExpectedLanguagePath = 'en-US'
            $mockTestPathReturnValue = $true

            It 'Should call Import-LocalizedData with en-US language' {
                { Get-LocalizedData -ResourceName 'DummyResource' } | Should -Not -Throw
            }
        }

        Assert-VerifiableMock
    }

    Describe 'DscResource.LocalizationHelper\New-InvalidResultException' {
        Context 'When calling with Message parameter only' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'

                { New-InvalidResultException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
            }
        }

        Context 'When calling with both the Message and ErrorRecord parameter' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'
                $mockExceptionErrorMessage = 'Mocked exception error message'

                $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
                $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $mockException, $null, 'InvalidResult', $null

                { New-InvalidResultException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } | Should -Throw ('System.Exception: {0} ---> System.Exception: {1}' -f $mockErrorMessage, $mockExceptionErrorMessage)
            }
        }

        Assert-VerifiableMock
    }

    Describe 'DscResource.LocalizationHelper\New-ObjectNotFoundException' {
        Context 'When calling with Message parameter only' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'

                { New-ObjectNotFoundException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
            }
        }

        Context 'When calling with both the Message and ErrorRecord parameter' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'
                $mockExceptionErrorMessage = 'Mocked exception error message'

                $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
                $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $mockException, $null, 'InvalidResult', $null

                { New-ObjectNotFoundException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } | Should -Throw ('System.Exception: {0} ---> System.Exception: {1}' -f $mockErrorMessage, $mockExceptionErrorMessage)
            }
        }

        Assert-VerifiableMock
    }

    Describe 'DscResource.LocalizationHelper\New-InvalidOperationException' {
        Context 'When calling with Message parameter only' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'

                { New-InvalidOperationException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
            }
        }

        Context 'When calling with both the Message and ErrorRecord parameter' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'
                $mockExceptionErrorMessage = 'Mocked exception error message'

                $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
                $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $mockException, $null, 'InvalidResult', $null

                { New-InvalidOperationException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } | Should -Throw ('System.InvalidOperationException: {0} ---> System.Exception: {1}' -f $mockErrorMessage, $mockExceptionErrorMessage)
            }
        }

        Assert-VerifiableMock
    }

    Describe 'DscResource.LocalizationHelper\New-NotImplementedException' {
        Context 'When calling with Message parameter only' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'

                { New-NotImplementedException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
            }
        }

        Context 'When calling with both the Message and ErrorRecord parameter' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'
                $mockExceptionErrorMessage = 'Mocked exception error message'

                $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
                $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $mockException, $null, 'InvalidResult', $null

                { New-NotImplementedException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } | Should -Throw ('System.NotImplementedException: {0} ---> System.Exception: {1}' -f $mockErrorMessage, $mockExceptionErrorMessage)
            }
        }

        Assert-VerifiableMock
    }

    Describe 'DscResource.LocalizationHelper\New-InvalidArgumentException' {
        Context 'When calling with both the Message and ArgumentName parameter' {
            It 'Should throw the correct error' {
                $mockErrorMessage = 'Mocked error'
                $mockArgumentName = 'MockArgument'

                { New-InvalidArgumentException -Message $mockErrorMessage -ArgumentName $mockArgumentName } | Should -Throw ('Parameter name: {0}' -f $mockArgumentName)
            }
        }

        Assert-VerifiableMock
    }
}

