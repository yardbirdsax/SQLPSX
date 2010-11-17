$mInfo = $MyInvocation.MyCommand.ScriptBlock.Module
$mInfo.OnRemove = {
     if ($Script:conn.state -eq 'open')
     {
        Write-Host -BackgroundColor Black -ForegroundColor Yellow "Connection $($Script:conn.database) closed"
        $Script:conn.Close()
     }
    
    Write-Host -BackgroundColor Black -ForegroundColor Yellow "$($MyInvocation.MyCommand.ScriptBlock.Module.name) removed on $(Get-Date)"
    Remove-IseMenu SQLIse
}

import-module ISECreamBasic
import-module SQLParser
import-module adolib
import-module WPK

. $psScriptRoot\Get-ConnectionInfo.ps1
. $psScriptRoot\Set-Options.ps1
. $psScriptRoot\Switch-CommentOrText.ps1
. $psScriptRoot\Switch-SelectedCommentOrText.ps1
. $psScriptRoot\Show-TableBrowser.ps1
. $psScriptRoot\Get-DbObjectList.ps1
. $psScriptRoot\Show-DbObjectList.ps1
. $psScriptRoot\Show-ConnectionManager.ps1
. $psScriptRoot\Get-TabObjectList.ps1
. $psScriptRoot\Invoke-Coalesce.ps1
. $psScriptRoot\Get-TableAlias.ps1
. $psScriptRoot\TabExpansion.ps1
. $psScriptRoot\ConvertTo-StringData.ps1
. $psScriptRoot\Library-UserStore.ps1
. $psScriptRoot\ConvertFrom-Xml.ps1

Set-Alias Expand-String $psScriptRoot\Expand-String.ps1

$env:SQLPsx_QueryOutputformat = "auto"              

$Script:conn=new-object System.Data.SqlClient.SQLConnection

#Load saved options into hashtable
Initialize-UserStore  -fileName "options.txt" -dirName "SQLIse" -defaultFile "$psScriptRoot\defaultopts.ps1"
$options = Read-UserStore -fileName "options.txt" -dirName "SQLIse" -typeName "Hashtable"

$Script:DatabaseList = New-Object System.Collections.ArrayList

$bitmap = new-object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.UriSource = "$psScriptRoot\SQLPSX.PNG"
$bitmap.EndInit()

#######################
function Invoke-ParseSql
{
    param()
    if (-not $psise.CurrentFile)
    {
        Write-Error 'You must have an open script file'
        return
    }
    
    $selectedRunspace = $psise.CurrentFile
    $selectedEditor=$selectedRunspace.Editor

    if (-not $selectedEditor.SelectedText)
    {
        $inputScript = $selectedEditor.Text
    }
    else
    {
        $inputScript = $selectedEditor.SelectedText
    }
    Test-SqlScript -InputScript $inputScript -QuotedIdentifierOff:$($options.QuotedIdentifierOff) -SqlVersion:$($options.SqlVersion)
 
} #Invoke-ParseSql

#######################
function Format-Sql
{
    param()
    if (-not $psise.CurrentFile)
    {
        Write-Error 'You must have an open script file'
        return
    }
    
    $selectedRunspace = $psise.CurrentFile
    $selectedEditor=$selectedRunspace.Editor

    if (-not $selectedEditor.SelectedText)
    {
        $inputScript = $selectedEditor.Text
        $outputScript = Out-SqlScript -InputScript $inputScript -QuotedIdentifierOff:$($options.QuotedIdentifierOff) -SqlVersion:$($options.SqlVersion) -AlignClauseBodies:$($options.AlignClauseBodies) `
        -AlignColumnDefinitionFields:$($options.AlignColumnDefinitionFields) -AlignSetClauseItem:$($options.AlignSetClauseItem) -AsKeywordOnOwnLine:$($options.AsKeywordOnOwnLine) `
        -IncludeSemicolons:$($options.IncludeSemicolons) -IndentationSize:$($options.IndentationSize) -IndentSetClause:$($options.IndentSetClause) -IndentViewBody:$($options.IndentViewBody) `
        -KeywordCasing:$($options.KeywordCasing) -MultilineInsertSourcesList:$($options.MultilineInsertSourcesList) -MultilineInsertTargetsList:$($options.MultilineInsertTargetsList) `
        -MultilineSelectElementsList:$($options.MultilineSelectElementsList) -MultilineSetClauseItems:$($options.MultilineSetClauseItems) -MultilineViewColumnsList:$($options.MultilineViewColumnsList) `
        -MultilineWherePredicatesList:$($options.MultilineWherePredicatesList) -NewLineBeforeCloseParenthesisInMultilineList:$($options.NewLineBeforeCloseParenthesisInMultilineList) `
        -NewLineBeforeFromClause:$($options.NewLineBeforeFromClause) -NewLineBeforeGroupByClause:$($options.NewLineBeforeGroupByClause) -NewLineBeforeHavingClause:$($options.NewLineBeforeHavingClause) `
        -NewLineBeforeJoinClause:$($options.NewLineBeforeJoinClause) -NewLineBeforeOpenParenthesisInMultilineList:$($options.NewLineBeforeOpenParenthesisInMultilineList) `
        -NewLineBeforeOrderByClause:$($options.NewLineBeforeOrderByClause) -NewLineBeforeOutputClause:$($options.NewLineBeforeOutputClause) -NewLineBeforeWhereClause:$($options.NewLineBeforeWhereClause)

        if ($outputScript)
        { $selectedEditor.Text = $outputScript }
    }
    else
    {
        $inputScript = $selectedEditor.SelectedText
        $outputScript = Out-SqlScript -InputScript $inputScript -QuotedIdentifierOff:$($options.QuotedIdentifierOff) -SqlVersion:$($options.SqlVersion) -AlignClauseBodies:$($options.AlignClauseBodies) `
        -AlignColumnDefinitionFields:$($options.AlignColumnDefinitionFields) -AlignSetClauseItem:$($options.AlignSetClauseItem) -AsKeywordOnOwnLine:$($options.AsKeywordOnOwnLine) `
        -IncludeSemicolons:$($options.IncludeSemicolons) -IndentationSize:$($options.IndentationSize) -IndentSetClause:$($options.IndentSetClause) -IndentViewBody:$($options.IndentViewBody) `
        -KeywordCasing:$($options.KeywordCasing) -MultilineInsertSourcesList:$($options.MultilineInsertSourcesList) -MultilineInsertTargetsList:$($options.MultilineInsertTargetsList) `
        -MultilineSelectElementsList:$($options.MultilineSelectElementsList) -MultilineSetClauseItems:$($options.MultilineSetClauseItems) -MultilineViewColumnsList:$($options.MultilineViewColumnsList) `
        -MultilineWherePredicatesList:$($options.MultilineWherePredicatesList) -NewLineBeforeCloseParenthesisInMultilineList:$($options.NewLineBeforeCloseParenthesisInMultilineList) `
        -NewLineBeforeFromClause:$($options.NewLineBeforeFromClause) -NewLineBeforeGroupByClause:$($options.NewLineBeforeGroupByClause) -NewLineBeforeHavingClause:$($options.NewLineBeforeHavingClause) `
        -NewLineBeforeJoinClause:$($options.NewLineBeforeJoinClause) -NewLineBeforeOpenParenthesisInMultilineList:$($options.NewLineBeforeOpenParenthesisInMultilineList) `
        -NewLineBeforeOrderByClause:$($options.NewLineBeforeOrderByClause) -NewLineBeforeOutputClause:$($options.NewLineBeforeOutputClause) -NewLineBeforeWhereClause:$($options.NewLineBeforeWhereClause)

        if ($outputScript)
        { $selectedEditor.InsertText($outputScript) }
    }
 
} #Format-Sql

#######################
function Connect-Sql
{
    param(
        $database,
        $server,
        $user,
        $password
    )
    if ($database)
    {
        if (!$server)
        {
            $server = 'localhost'
        }
    }
    else
    {
        $script:connInfo = Get-ConnectionInfo $bitmap
        if ($connInfo)
        { 
            $database = $connInfo.Database
            $server = $connInfo.Server
            $user = $connInfo.UserName
            $password = $connInfo.Password
        }
    }
    # Write-host "database $database"
    # Write-host "server $server"
     
    if ($database)
    { 
        $Script:conn = new-connection -server $server -database $database -user $user -password $password
        $handler    = [System.Data.SqlClient.SqlInfoMessageEventHandler] {
            if ($filePath  -ne $null)
            {
                $_.Message | Out-File -FilePath $filePath -append
            }
                else
            {
                Write-Host $_
                #Write-Host $error[0].InnerException
            }
        }
        $Script:conn.add_InfoMessage($handler)
        if ($Script:conn.State -eq 'Open')
        { 
            invoke-query -sql:'sp_databases' -connection:$Script:conn | foreach { [void]$Script:DatabaseList.Add($_.DATABASE_NAME) } 
            Get-TabObjectList
        }
    }
    
} #Connect-Sql

#######################
function Disconnect-Sql
{
    param()

    $Script:conn.Close()
    $Script:DatabaseList.Clear()

} #Disconnect-Sql

#######################
function USE-ReopenSql
{
    param()
    if (!! $Script:conn.ConnectionString )
    {
        $Script:conn.Open()
        if ($Script:conn.State -eq 'Open')
        { 
            invoke-query -sql:'sp_databases' -connection:$Script:conn | foreach { [void]$Script:DatabaseList.Add($_.DATABASE_NAME) } 
            Get-TabObjectList
        }
    }
} #USE-ReopenSql
#######################
function Prompt
{
    param()
    $basePrompt = $(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + 'PS ' + $(Get-Location)
    $sqlPrompt = ' #[SQL]' + $(if ($Script:conn.State -eq 'Open') { $($Script:conn.DataSource) + '.' + $($Script:conn.Database) } else { '---'})
    $oraclePrompt = ' #[Oracle]' + $(if ($oracle_conn.State -eq 'Open') { $($oracle_conn.DataSource) } else { '---'})
    $basePrompt + $sqlPrompt + $oraclePrompt +$(if ($nestedpromptlevel -ge 1) { ' >>' }) + ' > '

} #Prompt

#######################
function Get-FileName
{
    param($ext,$extDescription)
    $sfd = New-SaveFileDialog -AddExtension -DefaultExt "$ext" -Filter "$extDescription (.$ext)|*.$ext|All files(*.*)|*.*" -Title "Save Results" -InitialDirectory $pwd.path
    [void]$sfd.ShowDialog()
    return $sfd.FileName

} #Get-FileName

#######################
function Invoke-ExecuteSql
{
    param(
        $inputScript,
        $displaymode = $null,
        $OutputVariable = $null
        )
    
    if ($inputScript -eq $null)
    {
        if (-not $psise.CurrentFile)
        {
            Write-Error 'You must have an open script file'
            return
        }
        
        if ($conn.State -eq 'Closed')
        { Connect-Sql }
        
        $selectedRunspace = $psise.CurrentFile
        $selectedEditor=$selectedRunspace.Editor

        if ($selectedEditor.SelectedText)
        {
            $inputScript = $selectedEditor.SelectedText
            $hasSelection = $True
        }
        else
        {
            $inputScript = $selectedEditor.Text 
            $hasSelection = $False
        }
    }
    
    if ( $displaymode -eq $null)
    {
        if ($env:SQLPsx_QueryOutputformat)
        {
            $displaymode = $env:SQLPsx_QueryOutputformat
        }
        else
        {
            # this is the fallback to the released version
            switch ($options.Results)
            {
                'To Grid' { $displaymode ='grid'}
                'To Text' { $displaymode ='auto'}
                'To File' { $displaymode ='file'}
                'To CSV'  { $displaymode = 'csv'}
                'To Variable' { $displaymode ='variable'}
            }
        }
    }
    $displaymode_x = $displaymode
    if (('isetab', 'inline') -contains $displaymode_x ) { $displaymode_x = 'wide' }
    
    # determine insertposition for inline mode
    if ( $displaymode -eq 'inline')
    {
        if ($hasselection)
        {
            $selectedEditor.InsertText('')
            $selectedEditor.InsertText($inputScript)
            $EndLine =  $selectedEditor.CaretLine
            $EndColumn = $selectedEditor.CaretColumn
        }
        else
        {
            $EndLine =  $selectedEditor.LineCount 
            $EndColumn = $selectedEditor.GetLineLength($EndLine) + 1
        }
        #"EndLine   $EndLine"
        #"EndColumn $EndColumn"
        $LineCount  = $selectedEditor.LineCount
        if (  $EndLine -lt  $LineCount)
        {
            if ($EndColumn -eq 1)
            {        
                $selectedEditor.SetCaretPosition($EndLine, 1)
            }
            else
            {
                $selectedEditor.SetCaretPosition(($EndLine + 1), 1)
            }
        }
        else
        {
            if ($EndColumn -ne 1)
            {
                $EndColumn =  $selectedEditor.GetLineLength($LineCount) + 1
                $selectedEditor.SetCaretPosition($EndLine, $EndColumn)
                $selectedEditor.InsertText("`r`n")
            }
            else
            {
                $selectedEditor.SetCaretPosition($EndLine, $EndColumn)
            }
        }
        
    }

        
    # fix CR not followed by NL and NL not preceded by CR
    $inputScript = $inputScript  -replace  "`r(?!`n)","`r`n" -replace "`(?<!`r)`n", "`r`n"
     
    $blocks = $inputScript -split  "\r?\n[ \t]*go[ \t]*(?=\r?\n)"
    $blocknr = 0
    $linenr = 1
    $sql_errors = @()
    $filePath = $null
    foreach ($inputScript in $blocks)
    { 
        $linecount = ($inputScript -split [System.Environment]::NewLine).count
        #$linecount = ($inputScript -split "\r?\n").count
        $begline = $linenr
        $endline = $linenr + $linecount -1 
        if ($blocknr++ -ge 1)
        {        
            $begline = $linenr + 1
#             #"----------------------------"
#             #$inputScript
            if ($filePath -eq $null)
            {
                Write-Host "---------- Blocknr: $blocknr ---  Line: $begline - $endline ---------- $linecount"
            }
        }
        $linenr += $linecount #+ 1

    if ($options.PoshMode)
    {
        Invoke-PoshCode $inputScript
        $inputScript = Remove-PoshCode $inputScript
        $inputScript = Expand-String $inputScript
    }

    if ($inputScript -and $inputScript -ne "")
    {
        
         try {
            $res = invoke-query -sql $inputScript -connection $Script:conn
         }
         catch {
            $e = $_
            $error_msg = "Blocknr $blocknr $begline $endline $e"
            $sql_errors += $error_msg
            Write-Host $e -ForegroundColor Red -BackgroundColor White
            $res = $null
         }   
         
         
        switch($displaymode_x)
        {
            'grid' {
                     if ($res.Tables)
                     {
                        Write-host 'multi'
                        $res.tables | %{ $_ |  Out-GridView -Title $psise.CurrentFile.DisplayName}
                     }
                     elseif ($res -ne $null)
                     {
                      $res |  Out-GridView -Title $psise.CurrentFile.DisplayName
                     }
                   }
            'auto'  {    
                         if ($res.Tables)
                         {
                            Write-host 'multiple resultsets'
                            $res.tables | %{
                                $_ | %{
                                 if ($_.gettype().Name -eq 'DataRow' )
                                 {  # "this result has one row "
                                    if ($_.itemarray.count -eq 1)
                                    {   # "result: 1 row / 1 column"
                                        $columnname = $_.Table.Columns[0].ColumnName
                                        $columnname
                                        '-' * ($columnname.length)
                                        $_.item(0)
                                        ''
                                    }
                                    else
                                    {   # result: 1 row / multiple columns
                                        $_ | fl
                                    }
                                 }
                                 else
                                 {  #"-- other"
                                    $_ 
                                 }
                               }  
                             }
                         }
                         elseif ($res.gettype().Name -eq 'DataRow' )
                         {
                            # result has one row
                            if ($res.itemarray.count -eq 1)
                            {   # result: 1 row / 1 column -- display is perfect
                                $columnname = $res.Table.Columns[0].ColumnName
                                $columnname
                                '-' * ($columnname.length)
                                $res.item(0)
                                ''
                            }
                            else
                            {   # result: 1 row / multiple columns -- This is complete and nice too
                                $res | fl
                            }
                         }
                         else
                         {
                            $res
                         }
                   }
            'table' {
                     if ($res.Tables)
                     {
                            Write-host 'multi'
                        $res.tables | %{ $_ | ft -auto }
                     }
                     else
                     {
                      $res | ft -auto
                     }
                   }
            'list' {
                     if ($res.Tables)
                     {
                            Write-host 'multi'
                        $res.tables | %{ $_ | fl }
                     }
                     else
                     {
                      $res | fl
                     }
                   }
            
            'file' {
                        if ($filePath -eq $null)
                        {
                            $filePath = Get-FileName 'txt' 'Text'
                            '' |  Out-File -FilePath $filePath -Force
                        }
                        if ($filePath)
                        {
                            if ($res.Tables)
                            {
                                $res.tables | %{ $_ | Out-File -FilePath $filePath -append }
                            }
                            else
                            {
                                $res | Out-File -FilePath $filePath -append
                            }
                        }
                      }
            'csv' {
                      $filePath = Get-FileName 'csv' 'CSV'
                      if ($filePath)
                      # what todo with multi resultset 
                      {$res | Export-Csv -Path $filepath -NoTypeInformation -Force
                       Write-Host ""}
                     }
            'variable' {
                        if (! $OutputVariable)
                        {
                            $OutputVariable = Read-Host 'Variable (no "$" needed)'
                        }
                        Set-Variable -Name $OutputVariable -Value $res -Scope Global
                    }
            'wide'   {  # combined code for inline and isetab
                        $text = ''                        
                         if ($res.Tables)
                         {
                            # 'multiple resultsets'
                            $res.tables | %{
                                #$_.gettype()
                                $col_cnt = $_.columns.count
                                $row_cnt = $_.rows.count
                                $columns = ''
                                $col1name = $_.Columns[0].ColumnName
                                foreach ($i in 0.. ($col_cnt - 1))
                                {
                                    if ($columns) { $columns +=  ', '+ $_.Columns[$i].ColumnName }
                                    else { $columns = $_.Columns[$i].ColumnName}
                                }
                                if ($row_cnt -gt 1)
                                {   "# result has multiple rows -- use ft"
                                    # http://poshoholic.com/2010/11/11/powershell-quick-tip-creating-wide-tables-with-powershell/
                                    $c = '($_ | ft -Property ' + $columns + ' -auto | Out-string -width 10000 -stream ) -replace " *$", ""-replace "\.\.\.$", "" -join "`r`n" '
                                    $text += Invoke-expression $c
                                }
                                else
                                {
                                    $_ | %{
                                        if ( $row_cnt -eq 1 )
                                        {   
                                            if ($col_cnt -eq 1)
                                            {   # result: 1 row / 1 column -- add column header
                                                $text += "`r`n" + $col1name
                                                $text += "`r`n" + ('-' * ($col1name.length))
                                                $text += "`r`n" + $_.item(0)
                                            }
                                            else
                                            {   "# result: 1 row / multiple columns -- use fl"
                                                $text += ($_ | fl| Out-string -width 10000)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else     
                        {   # single resultset
                            if (! $res)
                            {   # Print and similar actions
                            }
                            elseif ($res.gettype().Name -eq 'DataRow' )
                            {   # result has one row
                                if ($res.itemarray.count -eq 1)
                                {   # result: 1 row / 1 column -- add column header
                                    $col1name = $res.Table.Columns.item(0).columnName
                                    $text += "`r`n" +$col1name
                                    $text += "`r`n" +('-' * ($col1name.length))
                                    $text += "`r`n" +$res.item(0)
                                }
                                else
                                {   # result: 1 row / multiple columns -- use fl
                                    $text += ($res | fl| Out-string -width 10000)
                                }
                            }
                            else
                            {   # result has multiple rows -- use ft
                                $columns = ''
                                foreach ($i in 0.. ($res[0].Table.columns.count -1))
                                {
                                    if ($columns) { $columns +=  ', '+ $res[0].Table.Columns[$i].ColumnName }
                                    else { $columns = $res[0].Table.Columns[$i].ColumnName}
                                }
                                $c = '($res | ft -Property ' + $columns + ' -auto | Out-string -width 10000 -stream ) -replace " *$", ""-replace "\.\.\.$", "" -join "`r`n" '
                                $text += Invoke-expression $c
                            }
                        }    
                        # ---------------------------------------------------------------------------------
                        
                        if (  $displaymode -eq 'inline')
                        {
                            $selectedEditor.InsertText($text)
                        }
                        else
                        { # isetab
                             $count = $psise.CurrentPowerShellTab.Files.count
                             $psIse.CurrentPowerShellTab.Files.Add()
                             $Newfile = $psIse.CurrentPowerShellTab.Files[$count]
                             $Newfile.Editor.Text = $text
                        }
                    }        
        }
    }
#         if ($blocknr++ -ge 0)
#         {        
#             #"----------------------------"
#             #$inputScript
#             Write-Host "---------- Blocknr: $blocknr ---  Line: $begline - $endline ---------- $linecount"
#         }
    }
    $sql_errors
        
} #Invoke-ExecuteSql

#######################
function Write-Options
{
    param()
    Write-UserStore -fileName "options.txt" -dirName "SQLIse" -object $options

} #Write-Options

#######################
function Switch-Database
{
    param()

    $Action = {
        $this.Parent.Tag = $this.SelectedItem
        $window.Close() }
                
    $database = New-ComboBox -Name Database -Width 200 -Height 20 {$DatabaseList} -SelectedItem $conn.Database -On_SelectionChanged $Action -Show

    if ($database)
    { 
        $Script:conn.ChangeDatabase($database) 
        $connInfo.Database = $database
        Get-TabObjectList
    } 

} #Switch-Database

#######################
function Edit-Uppercase
{
    param()
    if (-not $psise.CurrentFile)
    {
        Write-Error 'You must have an open script file'
        return
    }
    
    $selectedRunspace = $psise.CurrentFile
    $selectedEditor=$selectedRunspace.Editor

    if (-not $selectedEditor.SelectedText)
    {
        $output = $($selectedEditor.Text).ToUpper()
        if ($output)
        { $selectedEditor.Text = $output }

    }
    else
    {
        $output = $($selectedEditor.SelectedText).ToUpper()
        if ($output)
        { $selectedEditor.InsertText($output) }

    }

} #Edit-Uppercase

#######################
function Edit-Lowercase
{
    param()
    if (-not $psise.CurrentFile)
    {
        Write-Error 'You must have an open script file'
        return
    }
    
    $selectedRunspace = $psise.CurrentFile
    $selectedEditor=$selectedRunspace.Editor

    if (-not $selectedEditor.SelectedText)
    {
        $output = $($selectedEditor.Text).ToLower()
        if ($output)
        { $selectedEditor.Text = $output }

    }
    else
    {
        $output = $($selectedEditor.SelectedText).ToLower()
        if ($output)
        { $selectedEditor.InsertText($output) }

    }

} #Edit-Lowercase

#######################
function Set-PoshVariable
{
    param($name,$value)

    Set-Variable -Name $name -Value $value -Scope Global

} #Set-PoshVariable

#######################
function Invoke-PoshCode
{
    param($text)

    foreach ( $line in $text -split [System.Environment]::NewLine )
    {
        if ( $line.length -gt 0) {
            if ( $line -match "^\s*!!" ) {
                $line = $line -replace "^\s*!!", ""
                invoke-expression $line
            }
        }
    }

} #Invoke-PoshCode

#######################
function Remove-PoshCode
{
    param($text)

    $returnedText = ""
    foreach ( $line in $text -split [System.Environment]::NewLine )
    {
        if ( $line.length -gt 0) {
            if ( $line -notmatch "^\s*!!" ) {
                $returnText += "{0}{1}" -f $line,[System.Environment]::NewLine
            }
        }
    }
    $returnText

} #Remove-PoshCode

#######################
Add-IseMenu -name SQLIse @{
    "Parse" = {Invoke-ParseSql} | Add-Member NoteProperty ShortcutKey "CTRL+SHIFT+F5" -PassThru
    "Format" = {Format-Sql} | Add-Member NoteProperty ShortcutKey "CTRL+ 4" -PassThru
    "Connection" =@{
                    "Connect..." = {Connect-Sql}
                    "Reconnect"  = {USE-ReopenSql}
                    "Disconnect" = {Disconnect-Sql}
    }
    "Execute" = {Invoke-ExecuteSql} | Add-Member NoteProperty ShortcutKey "CTRL+ALT+F5" -PassThru
    "Change Database..." = {Switch-Database}
    "Options..." = {Set-Options; Write-Options}
    "Edit" =@{
                    "Make Uppercase         CTRL+SHIFT+U" = {Edit-Uppercase}
                    "Make Lowercase         CTRL+U" = {Edit-Lowercase}
                    "Toggle Comments" = {Switch-SelectedCommentOrText} | Add-Member NoteProperty ShortcutKey "CTRL+ALT+K" -PassThru
            }
    "Table Browser" = {Show-TableBrowser -resource @{conn = $conn} | Out-Null}
    "Object Browser" = {Show-DbObjectList -ds (Get-DbObjectList)}
    "Manage Connections" = { Show-ConnectionManager }
	"Tab Expansion" = @{
                        "Refresh Alias Cache" = {Get-TableAlias} | Add-Member NoteProperty ShortcutKey "CTRL+ALT+T" -PassThru
                        "Refresh Object Cache" = {Get-TabObjectList} | Add-Member NoteProperty ShortcutKey "CTRL+ALT+R" -PassThru
                       }
     "Output Format" = {Set-Outputformat}
} # -module SQLIse

New-Alias -name setvar -value Set-PoshVariable -Description "SqlIse Alias"
Export-ModuleMember -function * -Variable options, bitmap, conn, DatabaseList, SavedConnections, dsDbObjects -alias setvar
