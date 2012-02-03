<#
.SYNOPSIS
 Gets a Report Service folder object from the web service.
.PARAMETER ReportServer
 The name of the report server, or can be the ReportServer object itself.

#>
function Get-RSServerPermission
{

  param
  (
    [parameter(mandatory=$true,ValueFromPipeline=$true)][Object]$ReportServer
  )
  
  BEGIN {
    Set-StrictMode -Version "Latest";
    
    #Initialize variables
    $permissions = @();    #Empty collection to hold permissions returned
    
  }
  PROCESS {
  
    #Pass the ReportServer object to through the Get-ReportServer function.
    #This is so that even if a string is passed, a ReportServer proxy object will be generated.
    $ReportServer = Get-ReportServer -ReportServer $ReportServer;

    $permissions = $ReportServer.GetSystemPolicies();
    
  }
  
  END {
    return $permissions;
  }

}