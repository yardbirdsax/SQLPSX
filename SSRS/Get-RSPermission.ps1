<#
.SYNOPSIS
 Gets the permissions assigned to a particular object in Reporting Services
.PARAMETER ReportServer 
 The Report Server to execute the query against. Can be either a web service object or the name of the server.
.PARAMETER Path
 The full path to the item whose permissions should be retrieved.
#>
function Get-RSPermission
{

  param
  (
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="Folder")][Object]$ReportServer,
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="Folder")][String]$Path
  )
  
  BEGIN {
    Set-StrictMode -Version "Latest";
    $Permissions = @(); #To hold the retrieved permissions

  }
  PROCESS {
  
    #Pass the ReportServer object to through the Get-ReportServer function.
    #This is so that even if a string is passed, a ReportServer proxy object will be generated.
    $ReportServer = Get-ReportServer -ReportServer $ReportServer;
      
    #Retrieve the permissions for the object specified and add them to the collection
    $Permissions += $ReportServer.GetPolicies($Path,[ref]$null) | Add-Member -MemberType NoteProperty -Name ;
    }
  END {
    return $Permissions;
  }
  

}