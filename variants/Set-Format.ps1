ipmo WPK            
            
$env:WPKResult = "auto"              
New-StackPanel {            
    New-RadioButton -Content "auto"  -GroupName Results -IsChecked $True -On_Click { $env:WPKResult = "auto" }            
    New-RadioButton -Content "list"  -GroupName Results -On_Click { $env:WPKResult = "list" }            
    New-RadioButton -Content "table" -GroupName Results -On_Click { $env:WPKResult = "table" }            
} -asjob            
            
