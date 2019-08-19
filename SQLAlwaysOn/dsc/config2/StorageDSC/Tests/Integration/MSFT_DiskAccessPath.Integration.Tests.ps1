$script:DSCModuleName = 'StorageDsc'
$script:DSCResourceName = 'MSFT_DiskAccessPath'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Integration Test Template Version: 1.1.1
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Integration" {
        #region Integration Tests for DiskNumber
        Context 'Partition and format newly provisioned disk using Disk Number with two volumes and assign Access Paths' {
            BeforeAll {
                # Create a VHD and attach it to the computer
                $VHDPath = Join-Path -Path $TestDrive `
                    -ChildPath 'TestDisk.vhd'
                $null = New-VDisk -Path $VHDPath -SizeInMB 1024 -Verbose
                $null = Mount-DiskImage -ImagePath $VHDPath -StorageType VHD -NoDriveLetter
                $diskImage = Get-DiskImage -ImagePath $VHDPath
                $disk = Get-Disk -Number $diskImage.Number
                $FSLabelA = 'TestDiskA'
                $FSLabelB = 'TestDiskB'

                # Get a couple of mount point paths
                $accessPathA = Join-Path -Path $ENV:Temp -ChildPath 'DiskAccessPath_MountA'
                if (-not (Test-Path -Path $accessPathA))
                {
                    $null = New-Item -Path $accessPathA -ItemType Directory
                } # if

                $accessPathB = Join-Path -Path $ENV:Temp -ChildPath 'DiskAccessPath_MountB'
                if (-not (Test-Path -Path $accessPathB))
                {
                    $null = New-Item -Path $accessPathB -ItemType Directory
                } # if
            }

            Context "Create first volume on Disk Number $($disk.Number)" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        # This is to pass to the Config
                        $configData = @{
                            AllNodes = @(
                                @{
                                    NodeName   = 'localhost'
                                    AccessPath = $accessPathA
                                    DiskId     = $disk.Number
                                    DiskIdType = 'Number'
                                    FSLabel    = $FSLabelA
                                    Size       = 100MB
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
                            -OutputPath $TestDrive `
                            -ConfigurationData $configData

                        Start-DscConfiguration `
                            -Path $TestDrive `
                            -ComputerName localhost `
                            -Wait `
                            -Verbose `
                            -Force `
                            -ErrorAction Stop
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should have set the resource and all the parameters should match' {
                    $current = Get-DscConfiguration | Where-Object {
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.DiskId           | Should -Be $disk.Number
                    $current.AccessPath       | Should -Be "$($accessPathA)\"
                    $current.FSLabel          | Should -Be $FSLabelA
                    $current.Size             | Should -Be 100MB
                }
            }
            # Create a file on the new disk to ensure it still exists after reattach
            $testFilePath = Join-Path -Path $accessPathA -ChildPath 'IntTestFile.txt'
            Set-Content `
                -Path $testFilePath `
                -Value 'Test' `
                -NoNewline

            # This test will ensure the disk can be remounted if the access path is removed.
            Remove-PartitionAccessPath `
                -DiskNumber $disk.Number `
                -PartitionNumber 2 `
                -AccessPath $accessPathA `
                -ErrorAction SilentlyContinue

            Context "Remount first volume on Disk Number $($disk.Number)" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        # This is to pass to the Config
                        $configData = @{
                            AllNodes = @(
                                @{
                                    NodeName   = 'localhost'
                                    AccessPath = $accessPathA
                                    DiskId     = $disk.Number
                                    DiskIdType = 'Number'
                                    FSLabel    = $FSLabelA
                                    Size       = 100MB
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
                            -OutputPath $TestDrive `
                            -ConfigurationData $configData

                        Start-DscConfiguration `
                            -Path $TestDrive `
                            -ComputerName localhost `
                            -Wait `
                            -Verbose `
                            -Force `
                            -ErrorAction Stop
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should have set the resource and all the parameters should match' {
                    $current = Get-DscConfiguration | Where-Object {
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.DiskId           | Should -Be $disk.Number
                    $current.AccessPath       | Should -Be "$($accessPathA)\"
                    $current.FSLabel          | Should -Be $FSLabelA
                    $current.Size             | Should -Be 100MB
                }

                It 'Should contain the test file' {
                    Test-Path -Path $testFilePath        | Should -Be $true
                    Get-Content -Path $testFilePath -Raw | Should -Be 'Test'
                }

                Context "Create second volume on Disk Number $($disk.Number)" {
                    It 'Should compile and apply the MOF without throwing' {
                        {
                            # This is to pass to the Config
                            $configData = @{
                                AllNodes = @(
                                    @{
                                        NodeName   = 'localhost'
                                        AccessPath = $accessPathB
                                        DiskId     = $disk.Number
                                        DiskIdType = 'Number'
                                        FSLabel    = $FSLabelB
                                    }
                                )
                            }

                            & "$($script:DSCResourceName)_Config" `
                                -OutputPath $TestDrive `
                                -ConfigurationData $configData

                            Start-DscConfiguration `
                                -Path $TestDrive `
                                -ComputerName localhost `
                                -Wait `
                                -Verbose `
                                -Force `
                                -ErrorAction Stop
                        } | Should -Not -Throw
                    }

                    It 'Should be able to call Get-DscConfiguration without throwing' {
                        { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                    }

                    It 'Should have set the resource and all the parameters should match' {
                        $current = Get-DscConfiguration | Where-Object {
                            $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                        }
                        $current.DiskId           | Should -Be $disk.Number
                        $current.AccessPath       | Should -Be "$($accessPathB)\"
                        $current.FSLabel          | Should -Be $FSLabelB
                        $current.Size             | Should -Be 935198720
                    }
                }
            }

            # A system partition will have been added to the disk as well as the 2 test partitions
            It 'Should have 3 partitions on disk' {
                ($disk | Get-Partition).Count | Should -Be 3
            }

            AfterAll {
                # Clean up
                Remove-PartitionAccessPath `
                    -DiskNumber $disk.Number `
                    -PartitionNumber 2 `
                    -AccessPath $accessPathA `
                    -ErrorAction SilentlyContinue
                Remove-PartitionAccessPath `
                    -DiskNumber $disk.Number `
                    -PartitionNumber 3 `
                    -AccessPath $accessPathB `
                    -ErrorAction SilentlyContinue
                $null = Remove-Item -Path $accessPathA -Force
                $null = Remove-Item -Path $accessPathB -Force
                $null = Dismount-DiskImage -ImagePath $VHDPath -StorageType VHD
                $null = Remove-Item -Path $VHDPath -Force
            }
        }
        #endregion

        #region Integration Tests for Disk Unique Id
        Context 'Partition and format newly provisioned disk using Disk Unique Id with two volumes and assign Access Paths' {
            BeforeAll {
                # Create a VHD and attach it to the computer
                $VHDPath = Join-Path -Path $TestDrive `
                    -ChildPath 'TestDisk.vhd'
                $null = New-VDisk -Path $VHDPath -SizeInMB 1024
                $null = Mount-DiskImage -ImagePath $VHDPath -StorageType VHD -NoDriveLetter
                $diskImage = Get-DiskImage -ImagePath $VHDPath
                $disk = Get-Disk -Number $diskImage.Number
                $FSLabelA = 'TestDiskA'
                $FSLabelB = 'TestDiskB'

                # Get a couple of mount point paths
                $accessPathA = Join-Path -Path $ENV:Temp -ChildPath 'DiskAccessPath_MountA'
                if (-not (Test-Path -Path $accessPathA))
                {
                    $null = New-Item -Path $accessPathA -ItemType Directory
                } # if

                $accessPathB = Join-Path -Path $ENV:Temp -ChildPath 'DiskAccessPath_MountB'
                if (-not (Test-Path -Path $accessPathB))
                {
                    $null = New-Item -Path $accessPathB -ItemType Directory
                } # if
            }

            Context "Create first volume on Disk Unique Id $($disk.UniqueId)" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        # This is to pass to the Config
                        $configData = @{
                            AllNodes = @(
                                @{
                                    NodeName   = 'localhost'
                                    AccessPath = $accessPathA
                                    DiskId     = $disk.UniqueId
                                    DiskIdType = 'UniqueId'
                                    FSLabel    = $FSLabelA
                                    Size       = 100MB
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
                            -OutputPath $TestDrive `
                            -ConfigurationData $configData

                        Start-DscConfiguration `
                            -Path $TestDrive `
                            -ComputerName localhost `
                            -Wait `
                            -Verbose `
                            -Force `
                            -ErrorAction Stop
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should have set the resource and all the parameters should match' {
                    $current = Get-DscConfiguration | Where-Object {
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.DiskId           | Should -Be $disk.UniqueId
                    $current.AccessPath       | Should -Be "$($accessPathA)\"
                    $current.FSLabel          | Should -Be $FSLabelA
                    $current.Size             | Should -Be 100MB
                }
            }

            # Create a file on the new disk to ensure it still exists after reattach
            $testFilePath = Join-Path -Path $accessPathA -ChildPath 'IntTestFile.txt'
            Set-Content `
                -Path $testFilePath `
                -Value 'Test' `
                -NoNewline

            # This test will ensure the disk can be remounted if the access path is removed.
            Remove-PartitionAccessPath `
                -DiskNumber $disk.Number `
                -PartitionNumber 2 `
                -AccessPath $accessPathA

            Context "Remount first volume on Disk Unique Id $($disk.UniqueId)" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        # This is to pass to the Config
                        $configData = @{
                            AllNodes = @(
                                @{
                                    NodeName   = 'localhost'
                                    AccessPath = $accessPathA
                                    DiskId     = $disk.UniqueId
                                    DiskIdType = 'UniqueId'
                                    FSLabel    = $FSLabelA
                                    Size       = 100MB
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
                            -OutputPath $TestDrive `
                            -ConfigurationData $configData

                        Start-DscConfiguration `
                            -Path $TestDrive `
                            -ComputerName localhost `
                            -Wait `
                            -Verbose `
                            -Force `
                            -ErrorAction Stop
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should have set the resource and all the parameters should match' {
                    $current = Get-DscConfiguration | Where-Object {
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.DiskId           | Should -Be $disk.UniqueId
                    $current.AccessPath       | Should -Be "$($accessPathA)\"
                    $current.FSLabel          | Should -Be $FSLabelA
                    $current.Size             | Should -Be 100MB
                }

                It 'Should contain the test file' {
                    Test-Path -Path $testFilePath        | Should -Be $true
                    Get-Content -Path $testFilePath -Raw | Should -Be 'Test'
                }

                Context "Create second volume on Disk Unique Id $($disk.UniqueId)" {
                    It 'Should compile and apply the MOF without throwing' {
                        {
                            # This is to pass to the Config
                            $configData = @{
                                AllNodes = @(
                                    @{
                                        NodeName   = 'localhost'
                                        AccessPath = $accessPathB
                                        DiskId     = $disk.UniqueId
                                        DiskIdType = 'UniqueId'
                                        FSLabel    = $FSLabelB
                                    }
                                )
                            }

                            & "$($script:DSCResourceName)_Config" `
                                -OutputPath $TestDrive `
                                -ConfigurationData $configData

                            Start-DscConfiguration `
                                -Path $TestDrive `
                                -ComputerName localhost `
                                -Wait `
                                -Verbose `
                                -Force `
                                -ErrorAction Stop
                        } | Should -Not -Throw
                    }

                    It 'Should be able to call Get-DscConfiguration without throwing' {
                        { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                    }

                    It 'Should have set the resource and all the parameters should match' {
                        $current = Get-DscConfiguration | Where-Object {
                            $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                        }
                        $current.DiskId           | Should -Be $disk.UniqueId
                        $current.AccessPath       | Should -Be "$($accessPathB)\"
                        $current.FSLabel          | Should -Be $FSLabelB
                        $current.Size             | Should -Be 935198720
                    }
                }
            }

            # A system partition will have been added to the disk as well as the 2 test partitions
            It 'Should have 3 partitions on disk' {
                ($disk | Get-Partition).Count | Should -Be 3
            }

            AfterAll {
                # Clean up
                Remove-PartitionAccessPath `
                    -DiskNumber $disk.Number `
                    -PartitionNumber 2 `
                    -AccessPath $accessPathA `
                    -ErrorAction SilentlyContinue
                Remove-PartitionAccessPath `
                    -DiskNumber $disk.Number `
                    -PartitionNumber 3 `
                    -AccessPath $accessPathB `
                    -ErrorAction SilentlyContinue
                $null = Remove-Item -Path $accessPathA -Force
                $null = Remove-Item -Path $accessPathB -Force
                $null = Dismount-DiskImage -ImagePath $VHDPath -StorageType VHD
                $null = Remove-Item -Path $VHDPath -Force
            }
        }
        #endregion

        #region Integration Tests for Disk Guid
        Context 'Partition and format newly provisioned disk using Disk Guid with two volumes and assign Access Paths' {
            BeforeAll {
                # Create a VHD and attach it to the computer
                $VHDPath = Join-Path -Path $TestDrive `
                    -ChildPath 'TestDisk.vhd'
                $null = New-VDisk -Path $VHDPath -SizeInMB 1024 -Initialize
                $null = Mount-DiskImage -ImagePath $VHDPath -StorageType VHD -NoDriveLetter
                $diskImage = Get-DiskImage -ImagePath $VHDPath
                $disk = Get-Disk -Number $diskImage.Number
                $FSLabelA = 'TestDiskA'
                $FSLabelB = 'TestDiskB'

                # Get a couple of mount point paths
                $accessPathA = Join-Path -Path $ENV:Temp -ChildPath 'DiskAccessPath_MountA'
                if (-not (Test-Path -Path $accessPathA))
                {
                    $null = New-Item -Path $accessPathA -ItemType Directory
                } # if

                $accessPathB = Join-Path -Path $ENV:Temp -ChildPath 'DiskAccessPath_MountB'
                if (-not (Test-Path -Path $accessPathB))
                {
                    $null = New-Item -Path $accessPathB -ItemType Directory
                } # if
            }

            Context "Create first volume on Disk Guid $($disk.Guid)" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        # This is to pass to the Config
                        $configData = @{
                            AllNodes = @(
                                @{
                                    NodeName   = 'localhost'
                                    AccessPath = $accessPathA
                                    DiskId     = $disk.Guid
                                    DiskIdType = 'Guid'
                                    FSLabel    = $FSLabelA
                                    Size       = 100MB
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
                            -OutputPath $TestDrive `
                            -ConfigurationData $configData

                        Start-DscConfiguration `
                            -Path $TestDrive `
                            -ComputerName localhost `
                            -Wait `
                            -Verbose `
                            -Force `
                            -ErrorAction Stop
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should have set the resource and all the parameters should match' {
                    $current = Get-DscConfiguration | Where-Object {
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.DiskId           | Should -Be $disk.Guid
                    $current.AccessPath       | Should -Be "$($accessPathA)\"
                    $current.FSLabel          | Should -Be $FSLabelA
                    $current.Size             | Should -Be 100MB
                }
            }

            # Create a file on the new disk to ensure it still exists after reattach
            $testFilePath = Join-Path -Path $accessPathA -ChildPath 'IntTestFile.txt'
            Set-Content `
                -Path $testFilePath `
                -Value 'Test' `
                -NoNewline

            # This test will ensure the disk can be remounted if the access path is removed.
            Remove-PartitionAccessPath `
                -DiskNumber $disk.Number `
                -PartitionNumber 2 `
                -AccessPath $accessPathA `
                -ErrorAction SilentlyContinue

            Context "Remount first volume on Disk Guid $($disk.Guid)" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        # This is to pass to the Config
                        $configData = @{
                            AllNodes = @(
                                @{
                                    NodeName   = 'localhost'
                                    AccessPath = $accessPathA
                                    DiskId     = $disk.Guid
                                    DiskIdType = 'Guid'
                                    FSLabel    = $FSLabelA
                                    Size       = 100MB
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
                            -OutputPath $TestDrive `
                            -ConfigurationData $configData

                        Start-DscConfiguration `
                            -Path $TestDrive `
                            -ComputerName localhost `
                            -Wait `
                            -Verbose `
                            -Force `
                            -ErrorAction Stop
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should have set the resource and all the parameters should match' {
                    $current = Get-DscConfiguration | Where-Object {
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.DiskId           | Should -Be $disk.Guid
                    $current.AccessPath       | Should -Be "$($accessPathA)\"
                    $current.FSLabel          | Should -Be $FSLabelA
                    $current.Size             | Should -Be 100MB
                }

                It 'Should contain the test file' {
                    Test-Path -Path $testFilePath        | Should -Be $true
                    Get-Content -Path $testFilePath -Raw | Should -Be 'Test'
                }

                Context "Create second volume on Disk Guid $($disk.Guid)" {
                    It 'Should compile and apply the MOF without throwing' {
                        {
                            # This is to pass to the Config
                            $configData = @{
                                AllNodes = @(
                                    @{
                                        NodeName   = 'localhost'
                                        AccessPath = $accessPathB
                                        DiskId     = $disk.Guid
                                        DiskIdType = 'Guid'
                                        FSLabel    = $FSLabelB
                                    }
                                )
                            }

                            & "$($script:DSCResourceName)_Config" `
                                -OutputPath $TestDrive `
                                -ConfigurationData $configData

                            Start-DscConfiguration `
                                -Path $TestDrive `
                                -ComputerName localhost `
                                -Wait `
                                -Verbose `
                                -Force `
                                -ErrorAction Stop
                        } | Should -Not -Throw
                    }

                    It 'Should be able to call Get-DscConfiguration without throwing' {
                        { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                    }

                    It 'Should have set the resource and all the parameters should match' {
                        $current = Get-DscConfiguration | Where-Object {
                            $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                        }
                        $current.DiskId           | Should -Be $disk.Guid
                        $current.AccessPath       | Should -Be "$($accessPathB)\"
                        $current.FSLabel          | Should -Be $FSLabelB
                        $current.Size             | Should -Be 935198720
                    }
                }
            }

            # A system partition will have been added to the disk as well as the 2 test partitions
            It 'Should have 3 partitions on disk' {
                ($disk | Get-Partition).Count | Should -Be 3
            }

            AfterAll {
                # Clean up
                Remove-PartitionAccessPath `
                    -DiskNumber $disk.Number `
                    -PartitionNumber 2 `
                    -AccessPath $accessPathA `
                    -ErrorAction SilentlyContinue
                Remove-PartitionAccessPath `
                    -DiskNumber $disk.Number `
                    -PartitionNumber 3 `
                    -AccessPath $accessPathB `
                    -ErrorAction SilentlyContinue
                $null = Remove-Item -Path $accessPathA -Force
                $null = Remove-Item -Path $accessPathB -Force
                $null = Dismount-DiskImage -ImagePath $VHDPath -StorageType VHD
                $null = Remove-Item -Path $VHDPath -Force
            }
        }
        #endregion

        #region Integration Tests for DiskNumber to test if a single disk with a volume using the whole disk can be remounted
        Context 'Partition a disk using Disk Number with a single volume using the whole disk, dismount the volume then reprovision it' {
            BeforeAll {
                # Create a VHD and attach it to the computer
                $VHDPath = Join-Path -Path $TestDrive `
                    -ChildPath 'TestDisk.vhd'
                $null = New-VDisk -Path $VHDPath -SizeInMB 1024 -Verbose
                $null = Mount-DiskImage -ImagePath $VHDPath -StorageType VHD -NoDriveLetter
                $diskImage = Get-DiskImage -ImagePath $VHDPath
                $disk = Get-Disk -Number $diskImage.Number
                $FSLabelA = 'TestDiskA'

                # Get a mount point path
                $accessPathA = Join-Path -Path $ENV:Temp -ChildPath 'DiskAccessPath_MountA'
                if (-not (Test-Path -Path $accessPathA))
                {
                    $null = New-Item -Path $accessPathA -ItemType Directory
                } # if
            }

            Context "Create first volume on Disk Number $($disk.Number)" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        # This is to pass to the Config
                        $configData = @{
                            AllNodes = @(
                                @{
                                    NodeName   = 'localhost'
                                    AccessPath = $accessPathA
                                    DiskId     = $disk.Number
                                    DiskIdType = 'Number'
                                    FSLabel    = $FSLabelA
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
                            -OutputPath $TestDrive `
                            -ConfigurationData $configData

                        Start-DscConfiguration `
                            -Path $TestDrive `
                            -ComputerName localhost `
                            -Wait `
                            -Verbose `
                            -Force `
                            -ErrorAction Stop
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should have set the resource and all the parameters should match' {
                    $current = Get-DscConfiguration | Where-Object {
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.DiskId           | Should -Be $disk.Number
                    $current.AccessPath       | Should -Be "$($accessPathA)\"
                    $current.FSLabel          | Should -Be $FSLabelA
                }
            }
            # Create a file on the new disk to ensure it still exists after reattach
            $testFilePath = Join-Path -Path $accessPathA -ChildPath 'IntTestFile.txt'
            Set-Content `
                -Path $testFilePath `
                -Value 'Test' `
                -NoNewline

            # This test will ensure the disk can be remounted if the access path is removed.
            Remove-PartitionAccessPath `
                -DiskNumber $disk.Number `
                -PartitionNumber 2 `
                -AccessPath $accessPathA

            Context "Remount first volume on Disk Number $($disk.Number)" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        # This is to pass to the Config
                        $configData = @{
                            AllNodes = @(
                                @{
                                    NodeName   = 'localhost'
                                    AccessPath = $accessPathA
                                    DiskId     = $disk.Number
                                    DiskIdType = 'Number'
                                    FSLabel    = $FSLabelA
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
                            -OutputPath $TestDrive `
                            -ConfigurationData $configData

                        Start-DscConfiguration `
                            -Path $TestDrive `
                            -ComputerName localhost `
                            -Wait `
                            -Verbose `
                            -Force `
                            -ErrorAction Stop
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should have set the resource and all the parameters should match' {
                    $current = Get-DscConfiguration | Where-Object {
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.DiskId           | Should -Be $disk.Number
                    $current.AccessPath       | Should -Be "$($accessPathA)\"
                    $current.FSLabel          | Should -Be $FSLabelA
                }

                It 'Should contain the test file' {
                    Test-Path -Path $testFilePath        | Should -Be $true
                    Get-Content -Path $testFilePath -Raw | Should -Be 'Test'
                }
            }

            # A system partition will have been added to the disk as well as the 2 test partitions
            It 'Should have 2 partitions on disk' {
                ($disk | Get-Partition).Count | Should -Be 2
            }

            AfterAll {
                # Clean up
                Remove-PartitionAccessPath `
                    -DiskNumber $disk.Number `
                    -PartitionNumber 2 `
                    -AccessPath $accessPathA `
                    -ErrorAction SilentlyContinue
                $null = Remove-Item -Path $accessPathA -Force
                $null = Dismount-DiskImage -ImagePath $VHDPath -StorageType VHD
                $null = Remove-Item -Path $VHDPath -Force
            }
        }
        #endregion
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
