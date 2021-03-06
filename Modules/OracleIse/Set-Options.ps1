function Set-OracleOptions
{
param()
New-Grid -Columns 3 -Rows 7 -width 600 -height 230 {
      $script:Action = {
        $results = $window | Get-ChildControl |  where { $_.GroupName -eq "Results" -and $_.IsChecked } | foreach { $_.Content }
        $oracle_options.Results = $results
#         $OutputVariable = $window | Get-ChildControl OutputVariable
#         $options.OutputVariable = $OutputVariable.Text
        $window | Get-ChildControl |  where { $_.gettype().Name -eq "CheckBox" } | foreach { $oracle_options.$($_.Content) = $_.IsChecked }
#         $indentationSize = $window | Get-ChildControl IndentationSize
#         $options.IndentationSize = $indentationSize.Text
#         $SqlVersion = $window | Get-ChildControl SqlVersion
#         $options.SqlVersion = $SqlVersion.SelectedItem
#         $KeywordCasing = $window | Get-ChildControl KeywordCasing
#         $options.KeywordCasing = $KeywordCasing.SelectedItem
        $this.Parent.Parent.Tag = $oracle_options
        $window.Close()
    }
    New-Label -Row 1 "Results To:"
    New-RadioButton -Content "To Text" -Row 2 -GroupName Results -HorizontalAlignment Center -IsChecked $("To Text" -eq $oracle_options.Results)
    New-RadioButton -Content "To Grid" -Row 2 -Column 1 -GroupName Results -IsChecked $("To Grid" -eq $oracle_options.Results)
    New-RadioButton -Content "To File" -Row 3 -GroupName Results -HorizontalAlignment Center -IsChecked $("To File" -eq $oracle_options.Results)
    New-RadioButton -Content "To CSV" -Row 3 -Column 1 -GroupName Results -IsChecked $("To CSV" -eq $oracle_options.Results)
    New-RadioButton -Content "To Variable" -Row 2 -Column 3 -GroupName Results -IsChecked $("To Variable" -eq $oracle_options.Results)
    #New-TextBox -Row 3 -Column 3 -Text $options.OutputVariable -Name OutputVariable
        
#     New-StackPanel -Orientation horizontal -Row 4 -HorizontalAlignment Left -ColumnSpan 2 {
#     New-CheckBox -Row 4 -Content "QuotedIdentifierOff" -HorizontalAlignment Left -IsChecked $options.QuotedIdentifierOff
#     }
#         
#     New-StackPanel -Orientation horizontal -Row 5 -HorizontalAlignment Left -ColumnSpan 2 {
#     New-Label -Row 5 "SQL Version:" -VerticalContentAlignment 'Center'
#     New-ComboBox -Row 5 -Column 1 -Name SqlVersion -Width 200 -Height 20 {'Sql100','Sql90','Sql80'} -SelectedItem $options.SqlVersion
#     }
#     
#     New-Separator -Row 6 -ColumnSpan 2
# 
#     New-CheckBox -Row 7 -Content "AlignClauseBodies" -HorizontalAlignment Left -IsChecked $options.AlignClauseBodies
#     New-CheckBox -Row 7 -Column 1 -Content "AlignColumnDefinitionFields"  -HorizontalAlignment Left -IsChecked $options.AlignColumnDefinitionFields
#     New-CheckBox -Row 8 -Content "AlignSetClauseItem" -HorizontalAlignment Left -IsChecked $options.AlignSetClauseItem
#     New-CheckBox -Row 8 -Column 1 -Content "AsKeywordOnOwnLine" -HorizontalAlignment Left -IsChecked $options.AsKeywordOnOwnLine
#     New-CheckBox -Row 9 -Content "IncludeSemicolons" -HorizontalAlignment Left -IsChecked $options.IncludeSemicolons
#         
#     New-StackPanel -Orientation horizontal -Row 10 -HorizontalAlignment Left -ColumnSpan 2 {
#     New-Label -Row 10 "Indentation Size:" -VerticalContentAlignment 'Center'
#     New-TextBox -Row 10 -Column 1 -Name IndentationSize -Width 20 -Height 20 -Text $options.IndentationSize
#     }
#     
#     New-Separator -Row 11 -ColumnSpan 2
#     
#     New-CheckBox -Row 12 -Content "IndentSetClause" -HorizontalAlignment Left -IsChecked $options.IndentSetClause
#     New-CheckBox -Row 12 -Column 1 -Content "IndentViewBody" -IsChecked $options.IndentViewBody
# 
#     New-StackPanel -Orientation horizontal -Row 13 -HorizontalAlignment Left -ColumnSpan 2 {
#     New-Label -Row 13 "Keyword Casing:" -VerticalContentAlignment 'Center'
#     New-ComboBox -Row 13 -Column 1 -Name KeywordCasing -Width 200 -Height 20 {'Uppercase','Lowercase','PascalCase'} -SelectedItem $options.KeywordCasing
#     }
#     
    New-Separator -Row 3 -ColumnSpan 2
#     
#     New-CheckBox -Row 15 -Content "MultilineInsertSourcesList" -HorizontalAlignment Left -IsChecked $options.MultilineInsertSourcesList
#     New-CheckBox -Row 15 -Column 1 -Content "MultilineInsertTargetsList" -IsChecked $options.MultilineInsertTargetsList
#     New-CheckBox -Row 16 -Content "MultilineSelectElementsList" -HorizontalAlignment Left -IsChecked $options.MultilineSelectElementsList
#     New-CheckBox -Row 16 -Column 1 -Content "MultilineSetClauseItems" -IsChecked $options.MultilineSetClauseItems
#     New-CheckBox -Row 17 -Content "MultilineViewColumnsList" -HorizontalAlignment Left -IsChecked $options.MultilineViewColumnsList
#     New-CheckBox -Row 17 -Column 1 -Content "MultilineWherePredicatesList" -IsChecked $options.MultilineWherePredicatesList
#     New-CheckBox -Row 18 -Content "NewLineBeforeCloseParenthesisInMultilineList" -HorizontalAlignment Left -IsChecked $options.NewLineBeforeCloseParenthesisInMultilineList
#     New-CheckBox -Row 18 -Column 1 -Content "NewLineBeforeFromClause" -IsChecked $options.NewLineBeforeFromClause
#     New-CheckBox -Row 19 -Content "NewLineBeforeGroupByClause" -HorizontalAlignment Left -IsChecked $options.NewLineBeforeGroupByClause
#     New-CheckBox -Row 19 -Column 1 -Content "NewLineBeforeHavingClause" -IsChecked $options.NewLineBeforeHavingClause
#     New-CheckBox -Row 20 -Content "NewLineBeforeJoinClause" -HorizontalAlignment Left -IsChecked $options.NewLineBeforeJoinClause
#     New-CheckBox -Row 20 -Column 1 -Content "NewLineBeforeOpenParenthesisInMultilineList" -IsChecked $options.NewLineBeforeOpenParenthesisInMultilineList
#     New-CheckBox -Row 21 -Content "NewLineBeforeOrderByClause" -HorizontalAlignment Left -IsChecked $options.NewLineBeforeOrderByClause
#     New-CheckBox -Row 21 -Column 1 -Content "NewLineBeforeOutputClause" -IsChecked $options.NewLineBeforeOutputClause
#     New-CheckBox -Row 22 -Content "NewLineBeforeWhereClause" -HorizontalAlignment Left -IsChecked $options.NewLineBeforeWhereClause
    New-CheckBox -Row 4 -Column 1 -Content "PoshMode" -IsChecked $oracle_options.PoshMode
    
    New-Separator -Row 5 -ColumnSpan 2
     
    New-StackPanel -Orientation horizontal -Row 6 -Column 1 -HorizontalAlignment Right {
        New-Button -Name OK "OK"   -On_Click $Action -Width 75 -Height 25
        New-Button -Name Cancel "Cancel"   -On_Click {$window.Close()} -Width 75 -Height 25
    }
        
} -show
}
