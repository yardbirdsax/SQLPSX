<#
.SYNOPSIS
  Creates a new Report Server folder
.PARAMETER ReportServer
  The name of the report server to connect to. Can also be passed as a property of a pipeline object.
.PARAMETER Path
  The path at which to create the folder. Can also be passed as a property of a pipeline object.
.PARAMETER Name
  The name of the folder to be created.
.EXAMPLE
  Get-RSServer -ReportServer "MyReportServer.MyDomain.Com" | New-RSFolder -Name "MyFolder"
   
  Creates a new folder at the root of the Report Server.
.EXAMPLE
  Get-RSServer -ReportServer "MyReportServer.MyDomain.Com" | Get-RSFolder "MyFolder" | New-RSFolder -Name "MyOtherFolder"
  
  Creates a new folder within a parent folder.
#>
function New-RSFolder 
{

  [CmdletBinding()]
  param
  (
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [object]$ReportServer,
    [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [string]$Path = "/",
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$Name    
  )

  process
  {
    #Pass the ReportServer object to through the Get-ReportServer function.
    #This is so that even if a string is passed, a ReportServer proxy object will be generated.
    $ReportServer = Get-RSServer -ReportServer $ReportServer;
  
    #Create the folder.
    $folder = $ReportServer.CreateFolder($Name,$Path,$null);
    
    Write-Output $folder;
  }
  
}
