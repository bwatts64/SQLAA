# SqlServerDsc

The **SqlServerDsc** module contains DSC resources
for deployment and configuration of SQL Server.

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/b3g8f7kftx64n26l/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/SqlServerDsc/branch/master)
[![codecov](https://codecov.io/gh/PowerShell/SqlServerDsc/branch/master/graph/badge.svg)](https://codecov.io/gh/PowerShell/SqlServerDsc/branch/master)

This is the branch containing the latest release -
no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/b3g8f7kftx64n26l/branch/dev?svg=true)](https://ci.appveyor.com/project/PowerShell/SqlServerDsc/branch/dev)
[![codecov](https://codecov.io/gh/PowerShell/SqlServerDsc/branch/dev/graph/badge.svg)](https://codecov.io/gh/PowerShell/SqlServerDsc/branch/dev)

This is the development branch
to which contributions should be proposed by contributors as pull requests.
This development branch will periodically be merged to the master branch,
and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Regardless of the way you want to contribute
we are tremendously happy to have you here.

There are several ways you can contribute.
You can submit an issue to report a bug.
You can submit an issue to request an improvement.
You can take part in discussions for issues.
You can review pull requests and comment on other contributors changes.
You can also improve the resources and tests,
or even create new resources,
by sending in pull requests yourself.

* If you want to submit an issue or take part in discussions,
  please browse the list of [issues](https://github.com/PowerShell/SqlServerDsc/issues).
  Please check out [Contributing to the DSC Resource Kit](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md)
  on how to work with issues.
* If you want to review pull requests,
  please first check out the [Review Pull Request guidelines](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md#reviewing-pull-requests),
  and the browse the list of [pull requests](https://github.com/PowerShell/SqlServerDsc/pulls)
  and look for those pull requests with label 'needs review'.
* If you want to improve this resource module,
  then please check out the following guidelines.
  * The specific [Contributing to SqlServerDsc](https://github.com/PowerShell/SqlServerDsc/blob/dev/CONTRIBUTING.md)
    guidelines.
  * The common [Style Guidelines & Best Practices](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md).
  * The common [Testing Guidelines](https://github.com/PowerShell/DscResources/blob/master/TestsGuidelines.md).
  * If you are new to GitHub (and git),
    then please check out [Getting Started with GitHub](https://github.com/PowerShell/DscResources/blob/master/GettingStartedWithGitHub.md).
  * If you are new to Pester and writing test, then please check out
    [Getting started with Pester](https://github.com/PowerShell/DscResources/blob/master/GettingStartedWithPester.md).

If you need any help along the way,
don't be afraid to ask.
We are here for each other.

## Installation

### From GitHub source code

To manually install the module, download the source code from GitHub and unzip
the contents to the '$env:ProgramFiles\WindowsPowerShell\Modules' folder.

### From PowerShell Gallery

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

```powershell
Find-Module -Name SqlServerDsc | Install-Module
```

To confirm installation, run the below command and ensure you see the SQL Server
DSC resources available:

```powershell
Get-DscResource -Module SqlServerDsc
```

## Requirements

The minimum Windows Management Framework (PowerShell) version required is 5.0
or higher, which ships with Windows 10 or Windows Server 2016,
but can also be installed on Windows 7 SP1, Windows 8.1,
Windows Server 2008 R2 SP1, Windows Server 2012 and Windows Server 2012 R2.

## Examples

You can review the [Examples](/Examples) directory in the SqlServerDsc module
for some general use scenarios for all of the resources that are in the module.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

* [**SqlAG**](#sqlag)
  resource to ensure an availability group is present or absent.
* [**SqlAGDatabase**](#sqlagdatabase)
  to manage the database membership in Availability Groups.
* [**SqlAgentAlert**](#sqlagentalert)
  resource to manage SQL Agent Alerts.
* [**SqlAgentFailsafe**](#sqlagentfailsafe)
  resource to manage SQL Agent Failsafe Operator.
* [**SqlAgentOperator**](#sqlagentoperator)
  resource to manage SQL Agent Operators.
* [**SqlAGListener**](#sqlaglistener)
  Create or remove an availability group listener.
* [**SqlAGReplica**](#sqlagreplica)
  resource to ensure an availability group replica is present or absent.
* [**SqlAlias**](#sqlalias) resource to manage SQL Server client Aliases.
* [**SqlAlwaysOnService**](#sqlalwaysonservice) resource to enable
  always on on a SQL Server.
* [**SqlDatabase**](#sqldatabase) resource to manage ensure database
  is present or absent.
* [**SqlDatabaseDefaultLocation**](#sqldatabasedefaultlocation) resource
  to manage default locations for Data, Logs, and Backups for SQL Server
* [**SqlDatabaseOwner**](#sqldatabaseowner) resource to manage SQL
  database owners.
* [**SqlDatabasePermission**](#sqldatabasepermission) resource to
  manage SQL database permissions.
* [**SqlDatabaseRecoveryModel**](#sqldatabaserecoverymodel) resource
  to manage database recovery model.
* [**SqlDatabaseRole**](#sqldatabaserole) resource to manage SQL database roles.
* [**SqlDatabaseUser**](#sqldatabaseuser) resource to manage SQL database users.
* [**SqlRS**](#sqlrs) configures SQL Server Reporting.
  Services to use a database engine in another instance.
* [**SqlRSSetup**](#sqlrssetup) Installs the standalone
  [Microsoft SQL Server Reporting Services](https://docs.microsoft.com/en-us/sql/reporting-services/create-deploy-and-manage-mobile-and-paginated-reports).
* [**SqlScript**](#sqlscript) resource to extend DSC Get/Set/Test
  functionality to T-SQL.
* [**SqlScriptQuery**](#sqlscriptquery) resource to extend DSC Get/Set/Test
  functionality to T-SQL.
* [**SqlServerConfiguration**](#sqlserverconfiguration) resource to manage
  [SQL Server Configuration Options](https://msdn.microsoft.com/en-us/library/ms189631.aspx).
* [**SqlServerDatabaseMail**](#sqlserverdatabasemail) resource
  to manage SQL Server Database Mail.
* [**SqlServerEndpoint**](#sqlserverendpoint) resource to ensure database endpoint
  is present or absent.
* [**SqlServerEndpointPermission**](#sqlserverendpointpermission) Grant or revoke
  permission on the endpoint.
* [**SqlServerEndpointState**](#sqlserverendpointstate) Change state of the endpoint.
* [**SqlServerLogin**](#sqlserverlogin) resource to manage SQL logins.
* [**SqlServerMaxDop**](#sqlservermaxdop) resource to manage MaxDegree of Parallelism
  for SQL Server.
* [**SqlServerMemory**](#sqlservermemory) resource to manage Memory for SQL Server.
* [**SqlServerNetwork**](#sqlservernetwork) resource to manage SQL Server Network
  Protocols.
* [**SqlServerPermission**](#sqlserverpermission) Grant or revoke permission on
  the SQL Server.
* [**SqlServerReplication**](#sqlserverreplication) resource to manage SQL Replication
  distribution and publishing.
* [**SqlServerRole**](#sqlserverrole) resource to manage SQL server roles.
* [**SqlServerSecureConnection**](#sqlserversecureconnection) resource to
  enable encrypted SQL connections.
* [**SqlServiceAccount**](#sqlserviceaccount) Manage the service account
  for SQL Server services.
* [**SqlSetup**](#sqlsetup) installs a standalone SQL Server instance.
* [**SqlWaitForAG**](#sqlwaitforag) resource to
  wait until availability group is created on primary server.
* [**SqlWindowsFirewall**](#sqlwindowsfirewall) configures firewall settings to
  allow remote access to a SQL Server instance.

### SqlAG

This resource is used to create, remove, and update an Always On Availability Group.
It will also manage the Availability Group replica on the specified node.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2012 or later.
* 'NT SERVICE\ClusSvc' or 'NT AUTHORITY\SYSTEM' must have the 'Connect SQL',
  'Alter Any Availability Group', and 'View Server State' permissions.

#### Parameters

* **`[String]` Name** _(Key)_: The name of the availability group.
* **`[String]` ServerName** _(Required)_: Hostname of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: Name of the SQL instance to be configured.
* **`[String]` Ensure** _(Write)_: Specifies if the availability group should be
  present or absent. Default is Present. { *Present* | Absent }
* **`[String]` AutomatedBackupPreference** _(Write)_: Specifies the automated backup
  preference for the availability group. When creating a group the default is 'None'.
  { Primary | SecondaryOnly | Secondary | *None* }
* **`[String]` AvailabilityMode** _(Write)_: Specifies the replica availability mode.
  Default when creating a group is 'AsynchronousCommit'.
  { *AsynchronousCommit* | SynchronousCommit }
* **`[UInt32]` BackupPriority** _(Write)_: Specifies the desired priority of the
  replicas in performing backups. The acceptable values for this parameter are:
  integers from 0 through 100. Of the set of replicas which are online and available,
  the replica that has the highest priority performs the backup. When creating
  a group the default is 50.
* **`[Boolean]` BasicAvailabilityGroup** _(Write)_: Specifies the type of
  availability group is Basic. This is only available is SQL Server 2016
  and later and is ignored when applied to previous versions.
* **`[Boolean]` DatabaseHealthTrigger** _(Write)_: Specifies if the option
  Database Level Health Detection is enabled. This is only available is SQL
  Server 2016 and later and is ignored when applied to previous versions.
* **`[Boolean]` DtcSupportEnabled** _(Write)_: Specifies if the option Database
  DTC Support is enabled. This is only available is SQL Server 2016 and later
  and is ignored when applied to previous versions. This can't be altered once
  the Availability Group is created and is ignored if it is the case.
* **`[String]` ConnectionModeInPrimaryRole** _(Write)_: Specifies how the availability
  replica handles connections when in the primary role.
  { AllowAllConnections | AllowReadWriteConnections }
* **`[String]` ConnectionModeInSecondaryRole** _(Write)_: Specifies how the availability
  replica handles connections when in the secondary role.
  { AllowNoConnections | AllowReadIntentConnectionsOnly | AllowAllConnections }
* **`[String]` EndpointHostName** _(Write)_: Specifies the hostname or IP address
  of the availability group replica endpoint. Default is the instance network name.
* **`[String]` FailureConditionLevel** _(Write)_: Specifies the automatic failover
  behavior of the availability group. { OnServerDown | OnServerUnresponsive |
  OnCriticalServerErrors | OnModerateServerErrors |
  OnAnyQualifiedFailureCondition }
* **`[String]` FailoverMode** _(Write)_: Specifies the failover mode.
  When creating a group the default is 'Manual'. { Automatic | *Manual* }
* **`[UInt32]` HealthCheckTimeout** _(Write)_: Specifies the length of time, in
  milliseconds, after which AlwaysOn availability groups declare an unresponsive
  server to be unhealthy. When creating a group the default is 30000.
* **`[Boolean]` ProcessOnlyOnActiveNode** _(Write)_: Specifies that the resource
  will only determine if a change is needed if the target node is the active
  host of the SQL Server Instance.

#### Read-Only Properties from Get-TargetResource

* **`[String]` EndpointUrl** _(Read)_: Gets the Endpoint URL of the
  availability group replica endpoint.
* **`[UInt32]` EndpointPort** _(Read)_: Gets the port the database mirroring
  endpoint is listening on
* **`[UInt32]` Version** _(Read)_: Gets the major version of the SQL Server
  instance.
* **`[Boolean]` IsActiveNode** _(Read)_: Determines if the current node is
  actively hosting the SQL Server instance.

#### Examples

* [Add a SQL Server Always On Availability Group](/Examples/Resources/SqlAG/1-CreateAvailabilityGroup.ps1)
* [Add a SQL Server Always On Availability Group and explicitly defines its properties](/Examples/Resources/SqlAG/3-CreateAvailabilityGroupDetailed.ps1)
* [Remove a SQL Server Always On Availability Group](/Examples/Resources/SqlAG/2-RemoveAvailabilityGroup.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAG).

### SqlAGDatabase

This resource is used to add and/or remove databases to a specified availability
group.

### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2012 or later.
* Target machine must be running Windows Management Framework (WMF) 5 or later.

### Parameters

* **`[String]` DatabaseName** _(Required)_: The name of the database(s) to add to
  the availability group. This accepts wildcards.
* **`[String]` ServerName** _(Key)_: Hostname of the SQL Server where the primary
  replica of the availability group lives. If the availability group is not
  currently on this server, the resource will attempt to connect to the server
  where the primary replica lives.
* **`[String]` InstanceName** _(Key)_: Name of the SQL instance where the primary
  replica of the availability group lives. If the availability group is not currently
  on this instance, the resource will attempt to connect to the instance where the
  primary replica lives.
* **`[String]` AvailabilityGroupName** _(Key)_: The name of the availability group
  in which to manage the database membership(s).
* **`[String]` BackupPath** _(Required)_: The path used to seed the availability
  group replicas. This should be a path that is accessible by all of the replicas.
* **`[String]` Ensure** _(Write)_: Specifies the membership of the database(s) in
  the availability group. The options are:

  * **Present**:  The defined database(s) are added to the availability group.
    All other databases that may be a member of the availability group are ignored.
  * **Absent**:   The defined database(s) are removed from the availability group.
    All other databases that may be a member of the availability group are ignored.

  The default is 'Present'. { *Present* | Absent  }

* **`[Boolean]` Force** _(Write)_: When used with "Ensure = 'Present'" it ensures
  the specified database(s) are the only databases that are a member of the specified
  Availability Group. This parameter is ignored when 'Ensure' is 'Absent'.
* **`[Boolean]` MatchDatabaseOwner** _(Write)_: If set to $true, this ensures the
  database owner of the database on the primary replica is the owner of the database
  on all secondary replicas. This requires the database owner is available
  as a login on all replicas and that the PsDscRunAsCredential has impersonate any
  login, control server, impersonate login, or control login permissions.
  If set to $false, the owner of the database will be the PsDscRunAsCredential.
  The default is '$false'.
* **`[Boolean]` ReplaceExisting** _(Write)_: If set to $true, this adds the restore
  option WITH REPLACE.
  If set to $false, Existing databases and files will block the restore
  and throw error.
  The default is '$false'.
* **`[Boolean]` ProcessOnlyOnActiveNode** _(Write)_: Specifies that the resource
  will only determine if a change is needed if the target node is the active
  host of the SQL Server Instance.

#### Read-Only Properties from Get-TargetResource

* **`[Boolean]` IsActiveNode** _(Read)_: Determines if the current node is
  actively hosting the SQL Server instance.

#### Examples

* [Add a database to an Availability Group](/Examples/Resources/SqlAGDatabase/1-AddDatabaseToAvailabilityGroup.ps1)
* [Remove a database from an Availability Group](/Examples/Resources/SqlAGDatabase/2-RemoveDatabaseFromAvailabilityGroup.ps1)
* [Enforce only specified databases as member in an Availability Group](/Examples/Resources/SqlAGDatabase/3-MatchDefinedDatabaseInAvailabilityGroup.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAGDatabase).

### SqlAgentAlert

This resource is used to add/remove SQL Agent Alerts. You can also
update the severity or message id.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` Name** _(Key)_: The name of the SQL Agent Alert.
* **`[String]` Ensure** _(Write)_: Specifies if the SQL Agent Alert should
  be present or absent. Default is Present. { *Present* | Absent }
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be
  configured. Default is $env:COMPUTERNAME.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` Severity** _(Write)_: The severity of the SQL Agent Alert.
* **`[String]` MessageId** _(Write)_: The message id of the SQL Agent Alert.

#### Examples

* [Add a SQL Agent Alert](/Examples/Resources/SqlAgentAlert/1-AddAlert.ps1)
* [Remove a SQL Agent Alert](/Examples/Resources/SqlAgentAlert/2-RemoveAlert.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAgentAlert).

### SqlAgentFailsafe

This resource is used to add/remove the SQL Agent Failsafe Operator. You can also
update the Notification method.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` Name** _(Key)_: The name of the SQL Agent Failsafe Operator.
* **`[String]` Ensure** _(Write)_: Specifies if the SQL Agent Failsafe Operator
  should be present or absent. Default is Present. { *Present* | Absent }
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be
  configured. Default is $env:COMPUTERNAME.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` NotificationMethod** _(Write)_: The method of notification for the
  Failsafe Operator. The default is none.

#### Examples

* [Add SQL Agent Failsafe Operator](/Examples/Resources/SqlAgentFailsafe/1-AddFailsafe.ps1)
* [Remove SQL Agent Failsafe Operator](/Examples/Resources/SqlAgentFailsafe/2-RemoveFailsafe.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAgentFailsafe).

### SqlAgentOperator

This resource is used to add/remove SQL Agent Operators. You can also update
the operators email address.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` Name** _(Key)_: The name of the SQL Agent Operator.
* **`[String]` Ensure** _(Write)_: Specifies if the SQL Agent Operator should
  be present or absent. Default is Present. { *Present* | Absent }
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be
  configured. Default is $env:COMPUTERNAME.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` EmailAddress** _(Write)_: The email address to be used for
  the SQL Agent Operator.

#### Examples

* [Add a SQL Agent Operator](/Examples/Resources/SqlAgentOperator/1-AddOperator.ps1)
* [Remove a SQL Agent Operator](/Examples/Resources/SqlAgentOperator/2-RemoveOperator.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAgentOperator).

### SqlAGListener

No description.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2012 or later.
* Target machine must have access to the SQLPS PowerShell module or the SqlServer
  PowerShell module.
* Requires that the Cluster name Object (CNO) has been delegated the right
  _Create Computer Object_ in the organizational unit (OU) in which the
  Cluster Name Object (CNO) resides.

#### Parameters

* **`[String]` InstanceName** _(Key)_: The SQL Server instance name of the primary
  replica.
* **`[String]` AvailabilityGroup** _(Key)_: The name of the availability group to
  which the availability group listener is or will be connected.
* **`[String]` ServerName** _(Write)_: The host name or FQDN of the primary replica.
* **`[String]` Ensure** _(Write)_: If the availability group listener should be present
  or absent. Default value is 'Present'. { *Present* | Absent }.
* **`[String]` Name** _(Write)_: The name of the availability group listener, max
  15 characters. This name will be used as the Virtual Computer Object (VCO).
* **`[String[]]` IpAddress** _(Write)_: The IP address used for the availability
  group listener, in the format 192.168.10.45/255.255.252.0. If using DHCP, set
  to the first IP-address of the DHCP subnet, in the format 192.168.8.1/255.255.252.0.
  Must be valid in the cluster-allowed IP range.
* **`[Uint16]` Port** _(Write)_: The port used for the availability group listener.
* **`[Boolean]` DHCP** _(Write)_: If DHCP should be used for the availability group
  listener instead of static IP address.

#### Examples

* [Adds an Availability Group listener with the same name as the Availability Group VCO](/Examples/Resources/SqlAGListener/1-AddAvailabilityGroupListenerWithSameNameAsVCO.ps1)
* [Adds an Availability Group listener with a different name than the Availability Group VCO](/Examples/Resources/SqlAGListener/2-AddAvailabilityGroupListenerWithDifferentNameAsVCO.ps1)
* [Removes an Availability Group listener with the same name as the Availability Group VCO](/Examples/Resources/SqlAGListener/3-RemoveAvailabilityGroupListenerWithSameNameAsVCO.ps1)
* [Removes an Availability Group listener with a different name than the Availability Group VCO](/Examples/Resources/SqlAGListener/4-RemoveAvailabilityGroupListenerWithDifferentNameAsVCO.ps1)
* [Adds an Availability Group listener using DHCP on the default server subnet](/Examples/Resources/SqlAGListener/5-AddAvailabilityGroupListenerUsingDHCPWithDefaultServerSubnet.ps1)
* [Adds an Availability Group listener using DHCP with a specific subnet](/Examples/Resources/SqlAGListener/6-AddAvailabilityGroupListenerUsingDHCPWithSpecificSubnet.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAGListener).

### SqlAGReplica

This resource is used to create, remove, and update an
Always On Availability Group Replica.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2012 or later.
* 'NT SERVICE\ClusSvc' or 'NT AUTHORITY\SYSTEM' must have the 'Connect SQL',
  'Alter Any Availability Group', and 'View Server State' permissions.

#### Parameters

* **`[String]` Name** _(Key)_: The name of the availability group replica. For named
  instances this must be in the following format ServerName\InstanceName.
* **`[String]` AvailabilityGroupName** _(Key)_: The name of the availability group.
* **`[String]` ServerName** _(Required)_: Hostname of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: Name of the SQL instance to be configured.
* **`[String]` PrimaryReplicaServerName** _(Write)_: Hostname of the SQL Server where
  the primary replica is expected to be active. If the primary replica is not found
  here, the resource will attempt to find the host that holds the primary replica
  and connect to it.
* **`[String]` PrimaryReplicaInstanceName** _(Write)_: Name of the SQL instance
  where the primary replica lives.
* **`[String]` Ensure** _(Write)_: Specifies if the availability group replica should
  be present or absent. Default is Present. { *Present* | Absent }
* **`[String]` AvailabilityMode** _(Write)_: Specifies the replica availability mode.
  When creating a replica the default is 'AsynchronousCommit'.
  { *AsynchronousCommit* | SynchronousCommit }
* **`[UInt32]` BackupPriority** _(Write)_: Specifies the desired priority of the
  replicas in performing backups. The acceptable values for this parameter are:
  integers from 0 through 100. Of the set of replicas which are online and available,
  the replica that has the highest priority performs the backup. When creating a
  replica the default is 50.
* **`[String]` ConnectionModeInPrimaryRole** _(Write)_: Specifies how the availability
  replica handles connections when in the primary role.
  { AllowAllConnections | AllowReadWriteConnections }
* **`[String]` ConnectionModeInSecondaryRole** _(Write)_: Specifies how the availability
  replica handles connections when in the secondary role.
  { AllowNoConnections | AllowReadIntentConnectionsOnly | AllowAllConnections }
* **`[String]` EndpointHostName** _(Write)_: Specifies the hostname or IP address
  of the availability group replica endpoint. Default is the instance network name.
* **`[String]` FailoverMode** _(Write)_: Specifies the failover mode.
  When creating a replica the default is 'Manual'. { Automatic | *Manual* }
* **`[String]` ReadOnlyRoutingConnectionUrl** _(Write)_: Specifies the fully-qualified
  domain name (FQDN) and port to use when routing to the replica for read only
  connections.
* **`[String[]]` ReadOnlyRoutingList** _(Write)_: Specifies an ordered list of replica
  server names that represent the probe sequence for connection director to use
  when redirecting read-only connections through this availability replica. This
  parameter applies if the availability replica is the current primary replica of
  the availability group.
* **`[Boolean]` ProcessOnlyOnActiveNode** _(Write)_: Specifies that the resource
  will only determine if a change is needed if the target node is the active
  host of the SQL Server instance.

#### Read-Only Properties from Get-TargetResource

* **`[Uint16]` EndpointPort** _(Read)_: Output the network port the endpoint is
  listening on. Used by Get-TargetResource.
* **`[String]` EndpointUrl** _(Read)_: Output the endpoint URL of the
  Availability Group Replica. Used by Get-TargetResource.
* **`[Boolean]` IsActiveNode** _(Read)_: Determines if the current node is
  actively hosting the SQL Server instance.

#### Examples

* [Add a SQL Server Always On Availability Group Replica](/Examples/Resources/SqlAGReplica/1-CreateAvailabilityGroupReplica.ps1)
* [Remove a SQL Server Always On Availability Group Replica](/Examples/Resources/SqlAGReplica/2-RemoveAvailabilityGroupReplica.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAGReplica).

### SqlAlias

No description.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.

#### Parameters

* **`[String]` Name** _(Key)_: The name of Alias (e.g. svr01\inst01).
* **`[String]` ServerName** _(Key)_: The SQL Server you are aliasing (the NetBIOS
  name or FQDN).
* **`[String]` Ensure** _(Write)_: Determines whether the alias should be added or
  removed. Default value is 'Present'. { *Present* | Absent }.
* **`[String]` Protocol** _(Write)_: Protocol to use when connecting. Valid values
  are 'TCP' or 'NP' (Named Pipes). Default value is 'TCP'. { *TCP* | NP }.
* **`[Uint16]` TCPPort** _(Write)_: The TCP port SQL is listening on. Only used when
  protocol is set to 'TCP'. Default value is port 1433.
* **`[Boolean]` UseDynamicTcpPort** _(Write)_: The UseDynamicTcpPort specify that
  the Net-Library will determine the port dynamically. The port specified in Port
  number will not be used. Default value is '$false'.

#### Read-Only Properties from Get-TargetResource

* **`[String]` PipeName** _(Read)_: Named Pipes path from the Get-TargetResource
  method.

#### Examples

* [Add an SQL Server alias](/Examples/Resources/SqlAlias/1-AddSqlAlias.ps1)
* [Remove an SQL Server alias](/Examples/Resources/SqlAlias/2-RemoveSqlAlias.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAlias).

### SqlAlwaysOnService

Enables or disabled SQL Server Always On high availability and disaster recovery
(Always On HADR).

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2012 or later.

#### Parameters

* **`[String]` ServerName** _(Key)_: The hostname of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` Ensure** _(Required)_: An enumerated value that describes if the SQL
  Server should have Always On high availability and disaster recovery (HADR)
  property enabled ('Present') or disabled ('Absent'). { Present | Absent }.
* **`[SInt32]` RestartTimeout** _(Write)_: The length of time, in seconds, to wait
  for the service to restart. Default is 120 seconds.

#### Read-Only Properties from Get-TargetResource

* **`[Boolean]` IsHadrEnabled** _(Read)_: Returns the status of AlwaysOn high
  availability and disaster recovery (HADR).

#### Examples

* [Enable SQL Server Always On](/Examples/Resources/SqlAlwaysOnService/1-EnableAlwaysOn.ps1)
* [Disable SQL Server Always On](/Examples/Resources/SqlAlwaysOnService/2-DisableAlwaysOn.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAlwaysOnService).

### SqlDatabase

This resource is used to create or delete a database. For more information about
SQL Server databases, please read the following articles [Create a Database](https://docs.microsoft.com/en-us/sql/relational-databases/databases/create-a-database)
and [Delete a Database](https://docs.microsoft.com/en-us/sql/relational-databases/databases/delete-a-database).

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` ServerName** _(Key)_: The host name of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` Name** _(Key)_: The name of database to be created or dropped.
* **`[String]` Collation** _(Write)_: The name of the SQL collation to use
  for the new database. Defaults to server collation.
* **`[String]` Ensure** _(Write)_: When set to 'Present', the database will be created.
  When set to 'Absent', the database will be dropped. { *Present* | Absent }.

#### Examples

* [Create a Database](/Examples/Resources/SqlDatabase/1-CreateDatabase.ps1)
* [Delete a database](/Examples/Resources/SqlDatabase/2-DeleteDatabase.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabase).

### SqlDatabaseDefaultLocation

This resource is used to configure default locations for user databases. The
types of default locations that can be changed are Data, Log, and Backup. For
more information about database default locations, please read the article
[Changing the Database Default Locations](https://technet.microsoft.com/en-us/library/dd206993.aspx).

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` ServerName** _(Key)_: The host name of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to
  be configured.
* **`[String]` Type** _(Key)_: The type of database default location to be
  configured. { Data | Log | Backup }
* **`[String]` Path** _(Required)_: The path to the default directory to be configured.
* **`[Boolean]` RestartService** _(Write)_: If set to $true then SQL Server and
  dependent services will be restarted if a change to the configuration is made.
  The default value is $false.
* **`[Boolean]` ProcessOnlyOnActiveNode** _(Write)_: Specifies that the resource
  will only determine if a change is needed if the target node is the active
  host of the SQL Server Instance.

#### Read-Only Property from Get-TargetResource

* **`[Boolean]` IsActiveNode** _(Read)_: Determines if the current node is
  actively hosting the SQL Server instance.

#### Examples

* [Set database default locations](/Examples/Resources/SqlDatabaseDefaultLocation/1-SetDatabaseDefaultLocation.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabaseDefaultLocation).

### SqlDatabaseOwner

This resource is used to configure the owner of a database.
For more information about database owner, please read the article
[Changing the Database Owner](https://technet.microsoft.com/en-us/library/ms190909.aspx).

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` Database** _(Key)_: The name of database to be configured.
* **`[String]` Name** _(Required)_: The name of the login that will become a owner
  of the desired sql database.
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.

#### Examples

* [Set database owner](/Examples/Resources/SqlDatabaseOwner/1-SetDatabaseOwner.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabaseOwner).

### SqlDatabasePermission

This resource is used to grant, deny or revoke permissions for a user in a database.
For more information about permissions, please read the article
[Permissions (Database Engine)](https://msdn.microsoft.com/en-us/library/ms191291.aspx).

>Note! When revoking permission with PermissionState 'GrantWithGrant', both the
grantee and _all the other users the grantee has granted the same permission to_,
will also get their permission revoked.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` ServerName** _(Key)_: The host name of the SQL Server to be configured.
  Default values is '$env:COMPUTERNAME'.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
  Default value is 'MSSQLSERVER'.
* **`[String]` Database** _(Key)_: The name of the database.
* **`[String]` Name** _(Key)_: The name of the user that should be granted or denied
  the permission.
* **`[String]` PermissionState** _(Key)_: The state of the permission.
  { Grant | Deny | GrantWithGrant }.
* **`[String[]]` Permissions** _(Required)_: The permissions to be granted or denied
  for the user in the database. Valid permissions can be found in the article
  [SQL Server Permissions](https://msdn.microsoft.com/en-us/library/ms191291.aspx#Anchor_3).
* **`[String]` Ensure** _(Write)_: If the permission should be granted (Present)
  or revoked (Absent). { Present | Absent }.

#### Examples

* [Grant Database Permission](/Examples/Resources/SqlDatabasePermission/1-GrantDatabasePermissions.ps1)
* [Revoke Database Permission](/Examples/Resources/SqlDatabasePermission/2-RevokeDatabasePermissions.ps1)
* [Deny Database Permission](/Examples/Resources/SqlDatabasePermission/3-DenyDatabasePermissions.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabasePermission).

### SqlDatabaseRecoveryModel

This resource set the recovery model for a database. The recovery model controls
how transactions are logged, whether the transaction log requires (and allows)
backing up, and what kinds of restore operations are available.
Three recovery models exist: full, simple, and bulk-logged.
Read more about recovery model in this article
[View or Change the Recovery Model of a Database](https://msdn.microsoft.com/en-us/library/ms189272.aspx)

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` Name** _(Key)_: The SQL database name.
* **`[String]` ServerName** _(Key)_: The host name of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` RecoveryModel** _(Required)_: The recovery model to use for the database.
  { Full | Simple | BulkLogged }.

#### Examples

* [Set the RecoveryModel of a database](/Examples/Resources/SqlDatabaseRecoveryModel/1-SetDatabaseRecoveryModel.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabaseRecoveryModel).

### SqlDatabaseRole

This resource is used to create a database role when Ensure is set to 'Present'
or remove a database role when Ensure is set to 'Absent'. The resource also
manages members in both built-in and user created database roles.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` ServerName** _(Key)_: The host name of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` Database** _(Key)_: The name of the database in which the role should
  be configured.
* **`[String]` Name** _(Key)_: The name of the database role to be added or removed.
* **`[String[]]` Members** _(Write)_: The members the database role should have.
  This parameter will replace all the current database role members with the
  specified members. Can only be used when parameter Ensure is set to 'Present'.
* **`[String[]]` MembersToInclude** _(Write)_: The members the database role should
  include. This parameter will only add members to a database role. Can only
  be used when parameter Ensure is set to 'Present'. Can not be used at the same
  time as parameter Members.
* **`[String[]]` MembersToExclude** _(Write)_: The members the database role should
  exclude. This parameter will only remove members from a database role. Can only
  be used when parameter Ensure is set to 'Present'. Can not be used at the same
  time as parameter Members.
* **`[String]` Ensure** _(Write)_: If 'Present' (the default value) then the role
  will be added to the database and the role membership will be set. If 'Absent'
  then the role will be removed from the database. { *Present* | Absent }.

#### Read-Only Properties from Get-TargetResource

* **`[String]` MembersInDesiredState** _(Read)_: Indicates whether the database
  role members are in the desired state.

#### Examples

* [Add Role to a database](/Examples/Resources/SqlDatabaseRole/1-AddDatabaseRole.ps1)
* [Remove Role from a database](/Examples/Resources/SqlDatabaseRole/2-RemoveDatabaseRole.ps1)
* [Enforce Role membership](/Examples/Resources/SqlDatabaseRole/3-EnforceDatabaseRoleMembers.ps1)
* [Members to include in database role](/Examples/Resources/SqlDatabaseRole/4-MembersToIncludeInDatabaseRole.ps1)
* [Members to exclude from database role](/Examples/Resources/SqlDatabaseRole/5-MembersToExcludeFromDatabaseRole.ps1)
* [Members to include and exclude in a database role](/Examples/Resources/SqlDatabaseRole/6-MembersToIncludeAndExcludeInDatabaseRole.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabaseRole).

### SqlDatabaseUser

This resource is used to create a database users. A database user can be
created with or without a login, and a database users can be mapped to a
certificate or asymmetric key. The resource also allows re-mapping of the
SQL login.

> **Note:** This resource does not yet support [Contained Databases](https://docs.microsoft.com/en-us/sql/relational-databases/databases/contained-databases).

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` Name** _(Key)_: Specifies the name of the database user to
  be added or removed.
* **`[String]` ServerName** _(Key)_: Specifies the host name of the SQL
  Server on which the instance exist.
* **`[String]` InstanceName** _(Key)_: Specifies the SQL instance in which
  the database exist.
* **`[String]` DatabaseName** _(Key)_: Specifies the name of the database in
  which to configure the user.
* **`[String]` LoginName** _(Write)_: Specifies the name of the SQL login to
  associate with the database user. This must be specified if parameter
  UserType is set to 'Login'.
* **`[String]` AsymmetricKeyName** _(Write)_: Specifies the name of the
  asymmetric key to associate with the database user. This must be
  specified if parameter UserType is set to 'AsymmetricKey'.
* **`[String]` CertificateName** _(Write)_: Specifies the name of the
  certificate to associate with the database user. This must be specified
  if parameter UserType is set to 'Certificate'.
* **`[String]` UserType** _(Write)_: Specifies the type of the database
  user. Valid values are 'Login', 'NoLogin', 'Certificate', or 'AsymmetricKey'.
  Defaults to 'NoLogin'. { Login | *NoLogin* | Certificate | AsymmetricKey }.
* **`[String]` Ensure** _(Write)_: Specifies if the database user should
  be present or absent. If 'Present' then the database user will be added
  to the database and, if needed, the login mapping will be updated. If
  'Absent' then the database user will be removed from the database.
  Defaults to 'Present'. { *Present* | Absent }.
* **`[Boolean]` Force** _(Write)_: Specifies if the resource is allowed
  to re-create the database user if either the user type, the asymmetric
  key, or the certificate changes. Defaults to $false not allowing
  database users to be re-created.

#### Read-Only Properties from Get-TargetResource

* **`[String]` AuthenticationType** _(Read)_: Returns the authentication
  type of the SQL login connected to the database user. This will return either 'Windows',
  'Instance' or 'None'. The value 'Windows' means the SQL login is using
  Windows Authentication, 'Instance' means that the SQL login
  is using SQL authentication, and 'None' means that the database user have
  no SQL login connected to it.
* **`[String]` LoginType** _(Read)_: Returns the login type of the SQL
  login connected to the database user. If no SQL login is connected to
  the database user this returns `$null`.

#### Examples

* [Add a database user to a database, with a SQL login](/Examples/Resources/SqlDatabaseUser/1-AddDatabaseUserWithLogin.ps1)
* [Add a database user to a database, without a SQL login](/Examples/Resources/SqlDatabaseUser/2-AddDatabaseUserWithoutLogin.ps1)
* [Add a database user to a database, mapped to an asymmetric key](/Examples/Resources/SqlDatabaseUser/3-AddDatabaseUserMappedToAsymmetricKey.ps1)
* [Add a database user to a database, mapped to a certificate](/Examples/Resources/SqlDatabaseUser/4-AddDatabaseUserMappedToCertificate.ps1)
* [Remove database user from a database](/Examples/Resources/SqlDatabaseUser/5-RemoveDatabaseUser.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabaseUser).

### SqlRS

Initializes and configures SQL Reporting Services server.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Reporting Services 2008 or later.
* To use parameter `UseSSL` target machine must be running SQL Server Reporting
  Services 2008 R2 or later.
* If `PsDscRunAsCredential` common parameter is used to run the resource, the
  specified credential must have permissions to connect to the SQL Server instance
  specified in `DatabaseServerName` and `DatabaseInstanceName`, and have permission
  to create the Reporting Services databases.

#### Parameters

* **`[String]` InstanceName** _(Key)_: Name of the SQL Server Reporting Services
  instance to be configured.
* **`[String]` DatabaseServerName** _(Required)_: Name of the SQL Server to host
  the Reporting Service database.
* **`[String]` DatabaseInstanceName** _(Required)_: Name of the SQL Server instance
  to host the Reporting Service database.
* **`[String]` ReportServerVirtualDir** _(Write)_: Report Server Web Service virtual
  directory. Optional.
* **`[String]` ReportsVirtualDir** _(Write)_: Report Manager/Report Web App virtual
  directory name. Optional.
* **`[String[]]` ReportServerReservedUrl** _(Write)_: Report Server URL reservations.
  Optional. If not specified, 'http://+:80' URL reservation will be used.
* **`[String[]]` ReportsReservedUrl** _(Write)_: Report Manager/Report Web App URL
  reservations. Optional. If not specified, 'http://+:80' URL reservation will be
  used.
* **`[Boolean]` UseSsl** _(Write)_: If connections to the Reporting Services must
  use SSL. If this parameter is not assigned a value, the default is that Reporting
  Services does not use SSL.
* **`[Boolean]` SuppressRestart** _(Write)_: Reporting Services need to be restarted
  after initialization or settings change. If this parameter is set to $true,
  Reporting Services will not be restarted, even after initialisation.

#### Read-Only Properties from Get-TargetResource

* **`[Boolean]` IsInitialized** _(Read)_: Output is the Reporting Services instance
  initialized.

#### Examples

* [Default configuration](Examples/Resources/SqlRS/1-DefaultConfiguration.ps1)
* [Custom virtual directories and reserved URLs](Examples/Resources/SqlRS/2-CustomConfiguration.ps1)
* [Custom virtual directory and using SSL](Examples/Resources/SqlRS/3-CustomConfigurationUsingSsl.ps1)
* [Complete example with two instances in default configuration](/Examples/Resources/SqlRS/4-CompleteWithTwoInstances.ps1)

#### Known issues

* This resource does not currently have full SSL support, please see
  [issue #587](https://github.com/PowerShell/SqlServerDsc/issues/587) for more
  information.

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlRS).

#### Error messages

##### Error: The parameter is incorrect (HRESULT:-2147024809)

This is for example caused by trying to add an URL with the wrong format
i.e. 'htp://+:80'.

##### Error: The Url has already been reserved (HRESULT:-2147220932)

This is caused when the URL is already reserved. For example when 'http://+:80'
already exist.

##### Error: Cannot create a file when that file already exists (HRESULT:-2147024713)

This is caused when trying to add another URL using the same protocol. For example
when trying to add 'http://+:443' when 'http://+:80' already exist.

### SqlRSSetup

Installs the standalone [Microsoft SQL Server Reporting Services](https://docs.microsoft.com/en-us/sql/reporting-services/create-deploy-and-manage-mobile-and-paginated-reports).

If both `SourceCredential` and `PsDscRunAsCredential` is used then the
credentials in `SourceCredential` will only be used to copy the
installation media locally, and then the credentials in `PsDscRunAsCredential`
will be used during installation. If `PsDscRunAsCredential` is not
used, then the installation will run as SYSTEM.

>To install Microsoft SQL Server Reporting Services 2016 (or older),
>please use the resource SqlSetup.

#### Requirements

* Target machine must be running Windows Server 2012 or later.
* If `PsDscRunAsCredential` common parameter is used to run the resource,
  the specified credential must have permissions to connect to the location
  where the Microsoft SQL Server Reporting Services media is placed.
* The parameter IAcceptLicenseTerms must be set to 'Yes'.
* The parameter InstanceName can only be set to 'SSRS' since there is
  no way to change the instance name.
* When using action 'Uninstall', the same version of the executable as the version
  of the installed product must be used. If not, sometimes the uninstall
  is successful (because the executable returns exit code 0) but the
  Microsoft SQL Server Reporting Services instance was not actually removed.

>NOTE: When using the action 'Uninstall' and the target node to begin with
>requires a restart, on the first run the Microsoft SQL Server Reporting
>Services instance will not be uninstalled, but instead exit with code
>3010 and the node will be, by default, restarted. On the second run after
>restart, the Microsoft SQL Server Reporting Services instance will be
>uninstalled. If the parameter SuppressRestart is used, then the node must
>be restarted manually before the Microsoft SQL Server Reporting Services
>instance will be successfully uninstalled.
>
>The Microsoft SQL Server Reporting Services log will indicate that a
>restart is required by outputting; "*No action was taken as a system
>reboot is required (0x8007015E)*". The log is default located in the
>SSRS folder in `%TEMP%`, e.g. `C:\Users\<user>\AppData\Local\Temp\SSRS`.

#### Parameters

* **`[String]` InstanceName** _(Key)_: Name of the Microsoft SQL Server
  Reporting Service instance to installed. This can only be set to 'SSRS'.
  { 'SSRS' }
* **`[String]` IAcceptLicenseTerms** _(Required)_: Accept licens terms.
  This must be set to 'Yes'. { 'Yes' }
* **`[String]` SourcePath** _(Required)_: The path to the installation media
  file to be used for installation, e.g an UNC path to a shared resource.
  Environment variables can be used in the path.
* **`[String]` Action** _(Write)_: The action to be performed. Default
  value is 'Install' which performs either install or upgrade.
  { *Install* | Uninstall }
* **`[PSCredential]` SourceCredential** _(Write)_: Credentials used to
  access the path set in the parameter 'SourcePath'.
* **`[Boolean]` SuppressRestart** _(Write)_: Suppresses any attempts to
  restart.
* **`[String]` ProductKey** _(Write)_: Sets the custom license key, e.g.
  '12345-12345-12345-12345-12345'.
* **`[Boolean]` ForceRestart** _(Write)_: Forces a restart after installation
  is finished.
* **`[Boolean]` EditionUpgrade** _(Write)_: Upgrades the edition of the
  installed product. Requires that either the ProductKey or the Edition
  parameter is also assigned. By default no edition upgrade is performed.
* **`[Boolean]` VersionUpgrade** _(Write)_: Upgrades installed product
  version, if the major product version of the source executable is higher
  than the major current version. Requires that either the ProductKey or
  the Edition parameter is also assigned. Default is $false.
* **`[String]` Edition** _(Write)_: Sets the custom free edition.
  { 'Development' | 'Evaluation' | 'ExpressAdvanced' }
* **`[String]` LogPath** _(Write)_: Specifies the setup log file location,
  e.g. 'log.txt'. By default, log files are created under `%TEMP%`.
* **`[String]` InstallFolder** _(Write)_: Sets the install folder, e.g.
  'C:\Program Files\SSRS'. Default value is 'C:\Program Files\Microsoft
  SQL Server Reporting Services'.
* **`[UInt32]` SetupProcessTimeout** _(Write)_: The timeout, in seconds, to wait
  for the setup process to finish. Default value is 7200 seconds (2 hours). If
  the setup process does not finish before this time, and error will be thrown.

#### Read-Only Properties from Get-TargetResource

* **`[String]` ErrorDumpDirectory** _(Read)_: Returns the path to error
  dump log files.
* **`[String]` CurrentVersion** _(Read)_: Returns the current version
  of the installed Microsoft SQL Server Reporting Service instance.
* **`[String]` ServiceName** _(Read)_: Returns the current name
  of the Microsoft SQL Server Reporting Service instance Windows service.

#### Examples

* [Install Reporting Services](Examples/Resources/SqlRSSetup/1-InstallReportingServices.ps1)
* [Uninstall Reporting Services](Examples/Resources/SqlRSSetup/2-UninstallReportingServices.ps1)

#### Known issues

* [SqlRSSetup: Will always make an edition upgrade](https://github.com/PowerShell/SqlServerDsc/issues/1311)

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlRSSetup).

### SqlScript

Provides the means to run a user generated T-SQL script on the SQL Server instance.
Three scripts are required; Get T-SQL script, Set T-SQL script and the Test T-SQL
script.

#### Scripts

##### Get T-SQL Script (GetFilePath)

The Get T-SQL script is used to query the status when running the cmdlet
Get-DscConfiguration, and the result can be found in the property `GetResult`.

##### Test T-SQL Script (TestFilePath)

The Test T-SQL script is used to test if the desired state is met. If Test
T-SQL raises an error or returns any value other than 'null' the test fails, thus
the Set T-SQL script is run.

##### Set T-SQL Script (SetFilePath)

The Set T-SQL script performs the actual change when Test T-SQL script fails.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server 2008 or later.
* Target machine must have access to the SQLPS PowerShell module or the SqlServer
  PowerShell module.

_Note: There is a known problem running this resource using PowerShell 4.0.
See [issue #273](https://github.com/PowerShell/SqlServerDsc/issues/273)
for more information._

#### Parameters

* **`[String]` ServerInstance** _(Key)_: The name of an instance of the Database
  Engine. For a default instance, only specify the computer name. For a named
  instances, use the format ComputerName\\InstanceName.
* **`[String]` SetFilePath** _(Key)_: Path to the T-SQL file that will perform Set
  action.
* **`[String]` GetFilePath** _(Key)_: Path to the T-SQL file that will perform Get
  action. Any values returned by the T-SQL queries will also be returned by the
  cmdlet Get-DscConfiguration through the `GetResult` property.
* **`[String]` TestFilePath** _(Key)_: Path to the T-SQL file that will perform Test
  action. Any script that does not throw an error or returns null is evaluated to
  true. The cmdlet Invoke-Sqlcmd treats T-SQL Print statements as verbose text,
  and will not cause the test to return false.
* **`[PSCredential]` Credential** _(Write)_: The credentials to authenticate with,
  using SQL Authentication. To authenticate using Windows Authentication, assign
  the credentials to the built-in parameter `PsDscRunAsCredential`. If both parameters
  `Credential` and `PsDscRunAsCredential` are not assigned, then SYSTEM account will
  be used to authenticate using Windows Authentication.
* **`[UInt32]` QueryTimeout** _(Write)_: Specifies, as an integer, the number of
  seconds after which the T-SQL script execution will time out.  In some SQL Server
  versions there is a bug in Invoke-Sqlcmd where the normal default value 0 (no
  timeout) is not respected and the default value is incorrectly set to 30 seconds.
* **`[String[]]` Variable** _(Write)_: Specifies, as a string array, a scripting
  variable for use in the sql script, and sets a value for the variable. Use a
  Windows PowerShell array to specify multiple variables and their values. For more
  information how to use this, please go to the help documentation for [Invoke-Sqlcmd](https://technet.microsoft.com/en-us/library/mt683370.aspx).

#### Read-Only Properties from Get-TargetResource

* **`[String]` GetResult** _(Read)_: Contains the values returned from the T-SQL
  script provided in the parameter `GetFilePath` when cmdlet Get-DscConfiguration
  is run.

#### Examples

* [Run a script using SQL Authentication](/Examples/Resources/SqlScript/1-RunScriptUsingSQLAuthentication.ps1)
* [Run a script using Windows Authentication](/Examples/Resources/SqlScript/2-RunScriptUsingWindowsAuthentication.ps1)
* [This example shows one way to create the SQL script files and how to run those files](/Examples/Resources/SqlScript/3-RunScriptCompleteExample.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlScript).

### SqlScriptQuery

Provides the means to run a user generated T-SQL script on the SQL Server instance.
Three scripts are required; Get T-SQL script, Set T-SQL script and the Test T-SQL
script.

#### Scripts

##### Get T-SQL Script (GetQuery)

The Get T-SQL script is used to query the status when running the cmdlet
Get-DscConfiguration, and the result can be found in the property `GetResult`.

##### Test T-SQL Script (TestQuery)

The Test T-SQL script is used to test if the desired state is met. If Test
T-SQL raises an error or returns any value other than 'null' the test fails, thus
the Set T-SQL script is run.

##### Set T-SQL Script (SetQuery)

The Set T-SQL script performs the actual change when Test T-SQL script fails.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server 2008 or later.
* Target machine must have access to the SQLPS PowerShell module or the SqlServer
  PowerShell module.

#### Parameters

* **`[String]` ServerInstance** _(Key)_: The name of an instance of the Database
  Engine. For a default instance, only specify the computer name. For a named
  instances, use the format ComputerName\\InstanceName.
* **`[String]` SetQuery** _(Key)_: Query that will perform Set
  action.
* **`[String]` GetQuery** _(Key)_: Query that will perform Get
  action. Any values returned by the T-SQL queries will also be returned by the
  cmdlet Get-DscConfiguration through the `GetResult` property.
* **`[String]` TestQuery** _(Key)_: Query that will perform Test
  action. Any script that does not throw an error or returns null is evaluated to
  true. The cmdlet Invoke-Sqlcmd treats T-SQL Print statements as verbose text,
  and will not cause the test to return false.
* **`[PSCredential]` Credential** _(Write)_: The credentials to authenticate with,
  using SQL Authentication. To authenticate using Windows Authentication, assign
  the credentials to the built-in parameter `PsDscRunAsCredential`. If both parameters
  `Credential` and `PsDscRunAsCredential` are not assigned, then SYSTEM account will
  be used to authenticate using Windows Authentication.
* **`[UInt32]` QueryTimeout** _(Write)_: Specifies, as an integer, the number of
  seconds after which the T-SQL script execution will time out.  In some SQL Server
  versions there is a bug in Invoke-Sqlcmd where the normal default value 0 (no
  timeout) is not respected and the default value is incorrectly set to 30 seconds.
* **`[String[]]` Variable** _(Write)_: Specifies, as a string array, a scripting
  variable for use in the sql script, and sets a value for the variable. Use a
  Windows PowerShell array to specify multiple variables and their values. For more
  information how to use this, please go to the help documentation for [Invoke-Sqlcmd](https://technet.microsoft.com/en-us/library/mt683370.aspx).

#### Read-Only Properties from Get-TargetResource

* **`[String]` GetResult** _(Read)_: Contains the values returned from the T-SQL
  script provided in the parameter `GetQuery` when cmdlet Get-DscConfiguration
  is run.

#### Examples

* [Run a script using SQL Authentication](/Examples/Resources/SqlScriptQuery/1-RunScriptUsingSQLAuthentication.ps1)
* [Run a script using Windows Authentication](/Examples/Resources/SqlScriptQuery/2-RunScriptUsingWindowsAuthentication.ps1)
* [This example shows one way to create the SQL script files and how to run those files](/Examples/Resources/SqlScriptQuery/3-RunScriptCompleteExample.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlScript).

### SqlServerConfiguration

This resource manage the [SQL Server Configuration Options](https://msdn.microsoft.com/en-us/library/ms189631.aspx)
on a SQL Server instance.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` ServerName** _(Key)_: The hostname of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: Name of the SQL instance to be configured.
* **`[String]` OptionName** _(Key)_: The name of the SQL configuration option to
  be checked. For all possible values reference [MSDN](https://msdn.microsoft.com/en-us/library/ms189631.aspx)
  or run sp_configure.
* **`[SInt32]` OptionValue** _(Required)_: The desired value of the SQL configuration
  option.
* **`[Boolean]` RestartService** _(Write)_: Determines whether the instance should
  be restarted after updating the configuration option.
* **`[UInt32]` RestartTimeout** _(Write)_: The length of time, in seconds, to wait
  for the service to restart. Default is 120 seconds.

#### Examples

* [Configure two instances on the same server to have CLR enabled](/Examples/Resources/SqlServerConfiguration/1-ConfigureTwoInstancesOnTheSameServerToEnableClr.ps1)
* [Configure a instance to have 'Priority Boost' enabled](/Examples/Resources/SqlServerConfiguration/2-ConfigureInstanceToEnablePriorityBoost.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerConfiguration).

### SqlServerDatabaseMail

Resource to manage SQL Server Database Mail.

>**Note:** Database Mail XPs can be enabled using the resource SqlServerConfiguration.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.
* Target machine must be running SQL Server Agent.
* Target machine must have enabled Database Mail XPs.

#### Parameters

* **`[String]` AccountName** _(Key)_: The name of the Database Mail account.
* **`[String]` ServerName** _(Write)_: The hostname of the SQL Server to be configured.
  Defaults to $env:COMPUTERNAME.
* **`[String]` InstanceName** _(Key)_: Name of the SQL instance to be configured.
* **`[String]` Ensure** _(Write)_: Specifies the desired state of the Database Mail.
  When set to 'Present', the Database Mail will be created. When set to 'Absent',
  the Database Mail will be removed. Default value is 'Present'.
  { *Present* | Absent }.
* **`[String]` ProfileName** _(Required)_: The name of the Database Mail profile.
* **`[String]` Description** _(Write)_: The description for the Database Mail
  profile and account.
* **`[String]` EmailAddress** _(Required)_: The e-mail address from which mail
  will originate.
* **`[String]` DisplayName** _(Write)_: The display name of the originating e-mail
  address. Default value is the same value assigned to the EmailAddress parameter.
* **`[String]` ReplyToAddress** _(Write)_: The e-mail address to which the receiver
  of e-mails will reply to. Default value is the same e-mail address assigned to
  parameter EmailAddress.
* **`[String]` MailServerName** _(Required)_: The fully qualified domain name of
  the mail server name to which e-mail are sent.
* **`[UInt16]` TcpPort** _(Write)_: The TCP port used for communication. Default
  value is port 25.
* **`[String]` LoggingLevel** _(Write)_: The logging level that the Database Mail
  will use. If not specified the default logging level is 'Extended'.
  { Normal | *Extended* | Verbose }.

#### Examples

* [Enable Database Mail](/Examples/Resources/SqlServerDatabaseMail/1-EnableDatabaseMail.ps1)
* [Disable Database Mail](/Examples/Resources/SqlServerDatabaseMail/2-DisableDatabaseMail.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerDatabaseMail).

### SqlServerEndpoint

This resource is used to create an endpoint. Currently it only supports creating
a database mirror endpoint which can be used by, for example, AlwaysOn.

>Note: The endpoint will be started after creation, but will not be enforced. Please
use [**SqlServerEndpointState**](#sqlserverendpointstate) to make sure the endpoint
remains in started state. To set connect permission to the endpoint, please use
the resource [**SqlServerEndpointPermission**](#sqlserverendpointpermission).

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Security Requirements

* The built-in parameter PsDscRunAsCredential must be set to the credentials of
  an account with the permission to create and alter endpoints.

#### Parameters

* **`[String]` EndpointName** _(Key)_: The name of the endpoint.
* **`[String]` Ensure** _(Write)_: If the endpoint should be present or absent.
  Default values is 'Present'. { *Present* | Absent }.
* **`[Uint16]` Port** _(Write)_: The network port the endpoint is listening on.
  Default value is 5022.
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be configured.
  Default value is $env:COMPUTERNAME.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` IpAddress** _(Write)_: The network IP address the endpoint is listening
  on. Defaults to '0.0.0.0' which means listen on any valid IP address.
* **`[String]` Owner** _(Write)_: The owner of the endpoint. Default is the
  login used for the creation.

#### Examples

* [Create an endpoint with default values](/Examples/Resources/SqlServerEndpoint/1-CreateEndpointWithDefaultValues.ps1)
* [Create an endpoint with specific port and IP address](/Examples/Resources/SqlServerEndpoint/2-CreateEndpointWithSpecificPortIPAddressOwner.ps1)
* [Remove an endpoint](/Examples/Resources/SqlServerEndpoint/3-RemoveEndpoint.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerEndpoint).

### SqlServerEndpointPermission

This resource is used to give connect permission to an endpoint for a user (login).

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` ServerName** _(Required)_: The host name of the SQL Server to be configured.
* **`[String]` Ensure** _(Write)_: If the permission should be present or absent.
  Default value is 'Present'. { *Present* | Absent }.
* **`[String]` Name** _(Required)_: The name of the endpoint.
* **`[String]` Principal** _(Key)_: The login to which permission will be set.
* **`[String]` Permission** _(Write)_: The permission to set for the login. Valid
  value for permission are only CONNECT. { Connect }.

#### Examples

* [Add connect permission to an Endpoint](/Examples/Resources/SqlServerEndpointPermission/1-AddConnectPermission.ps1)
* [Remove the connect permission for an Endpoint](/Examples/Resources/SqlServerEndpointPermission/2-RemoveConnectPermission.ps1)
* [Add connect permission to both an Always On primary replica and an Always On secondary replica, and where each replica has a different SQL service account](/Examples/Resources/SqlServerEndpointPermission/3-AddConnectPermissionToTwoReplicasEachWithDifferentServiceAccount.ps1)
* [Remove connect permission to both an Always On primary replica and an Always On secondary replica, and where each replica has a different SQL service account](/Examples/Resources/SqlServerEndpointPermission/4-RemoveConnectPermissionForTwoReplicasEachWithDifferentServiceAccount.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerEndpointPermission).

### SqlServerEndpointState

This resource is used to set the state of an endpoint.

>Note: Currently this resource can only be used with Database Mirror endpoints.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.
* Target machine must have access to the SQLPS PowerShell module or the SqlServer
  PowerShell module.

#### Parameters

* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be configured.
  Default value is $env:COMPUTERNAME.
* **`[String]` Name** _(Key)_: The name of the endpoint.
* **`[String]` State** _(Write)_: The state of the endpoint. Valid states are Started,
  Stopped or Disabled. Default value is 'Started'.
  { *Started* | Stopped | Disabled }.

#### Examples

* [Make sure that an endpoint is started](/Examples/Resources/SqlServerEndpointState/1-MakeSureEndpointIsStarted.ps1)
* [Make sure that an endpoint is stopped](/Examples/Resources/SqlServerEndpointState/2-MakeSureEndpointIsStopped.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerEndpointState).

### SqlServerLogin

No description.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.
* When the `LoginType` `'SqlLogin'` is used, then the login authentication
  mode must have been set to `Mixed` or `Normal`. If set to `Integrated`
  and error will be thrown.

#### Parameters

* **`[String]` ServerName** _(Key)_:The hostname of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: Name of the SQL instance to be configured.
* **`[String]` Name** _(Key)_: The name of the login.
* **`[String]` Ensure** _(Write)_: The specified login is Present or Absent.
  { *Present* | Absent }.
* **`[PSCredential]` LoginCredential** _(Write)_: If LoginType is 'SqlLogin' then
  a PSCredential is needed for the password to the login.
* **`[String]` LoginType** _(Write)_: The type of login to be created. If LoginType
  is 'WindowsUser' or 'WindowsGroup' then provide the name in the format DOMAIN\name.
  Default is WindowsUser. Unsupported login types are Certificate, AsymmetricKey,
  ExternalUser, and ExternalGroup. {SqlLogin | WindowsUser | WindowsGroup }
* **`[Boolean]` LoginMustChangePassword** _(Write)_: Specifies if the login is required
  to have its password change on the next login. Only applies to SQL Logins.
  Default is $true.
* **`[Boolean]` LoginPasswordExpirationEnabled** _(Write)_: Specifies if the login
  password is required to expire in accordance to the operating system security
  policy. Only applies to SQL Logins. Default is $true.
* **`[Boolean]` LoginPasswordPolicyEnforced** _(Write)_: Specifies if the login password
  is required to conform to the password policy specified in the system security
  policy. Only applies to SQL Logins. Default is $true.
* **`[Boolean]` Disabled** _(Write)_: Specifies if the login is disabled. Default
  is $false.

#### Examples

* [Add a login](/Examples/Resources/SqlServerLogin/1-AddLogin.ps1)
* [Remove a login](/Examples/Resources/SqlServerLogin/2-RemoveLogin.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerLogin).

### SqlServerMaxDop

This resource set the max degree of parallelism server configuration option.
The max degree of parallelism option is used to limit the number of processors to
use in parallel plan execution.
Read more about max degree of parallelism in this article
[Configure the max degree of parallelism Server Configuration Option](https://msdn.microsoft.com/en-us/library/ms189094.aspx)

#### Formula for dynamically allocating max degree of parallelism

* If the number of configured NUMA nodes configured in SQL Server equals 1, then
  max degree of parallelism is calculated using number of cores divided in 2
  (numberOfCores / 2), then rounded up to the next integer (3.5 > 4).
* If the number of cores configured in SQL Server are greater than or equal to
  8 cores then max degree of parallelism will be set to 8.
* If the number of configured NUMA nodes configured in SQL Server is greater than
  2 and the number of cores are less than 8 then max degree of parallelism will
  be set to the number of cores.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` InstanceName** (Key): The name of the SQL instance to be configured.
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be configured.
  Default value is $env:COMPUTERNAME.
* **`[String]` Ensure** _(Write)_: When set to 'Present' then max degree of parallelism
  will be set to either the value in parameter MaxDop or dynamically configured
  when parameter DynamicAlloc is set to $true. When set to 'Absent' max degree of
  parallelism will be set to 0 which means no limit in number of processors used
  in parallel plan execution. { *Present* | Absent }.
* **`[Boolean]` DynamicAlloc** _(Write)_: If set to $true then max degree of parallelism
  will be dynamically configured. When this is set parameter is set to $true, the
  parameter MaxDop must be set to $null or not be configured.
* **`[SInt32]` MaxDop** _(Write)_: A numeric value to limit the number of processors
  used in parallel plan execution.
* **`[Boolean]` ProcessOnlyOnActiveNode** _(Write)_: Specifies that the resource
  will only determine if a change is needed if the target node is the active
  host of the SQL Server instance.

#### Read-Only Property from Get-TargetResource

* **`[Boolean]` IsActiveNode** _(Read)_: Determines if the current node is
  actively hosting the SQL Server instance.

#### Examples

* [Set SQLServerMaxDop to 1](/Examples/Resources/SqlServerMaxDop/1-SetMaxDopToOne.ps1)
* [Set SQLServerMaxDop to Auto](/Examples/Resources/SqlServerMaxDop/2-SetMaxDopToAuto.ps1)
* [Set SQLServerMaxDop to Default](/Examples/Resources/SqlServerMaxDop/3-SetMaxDopToDefault.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerMaxDop).

### SqlServerMemory

This resource sets the minimum server memory and maximum server memory configuration
option.
That means it sets the minimum and the maximum amount of memory, in MB, in the buffer
pool used by the instance of SQL Server
The default setting for minimum server memory is 0, and the default setting for
maximum server memory is 2147483647 MB.
Read more about minimum server memory and maximum server memory in this article
[Server Memory Server Configuration Options](https://msdn.microsoft.com/en-us/library/ms178067.aspx).

#### Formula for dynamically allocating maximum memory

The formula is based on the [SQL Max Memory Calculator](http://sqlmax.chuvash.eu/)
website. The website code is in the sql-max GitHub repository maintained by [@mirontoli](https://github.com/mirontoli).
The dynamic maximum memory (in MB) is calculate with this formula:
SQL Max Memory = TotalPhysicalMemory - (NumOfSQLThreads\*ThreadStackSize) -
(1024\*CEILING(NumOfCores/4)) - OSReservedMemory.

##### NumOfSQLThreads

* If the number of cores is less than or equal to 4, the number of SQL threads
  is set to: 256 + (NumberOfCores - 4) \* 8.
* If the number of cores is greater than 4, the number of SQL threads is set
  to: 0 (zero).

##### ThreadStackSize

* If the architecture of windows server is x86, the size of thread stack is 1MB.
* If the architecture of windows server is x64, the size of thread stack is 2MB.
* If the architecture of windows server is IA64, the size of thread stack is 4MB.

##### OSReservedMemory

* If the total physical memory is less than or equal to 20GB, the percentage of
  reserved memory for OS is 20% of total physical memory.
* If the total physical memory is greater than 20GB, the percentage of reserved
  memory for OS is 12.5% of total physical memory.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be configured.
  Default value is $env:COMPUTERNAME.
* **`[Boolean]` DynamicAlloc** _(Write)_: If set to $true then max memory will be
  dynamically configured. When this is set parameter is set to $true, the parameter
  MaxMemory must be set to $null or not be configured. Default value is $false.
* **`[String]` Ensure** _(Write)_: When set to 'Present' then min and max memory
  will be set to either the value in parameter MinMemory and MaxMemory or dynamically
  configured when parameter DynamicAlloc is set to $true. When set to 'Absent' min
  and max memory will be set to default values. { *Present* | Absent }.
* **`[SInt32]` MinMemory** _(Write)_: Minimum amount of memory, in MB, in the buffer
  pool used by the instance of SQL Server.
* **`[SInt32]` MaxMemory** _(Write)_: Maximum amount of memory, in MB, in the buffer
  pool used by the instance of SQL Server.
* **`[Boolean]` ProcessOnlyOnActiveNode** _(Write)_: Specifies that the resource
  will only determine if a change is needed if the target node is the active
  host of the SQL Server instance.

#### Read-Only Properties from Get-TargetResource

* **`[Boolean]` IsActiveNode** _(Read)_: Determines if the current node is
  actively hosting the SQL Server instance.

#### Examples

* [Set SQLServerMaxMemory to 12GB](/Examples/Resources/SqlServerMemory/1-SetMaxMemoryTo12GB.ps1)
* [Set SQLServerMaxMemory to Auto](/Examples/Resources/SqlServerMemory/2-SetMaxMemoryToAuto.ps1)
* [Set SQLServerMinMemory to 2GB and SQLServerMaxMemory to Auto](/Examples/Resources/SqlServerMemory/3-SetMinMemoryToFixedValueAndMaxMemoryToAuto.ps1)
* [Set SQLServerMaxMemory to Default](/Examples/Resources/SqlServerMemory/4-SetMaxMemoryToDefault.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerMemory).

### SqlServerNetwork

This resource is used to change the network settings for the instance.

Read more about the network settings in the article
[TCP/IP Properties (IP Addresses Tab)](https://docs.microsoft.com/en-us/sql/tools/configuration-manager/tcp-ip-properties-ip-addresses-tab).

>Note: Currently only TCP is supported.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` ProtocolName** _(Required)_: The name of network protocol to be configured.
  Only tcp is currently supported. { tcp }.
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be configured.
  Default value is $env:COMPUTERNAME.
* **`[Boolean]` IsEnabled** _(Write)_: Enables or disables the network protocol.
* **`[Boolean]` TcpDynamicPort** _(Write)_: Specifies whether the SQL Server
  instance should use a dynamic port. Value cannot be set to $true if TcpPort
  is set to a non-empty string.
* **`[String]` TcpPort** _(Write)_: The TCP port(s) that SQL Server should be listening
  on. If the IP address should listen on more than one port, list all ports separated
  with a comma ('1433,1500,1501'). To use this parameter set TcpDynamicPort to
  $false.
* **`[Boolean]` RestartService** _(Write)_: If set to $true then SQL Server and
  dependent services will be restarted if a change to the configuration is made.
  The default value is $false.
* **`[Uint16]` RestartTimeout** _(Write)_: Timeout value for restarting the SQL Server
  services. The default value is 120 seconds.

#### Examples

* [Enable TCP/IP with static port and restart SQL Server](/Examples/Resources/SqlServerNetwork/1-EnableTcpIpWithStaticPort.ps1)
* [Enable TCP/IP with dynamic port](/Examples/Resources/SqlServerNetwork/2-EnableTcpIpWithDynamicPort.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerNetwork).

### SqlServerPermission

This resource sets server permissions to a user (login).

>Note: Currently the resource only supports ConnectSql, AlterAnyAvailabilityGroup,
AlterAnyEndPoint and ViewServerState.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.
* Target machine must have access to the SQLPS PowerShell module or the SqlServer
  PowerShell module.

#### Parameters

* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` Principal** _(Key)_: The login to which permission will be set.
* **`[String]` Ensure** _(Write)_: If the permission should be present or absent.
  Default value is 'Present'. { Present | Absent }.
* **`[String]` ServerName** _(Write)_: The host name of the SQL Server to be configured.
  Default value is $env:COMPUTERNAME.
* **`[String[]]` Permission** _(Write)_: The permission to set for the login. Valid
  values are ConnectSql, AlterAnyAvailabilityGroup, ViewServerState or AlterAnyEndPoint.
  { ConnectSql, AlterAnyAvailabilityGroup | AlterAnyEndPoint | ViewServerState }.

#### Examples

* [Add server permission for a login](/Examples/Resources/SqlServerPermission/1-AddServerPermissionForLogin.ps1)
* [Remove server permission for a login](/Examples/Resources/SqlServerPermission/2-RemoveServerPermissionForLogin.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerPermission).

### SqlServerReplication

This resource manage SQL Replication distribution and publishing.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server 2008 or later.

#### Parameters

* **`[String]` InstanceName** _(Key)_: SQL Server instance name where replication
  distribution will be configured.
* **`[String]` Ensure** _(Write)_: (Default = 'Present') 'Present' will configure
  replication, 'Absent' will disable replication.
* **`[String]` DistributorMode** _(Required)_: 'Local' - Instance will be configured
  as it's own distributor, 'Remote' - Instance will be configure with remote distributor
  (remote distributor needs to be already configured for distribution).
* **`[PSCredential]` AdminLinkCredentials** _(Required)_: - AdminLink password to
  be used when setting up publisher distributor relationship.
* **`[String]` DistributionDBName** _(Write)_: (Default = 'distribution') distribution
  database name. If DistributionMode='Local' this will be created, if 'Remote' needs
  to match distribution database on remote distributor.
* **`[String]` RemoteDistributor** _(Write)_: (Required if DistributionMode='Remote')
  SQL Server network name that will be used as distributor for local instance.
* **`[String]` WorkingDirectory** _(Required)_: Publisher working directory.
* **`[Boolean]` UseTrustedConnection** _(Write)_: (Default = $true) Publisher security
  mode.
* **`[Boolean]` UninstallWithForce** _(Write)_: (Default = $true) Force flag for
  uninstall procedure

#### Examples

* [Configure a instance as the distributor](/Examples/Resources/SqlServerReplication/1-ConfigureInstanceAsDistributor.ps1)
* [Configure a instance as the publisher](/Examples/Resources/SqlServerReplication/2-ConfigureInstanceAsPublisher.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerReplication).

### SqlServerRole

This resource is used to create a server role, when Ensure is set to 'Present'.
Or remove a server role, when Ensure is set to 'Absent'. The resource also manages
members in both built-in and user created server roles. For more information about
server roles, please read the below articles.

* [Create a Server Role](https://msdn.microsoft.com/en-us/library/ee677627.aspx)
* [Server-Level Roles](https://msdn.microsoft.com/en-us/library/ms188659.aspx)

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2008 or later.

#### Parameters

* **`[String]` ServerRoleName** _(Key)_: The name of of SQL role to add or remove.
* **`[String]` ServerName** _(Key)_: The host name of the SQL Server to be configured.
* **`[String]` InstanceName** _(Key)_: The name of the SQL instance to be configured.
* **`[String]` Ensure** _(Write)_: An enumerated value that describes if the server
  role is added (Present) or dropped (Absent). Default value is 'Present'.
  { *Present* | Absent }.
* **`[String[]]` Members** _(Write)_: The members the server role should have. This
  parameter will replace all the current server role members with the specified
  members.
* **`[String[]]` MembersToInclude** _(Write)_: The members the server role should
  include. This parameter will only add members to a server role. Can not be used
  at the same time as parameter Members.
* **`[String[]]` MembersToExclude** _(Write)_: The members the server role should
  exclude. This parameter will only remove members from a server role. Can only
  be used when parameter Ensure is set to 'Present'. Can not be used at the same
  time as parameter Members.

#### Examples

* [Add server role](/Examples/Resources/SqlServerRole/1-AddServerRole.ps1)
* [Remove server role](/Examples/Resources/SqlServerRole/2-RemoveServerRole.ps1)
* [Add members to server role](/Examples/Resources/SqlServerRole/3-AddMembersToServerRole.ps1)
* [Members to include in server role](/Examples/Resources/SqlServerRole/4-MembersToIncludeInServerRole.ps1)
* [Members to exclude from server role](/Examples/Resources/SqlServerRole/5-MembersToExcludeInServerRole.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerRole).

### SqlServerSecureConnection

Configures SQL connections to be encrypted.
Read more about encrypted connections in this article [Enable Encrypted Connections](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/enable-encrypted-connections-to-the-database-engine).

>Note: that the 'LocalSystem' service account will return a connection
error, even though the connection has been successful.
In that case, the 'SYSTEM' service account can be used.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* You must have a Certificate that is trusted and issued for
   `ServerAuthentication`.
* The name of the Certificate must be the fully qualified domain name (FQDN)
   of the computer.
* The Certificate must be installed in the LocalMachine Personal store.
* If `PsDscRunAsCredential` common parameter is used to run the resource, the
  specified credential must have permissions to connect to the SQL Server instance
  specified in `InstanceName`.

#### Parameters

* **`[String]` InstanceName** _(Key)_: Name of the SQL Server instance to be
   configured.
* **`[String]` Thumbprint** _(Required)_: Thumbprint of the certificate being
   used for encryption. If parameter Ensure is set to 'Absent', then the
   parameter Certificate can be set to an empty string.
* **`[String]` ServiceAccount** _(Required)_: Name of the account running the
   SQL Server service. If parameter is set to "LocalSystem", then a
   connection error is displayed. Use the "SYSTEM" account instead, in that
   case.
* **`[String]` Ensure** _(Write)_: If Encryption should be Enabled (Present)
  or Disabled (Absent). { *Present* | Absent }. Defaults to Present.
* **`[Boolean]` ForceEncryption** _(Write)_: If all connections to the SQL
  instance should be encrypted. If this parameter is not assigned a value,
  the default is, set to *True*, that all connections must be encrypted.
* **`[Boolean]` SuppressRestart** _(Write)_: If set to $true then the required
  restart will be suppressed. You will need to restart the service before
  changes will take effect. The default value is $false.

#### Examples

* [Force Secure Connection](Examples/Resources/SqlServerSecureConnection/1-ForceSecureConnection.ps1).
* [Secure Connection but not required](Examples/Resources/SqlServerSecureConnection/2-SecureConnectionNotForced.ps1).
* [Secure Connection disabled](Examples/Resources/SqlServerSecureConnection/3-SecureConnectionAbsent.ps1).
* [Secure Connection Using "SYSTEM" Account](/Examples/Resources/SqlServerSecureConnection/4-SecureConnectionUsingSYSTEMAccount.ps1).

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServerSecureConnection).

### SqlServiceAccount

Manage the service account for SQL Server services.

#### Requirements

* Target machine must have access to the SQLPS PowerShell module or the SqlServer
  PowerShell module.

#### Parameters

* **`[String]` ServerName** (Key): The host name of the SQL Server to be configured.
* **`[String]` InstanceName** (Key): The name of the SQL instance to be configured.
* **`[String]` ServiceType** (Key): The service type for **InstanceName**.
  { DatabaseEngine | SQLServerAgent | Search | IntegrationServices
  | AnalysisServices | ReportingServices | SQLServerBrowser
  | NotificationServices }
* **`[PSCredential]` ServiceAccount** (Required): The service account that should
  be used when running the service.
* **`[Boolean]` RestartService** (Write): Determines whether the service is
  automatically restarted when a change to the configuration was needed.
* **`[Boolean]` Force** (Write): Forces the service account to be updated.
  Useful for password changes. This will cause `Set-TargetResource` to be run on
  each consecutive run.
* **`[String]` VersionNumber** (Write): The version number of the SQL Server,
  mandatory for when IntegrationServices is used as **ServiceType**.
  Eg. 130 for SQL 2016.

#### Read-Only Properties from Get-TargetResource

* **`[String]` ServiceAccountName** _(Read)_: Returns the service account username
  for the service.

#### Examples

* [Run service under a user account](/Examples/Resources/SqlServiceAccount/1-ConfigureServiceAccount-UserAccount.ps1)
* [Run service with a virtual account](/Examples/Resources/SqlServiceAccount/2-ConfigureServiceAccount-VirtualAccount.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlServiceAccount).

### SqlSetup

Installs SQL Server on the target node.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* For configurations that utilize the 'InstallFailoverCluster' action, the following
  parameters are required (beyond those required for the standalone installation).
  See the article [Install SQL Server from the Command Prompt](https://msdn.microsoft.com/en-us/library/ms144259.aspx)
  under the section [Failover Cluster Parameters](https://msdn.microsoft.com/en-us/library/ms144259.aspx#Anchor_8)
  for more information.
  * InstanceName (can be MSSQLSERVER if you want to install a default clustered
    instance).
  * FailoverClusterNetworkName
  * FailoverClusterIPAddress
  * Additional parameters need when installing Database Engine.
    * InstallSQLDataDir
    * AgtSvcAccount
    * SQLSvcAccount
    * SQLSysAdminAccounts
  * Additional parameters need when installing Analysis Services.
    * ASSysAdminAccounts
    * AsSvcAccount
* The parameters below can only be used when installing SQL Server 2016 or
  later:
  * SqlTempdbFileCount
  * SqlTempdbFileSize
  * SqlTempdbFileGrowth
  * SqlTempdbLogFileSize
  * SqlTempdbLogFileGrowth

> **Note:** It is not possible to add or remove features to a SQL Server failover
cluster. This is a limitation of SQL Server. See article
[You cannot add or remove features to a SQL Server 2008, SQL Server 2008 R2, or
SQL Server 2012 failover cluster](https://support.microsoft.com/en-us/help/2547273/you-cannot-add-or-remove-features-to-a-sql-server-2008,-sql-server-2008-r2,-or-sql-server-2012-failover-cluster).

#### Feature flags

Feature flags are used to toggle functionality on or off. One or more
feature flags can be added to the parameter `FeatureFlag`, i.e.
`FeatureFlag = @('DetectionSharedFeatures')`.

>**NOTE:** The functionality, exposed
with a feature flag, can be changed from one release to another, including
having breaking changes.

<!-- markdownlint-disable MD013 -->
Feature flag | Description
--- | ---
DetectionSharedFeatures | A new way of detecting if the shared features is installed or not. This was implemented because the previous implementation did not work fully with SQL Server 2017.
<!-- markdownlint-enable MD013 -->

#### Credentials for running the resource

##### PsDscRunAsCredential

If PsDscRunAsCredential is set, the installation will be performed with those
credentials, and the user name will be used as the first system administrator.

##### SYSTEM

If PsDscRunAsCredential is not assigned credentials then installation will be
performed by the SYSTEM account. When installing as the SYSTEM account, then
parameter SQLSysAdminAccounts and ASSysAdminAccounts must be specified when
installing feature Database Engine and Analysis Services respectively.

#### Credentials for service accounts

##### Service Accounts

Service account username containing dollar sign ('$') is allowed, but if the
dollar sign is at the end of the username it will be considered a Managed Service
Account.

##### Managed Service Accounts

If a service account username has a dollar sign at the end of the name it will
be considered a Managed Service Account. Any password passed in
the credential object will be ignored, meaning the account is not expected to
need a '*SVCPASSWORD' argument in the setup arguments.

#### Parameters

* **`[String]` Action** _(Write)_: The action to be performed. Defaults to 'Install'.
  *Note: AddNode is not currently functional.*
  { _Install_ | InstallFailoverCluster | AddNode | PrepareFailoverCluster |
   CompleteFailoverCluster }
* **`[String]` InstanceName** _(Key)_: SQL instance to be installed.
* **`[String]` SourcePath** _(Write)_: The path to the root of the source files for
  installation. I.e and UNC path to a shared resource. Environment variables can
  be used in the path.
* **`[PSCredential]` SourceCredential** _(Write)_: Credentials used to access the
  path set in the parameter `SourcePath`. Using this parameter will trigger a
  copy of the installation media to a temp folder on the target node. Setup will
  then be started from the temp folder on the target node. For any subsequent
  calls to the resource, the parameter `SourceCredential` is used to evaluate what
  major version the file 'setup.exe' has in the path set, again, by the parameter
  `SourcePath`. To know how the temp folder is evaluated please read the online
  documentation for [System.IO.Path.GetTempPath()](https://msdn.microsoft.com/en-us/library/system.io.path.gettemppath(v=vs.110).aspx).
  If the path, that is assigned to parameter `SourcePath`, contains a leaf folder,
  for example '\\server\share\folder', then that leaf folder will be used as the
  name of the temporary folder. If the path, that is assigned to parameter
  `SourcePath`, does not have a leaf folder, for example '\\server\share', then
  a unique GUID will be used as the name of the temporary folder.
* **`[Boolean]` SuppressReboot** _(Write)_: Suppresses reboot.
* **`[Boolean]` ForceReboot** _(Write)_: Forces reboot.
* **`[String]` Features** _(Write)_: SQL features to be installed.
* **`[String]` InstanceID** _(Write)_: SQL instance ID, if different from InstanceName.
* **`[String]` ProductKey** _(Write)_: Product key for licensed installations.
* **`[String]` UpdateEnabled** _(Write)_: Enabled updates during installation.
* **`[String]` UpdateSource** _(Write)_: Path to the source of updates to be applied
  during installation.
* **`[String]` SQMReporting** _(Write)_: Enable customer experience reporting.
* **`[String]` ErrorReporting** _(Write)_: Enable error reporting.
* **`[String]` InstallSharedDir** _(Write)_: Installation path for shared SQL files.
* **`[String]` InstallSharedWOWDir** _(Write)_: Installation path for x86 shared
  SQL files.
* **`[String]` InstanceDir** _(Write)_: Installation path for SQL instance files.
* **`[PSCredential]` SQLSvcAccount** _(Write)_: Service account for the SQL service.
* **`[PSCredential]` AgtSvcAccount** _(Write)_: Service account for the SQL Agent
  service.
* **`[String]` SQLCollation** _(Write)_: Collation for SQL.
* **`[String[]]` SQLSysAdminAccounts** _(Write)_: Array of accounts to be made SQL
  administrators.
* **`[String]` SecurityMode** _(Write)_: Security mode to apply to the
  SQL Server instance. 'SQL' indicates mixed-mode authentication while
  'Windows' indicates Windows authentication.
  Default is Windows. { *Windows* | SQL }
* **`[PSCredential]` SAPwd** _(Write)_: SA password, if SecurityMode is set to 'SQL'.
* **`[String]` InstallSQLDataDir** _(Write)_: Root path for SQL database files.
* **`[String]` SQLUserDBDir** _(Write)_: Path for SQL database files.
* **`[String]` SQLUserDBLogDir** _(Write)_: Path for SQL log files.
* **`[String]` SQLTempDBDir** _(Write)_: Path for SQL TempDB files.
* **`[String]` SQLTempDBLogDir** _(Write)_: Path for SQL TempDB log files.
* **`[String]` SQLBackupDir** _(Write)_: Path for SQL backup files.
* **`[PSCredential]` FTSvcAccount** _(Write)_: Service account for the Full Text
  service.
* **`[PSCredential]` RSSvcAccount** _(Write)_: Service account for Reporting Services
  service.
* **`[String]` RSInstallMode** _(Write)_: Reporting Services install mode.
  { SharePointFilesOnlyMode | DefaultNativeMode | FilesOnlyMode }
* **`[PSCredential]` ASSvcAccount** _(Write)_: Service account for Analysis Services
  service.
* **`[String]` ASCollation** _(Write)_: Collation for Analysis Services.
* **`[String[]]` ASSysAdminAccounts** _(Write)_: Array of accounts to be made Analysis
  Services admins.
* **`[String]` ASDataDir** _(Write)_: Path for Analysis Services data files.
* **`[String]` ASLogDir** _(Write)_: Path for Analysis Services log files.
* **`[String]` ASBackupDir** _(Write)_: Path for Analysis Services backup files.
* **`[String]` ASTempDir** _(Write)_: Path for Analysis Services temp files.
* **`[String]` ASConfigDir** _(Write)_: Path for Analysis Services config.
* **`[String]` ASServerMode** _(Write)_: The server mode for SQL Server Analysis
  Services instance. The default is to install in Multidimensional mode. Valid
  values in a cluster scenario are MULTIDIMENSIONAL or TABULAR. Parameter
  ASServerMode is case-sensitive. All values must be expressed in upper case.
  { MULTIDIMENSIONAL | TABULAR | POWERPIVOT }.
* **`[PSCredential]` ISSvcAccount** _(Write)_: Service account for Integration
  Services service.
* **`[String]` SqlSvcStartupType** _(Write)_: Specifies the startup mode for
  SQL Server Engine service. { Automatic | Disabled | Manual }
* **`[String]` AgtSvcStartupType** _(Write)_: Specifies the startup mode for
  SQL Server Agent service. { Automatic | Disabled | Manual }
* **`[String]` AsSvcStartupType** _(Write)_: Specifies the startup mode for
  SQL Server Analysis service. { Automatic | Disabled | Manual }
* **`[String]` IsSvcStartupType** _(Write)_: Specifies the startup mode for
  SQL Server Integration service. { Automatic | Disabled | Manual }
* **`[String]` RsSvcStartupType** _(Write)_: Specifies the startup mode for
  SQL Server Report service. { Automatic | Disabled | Manual }
* **`[String]` BrowserSvcStartupType** _(Write)_: Specifies the startup mode for
  SQL Server Browser service. { Automatic | Disabled | Manual }
* **`[String]` FailoverClusterGroupName** _(Write)_: The name of the resource group
  to create for the clustered SQL Server instance.
  Default is 'SQL Server (_InstanceName_)'.
* **`[String[]]` FailoverClusterIPAddress** _(Write)_: Array of IP Addresses to be
  assigned to the clustered SQL Server instance. IP addresses must be in
  [dotted-decimal notation](https://en.wikipedia.org/wiki/Dot-decimal_notation),
  for example ````10.0.0.100````. If no IP address is specified, uses 'DEFAULT' for
  this setup parameter.
* **`[String]` FailoverClusterNetworkName** _(Write)_: Host name to be assigned to
  the clustered SQL Server instance.
* **`[UInt32]` SqlTempdbFileCount** _(Write)_: Specifies the number of tempdb
  data files to be added by setup.
* **`[UInt32]` SqlTempdbFileSize** _(Write)_: Specifies the initial size of
  each tempdb data file in MB.
* **`[UInt32]` SqlTempdbFileGrowth** _(Write)_: Specifies the file growth
  increment of each tempdb data file in MB.
* **`[UInt32]` SqlTempdbLogFileSize** _(Write)_: Specifies the initial size
  of each tempdb log file in MB.
* **`[UInt32]` SqlTempdbLogFileGrowth** _(Write)_: Specifies the file growth
  increment of each tempdb data file in MB.
* **`[UInt32]` SetupProcessTimeout** _(Write)_: The timeout, in seconds, to wait
  for the setup process to finish. Default value is 7200 seconds (2 hours). If
  the setup process does not finish before this time, and error will be thrown.
* **`[String[]]` FeatureFlag** _(Write)_: Feature flags are used to toggle
  functionality on or off. See the documentation for what additional
  functionality exist through a feature flag.

#### Read-Only Properties from Get-TargetResource

* **`[String]` SQLSvcAccountUsername** _(Read)_: Output user name for the SQL service.
* **`[String]` AgtSvcAccountUsername** _(Read)_: Output user name for the SQL Agent
  service.
* **`[String]` FTSvcAccountUsername** _(Read)_: Output username for the Full Text
  service.
* **`[String]` RSSvcAccountUsername** _(Read)_: Output username for the Reporting
  Services service.
* **`[String]` ASSvcAccountUsername** _(Read)_: Output username for the Analysis
  Services service.
* **`[String]` ISSvcAccountUsername** _(Read)_: Output user name for the Integration
  Services service.

#### Examples

* [Install a default instance on a single server](/Examples/Resources/SqlSetup/1-InstallDefaultInstanceSingleServer.ps1)
* [Install a named instance on a single server](/Examples/Resources/SqlSetup/2-InstallNamedInstanceSingleServer.ps1)
* [Install a named instance on a single server from an UNC path using SourceCredential](/Examples/Resources/SqlSetup/3-InstallNamedInstanceSingleServerFromUncPathUsingSourceCredential.ps1)
* [Install a named instance as the first node in SQL Server Failover Cluster](/Examples/Resources/SqlSetup/4-InstallNamedInstanceInFailoverClusterFirstNode.ps1)
* [Install a named instance as the second node in SQL Server Failover Cluster](/Examples/Resources/SqlSetup/5-InstallNamedInstanceInFailoverClusterSecondNode.ps1)
* [Install a named instance with the Agent Service set to Disabled](/Examples/Resources/SqlSetup/6-InstallNamedInstanceSingleServerWithAgtSvcStartupTypeDisabled.ps1)
* [Install a default instance on a single server (Sql Server 2016 or Later)](/Examples/Resources/SqlSetup/7-InstallDefaultInstanceSingleServer2016OrLater.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlSetup).

### SqlWaitForAG

This resource will wait for a cluster role/group to be created. This is used to
wait for an Availability Group to create the cluster role/group in the cluster.

>Note: This only evaluates if the cluster role/group has been created and when it
found it will wait for RetryIntervalSec a last time before returning. There is
currently no check to validate that the Availability Group was successfully created
or that it has finished creating the Availability Group.

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* Target machine must be running SQL Server Database Engine 2012 or later.
* Target machine must have access to the Failover Cluster PowerShell module.

#### Security Requirements

* The account running this resource must have permission in the cluster to be able
  to run the cmdlet Get-ClusterGroup.

#### Parameters

* **`[String]` Name** _(Key)_: Name of the cluster role/group to look for (normally
  the same as the Availability Group name).
* **`[Uint64]` RetryIntervalSec** _(Write)_: The interval, in seconds, to check for
  the presence of the cluster role/group. Default value is 20 seconds. When the
  cluster role/group has been found the resource will wait for this amount of time
  once more before returning.
* **`[UInt32]` RetryCount** _(Write)_: Maximum number of retries until the resource
  will timeout and throw an error. Default value is 30 times.

#### Read-Only Properties from Get-TargetResource

* **`[Boolean]` GroupExist** _(Read)_: Returns $true if the cluster role/group exist,
  otherwise it returns $false. Used by Get-TargetResource.

#### Examples

* [Wait for a cluster role/group to be available](/Examples/Resources/SqlWaitForAG/1-WaitForASingleClusterGroup.ps1)
* [Wait for multiple cluster roles/groups to be available](/Examples/Resources/SqlWaitForAG/2-WaitForMultipleClusterGroups.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlWaitForAG).

### SqlWindowsFirewall

This will set default firewall rules for the supported features. Currently the
features supported are Database Engine, Analysis Services, SQL Browser,
SQL Reporting Services and Integration Services.

#### Firewall rules

##### Database Engine (SQLENGINE) - Default instance

Firewall Rule | Firewall Display Name
--- | ---
Application: sqlservr.exe | SQL Server Database Engine instance MSSQLSERVER
Service: SQLBrowser | SQL Server Browser

##### Database Engine (SQLENGINE) - Named instance

Firewall Rule | Firewall Display Name
--- | ---
Application: sqlservr.exe | SQL Server Database Engine instance \<INSTANCE\>
Service: SQLBrowser | SQL Server Browser

##### Analysis Services (AS) - Default instance

Firewall Rule | Firewall Display Name
--- | ---
Service: MSSQLServerOLAPService | SQL Server Analysis Services instance MSSQLSERVER
Service: SQLBrowser | SQL Server Browser

##### Analysis Services (AS) - Named instance

Firewall Rule | Firewall Display Name
--- | ---
Service: MSOLAP$\<INSTANCE\> | SQL Server Analysis Services instance \<INSTANCE\>
Service: SQLBrowser | SQL Server Browser

##### Reporting Services (RS)

Firewall Rule | Firewall Display Name
--- | ---
Port: tcp/80 | SQL Server Reporting Services 80
Port: tcp/443 | SQL Server Reporting Services 443

##### Integration Services (IS)

Firewall Rule | Firewall Display Name
--- | ---
Application: MsDtsSrvr.exe | SQL Server Integration Services Application
Port: tcp/135 | SQL Server Integration Services Port

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.

#### Parameters

* **`[String]` Features** _(Key)_: SQL features to enable firewall rules for.
* **`[String]` InstanceName** _(Key)_: SQL instance to enable firewall rules for.
* **`[String]` Ensure** _(Write)_: Ensures that SQL firewall rules are **Present**
  or **Absent** on the machine. { *Present* | Absent }.
* **`[String]` SourcePath** _(Write)_: UNC path to the root of the source files for
  installation.
* **`[String]` SourceCredential** _(Write)_: Credentials used to access the path
  set in the parameter 'SourcePath'. This parameter is optional either if built-in
  parameter 'PsDscRunAsCredential' is used, or if the source path can be access
  using the SYSTEM account.

#### Read-Only Properties from Get-TargetResource

* **`[Boolean]` DatabaseEngineFirewall** _(Read)_: Is the firewall rule for the
  Database Engine enabled?
* **`[Boolean]` BrowserFirewall** _(Read)_: Is the firewall rule for the Browser
  enabled?
* **`[Boolean]` ReportingServicesFirewall** _(Read)_: Is the firewall rule for
  Reporting Services enabled?
* **`[Boolean]` AnalysisServicesFirewall** _(Read)_: Is the firewall rule for
  Analysis Services enabled?
* **`[Boolean]` IntegrationServicesFirewall** _(Read)_: Is the firewall rule for
  the Integration Services enabled?

#### Examples

* [Create inbound firewall rules](/Examples/Resources/SqlWindowsFirewall/1-CreateInboundFirewallRules.ps1)
* [Remove inbound firewall rules](/Examples/Resources/SqlWindowsFirewall/2-RemoveInboundFirewallRules.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/PowerShell/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlWindowsFirewall).
