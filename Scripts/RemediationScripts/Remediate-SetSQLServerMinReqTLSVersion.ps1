﻿<###
# Overview:
    This script is used to set required TLS version for SQL Server in a Subscription.
# Control ID:
    Azure_SQLDatabase_DP_Use_Secure_TLS_Version_Trial
# Display Name:
    Use Approved TLS Version in SQL Server.
# Prerequisites:
    1. Contributor or higher privileges on the SQL Servers in a Subscription.
    2. Must be connected to Azure with an authenticated account.
# Steps performed by the script:
    To remediate:
        1. Validate and install the modules required to run the script.
        2. Get the list of SQL Servers in a Subscription that do not use the required TLS version
        3. Back up details of SQL Servers that are to be remediated.
        4. Set the required TLS version on the all SQL Servers in the Subscription.
    To roll back:
        1. Validate and install the modules required to run the script.
        2. Get the list of SQL Servers in a Subscription, the changes made to which previously, are to be rolled back.
        3. Set the previous TLS versions on all SQL Servers in the Subscription.
# Instructions to execute the script:
    To remediate:
        1. Download the script.
        2. Load the script in a PowerShell session. Refer https://aka.ms/AzTS-docs/RemediationscriptExcSteps to know more about loading the script.
        3. Execute the script to set the required TLS version in all SQL Servers in the Subscription. Refer `Examples`, below.
    To roll back:
        1. Download the script.
        2. Load the script in a PowerShell session. Refer https://aka.ms/AzTS-docs/RemediationscriptExcSteps to know more about loading the script.
        3. Execute the script to set the previous TLS versions in all SQL Servers in the Subscription. Refer `Examples`, below.
# Examples:
    To remediate:
        1. To review the SQL Servers in a Subscription that will be remediated:
           Set-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -DryRun
        2. To set minimal required TLS version  of all SQL Servers in a Subscription:
           Set-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck
        3. To set minimal required TLS version on the of all SQL Servers in a Subscription, from a previously taken snapshot:
           Set-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -FilePath C:\AzTS\Subscriptions\00000000-xxxx-0000-xxxx-000000000000\202109131040\setMinTLSVersionForSQLServers\SQLServersWithoutMinReqTLSVersion.csv
        4. To set minimal required TLS version of all SQL Servers in a Subscription without taking back up before actual remediation:
           Set-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -SkipBackup
        To know more about the options supported by the remediation command, execute:
        Get-Help Set-SQLServerRequiredTLSVersion -Detailed
    To roll back:
        1. To reset minimal required TLS version of all SQL Servers in a Subscription, from a previously taken snapshot:
           Reset-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -FilePath C:\AzTS\Subscriptions\00000000-xxxx-0000-xxxx-000000000000\202109131040\setMinTLSVersionForSQLServers\RemediatedSQLServers.csv
        
        2. To reset minimal required TLS version of all SQL Servers in a Subscription, from a previously taken snapshot:
           Reset-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -FilePath C:\AzTS\Subscriptions\00000000-xxxx-0000-xxxx-000000000000\202109131040\setMinTLSVersionForSQLServers\RemediatedSQLServers.csv
        To know more about the options supported by the roll back command, execute:
        Get-Help Reset-SQLServerRequiredTLSVersion -Detailed        
###>


function Setup-Prerequisites
{
    

    # List of required modules
    $requiredModules = @("Az.Accounts", "Az.Resources")

    Write-Host "Required modules: $($requiredModules -join ', ')" -ForegroundColor $([Constants]::MessageType.Info)
    Write-Host "Checking if the required modules are present..."

    $availableModules = $(Get-Module -ListAvailable $requiredModules -ErrorAction Stop)

    # Check if the required modules are installed.
    $requiredModules | ForEach-Object {
        if ($availableModules.Name -notcontains $_)
        {
            Write-Host "Installing $($_) module..." -ForegroundColor $([Constants]::MessageType.Info)
            Install-Module -Name $_ -Scope CurrentUser -Repository 'PSGallery' -ErrorAction Stop
        }
        else
        {
            Write-Host "$($_) module is present." -ForegroundColor $([Constants]::MessageType.Update)
        }
    }
}

function Set-SQLServerRequiredTLSVersion
{
    <#
        .SYNOPSIS
        Remediates 'Azure_SQLServer_DP_Use_Secure_TLS_Version' Control.
        .DESCRIPTION
        Remediates 'Azure_SQLServer_DP_Use_Secure_TLS_Version' Control.
        Sets the required minimal TLS version on the all SQL Servers in the Subscription. 
        
        .PARAMETER SubscriptionId
        Specifies the ID of the Subscription to be remediated.
        
        .PARAMETER Force
        Specifies a forceful remediation without any prompts.
        
        .Parameter PerformPreReqCheck
        Specifies validation of prerequisites for the command.
        
        .PARAMETER DryRun
        Specifies a dry run of the actual remediation.
        .PARAMETER SkipBackup
        Specifies that no back up will be taken by the script before remediation.
        
        .PARAMETER FilePath
        Specifies the path to the file to be used as input for the remediation.
        .PARAMETER Path
        Specifies the path to the file to be used as input for the remediation when AutoRemediation switch is used.
        .PARAMETER AutoRemediation
        Specifies script is run as a subroutine of AutoRemediation Script.
        .PARAMETER TimeStamp
        Specifies the time of creation of file to be used for logging remediation details when AutoRemediation switch is used.
        .INPUTS
        None. You cannot pipe objects to Set-SQLServerRequiredTLSVersion.
        .OUTPUTS
        None. Set-SQLServerRequiredTLSVersion does not return anything that can be piped and used as an input to another command.
        .EXAMPLE
        PS> Set-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -DryRun
        .EXAMPLE
        PS> Set-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck
        .EXAMPLE
        PS> Set-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -FilePath C:\AzTS\Subscriptions\00000000-xxxx-0000-xxxx-000000000000\202109131040\setMinTLSVersionForSQLServers\SQLServersWithoutMinReqTLSVersion.csv
        .LINK
        None
    #>

    param (
        [String]
        [Parameter(ParameterSetName = "DryRun", Mandatory = $true, HelpMessage="Specifies the ID of the Subscription to be remediated")]
        [Parameter(ParameterSetName = "WetRun", Mandatory = $true, HelpMessage="Specifies the ID of the Subscription to be remediated")]
        $SubscriptionId,

        [Switch]
        [Parameter(ParameterSetName = "WetRun", HelpMessage="Specifies a forceful remediation without any prompts")]
        $Force,

        [Switch]
        [Parameter(ParameterSetName = "DryRun", HelpMessage="Specifies validation of prerequisites for the command")]
        [Parameter(ParameterSetName = "WetRun", HelpMessage="Specifies validation of prerequisites for the command")]
        $PerformPreReqCheck,

        [Switch]
        [Parameter(ParameterSetName = "DryRun", Mandatory = $true, HelpMessage="Specifies a dry run of the actual remediation")]
        $DryRun,

        [Switch]
        [Parameter(ParameterSetName = "WetRun", HelpMessage="Specifies no back up will be taken by the script before remediation")]
        $SkipBackup,


        [String]
        [Parameter(ParameterSetName = "WetRun", HelpMessage="Specifies the path to the file to be used as input for the remediation")]
        $FilePath,

        [String]
        [Parameter(ParameterSetName = "WetRun", HelpMessage="Specifies the path to the file to be used as input for the remediation when AutoRemediation switch is used")]
        $Path,

        [Switch]
        [Parameter(ParameterSetName = "WetRun", HelpMessage="Specifies script is run as a subroutine of AutoRemediation Script")]
        $AutoRemediation,

        [String]
        [Parameter(ParameterSetName = "WetRun", HelpMessage="Specifies the time of creation of file to be used for logging remediation details when AutoRemediation switch is used")]
        $TimeStamp
    )

    Write-Host $([Constants]::DoubleDashLine)
    Write-Host "[Step 1 of 4] Prepare to set required TLS version for SQL Servers in Subscription: [$($SubscriptionId)]"
    if ($PerformPreReqCheck)
    {
        try
        {
            Write-Host "Setting up prerequisites..."
            Setup-Prerequisites
        }
        catch
        {
            Write-Host "Error occurred while setting up prerequisites. Error: $($_)" -ForegroundColor $([Constants]::MessageType.Error)
            break
        }
    }

    # Connect to Azure account
    $context = Get-AzContext

    if ([String]::IsNullOrWhiteSpace($context))
    {
        Write-Host "No active Azure login session found. Exiting..." -ForegroundColor $([Constants]::MessageType.Error)
        break
    }

   
    # Setting up context for the current Subscription.
    $context = Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    
    if(-not($AutoRemediation))
    {
        Write-Host $([Constants]::SingleDashLine)
        Write-Host "Subscription Name: $($context.Subscription.Name)"
        Write-Host "Subscription ID: $($context.Subscription.SubscriptionId)"
        Write-Host "Account Name: $($context.Account.Id)"
        Write-Host "Account Type: $($context.Account.Type)"
        Write-Host $([Constants]::SingleDashLine)
    }

    Write-Host "To Set minimal TLS version for SQL Servers in a Subscription, Contributor or higher privileges on the SQL Servers are required." -ForegroundColor $([Constants]::MessageType.Warning)
    Write-Host $([Constants]::DoubleDashLine)
    Write-Host "[Step 2 of 4] Fetch all SQL Servers"

    $sqlServerResources = @()
    $requiredMinTLSVersion = 1.2


    # To keep track of remediated and skipped resources
    $logRemediatedResources = @()
    $logSkippedResources=@()

    $controlIds = "Azure_SQLDatabase_DP_Use_Secure_TLS_Version_Trial"

     if($AutoRemediation)
    {
        if(-not (Test-Path -Path $Path))
        {
        Write-Host "File containing failing controls details [$($Path)] not found. Skipping remediation..." -ForegroundColor $([Constants]::MessageType.Error)
        Write-Host $([Constants]::SingleDashLine)
        return
        }
        Write-Host "Fetching all SQL Servers failing for the [$($controlIds)] control from [$($Path)]..." -ForegroundColor $([Constants]::MessageType.Info)
        Write-Host $([Constants]::SingleDashLine)
        $controlForRemediation = Get-content -path $Path | ConvertFrom-Json
        $controls = $controlForRemediation.ControlRemediationList
        $resourceDetails = $controls | Where-Object { $controlIds -eq $_.ControlId };
        $validResources = $resourceDetails.FailedResourceList | Where-Object {![String]::IsNullOrWhiteSpace($_.ResourceId)}

        if(($resourceDetails | Measure-Object).Count -eq 0 -or ($validResources | Measure-Object).Count -eq 0)
        {
            Write-Host "No SQL Server(s) found in input json file for remediation." -ForegroundColor $([Constants]::MessageType.Error)
            Write-Host $([Constants]::SingleDashLine)
            return
        }  
        $validResources | ForEach-Object { 
            try
            {
            $name = $_.ResourceId.Split('/')[8]
            $resSqlServer = Get-AzSqlServer  -Name $name -ErrorAction SilentlyContinue
            $sqlServerResources = $sqlServerResources + $resSqlServer
            }
            catch
            {
            Write-Host "Valid resource id(s) not found in input json file. Error: [$($_)]" -ForegroundColor $([Constants]::MessageType.Error)
            Write-Host "Skipping the Resource: [$($_.ResourceName)]..."
            $logResource = @{}
            $logResource.Add("ResourceGroupName",($_.ResourceGroupName))
            $logResource.Add("ResourceName",($_.ResourceName))
            $logResource.Add("Reason","Valid resource id(s) not found in input json file.")    
            $logSkippedResources += $logResource
            Write-Host $([Constants]::SingleDashLine)
            }
        }
    }
    else
    {
        # No file path provided as input to the script. Fetch all SQL Servers in the Subscription.
        if ([String]::IsNullOrWhiteSpace($FilePath))
        {
            Write-Host "`nFetching all SQL Servers in Subscription: $($context.Subscription.SubscriptionId)" -ForegroundColor $([Constants]::MessageType.Info)

            # Get all SQL Servers in the Subscription
            $sqlServerResources = Get-AzSqlServer  -ErrorAction Stop

       
            $totalsqlServerResources = ($sqlServerResources | Measure-Object).Count
        
        }
        else
        {
                if (-not (Test-Path -Path $FilePath))
                {
                    Write-Host "ERROR: Input file - $($FilePath) not found. Exiting..." -ForegroundColor $([Constants]::MessageType.Error)
                    break
                }

                Write-Host "Fetching all SQL Servers(s) from $($FilePath)" -ForegroundColor $([Constants]::MessageType.Info)

                $sqlServerResourcesFromFile = Import-Csv -LiteralPath $FilePath
                $validsqlServerResources = $sqlServerResourcesFromFile | Where-Object { ![String]::IsNullOrWhiteSpace($_.ServerName) }
        
                $validsqlServerResources | ForEach-Object {
                    $resourceGroupName = $_.ResourceGroupName        
                    $serverName = $_.ServerName               

                    try
                    {
                        $sqlServerResources += (Get-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $serverName -ErrorAction SilentlyContinue) 

                    }
                    catch
                    {
                        Write-Host "Error fetching Server:   - $($serverName). Error: $($_)" -ForegroundColor $([Constants]::MessageType.Error)
                        Write-Host "Skipping this Server..." -ForegroundColor $([Constants]::MessageType.Warning)
                    }
                }
            }
    }
    
    $totalsqlServerResources = ($sqlServerResources | Measure-Object).Count

    if ($totalsqlServerResources -eq 0)
    {
        Write-Host "No SQL Servers found. Exiting..." -ForegroundColor $([Constants]::MessageType.Update)
        break
    }

    Write-Host "Found $($totalsqlServerResources) SQL Server(s)." -ForegroundColor $([Constants]::MessageType.Update)
 
 
     
    # Includes SQL Servers where minimal required TLS version is set  
    $sqlServersWithReqMinTLSVersion = @()

    # Includes SQL Servers where minimal required TLS version is not set   
    $sqlServersWithoutReqMinTLSVersion = @()

    # Includes SQL Servers that were skipped during remediation. There were errors remediating them.
    $sqlServersSkipped = @()

     
    Write-Host $([Constants]::DoubleDashLine)
    Write-Host "`n[Step 3 of 5] Fetching SQL Servers with (s)..."
    Write-Host "Separating SQL Server(s) for which TLS is less than required TLS version ..." -ForegroundColor $([Constants]::MessageType.Info)

    $sqlServerResources | ForEach-Object {
        $sqlServer = $_        
        if($_.MinimalTlsVersion -lt $requiredMinTLSVersion) 
        {
            $sqlServersWithoutReqMinTLSVersion +=  $sqlServer | Select-Object @{N='ServerName';E={$_.ServerName}},
                                                                        @{N='ResourceGroupName';E={$_.ResourceGroupName}},
                                                                        @{N='Location';E={$_.Location}},
                                                                        @{N='ServerVersion';E={$_.ServerVersion}},
                                                                        @{N='MinimalTlsVersion';E={$_.MinimalTlsVersion}}
        }
    }

    $totalsqlServersWithoutReqMinTLSVersion = ($sqlServersWithoutReqMinTLSVersion | Measure-Object).Count
     
    if ($totalsqlServersWithoutReqMinTLSVersion  -eq 0)
    {
        Write-Host "No SQL Server(s) found where TLS is less than required TLS version.. Exiting..." -ForegroundColor $([Constants]::MessageType.Update)
        Write-Host $([Constants]::DoubleDashLine)	
        
         if($AutoRemediation -and ($sqlServerResources |Measure-Object).Count -gt 0) 
        {
            $logFile = "LogFiles\"+ $($TimeStamp) + "\log_" + $($SubscriptionId) +".json"
            $log =  Get-content -Raw -path $logFile | ConvertFrom-Json
            foreach($logControl in $log.ControlList){
                if($logControl.ControlId -eq $controlIds){
                    $logControl.RemediatedResources=$logRemediatedResources
                    $logControl.SkippedResources=$logSkippedResources
                }
            }
            $log | ConvertTo-json -depth 10  | Out-File $logFile
        }	

        return
    }

    Write-Host "Found [$($totalsqlServersWithoutReqMinTLSVersion)] SQL servers where TLS version is either not set or less than required minimal TLS version." -ForegroundColor $([Constants]::MessageType.Update)
    Write-Host $([Constants]::SingleDashLine)	
     
    if(-not($AutoRemediation))
    {
        Write-Host "`nFollowing SQL Servers are having TLS version either not set or less than required minimal TLS version less than required TLS Version:" -ForegroundColor $([Constants]::MessageType.Info)
        $colsProperty =     @{Expression={$_.ServerName};Label="Server Name";Width=10;Alignment="left"},
                            @{Expression={$_.ResourceGroupName};Label="Resource Group";Width=10;Alignment="left"},
                            @{Expression={$_.Location};Label="Location";Width=7;Alignment="left"},
                            @{Expression={$_.ServerVersion};Label="Server Version";Width=7;Alignment="left"},
                            @{Expression={$_.minimalTlsVersion};Label="Minimal TLS Version";Width=7;Alignment="left"}

        $sqlServersWithoutReqMinTLSVersion | Format-Table -Property $colsProperty -Wrap
    }

    # Back up snapshots to `%LocalApplicationData%'.
    $backupFolderPath = "$([Environment]::GetFolderPath('LocalApplicationData'))\AzTS\Remediation\Subscriptions\$($context.Subscription.SubscriptionId.replace('-','_'))\$($(Get-Date).ToString('yyyyMMddhhmm'))\SetSQLServerMinReqTLSVersion"

    if (-not (Test-Path -Path $backupFolderPath))
    {
        New-Item -ItemType Directory -Path $backupFolderPath | Out-Null
    }

    Write-Host $([Constants]::DoubleDashLine)
    Write-Host "`n[Step 4 of 5] Backing up SQL Server(s) details..."
    if ([String]::IsNullOrWhiteSpace($FilePath))
    {        
      if(-not $SkipBackup)
      {
        # Backing up SQL Server details.
        $backupFile = "$($backupFolderPath)\sqlServersWithoutReqMinTLSVersion.csv"
        $sqlServersWithoutReqMinTLSVersion | Export-CSV -Path $backupFile -NoTypeInformation
        Write-Host "SQL Server(s) details have been successful backed up to $($backupFolderPath)" -ForegroundColor $([Constants]::MessageType.Update)
      }
    }
    else
    {
        Write-Host "Skipped as -FilePath is provided" -ForegroundColor $([Constants]::MessageType.Warning)
    }
  
    
    if (-not $DryRun)
    {  
        # Here AutoRemediation switch is used as there is no need to take user input at BRS level if user has given consent to proceed with the remediation in AutoRemediation Script.
        if(-not $AutoRemediation)
        {

                Write-Host "TLS Version will be set to required TLS version for all SQL Servers(s)." -ForegroundColor $([Constants]::MessageType.Warning)

                if (-not $Force)
                {
                    Write-Host "Do you want to set TLS version to required TLS version for all SQL Server(s)? " -ForegroundColor $([Constants]::MessageType.Warning) -NoNewline
            

                    $userInput = Read-Host -Prompt "(Y|N)" #TODO: 
            
                    if($userInput -ne "Y")
                    {
                        Write-Host "TLS version will not be changed for any SQL Server(s). Exiting..." -ForegroundColor $([Constants]::MessageType.Update)
                        break
                    }
                }
                else
                {
                    Write-Host "'Force' flag is provided. TLS version will be changed to required TLS version for all SQL Server(s) without any further prompts." -ForegroundColor $([Constants]::MessageType.Warning)
                }
           }

        Write-Host $([Constants]::DoubleDashLine)
        Write-Host "`n[Step 5 of 5] Configuring TLS version for SQL Server(s)..."

        # To hold results from the remediation.
        $sqlServersRemediated = @()
    
        # Remidiate Controls by setting TLS version to required TLS version
        $sqlServersWithoutReqMinTLSVersion | ForEach-Object {
            $sqlServer = $_
            $serverName = $_.ServerName;
            $resourceGroupName = $_.ResourceGroupName; 
            $tls = $_.MinimalTlsVersion;

            # Holds the list of SQL Servers where TLS version change is skipped
            $sqlServersSkipped = @()
            
             
            try
            {   
                $sqlServerTls = Set-AzSqlServer -ServerName $serverName  -ResourceGroupName $resourceGroupName -MinimalTlsVersion $requiredMinTLSVersion

                if ($sqlServerTls.MinimalTlsVersion -ne $requiredMinTLSVersion)
                {
                    $sqlServersSkipped += $sqlServer
                    $logResource = @{}
                    $logResource.Add("ResourceGroupName",($_.ResourceGroupName))
                    $logResource.Add("ResourceName",($_.ServerName))
                    $logResource.Add("Reason", "Error while setting the minimum required TLS version for SQL Server")
                       
                }
                else
                {
                    $sqlServersRemediated += $sqlServer | Select-Object @{N='ServerName';E={$serverName}},
                                                                        @{N='ResourceGroupName';E={$resourceGroupName}},
                                                                        @{N='Location';E={$_.Location}},
                                                                        @{N='ServerVersion';E={$_.ServerVersion}}, 
                                                                        @{N='MinimalTlsVersionBefore';E={$tls}},
                                                                        @{N='MinimalTlsVersionAfter';E={$sqlServerTls.MinimalTlsVersion}}

                    $logResource = @{}
                    $logResource.Add("ResourceGroupName",($_.ResourceGroupName))
                    $logResource.Add("ResourceName",($_.ServerName))
                    $logRemediatedResources += $logResource
 
                }
            }
            catch
            {
                $sqlServersSkipped += $sqlServer
                $logResource = @{}
                $logResource.Add("ResourceGroupName",($_.ResourceGroupName))
                $logResource.Add("ResourceName",($_.ServerName))
                $logResource.Add("Reason", "Error while setting the minimum required TLS version for SQL Server")
            }
        }

        $totalRemediatedSQLServers = ($sqlServersRemediated | Measure-Object).Count

        Write-Host $([Constants]::SingleDashLine)

        if ($totalRemediatedSQLServers -eq $sqlServersWithoutReqMinTLSVersion)
        {
            Write-Host "TLS Version changed to required TLS version for all $($totalsqlServersWithoutReqMinTLSVersion) SQL Server(s) ." -ForegroundColor $([Constants]::MessageType.Update)
        }
        else
        {
            Write-Host "TLS Version changed to required TLS version for $totalRemediatedSQLServers out of $($totalsqlServersWithoutReqMinTLSVersion) SQL Server(s)" -ForegroundColor $([Constants]::MessageType.Warning)
        }

        $colsProperty = @{Expression={$_.ServerName};Label="Server Name";Width=10;Alignment="left"},
                        @{Expression={$_.ResourceGroupName};Label="Resource Group";Width=10;Alignment="left"},
                        @{Expression={$_.ServerVersion};Label="Server Version";Width=7;Alignment="left"},
                        @{Expression={$_.MinimalTlsVersionBefore};Label="Minimal TLS Ver. Before";Width=7;Alignment="left"},
                        @{Expression={$_.MinimalTlsVersionAfter};Label="Minimal TLS Ver. After";Width=7;Alignment="left"}
 
                       
                      
        Write-Host $([Constants]::DoubleDashLine)
        if($AutoRemediation)
        {
            if ($($sqlServersRemediated | Measure-Object).Count -gt 0)
            {
                    # Write this to a file.
                    $sqlServersRemediatedFile = "$($backupFolderPath)\RemediatedsqlServersFileforMinTLS.csv"
                    $sqlServersRemediated| Export-CSV -Path $sqlServersRemediatedFile -NoTypeInformation
                    Write-Host "The information related to SQL Server(s) where minimum required TLS version is successfully set has been saved to [$($sqlServersRemediatedFile)]. Use this file for any roll back that may be required." -ForegroundColor $([Constants]::MessageType.Warning)
                    Write-Host $([Constants]::SingleDashLine)
            }

            if ($($sqlServersSkipped | Measure-Object).Count -gt 0)
            {   
                    # Write this to a file.
                    $sqlServerSkippedFile = "$($backupFolderPath)\SkippedsqlServersFileforMinTLS.csv"
                    $sqlServersSkipped | Export-CSV -Path $sqlServerSkippedFile -NoTypeInformation
                    Write-Host "The information related to SQL Server(s) where minimum required TLS version is not set has been saved to [$($sqlServersSkippedFile)]." -ForegroundColor $([Constants]::MessageType.Warning)
                    Write-Host $([Constants]::SingleDashLine)
            }
        }
        else
        {
            Write-Host "`nRemediation Summary:`n" -ForegroundColor $([Constants]::MessageType.Info)
        
            if ($($sqlServersRemediated | Measure-Object).Count -gt 0)
            {
                $sqlServersRemediated | Format-Table -Property $colsProperty -Wrap

                # Write this to a file.
                $sqlServersRemediatedFile = "$($backupFolderPath)\RemediatedsqlServersFileforMinTLS.csv"
                $sqlServersRemediated| Export-CSV -Path $sqlServersRemediatedFile -NoTypeInformation
                Write-Host "This information has been saved to $($sqlServersRemediatedFile)"
                Write-Host "Use this file for any roll back that may be required." -ForegroundColor $([Constants]::MessageType.Info)
            }

            if ($($sqlServersSkipped | Measure-Object).Count -gt 0)
            {
                Write-Host "`nError changing minimal TLS version for following SQL Server(s):" -ForegroundColor $([Constants]::MessageType.Error)
                $sqlServersSkipped | Format-Table -Property $colsProperty -Wrap
            
                # Write this to a file.
                $sqlServerSkippedFile = "$($backupFolderPath)\SkippedsqlServersFileforMinTLS.csv"
                $sqlServersSkipped | Export-CSV -Path $sqlServerSkippedFile -NoTypeInformation
                Write-Host "This information has been saved to $($sqlServerResourcesSkippedFile)"
             }
          }

          if($AutoRemediation){
            $logFile = "LogFiles\"+ $($TimeStamp) + "\log_" + $($SubscriptionId) +".json"
            $log =  Get-content -Raw -path $logFile | ConvertFrom-Json
            foreach($logControl in $log.ControlList){
                if($logControl.ControlId -eq $controlIds){
                    $logControl.RemediatedResources=$logRemediatedResources
                    $logControl.SkippedResources=$logSkippedResources
                    $logControl.RollbackFile = $sqlServersRemediatedFile
                }
            }
            $log | ConvertTo-json -depth 10  | Out-File $logFile
        }
    }
    else
    {
        Write-Host $([Constants]::DoubleDashLine)
        Write-Host "`n[Step 5 of 5] Changing minimal TLS version for SQL Servers(s)..."
        Write-Host $([Constants]::SingleDashLine)
        Write-Host "Skipped as -DryRun switch is provided." -ForegroundColor $([Constants]::MessageType.Warning)
        Write-Host $([Constants]::DoubleDashLine)

        Write-Host "`n**Next steps:**" -ForegroundColor $([Constants]::MessageType.Info)
        Write-Host "Run the same command with -FilePath $($backupFile) and without -DryRun, to change the minimal TLS version to required TLS version for all SQL Server(s) listed in the file." -ForegroundColor $([Constants]::MessageType.Info)
    }   
}

function Reset-SQLServerRequiredTLSVersion
{
     <#
        .SYNOPSIS
        Rolls back remediation done for 'Azure_SQLServer_DP_Use_Secure_TLS_Version' Control.
        .DESCRIPTION
        Rolls back remediation done for 'Azure_SQLServer_DP_Use_Secure_TLS_Version' Control.
        Resets minimal TLS Version on the production slot and all non-production slots in all SQL Servers in the Subscription. 
        
        .PARAMETER SubscriptionId
        Specifies the ID of the Subscription that was previously remediated.
        
        .PARAMETER Force
        Specifies a forceful roll back without any prompts.
        
        .Parameter PerformPreReqCheck
        Specifies validation of prerequisites for the command.
        
        .Parameter ExcludeNonProductionSlots
        Specifies exclusion of non-production slots from roll back.
        
        .PARAMETER FilePath
        Specifies the path to the file to be used as input for the roll back.
        .INPUTS
        None. You cannot pipe objects to Reset-SQLServerRequiredTLSVersion.
        .OUTPUTS
        None. Reset-SQLServerRequiredTLSVersion does not return anything that can be piped and used as an input to another command.
        .EXAMPLE
        PS> Reset-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -FilePath C:\AzTS\Subscriptions\00000000-xxxx-0000-xxxx-000000000000\202109131040\setMinTLSVersionForSQLServers\RemediatedSQLServers.csv
        .EXAMPLE
        PS> Reset-SQLServerRequiredTLSVersion -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -ExcludeNonProductionSlots -FilePath C:\AzTS\Subscriptions\00000000-xxxx-0000-xxxx-000000000000\202109131040\setMinTLSVersionForSQLServers\RemediatedSQLServers.csv
        .LINK
        None
    #>

    param (
        [String]
        [Parameter(Mandatory = $true, HelpMessage="Specifies the ID of the Subscription that was previously remediated.")]
        $SubscriptionId,

        [Switch]
        [Parameter(HelpMessage="Specifies a forceful roll back without any prompts")]
        $Force,

        [Switch]
        [Parameter(HelpMessage="Specifies validation of prerequisites for the command")]
        $PerformPreReqCheck,

        [String]
        [Parameter(Mandatory = $true, HelpMessage="Specifies the path to the file to be used as input for the roll back")]
        $FilePath
    )

    Write-Host $([Constants]::DoubleDashLine)
    Write-Host "`n[Step 1 of 4] Preparing to reset SQL Server TLS Version in Subscription: $($SubscriptionId)"

    if ($PerformPreReqCheck)
    {
        try
        {
            Write-Host "Setting up prerequisites..."
            Setup-Prerequisites
        }
        catch
        {
            Write-Host "Error occurred while setting up prerequisites. Error: $($_)" -ForegroundColor $([Constants]::MessageType.Error)
            break
        }
    }

    # Connect to Azure account
    $context = Get-AzContext

    if ([String]::IsNullOrWhiteSpace($context))
    {
        Write-Host "No active Azure login session found. Exiting..." -ForegroundColor $([Constants]::MessageType.Error)
        break
    }

    # Setting up context for the current Subscription.
    $context = Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    
    Write-Host $([Constants]::SingleDashLine)
    Write-Host "Subscription Name: $($context.Subscription.Name)"
    Write-Host "Subscription ID: $($context.Subscription.SubscriptionId)"
    Write-Host "Account Name: $($context.Account.Id)"
    Write-Host "Account Type: $($context.Account.Type)"
    Write-Host $([Constants]::SingleDashLine)

    Write-Host "*** To reset TLS Versions for SQL Server(s) in a Subscription, Contributor or higher privileges on the SQL Server(s) are required. ***" -ForegroundColor $([Constants]::MessageType.Info)
    Write-Host $([Constants]::DoubleDashLine)
    Write-Host "`n[Step 2 of 4] Preparing to fetch all SQL Server(s)..."
    
    if (-not (Test-Path -Path $FilePath))
    {
        Write-Host "ERROR: Input file - $($FilePath) not found. Exiting..." -ForegroundColor $([Constants]::MessageType.Error)
        break
    }

    Write-Host "Fetching all SQL Server(s) from $($FilePath)" -ForegroundColor $([Constants]::MessageType.Info)

       
        $sqlServersFromFile = Import-Csv -LiteralPath $FilePath
        $validsqlServers = $sqlServersFromFile | Where-Object { ![String]::IsNullOrWhiteSpace($_.ServerName) }
        
        $sqlServers = @()
        $sqlServerList = @()

        $validsqlServers | ForEach-Object {
            $server = $_
            $serverName = $_.ServerName
            $resourceGroupName = $_.ResourceGroupName
            $minimalTlsVersionBefore = $_.MinimalTlsVersionBefore
            $minimalTlsVersionAfter = $_.MinimalTlsVersionAfter

            try
            {
               $sqlServerList = ( Get-AzSqlServer -ServerName $serverName  -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue) 
               $sqlServers += $sqlServerList | Select-Object @{N='ServerName';E={$ServerName}},
                                                                        @{N='ResourceGroupName';E={$resourceGroupName}},
                                                                        @{N='Location';E={$_.Location}},
                                                                        @{N='ServerVersion';E={$_.ServerVersion}},
                                                                        @{N='MinimalTlsVersionAfter';E={$_.MinimalTlsVersion}},
                                                                        @{N='MinimalTlsVersionBefore';E={$minimalTlsVersionBefore}}
                                                                  


            }
            catch
            {
                Write-Host "Error fetching SQL Server :  $($serverName). Error: $($_)" -ForegroundColor $([Constants]::MessageType.Error)
                Write-Host "Skipping this SQL Server..." -ForegroundColor $([Constants]::MessageType.Warning)
            }
        }


        
    # Includes SQL Servers
    $sqlServersWithChangedTLS = @()

    
    Write-Host $([Constants]::DoubleDashLine)
    Write-Host "`n[Step 3 of 4] Fetching SQL(s)..."
    Write-Host "Separating SQL Servers..." -ForegroundColor $([Constants]::MessageType.Info)

    $sqlServers | ForEach-Object {
        $sqlServer = $_        
            if($_.MinimalTlsVersionAfter -ne $_.MinimalTlsVersionBefore)
            {
                $sqlServersWithChangedTLS += $sqlServer
            }
    }

    $totalsqlServersWithChangedTLS = ($sqlServersWithChangedTLS | Measure-Object).Count
     
    if ($totalsqlServersWithChangedTLS  -eq 0)
    {
        Write-Host "No SQL Servers found where minimal TLS version need to be changed.. Exiting..." -ForegroundColor $([Constants]::MessageType.Warning)
        Write-Host $([Constants]::DoubleDashLine)
        return
    } 

    
    Write-Host "Found [$($totalsqlServersWithChangedTLS)] SQL Servers " -ForegroundColor $([Constants]::MessageType.Update)
    Write-Host $([Constants]::SingleDashLine)	
    
     # Back up snapshots to `%LocalApplicationData%'.
    $backupFolderPath = "$([Environment]::GetFolderPath('LocalApplicationData'))\AzTS\Remediation\Subscriptions\$($context.Subscription.SubscriptionId.replace('-','_'))\$($(Get-Date).ToString('yyyyMMddhhmm'))\resetSQLServerMinReqTLSVersion"

    if (-not (Test-Path -Path $backupFolderPath))
    {
        New-Item -ItemType Directory -Path $backupFolderPath | Out-Null
    } 
    
    if (-not $Force)
    {
        Write-Host "Do you want to reset minimal TLS Version for all SQL Server(s)?" -ForegroundColor $([Constants]::MessageType.Warning) -NoNewline
            
        $userInput = Read-Host -Prompt "(Y|N)"

        if($userInput -ne "Y")
        {
            Write-Host "minimal TLS Version will not be reseted for any of the SQL Server(s). Exiting..." -ForegroundColor $([Constants]::MessageType.Update)
            break
        }
    }
    else
    {
        Write-Host "'Force' flag is provided. TLS Version will  be reseted for all of the SQL Server(s) without any further prompts." -ForegroundColor $([Constants]::MessageType.Warning) -NoNewline
    }

  

    
    Write-Host $([Constants]::DoubleDashLine)
    Write-Host "`n[Step 3 of 4]Resetting the minimal TLS Version for SQL Server(s) ..."

    # Includes SQL Server(s), to which, previously made changes were successfully rolled back.
    $sqlServersRolledBack = @()

    # Includes SQL Server(s) that were skipped during roll back. There were errors rolling back the changes made previously.
    $sqlServersSkipped = @()

   
     # Roll back by resetting TLS Version
        $sqlServersWithChangedTLS | ForEach-Object {
            $sqlServer = $_
            $serverName = $_.ServerName
            $resourceGroupName = $_.ResourceGroupName
            $minimalTlsVersionBefore = $_.MinimalTlsVersionBefore
            $minimalTlsVersionAfter = $_.MinimalTlsVersionAfter

           
            try
            {  
                $sqlserverResource =  Set-AzSqlServer -ServerName $serverName  -ResourceGroupName $resourceGroupName -MinimalTlsVersion $minimalTlsVersionBefore

                if ($sqlserverResource.MinimalTlsVersion -ne $minimalTlsVersionBefore)
                {
                    $sqlServersSkipped += $sqlServer
                       
                }
                else
                {
                   
                    $sqlServersRolledBack += $sqlServer | Select-Object @{N='ServerName';E={$ServerName}},
                                                                        @{N='ResourceGroupName';E={$resourceGroupName}},
                                                                        @{N='Location';E={$_.Location}},
                                                                        @{N='ServerVersion';E={$_.ServerVersion}}, 
                                                                        @{N='MinimalTlsVersionBefore';E={$MinimalTlsVersionAfter}},
                                                                        @{N='MinimalTlsVersionAfter';E={$sqlserverResource.MinimalTlsVersion}}
                }
            }
            catch
            {
                $sqlServersSkipped += $sqlServer
            }
       }
    

        $totalSqlServersRolledBack = ($sqlServersRolledBack | Measure-Object).Count

        Write-Host $([Constants]::SingleDashLine)

        if ($totalsqlServersRolledBack -eq $totalsqlServersWithChangedTLS)
        {
            Write-Host "TLS Version resetted for all $($totalsqlServersWithChangedTLS) SQL Server(s) ." -ForegroundColor $([Constants]::MessageType.Update)
        }
        else
        {
            Write-Host "TLS Version resetted  for  $totalSqlServersRolledBack out of $($totalsqlServersWithChangedTLS) SQL Servers(s)" -ForegroundColor $([Constants]::MessageType.Warning)
        }
        Write-Host $([Constants]::DoubleDashLine)
        Write-Host "`nRollback Summary:" -ForegroundColor $([Constants]::MessageType.Info)
        
        $colsProperty = @{Expression={$_.ServerName};Label="Server Name";Width=10;Alignment="left"},
                        @{Expression={$_.ResourceGroupName};Label="Resrouce Group";Width=10;Alignment="left"},
                        @{Expression={$_.Location};Label="Location";Width=10;Alignment="left"},
                        @{Expression={$_.ServerVersion};Label="Server Version";Width=7;Alignment="left"},
                        @{Expression={$_.MinimalTlsVersionAfter};Label="Minimal Tls Version After";Width=7;Alignment="left"},
                        @{Expression={$_.MinimalTlsVersionBefore};Label="Minimal Tls Version Before";Width=7;Alignment="left"}
            

        if ($($sqlServersRolledBack | Measure-Object).Count -gt 0)
        {
            $sqlServersRolledBack | Format-Table -Property $colsProperty -Wrap

            # Write this to a file.
            $sqlServersRolledBackFile = "$($backupFolderPath)\RolledBackSQLServerForMinimalTls.csv"
            $sqlServersRolledBack| Export-CSV -Path $sqlServersRolledBackFile -NoTypeInformation
            Write-Host "This information has been saved to $($sqlServersRolledBackFile)"
        }

        if ($($sqlServersSkipped | Measure-Object).Count -gt 0)
        {
            Write-Host "`nError resetting TLS for following SQL Server(s):" -ForegroundColor $([Constants]::MessageType.Error)
            $sqlServersSkipped | Format-Table -Property $colsProperty -Wrap
            
            # Write this to a file.
            $sqlServersSkippedFile = "$($backupFolderPath)\RollbackSkippedSQLServerForMinimalTls.csv"
            $sqlServersSkipped | Export-CSV -Path $sqlServersSkippedFile -NoTypeInformation
            Write-Host "This information has been saved to $($sqlServersSkippedFile)"
        }   
   
}

# Defines commonly used constants.
class Constants
{
    
    # Defines commonly used colour codes, corresponding to the severity of the log.
    static [Hashtable] $MessageType = @{
        Error = [System.ConsoleColor]::Red
        Warning = [System.ConsoleColor]::Yellow
        Info = [System.ConsoleColor]::Cyan
        Update = [System.ConsoleColor]::Green
        Default = [System.ConsoleColor]::White
    }

    static [String] $DoubleDashLine = "========================================================================================================================"
    static [String] $SingleDashLine = "------------------------------------------------------------------------------------------------------------------------"
}