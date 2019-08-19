# Contributing to xSQLServer

If you are keen to make xSQLServer better, why not consider contributing your work to the project? Every little change helps us make a better resource for everyone to use, and we would love to have contributions from the community.

## Core contribution guidelines

We follow all of the standard contribution guidelines for DSC resources [outlined in DscResources repo](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md), so please review these as a baseline for contributing.

## xSQLServer specific guidelines

### SQL Server products supported by resources

Any resource should be able to target at least all SQL Server versions that are currently supported by Microsoft (also those in extended support).
Unless the functionality that the resource targets does not exist in a certain SQL Server version.
There can also be other limitations that restrict the resource from tageting all supported versions.

Those SQL Server products that are still supported can be listed at the [Microsoft lifecycle site](https://support.microsoft.com/en-us/lifecycle/search?alpha=SQL%20Server).

### Naming convention

#### mof-based resource

All mof-based resource (with Get/Set/Test-TargetResource) should be prefixed with 'MSFT_xSQLServer'. I.e. MSFT_xSQLServerConfiguration

Please note that not all places should contain the prefix 'MSFT_'.

##### Folder and file structure

Please note that for the examples folder we don't use the 'MSFT_' prefix on the resource folders.
This is to make those folders more user friendly, to resemble the name the user would use in the configuration file.

```Text
DSCResources/MSFT_xSQLServerConfiguration/MSFT_xSQLServerConfiguration.psm1
DSCResources/MSFT_xSQLServerConfiguration/MSFT_xSQLServerConfiguration.schema.mof

Tests/Unit/MSFT_xSQLServerConfiguration.Tests.ps1

Examples/Resources/xSQLServerConfiguration/1-AddConfigurationOption.ps1
Examples/Resources/xSQLServerConfiguration/2-RemoveConfigurationOption.ps1
```

##### Schema mof file

Please note that the `FriendlyName` in the schema mof file should not contain the prefix `MSFT_`.

```powershell
[ClassVersion("1.0.0.0"), FriendlyName("xSQLServerConfiguration")]
class MSFT_xSQLServerConfiguration : OMI_BaseResource
{
    # Properties removed for readability.
};
```

#### Composite or class-based resource

Any composite (with a Configuration) or class-based resources should be prefixed with just 'xSQLServer'

### Localization

To be able to support localization we have added wrappers for the cmdlets `Write-Verbose` and `Write-Warning`, and also for the keyword `Throw`.
The localized strings are placed in a file named 'xSQLServer.strings.psd1' which are located in each language folder in the root of the module. For English language strings the folder is ['en-US'](https://github.com/PowerShell/xSQLServer/blob/dev/en-US).

|Function|Short description|
---|---|---
|`New-TerminatingError`| Throws a localized error message using `Throw`. The parameter `ErrorType` takes the message type for which it will get the localized message string. |
|`New-VerboseMessage`| Writes a localized verbose message using `Write-Verbose`. The parameter `ErrorType` takes the message type for which it will get the localized message string. |
|`New-WarningMessage`| Writes a localized warning message using `Write-Warning`. The parameter `ErrorType` takes the message type for which it will get the localized message string. |

### Helper functions

Helper functions or wrapper functions that are used by the resource can preferably be placed in the resource module file. If the functions are of a type that could be used by more than
one resource, then the functions can also be placed in the common [xSQLServerHelper.psm1](https://github.com/PowerShell/xSQLServer/blob/dev/xSQLServerHelper.psm1) module file.

### Tests

#### Using SMO stub classes

There are [stub classes](https://github.com/PowerShell/xSQLServer/blob/dev/Tests/Unit/Stubs/SMO.cs) for the SMO classes which can be used and improved on when creating tests where SMO classes are used in the code being tested.

#### AppVeyor

AppVeyor is the platform where the tests is run when sending in a Pull Request (PR). Due to a change in the build worker that AppVeyor provides it has already have the SMO assemblies loaded, which make our stub SMO classes unable to be initiated.
To get around this we need to get a clean PowerShell environment to run our tests in. One way is to use `Start-Job`. So this change needs to be done to the unit test template before sending in a Pull Request (PR).

```powershell
#
    AppVeyor build worker loads the SMO assembly which makes the SMO stub classes unable to be initiated.
    Running the tests in a Start-Job script block give us a clean environment. This is a workaround.
#>
$testJob = Start-Job -ArgumentList $PSScriptRoot -ScriptBlock {
    param
    (
        [System.String] $PSScriptRoot
    )

    # Unit test template goes here
}

$testJob | Receive-Job -Wait
```
