<#
.SYNOPSIS
 Gets a Report Service folder object from the web service.
.PARAMETER ReportServer
 The name of the report server, or can be the ReportServer object itself.
 Can be passed in by pipeline.
.PARAMETER Name
 The name of the folder to retrieve. Can return multiple results if there are multiple matches.
.PARAMETER Path
 The path under which to search for the folder.
.PARAMETER Recursive
 Indicates if a recursive search should be done.

#>
function Get-RSFolder
{

  param
  (
    [parameter(mandatory=$true,ValueFromPipeline=$true)][Object]$ReportServer,
    [parameter(mandatory=$false)][String]$Name,
    [parameter(mandatory=$false)][String]$Path = "/",
    [parameter(mandatory=$false)][Switch]$Recursive
  )
  
  Set-StrictMode -Version "Latest";
  
  #Pass the ReportServer object to through the Get-ReportServer function.
  #This is so that even if a string is passed, a ReportServer proxy object will be generated.
  $ReportServer = Get-ReportServer -ReportServer $ReportServer;
  
  #Get the items from the path and filter by type and name (if given)
  $folder = $ReportServer.ListChildren($Path,$Recursive) | 
            Where-Object { (($_.Type -eq "Folder") -and (($_.Name -like $Name) -or ($Name -eq [String]::Empty)))} |
            Add-Member -MemberType NoteProperty -Name ReportServer -Value $ReportServer -PassThru;
  
  return $folder;
}