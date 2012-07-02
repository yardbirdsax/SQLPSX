<#
.SYNOPSIS
 Gets a Report Service report object from the web service.
.PARAMETER ReportServer
 The name of the report server, or can be the ReportServer object itself.
 Can be passed in by pipeline.
.PARAMETER Name
 The name of the report to export (used in determining the file name). 
 Can return multiple results if there are multiple matches.
.PARAMETER Path
 The path to export the report to.
#>
function Export-RSReport
{

  param
  (
    [parameter(mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String]$Name,
    [parameter(mandatory=$true)]
    [String]$Path,
    [parameter(mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [System.XML.XMLDocument]$ReportDefinition
  )
  
  Set-StrictMode -Version "Latest";
  
  $filePath = ""
  
  
  if (-not (Test-Path $Path))  
  {
    Write-Warning "Path '$Path' not found. Exiting."
    break
  }
  
  $filePath = Join-Path $Path "$Name.rdl"
  
  $ReportDefinition.Save($filePath)
  
}