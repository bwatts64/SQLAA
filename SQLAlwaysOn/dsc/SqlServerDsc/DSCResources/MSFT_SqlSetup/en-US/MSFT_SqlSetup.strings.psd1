# Localized resources for SqlSetup

ConvertFrom-StringData @'
    UsingPath = Using path '{0}'.
    EvaluateReplicationFeature = Detecting replication feature ({0}).
    ReplicationFeatureFound = Replication feature detected.
    ReplicationFeatureNotFound = Replication feature not detected.
    EvaluateDataQualityClientFeature = Detecting Data Quality Client feature ({0}).
    DataQualityClientFeatureFound = Data Quality Client feature detected.
    DataQualityClientFeatureNotFound = Data Quality Client feature not detected.
    EvaluateDataQualityServicesFeature = Detecting Data Services Client feature ({0}).
    DataQualityServicesFeatureFound = Data Quality Services feature detected.
    DataQualityServicesFeatureNotFound = Data Quality Services feature not detected.
    ClusterInstanceFound = Clustered instance detected.
    ClusterInstanceNotFound = Clustered instance not detected.
    FailoverClusterResourceFound = Clustered SQL Server resource located.
    FailoverClusterResourceNotFound = Could not locate a SQL Server cluster resource for instance {0}.
    EvaluateDocumentationComponentsFeature = Detecting Documentation Components feature ({0}).
    DocumentationComponentsFeatureFound = Documentation Components feature detected.
    DocumentationComponentsFeatureNotFound = Documentation Components feature not detected.
    EvaluateDatabaseEngineFeature = Detecting Database Engine feature.
    DatabaseEngineFeatureFound = Database Engine feature detected.
    DatabaseEngineFeatureNotFound = Database Engine feature not detected.
    EvaluateFullTextFeature = Detecting Full-text feature.
    FullTextFeatureFound = Full-text feature detected.
    FullTextFeatureNotFound = Full-text feature not detected.
    EvaluateReportingServicesFeature = Detecting Reporting Services feature.
    ReportingServicesFeatureFound = Reporting Services feature detected.
    ReportingServicesFeatureNotFound = Reporting Services feature not detected.
    EvaluateAnalysisServicesFeature = Detecting Analysis Services feature.
    AnalysisServicesFeatureFound = Analysis Services feature detected.
    AnalysisServicesFeatureNotFound = Analysis Services feature not detected.
    EvaluateIntegrationServicesFeature = Detecting Integration Services feature.
    IntegrationServicesFeatureFound = Integration Services feature detected.
    IntegrationServicesFeatureNotFound = Integration Services feature not detected.
    EvaluateClientConnectivityToolsFeature = Detecting Client Connectivity Tools feature ({0}).
    ClientConnectivityToolsFeatureFound = Client Connectivity Tools feature detected.
    ClientConnectivityToolsFeatureNotFound = Client Connectivity Tools feature not detected.
    EvaluateClientConnectivityBackwardsCompatibilityToolsFeature = Detecting Client Connectivity Backwards Compatibility Tools feature ({0}).
    ClientConnectivityBackwardsCompatibilityToolsFeatureFound = Client Connectivity Backwards Compatibility Tools feature detected.
    ClientConnectivityBackwardsCompatibilityToolsFeatureNotFound = Client Connectivity Backwards Compatibility Tools feature not detected.
    EvaluateClientToolsSdkFeature = Detecting Client Tools SDK feature ({0}).
    ClientToolsSdkFeatureFound = Client Tools SDK feature detected.
    ClientToolsSdkFeatureNotFound = Client Tools SDK feature not detected.
    FeatureNotSupported = '{0}' is not a valid value for setting 'FEATURES'.  Refer to SQL Help for more information.
    PathRequireClusterDriveFound = Found assigned parameter '{0}'. Adding path '{1}' to list of paths that required cluster drive.
    FailoverClusterDiskMappingError = Unable to map the specified paths to valid cluster storage. Drives mapped: {0}.
    FailoverClusterIPAddressNotValid = Unable to map the specified IP Address(es) to valid cluster networks.
    AddingFirstSystemAdministratorSqlServer = Adding user '{0}' from the parameter 'PsDscRunAsCredential' as the first system administrator account for SQL Server.
    AddingFirstSystemAdministratorAnalysisServices = Adding user '{0}' from the parameter 'PsDscRunAsCredential' as the first system administrator account for Analysis Services.
    SetupArguments = Starting setup using arguments: {0}
    SetupExitMessage = Setup exited with code '{0}'.
    SetupSuccessful = Setup finished successfully.
    SetupSuccessfulRebootRequired = Setup finished successfully, but a reboot is required.
    SetupFailed = Please see the 'Summary.txt' log file in the 'Setup Bootstrap\\Log' folder.
    Reboot = Rebooting target node.
    SuppressReboot = Suppressing reboot of target node.
    TestFailedAfterSet = Test-TargetResource function returned false when Set-TargetResource function verified the desired state. This indicates that the Set-TargetResource did not correctly set set the desired state, or that the function Test-TargetResource does not correctly evaluate the desired state.
    FeaturesFound = Found features already installed: {0}
    NoFeaturesFound = No features are installed.
    UnableToFindFeature = Unable to find feature '{0}' among the installed features: '{1}'.
    EvaluatingClusterParameters = Clustered install, checking parameters.
    ClusterParameterIsNotInDesiredState = {0} '{1}' is not in the desired state for this cluster.
    EvaluateMasterDataServicesFeature = Detecting Master Data Services (MDS) feature ({0}).
    MasterDataServicesFeatureFound = Master Data Services (MDS) feature detected.
    MasterDataServicesFeatureNotFound = Master Data Services (MDS) feature not detected.
    FeatureAlreadyInstalled = The feature '{0}' is already installed so it will not be installed again.
    FeatureFlag = Using feature flag '{0}'
'@
