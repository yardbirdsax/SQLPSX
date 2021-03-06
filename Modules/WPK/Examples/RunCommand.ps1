New-Grid -Rows 'Auto', '1*', 'Auto' -Columns '1*', 'Auto' {
    New-TextBox -MinLines 1 -MinWidth 100 -Name Command -On_Loaded {
        Set-Resource "Command" $this -1
    } 
    New-Button "E_xecute" -Column 1 -MaxHeight 30 -On_Click {
        $Command = Get-Resource "Command"
        $output = Get-Resource "Output"
        $status = Get-Resource "Status"
        $timing = Measure-Command { $result = Invoke-Expression -Command $command.Text }
        $output.Content = $result | Out-String -Width 80  
        $status.Content = "Command Ran in $($timing.TotalSeconds) Seconds"
    }
    New-ScrollViewer -Row 1 -ColumnSpan 2 -MinWidth 400 -MaxHeight 400 {
        New-Label -Name Output -MinWidth 400 -FontFamily 'Lucida Console' -On_Loaded {
            Set-Resource "Output" $this -2
        }
    }
    New-Label -Row 2 -ColumnSpan 2 -Name Status -On_Loaded { Set-Resource "Status" $this -1 }
} -show