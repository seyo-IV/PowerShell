#Start-Process powershell.exe -ArgumentList "Remove-Item C:\temp\Security-Tool -Recurse -Force" -wait

Remove-Item -Path C:\Users\Public\Desktop\Security-Tool.lnk
$parentPath = (get-item $PSScriptRoot).parent.parent.FullName
Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-noprofile -command &{Start-Process powershell.exe -ArgumentList 'Remove-Item $parentPath\Security-Tool -Recurse -Force'}" -WorkingDirectory $env:windir -PassThru -Wait
