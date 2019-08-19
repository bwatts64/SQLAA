#
# Copyright="© Microsoft Corporation. All rights reserved."
#

configuration PrepSQLAO
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLServicecreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AgtServicecreds,

        [UInt32]$DatabaseEnginePort = 1433,
        
        [UInt32]$DatabaseMirrorPort = 5022,

        [UInt32]$ProbePortNumber = 59999,

        [Parameter(Mandatory)]
        [UInt32]$NumberOfDisks,

        [Parameter(Mandatory)]
        [String]$WorkloadType,

        [String]$DomainNetbiosName=(Get-NetBIOSName -DomainName $DomainName),

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30,

        [Parameter(Mandatory)]
        [String]$bloburi,
        [Parameter(Mandatory)]
        [String]$blobSAS,
        [parameter(Mandatory=$true)]
        [string]$Edition
    )

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName xComputerManagement,CDisk,xActiveDirectory,XDisk,xSql,xNetworking
    Import-DscResource -ModuleName SqlServerDsc
    Import-DscResource -ModuleName StorageDsc

    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$DomainFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$SQLCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SQLServicecreds.UserName)", $SQLServicecreds.Password)
    [System.Management.Automation.PSCredential]$AgtCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($AgtServicecreds.UserName)", $AgtServicecreds.Password)

    $RebootVirtualMachine = $true
    

    #Finding the next avaiable disk letter for Add disk
    $NewDiskLetter = "F:" 

    $NextAvailableDiskLetter = $NewDiskLetter[0]
    

    Node localhost
    {
        xSqlCreateVirtualDataDisk NewVirtualDisk
        {
            NumberOfDisks = $NumberOfDisks
            NumberOfColumns = $NumberOfDisks
            DiskLetter = $NextAvailableDiskLetter
            OptimizationType = $WorkloadType
            StartingDeviceID = 2
            RebootVirtualMachine = $RebootVirtualMachine
        }

        #region Install prerequisites for SQL Server
        WindowsFeature 'NetFramework35'
        {
            Name   = 'NET-Framework-Core'
            Ensure = 'Present'
        }

        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }

        WindowsFeature FC
        {
            Name = "Failover-Clustering"
            Ensure = "Present"
        }

        WindowsFeature FailoverClusterTools 
        { 
            Ensure = "Present" 
            Name = "RSAT-Clustering-Mgmt"
            DependsOn = "[WindowsFeature]FC"
        } 

        WindowsFeature FCPS
        {
            Name = "RSAT-Clustering-PowerShell"
            Ensure = "Present"
        }

        WindowsFeature ADPS
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
        }

        Script SqlServerPowerShell
        {
            SetScript = 'Install-PackageProvider -Name NuGet -Force; Install-Module -Name SqlServer -AllowClobber -Force; Import-Module -Name SqlServer -ErrorAction SilentlyContinue'
            TestScript = 'Import-Module -Name SqlServer -ErrorAction SilentlyContinue; if (Get-Module -Name SqlServer) { $True } else { $False }'
            GetScript = 'Import-Module -Name SqlServer -ErrorAction SilentlyContinue; @{Ensure = if (Get-Module -Name SqlServer) {"Present"} else {"Absent"}}'
        }
        
        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
        }

        Script New-ConfigurationFile {
            SetScript = {
                $bloburi=$using:bloburi
                $blobSAS=$using:blobSAS
                $Edition=$using:Edition

                Set-NetFirewallProfile -All -Enabled False -Verbose
                if((test-path -Path c:\SQLConfig) -eq $false) {
                    new-item -ItemType Directory -Path c:\ -Name SQLConfig
                }

                # Download MSI file local
                if($Edition -eq 'Enterprise (x64)') {
                    $msiFileName = 'en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso'
                }
                else {
                    $msiFIleName = 'en_sql_server_2016_standard_with_service_pack_1_x64_dvd_9540929.iso'
                }
                $msiURI = "$bloburi/$msiFileName$blobSAS"

                $msiURI | out-file -FilePath C:\SQLConfig\log.txt
                Invoke-WebRequest -uri "$msiURI" -OutFile "c:\SQLConfig\$msiFileName"
                
            }
            TestScript = {
                $Edition=$using:Edition
                if($Edition -eq 'Enterprise (x64)') {
                    $msiFileName = 'en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso'
                }
                else {
                    $msiFIleName = 'en_sql_server_2016_standard_with_service_pack_1_x64_dvd_9540929.iso'
                }
                Test-Path "c:\SQLConfig\$msiFileName" 
            }
            GetScript = { }
            DependsOn = "[xComputer]DomainJoin"
        }

        if($Edition -eq 'Enterprise (x64)') {
           $msiFileName = 'en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso'
        }
        else {
           $msiFIleName = 'en_sql_server_2016_standard_with_service_pack_1_x64_dvd_9540929.iso'
        }
        MountImage ISO
        {
            ImagePath   = "c:\SQLConfig\$msiFileName"
            DriveLetter = 'S'
        }

        WaitForVolume WaitForISO
        {
            DriveLetter      = 'S'
            RetryIntervalSec = 5
            RetryCount       = 10
        }

        SqlSetup 'InstallNamedInstance-INST2016'
        {
            InstanceName          = 'INST2016'
            Features              = 'SQLENGINE'
            SQLCollation          = 'SQL_Latin1_General_CP1_CI_AS'
            SQLSvcAccount         = $SQLCreds
            AgtSvcAccount         = $AgtCreds
            InstallSharedDir      = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir   = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir           = 'C:\Program Files\Microsoft SQL Server'
            InstallSQLDataDir     = 'F:\Program Files\Microsoft SQL Server\MSSQL13.INST2016\MSSQL\Data'
            SQLUserDBDir          = 'F:\Program Files\Microsoft SQL Server\MSSQL13.INST2016\MSSQL\Data'
            SQLUserDBLogDir       = 'F:\Program Files\Microsoft SQL Server\MSSQL13.INST2016\MSSQL\Data'
            SQLTempDBDir          = 'F:\Program Files\Microsoft SQL Server\MSSQL13.INST2016\MSSQL\Data'
            SQLTempDBLogDir       = 'F:\Program Files\Microsoft SQL Server\MSSQL13.INST2016\MSSQL\Data'
            SQLBackupDir          = 'F:\Program Files\Microsoft SQL Server\MSSQL13.INST2016\MSSQL\Backup'
            SourcePath            = 'S:\'
            UpdateEnabled         = 'False'
            ForceReboot           = $false
            BrowserSvcStartupType = 'Automatic'
            DependsOn             = '[WaitForVolume]WaitForISO'

            PsDscRunAsCredential  = $DomainCreds
        }

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }

    }
}

function Get-NetBIOSName
{ 
    [OutputType([string])]
    param(
        [string]$DomainName
    )

    if ($DomainName.Contains('.')) {
        $length=$DomainName.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        return $DomainName.Substring(0,$length)
    }
    else {
        if ($DomainName.Length -gt 15) {
            return $DomainName.Substring(0,15)
        }
        else {
            return $DomainName
        }
    }
}


