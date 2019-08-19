configuration SQLServerPrepareDsc
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

		[String]$DomainNetbiosName=(Get-NetBIOSName -DomainName $DomainName),

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLServicecreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AgtServicecreds,

        [Parameter(Mandatory)]
        [String]$vmNamePrefix,

        [Parameter(Mandatory)]
        [Int]$vmCount,

        [Parameter(Mandatory=$true)]
        [String]$ClusterName,

        [Parameter(Mandatory=$true)]
        [String[]]$ClusterIP,

        [Parameter(Mandatory)]
        [String]$SqlAlwaysOnAvailabilityGroupName,

        [Parameter(Mandatory)]
        [String]$SqlAlwaysOnAvailabilityGroupListenerName,

        [Parameter(Mandatory)]
        [String]$AGListenerIpAddress,

        [Parameter(Mandatory=$true)]
        [String]$witnessStorageBlobEndpoint,

        [Parameter(Mandatory=$true)]
        [String]$witnessStorageAccountKey,

        [UInt32]$DatabaseEnginePort = 1433,
        
        [UInt32]$DatabaseMirrorPort = 5022,

        [UInt32]$ProbePortNumber = 59999,

        [Parameter(Mandatory)]
        [String]$WorkloadType,

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30,

        [Parameter(Mandatory)]
        [String]$bloburi,
        [Parameter(Mandatory)]
        [String]$blobSAS,
        [parameter(Mandatory=$true)]
        [string]$Edition,

        [parameter(Mandatory=$true)]
        [string]$InstanceName
    )

    try {
        Import-DscResource -ModuleName xComputerManagement, xNetworking, xActiveDirectory, xFailoverCluster, SqlServer, SqlServerDsc, StorageDSC, PSDesiredStateConfiguration
    }
    catch {
        Write-Verbose -Message "Caught Import-Module Error: $_"
    }
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$DomainFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$SQLCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SQLServicecreds.UserName)", $SQLServicecreds.Password)
    [System.Management.Automation.PSCredential]$AgtCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($AgtServicecreds.UserName)", $AgtServicecreds.Password)


    $ipcomponents = $ClusterIP.Split('.')
    $ipcomponents[3] = [convert]::ToString(([convert]::ToInt32($ipcomponents[3])) + 1)
    $ipdummy = $ipcomponents -join "."
    $ClusterNameDummy = "c" + $ClusterName

    $suri = [System.uri]$witnessStorageBlobEndpoint
    $uricomp = $suri.Host.split('.')

    $witnessStorageAccount = $uriComp[0]
    $witnessEndpoint = $uricomp[-3] + "." + $uricomp[-2] + "." + $uricomp[-1]

    $computerName = $env:COMPUTERNAME
    $domainUserName = $DomainCreds.UserName.ToString()

    [System.Collections.ArrayList]$Nodes=@()
    For ($count=0; $count -lt $vmCount; $count++) {
        $Nodes.Add($vmNamePrefix + $Count.ToString())
    }

    
    $PrimaryReplica = $Nodes[0]

    Node localhost
    {
        Disk DataVolume
        {
             DiskId = 2
             DriveLetter = 'F'
             FSLabel = 'Data'
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
            DependsOn = "[WindowsFeature]FailoverClusterTools"
        }

        WindowsFeature FCPSCMD
        {
            Ensure    = 'Present'
            Name      = 'RSAT-Clustering-CmdInterface'
            DependsOn = '[WindowsFeature]FCPS'
        }

        WindowsFeature ADPS
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
        }

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

        SqlSetup "InstallNamedInstance-$instanceName"
        {
            InstanceName          = $instanceName
            Features              = 'SQLENGINE'
            SQLCollation          = 'SQL_Latin1_General_CP1_CI_AS'
            SQLSvcAccount         = $SQLCreds
            AgtSvcAccount         = $AgtCreds
            InstallSharedDir      = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir   = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir           = 'C:\Program Files\Microsoft SQL Server'
            InstallSQLDataDir     = "F:\Program Files\Microsoft SQL Server\MSSQL13.$instanceName\MSSQL\Data"
            SQLUserDBDir          = "F:\Program Files\Microsoft SQL Server\MSSQL13.$instanceName\MSSQL\Data"
            SQLUserDBLogDir       = "F:\Program Files\Microsoft SQL Server\MSSQL13.$instanceName\MSSQL\Data"
            SQLTempDBDir          = "F:\Program Files\Microsoft SQL Server\MSSQL13.$instanceName\MSSQL\Data"
            SQLTempDBLogDir       = "F:\Program Files\Microsoft SQL Server\MSSQL13.$instanceName\MSSQL\Data"
            SQLBackupDir          = "F:\Program Files\Microsoft SQL Server\MSSQL13.$instanceName\MSSQL\Backup"
            SourcePath            = 'S:\'
            UpdateEnabled         = 'False'
            ForceReboot           = $false
            BrowserSvcStartupType = 'Automatic'
            DependsOn             = '[WaitForVolume]WaitForISO'

            PsDscRunAsCredential  = $DomainCreds
        }

        SqlServerLogin AddClusterSvcAccountToSqlServer
        {
            Name = "NT SERVICE\ClusSvc"
            LoginType = "WindowsUser"
			ServerName = "$env:COMPUTERNAME"
			InstanceName = "$instanceName"
        }

        #TODO: Create a special group for "NT SERVICE\clusterSvc" and grant only 'Connect SQL', 
        #      'Alter Any Availability Group', and 'View Server State' permissions.
		SqlServerRole AddDomainAdminAccountToSysAdmin
        {
			Ensure = "Present"
            MembersToInclude = $DomainCreds.UserName,"NT SERVICE\ClusSvc"
            ServerRoleName = "sysadmin"
			ServerName = "$env:COMPUTERNAME"
			InstanceName = "$instanceName"
			DependsOn = "[SqlServerLogin]AddClusterSvcAccountToSqlServer"
        }


        if ($PrimaryReplica -eq $env:COMPUTERNAME) { #This is the primary
            xCluster CreateCluster
            {
                Name                          = $ClusterName
                StaticIPAddress               = $ClusterIP
                DomainAdministratorCredential = $DomainCreds
                DependsOn                     = "[WindowsFeature]FCPSCMD"
            }

            Script SetCloudWitness
            {
                GetScript = { 
                    return @{ 'Result' = $true }
                }
                SetScript = {
                    Set-ClusterQuorum -CloudWitness -AccountName $using:witnessStorageAccount -AccessKey $using:witnessStorageAccountKey -Endpoint $using:witnessEndpoint
                }
                TestScript = {
                    $(Get-ClusterQuorum).QuorumResource.ResourceType -eq "Cloud Witness"
                }
                DependsOn = "[xCluster]CreateCluster"
                PsDscRunAsCredential = $DomainCreds
            }

            SqlAlwaysOnService EnableAlwaysOn
            {
                Ensure               = 'Present'
                ServerName           = $env:COMPUTERNAME
                InstanceName         = $instanceName
                RestartTimeout       = 120
                DependsOn = "[xCluster]CreateCluster"
            }

            # Create a DatabaseMirroring endpoint
            SqlServerEndpoint HADREndpoint
            {
                EndPointName         = 'HADR'
                Ensure               = 'Present'
                Port                 = $DatabaseMirrorPort
                ServerName           = $env:COMPUTERNAME
                InstanceName         = "$instanceName"
                DependsOn            = "[SqlAlwaysOnService]EnableAlwaysOn"
            }

            # Create the availability group on the instance tagged as the primary replica
            SqlAG CreateAG
            {
                Ensure               = "Present"
                Name                 = $SqlAlwaysOnAvailabilityGroupName
                ServerName           = $env:COMPUTERNAME
                InstanceName         = "$instanceName"
                DependsOn            = "[SqlServerEndpoint]HADREndpoint"
                AvailabilityMode     = "SynchronousCommit"
                FailoverMode         = "Automatic" 
            }

            SqlAGListener AvailabilityGroupListener
            {
                Ensure               = 'Present'
                ServerName           = $PrimaryReplica
                InstanceName         = "$instanceName"
                AvailabilityGroup    = $SqlAlwaysOnAvailabilityGroupName
                Name                 = $ClusterName
                IpAddress            = "$ClusterIP/255.255.255.0"
                Port                 = 1433
                PsDscRunAsCredential = $DomainCreds
                DependsOn            = "[SqlAG]CreateAG"
            }

            Script SetProbePort
            {

                GetScript = { 
                    return @{ 'Result' = $true }
                }
                SetScript = {
                    $ipResourceName = $using:ClusterName + "_" + $using:ClusterIP
                    $ipResource = Get-ClusterResource $ipResourceName
                    $clusterResource = Get-ClusterResource -Name $using:ClusterName 

                    Set-ClusterParameter -InputObject $ipResource -Name ProbePort -Value $using:ProbePortNumber

                    Stop-ClusterResource $ipResource
                    Stop-ClusterResource $clusterResource

                    Start-ClusterResource $clusterResource #This should be enough
                    Start-ClusterResource $ipResource #To be on the safe side

                }
                TestScript = {
                    $ipResourceName = $using:ClusterName + "_" + $using:ClusterIP
                    $resource = Get-ClusterResource $ipResourceName
                    $probePort = $(Get-ClusterParameter -InputObject $resource -Name ProbePort).Value
                    Write-Verbose "ProbePort = $probePort"
                    ($(Get-ClusterParameter -InputObject $resource -Name ProbePort).Value -eq $using:ProbePortNumber)
                }
                DependsOn = "[SqlAGListener]AvailabilityGroupListener"
                PsDscRunAsCredential = $DomainCreds
            }

        } else {
            xWaitForCluster WaitForCluster
            {
                Name             = $ClusterName
                RetryIntervalSec = 10
                RetryCount       = 60
                DependsOn        = "[WindowsFeature]FCPSCMD","[Script]ResetSpns"
            }

            #We have to do this manually due to a problem with xCluster:
            #  see: https://github.com/PowerShell/xFailOverCluster/issues/7
            #      - Cluster is added with an IP and the xCluster module tries to access this IP. 
            #      - Cluster is not not yet responding on that addreess
            Script JoinExistingCluster
            {
                GetScript = { 
                    return @{ 'Result' = $true }
                }
                SetScript = {
                    $targetNodeName = $env:COMPUTERNAME
                    Add-ClusterNode -Name $targetNodeName -Cluster $using:PrimaryReplica
                }
                TestScript = {
                    $targetNodeName = $env:COMPUTERNAME
                    $(Get-ClusterNode -Cluster $using:PrimaryReplica).Name -contains $targetNodeName
                }
                DependsOn = "[xWaitForCluster]WaitForCluster"
                PsDscRunAsCredential = $DomainCreds
            }

            SqlAlwaysOnService EnableAlwaysOn
            {
                Ensure               = 'Present'
                ServerName           = $env:COMPUTERNAME
                InstanceName         = "$instanceName"
                RestartTimeout       = 120
                DependsOn = "[Script]JoinExistingCluster"
            }

              # Create a DatabaseMirroring endpoint
              SqlServerEndpoint HADREndpoint
              {
                  EndPointName         = 'HADR'
                  Ensure               = 'Present'
                  Port                 = 5022
                  ServerName           = $env:COMPUTERNAME
                  InstanceName         = "$instanceName"
                  DependsOn            = "[SqlAlwaysOnService]EnableAlwaysOn"
              }
    

              SqlWaitForAG WaitForAG
              {
                  Name                 = $ClusterName
                  RetryIntervalSec     = 20
                  RetryCount           = 30
                  PsDscRunAsCredential = $DomainCreds
                  DependsOn                  = "[SqlServerEndpoint]HADREndpoint","[SqlServerRole]AddDomainAdminAccountToSysAdmin"
              }
      
                # Add the availability group replica to the availability group
                SqlAGReplica AddReplica
                {
                    Ensure                     = 'Present'
                    Name                       = $env:COMPUTERNAME
                    AvailabilityGroupName      = $ClusterName
                    ServerName                 = $env:COMPUTERNAME
                    InstanceName               = "$instanceName"
                    PrimaryReplicaServerName   = $PrimaryReplica
                    PrimaryReplicaInstanceName = "$instanceName"
                    PsDscRunAsCredential = $DomainCreds
                    AvailabilityMode     = "SynchronousCommit"
                    FailoverMode         = "Automatic"
                    DependsOn            = "[SqlWaitForAG]WaitForAG"     
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