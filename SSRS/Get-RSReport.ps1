<#
.SYNOPSIS
 Gets a Report Service report object from the web service.
.PARAMETER ReportServer
 The name of the report server, or can be the ReportServer object itself.
 Can be passed in by pipeline.
.PARAMETER Name
 The name of the report to retrieve. Can return multiple results if there are multiple matches.
.PARAMETER Path
 The path under which to search for the report.
.PARAMETER Recursive
 Indicates if a recursive search should be done.
.PARAMETER IncludeDefinition
 Will retrieve the report definition from the server as well

#>
function Get-RSReport
{

  param
  (
    [parameter(mandatory=$true,ValueFromPipeline=$true)][Object]$ReportServer,
    [parameter(mandatory=$false)][String]$Name,
    [parameter(mandatory=$false)][String]$Path = "/",
    [parameter(mandatory=$false)][Switch]$Recursive,
    [parameter(mandatory=$false)][Switch]$IncludeDefinition
  )
  
  Set-StrictMode -Version "Latest";
  
  [Array]$reports = @()
  [String]$ParentPath = ""
  [System.Byte[]]$reportData = $null
  [System.Xml.XmlDocument]$reportXML = $null
  [System.IO.MemoryStream]$memoryStream = $null
  
  
  #Pass the ReportServer object to through the Get-ReportServer function.
  #This is so that even if a string is passed, a ReportServer proxy object will be generated.
  $ReportServer = Get-RSServer -ReportServer $ReportServer;
  
  #Check if the path given is a report. If yes, we just return that.
  $itemType = $ReportServer.GetItemType($Path)
  
  switch ($itemType)
  {
    "Report" {
      #Get the parent folder path
      $pathArray = $Path.Split("/")
      $ParentPath = [String]::Join("/",($pathArray[0..($pathArray.Count - 2)]))
      $Name = $pathArray[($pathArray.Count-1)]
    }
    "Folder" {
      $ParentPath = $Path
    }
  }
  
  #Get the items from the path and filter by type and name (if given)
  $reports = $ReportServer.ListChildren($ParentPath,$Recursive) | 
            Where-Object { (($_.Type -eq "Report") -and (($_.Name -like $Name) -or ($Name -eq [String]::Empty)))} |
            Add-Member -MemberType NoteProperty -Name ReportServer -Value $ReportServer -PassThru;
  
  #Get the report definition if it was asked for
  if ($IncludeDefinition)
  {
    $reports[0..($reports.Count - 1)] | ForEach-Object {
      $reportData = $ReportServer.GetReportDefinition($_.Path)
      $memoryStream = New-Object System.IO.MemoryStream($reportData,$false)
      $reportXML = New-Object System.Xml.XmlDocument 
      $reportXML.Load($memoryStream)
      Add-Member -MemberType NoteProperty -InputObject $_ -Name ReportDefinition -Value $reportXML -PassThru
    }
  }
  else
  {
    Write-Output $reports
  }
  
}