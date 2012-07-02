<#
.SYNOPSIS
  Creates a new Report Server data source.
.PARAMETER ReportServer
  The name of the report server to connect to. Can also be passed as a property of a pipeline object.
.PARAMETER Path
  The path at which to create the data source. Can also be passed as a property of a pipeline object.
.PARAMETER Name
  The name of the data source to be created.
.PARAMETER ConnectionString
  The connection string of the data source. Reference http://connectionstrings.com/ for examples.
.PARAMETER Extension
  The name of the extension to use for the data source. Defaults to "SQL".
.PARAMTEER UserName
  The user name of the stored credential.
.PARAMETER Password
  The password of the stored credenital.
.PARAMETER WindowsCredentials
  If specified the credentials passed in will be set as Windows credentials.
.PARAMETER Force
  If specified the function will over-write an existing data source if one exists.

#>
function New-RSDataSource 
{

  [CmdletBinding()]
  param
  (
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [object]$ReportServer,
    [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [string]$Path = "/",
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$Name,
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$ConnectionString,
    [parameter(mandatory=$false)]
    [string]$Extension = "SQL",
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$UserName,
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$Password,
    [parameter(mandatory=$false)]
    [switch]$WindowsCredentials,
    [parameter(mandatory=$false)]
    [switch]$Force
  )
  process
  {
    #Pass the ReportServer object to through the Get-ReportServer function.
    #This is so that even if a string is passed, a ReportServer proxy object will be generated.
    $ReportServer = Get-RSServer -ReportServer $ReportServer;
  
    #Create the datastore definition object
    $Namespace = $ReportServer.GetType().Namespace
    $dsDef = New-Object "$Namespace.DataSourceDefinition"
    $dsDef.ConnectString = $ConnectionString
    $dsDef.Extension = $Extension
    $dsDef.ImpersonateUserSpecified = $false
    $dsDef.UserName = $UserName
    $dsDef.Password = $Password
    $dsDef.WindowsCredentials = $WindowsCredentials
    $dsDef.CredentialRetrieval = "Store"
    
    #Create the datasource
    $ReportServer.CreateDataSource($Name,$Path,$Force,$dsDef,$null)
  }
  
}
