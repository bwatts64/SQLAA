#
# Copyright="© Microsoft Corporation. All rights reserved."
#

configuration ConfigSQLAO
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

	[Parameter(Mandatory)]
        [String]$ClusterName,

	[Parameter(Mandatory)]
        [String]$vmNamePrefix,

        [Parameter(Mandatory)]
        [Int]$vmCount,

        [Parameter(Mandatory)]
        [String]$SqlAlwaysOnAvailabilityGroupName,

        [Parameter(Mandatory)]
        [String]$SqlAlwaysOnAvailabilityGroupListenerName,

        [Parameter(Mandatory)]
        [String[]]$ClusterIpAddresses,

        [Parameter(Mandatory)]
        [String]$AGListenerIpAddress,

        [Parameter(Mandatory)]
        [String]$SqlAlwaysOnEndpointName,

        [Parameter(Mandatory)]
        [String]$witnessStorageName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$witnessStorageKey,


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
    Import-DscResource -ModuleName xComputerManagement, xFailOverCluster,CDisk,xActiveDirectory,xDisk,xNetworking,xSql,xSQLServer
    Import-DscResource -ModuleName SqlServerDsc
    Import-DscResource -ModuleName StorageDsc


    Enable-CredSSPNTLM -DomainName $DomainName

    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$DomainFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$SQLCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SQLServicecreds.UserName)", $SQLServicecreds.Password)
    [System.Management.Automation.PSCredential]$AgtCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($AgtServicecreds.UserName)", $AgtServicecreds.Password)

    $RebootVirtualMachine = $true
    

    #Finding the next avaiable disk letter for Add disk
    $NewDiskLetter = "F:" 

    $NextAvailableDiskLetter = $NewDiskLetter[0]

    [System.Collections.ArrayList]$Nodes=@()
    For ($count=0; $count -lt $vmCount; $count++) {
        $Nodes.Add($vmNamePrefix + $Count.ToString())
    }

    
    $PrimaryReplica = $Nodes[0]

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

                $nodes=$using:nodes
                $nodes | out-file C:\SQLConfig\nodes.txt
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

        xCluster FailoverCluster
        {
            Name = $ClusterName
            DomainAdministratorCredential = $DomainCreds
            PsDscRunAsCredential = $DomainCreds
            Nodes = $Nodes
            ClusterIPAddresses = $ClusterIpAddresses
            DependsOn = @("[WindowsFeature]FCPS","[xComputer]DomainJoin","[SqlSetup]InstallNamedInstance-INST2016")
        }

        Script CloudWitness
        {
            SetScript = "Set-ClusterQuorum -CloudWitness -AccountName ${witnessStorageName} -AccessKey $($witnessStorageKey.GetNetworkCredential().Password)"
            TestScript = "(Get-ClusterQuorum).QuorumResource.Name -eq 'Cloud Witness'"
            GetScript = "@{Ensure = if ((Get-ClusterQuorum).QuorumResource.Name -eq 'Cloud Witness') {'Present'} else {'Absent'}}"
            DependsOn = "[xCluster]FailoverCluster"
        }

        
            SqlServerEndpoint HADREndpoint
            {
                EndPointName         = $SqlAlwaysOnEndpointName
                Ensure               = 'Present'
                Port                 = 5022
                ServerName           = $PrimaryReplica
                InstanceName         = "INST2016"
                PsDscRunAsCredential = $DomainCreds
            }

            SqlAlwaysOnService EnableHADR
            {
                Ensure               = 'Present'
                InstanceName         = 'INST2016'
                ServerName           = $PrimaryReplica
                PsDscRunAsCredential = $DomainCreds
            }

            # Create the availability group on the instance tagged as the primary replica
            SqlAG AddAG
            {
                Ensure                        = 'Present'
                Name                          = $SqlAlwaysOnAvailabilityGroupName
                InstanceName                  = 'INST2016'
                ServerName                    = $PrimaryReplica
                ProcessOnlyOnActiveNode       = $true

                AutomatedBackupPreference     = 'Primary'
                AvailabilityMode              = 'SynchronousCommit'
                BackupPriority                = 50
                ConnectionModeInPrimaryRole   = 'AllowAllConnections'
                ConnectionModeInSecondaryRole = 'AllowNoConnections'
                FailoverMode                  = 'Automatic'
                HealthCheckTimeout            = 15000

                # sql server 2016 or later only
                BasicAvailabilityGroup        = $false
                DatabaseHealthTrigger         = $true
                DtcSupportEnabled             = $true
                
                PsDscRunAsCredential          = $DomainCreds
            }

      foreach($node in $nodes) {
            if($Node -ne $PrimaryReplica) {
                
                xSqlServerEndpoint "SqlSecondaryAlwaysOnEndpoint_$Node"
                {
                    SQLServer = $Node
                    SQLInstanceName = 'INST2016'
                    EndPointName = $SqlAlwaysOnEndpointName
                    Port = 5022
                    
                    PsDscRunAsCredential          = $DomainCreds
                }

                SqlAlwaysOnService "EnableSecondaryHADR_$Node"
                {
                    Ensure               = 'Present'
                    InstanceName         = 'INST2016'
                    ServerName           = $Node
                    PsDscRunAsCredential = $DomainCreds
                }

                Script "RestartSQLService_$Node"
                {
                    SetScript = {
                        $node = $using:node
                        get-service -Name 'MSSQL$INST2016' -ComputerName $node | Restart-Service
                    }
                    TestScript = { $false }
                    GetScript = { }
                    PsDscRunAsCredential = $DomainCreds
                }
                

                SqlAGReplica "AddReplica_$Node"
                {
                    Ensure                     = 'Present'
                    Name                       = "INST2016"
                    AvailabilityGroupName      = $SqlAlwaysOnAvailabilityGroupName
                    ServerName                 = $Node
                    InstanceName               = 'INST2016'
                    PrimaryReplicaServerName   = $PrimaryReplica
                    PrimaryReplicaInstanceName = 'INST2016'
                    AvailabilityMode           = 'SynchronousCommit'
                    FailoverMode               = 'Automatic'
            
                    PsDscRunAsCredential          = $DomainCreds
                }

                
            }
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

function Enable-CredSSPNTLM
{ 
    param(
        [Parameter(Mandatory=$true)]
        [string]$DomainName
    )
    
    # This is needed for the case where NTLM authentication is used

    Write-Verbose 'STARTED:Setting up CredSSP for NTLM'
   
    Enable-WSManCredSSP -Role client -DelegateComputer localhost, *.$DomainName -Force -ErrorAction SilentlyContinue
    Enable-WSManCredSSP -Role server -Force -ErrorAction SilentlyContinue

    if(-not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -ErrorAction SilentlyContinue))
    {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name '\CredentialsDelegation' -ErrorAction SilentlyContinue
    }

    if( -not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -value '1' -PropertyType dword -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'ConcatenateDefaults_AllowFreshNTLMOnly' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'ConcatenateDefaults_AllowFreshNTLMOnly' -value '1' -PropertyType dword -ErrorAction SilentlyContinue
    }

    if(-not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -ErrorAction SilentlyContinue))
    {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '1' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '1' -value "wsman/$env:COMPUTERNAME" -PropertyType string -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '2' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '2' -value "wsman/localhost" -PropertyType string -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '3' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '3' -value "wsman/*.$DomainName" -PropertyType string -ErrorAction SilentlyContinue
    }

    Write-Verbose "DONE:Setting up CredSSP for NTLM"
}
