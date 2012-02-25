#######################################################################################################################
# File:             SSRS.psm1                                                                              #
# Author:           Josh Feierman                                                                                     #
# Publisher:                                                                                                          #
# Copyright:        © 2011 Josh Feierman. All rights reserved.                                                        #
#                                                                                                                     #
#######################################################################################################################

Set-StrictMode -Version 2

#Get the location where the current script resides
$currentPath = $PSScriptRoot;
Write-Debug "Current path is $currentPath";

#Load all modules under the Modules subdirectory
$scriptsToLoad = Get-ChildItem -Path $currentPath -Include "*.ps1" -Exclude "Deploy.ps1" -Recurse;
Write-Debug "There are $($scriptsToLoad.Count) scripts to load.";

$totalCount = $scriptsToLoad.Count;
$currentCount = 0;
$percentComplete = 0;

foreach ($script in $scriptsToLoad)
{

	Write-Progress -Activity "Loading Scripts" -Status "Loading script $($script) ($($currentCount) of $($totalCount))" -PercentComplete $percentComplete;
	Write-Verbose "Loading script $($script) ($($currentCount) of $($totalCount))";
	. $script.FullName;
	$currentCount ++;
	$percentComplete = $currentCount / $totalCount * 100;

}

