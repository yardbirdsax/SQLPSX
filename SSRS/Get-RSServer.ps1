<#
.SYNOPSIS
 Gets a ReportServer web service object.
.PARAMETER ServerName
 The name of the server to create the web service proxy against. Can also be an existing 
 proxy object, in which case nothing is done. This is to allow for easier downstream use.
#>
function Get-RSServer
{

  param
  (
    [parameter(mandatory=$true)][Object]$ReportServer
  )

  Set-StrictMode -Version "Latest";
  
  switch -wildcard ($ReportServer.GetType().Name)
  {
    "ReportingServ*" {}
    "String"{
      $uri = "http://$ReportServer/ReportServer/ReportService2005.asmx";
      $ReportServer = New-WebServiceProxy -Uri $uri -UseDefaultCredential;
    }
  }
    
  return $reportServer;
  
}