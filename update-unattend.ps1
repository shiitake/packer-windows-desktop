param(
 $userName = "vagrant"
)


# Load XML file
$currentDir = (Get-Location).Path
$baseFile =  Join-Path -Path $currentDir -ChildPath "answer_files\11_hyperv\Autounattend.Base.xml"
$newFile =  Join-Path -Path $currentDir -ChildPath "answer_files\11_hyperv\Autounattend.xml"
[xml]$xmlContent = Get-Content $baseFile

# Get the component with the name 'Microsoft-Windows-Setup'
$windowsPEsettings = $xmlContent.unattend.settings | Where-Object { $_.pass -eq 'windowsPE' }
$setupComponent = $windowsPEsettings.component | Where-Object { $_.name -eq 'Microsoft-Windows-Setup' }

# Check if the component exists and update the FullName
if ($setupComponent -ne $null) {
    $setupComponent.UserData.FullName = $userName
    $setupComponent.UserData.Organization = $userName
} else {
    Write-Host "Component with the name 'Microsoft-Windows-Setup' not found."
}

# Get the component with the name 'Microsoft-Windows-Shell-Setup'
$oobeSystemSettings = $xmlContent.unattend.settings | Where-Object { $_.pass -eq 'oobeSystem' }
$shellSetupComponent = $oobeSystemSettings.component | Where-Object { $_.name -eq 'Microsoft-Windows-Shell-Setup' }
if ($shellSetupComponent -ne $null) {
  $shellSetupComponent.UserAccounts.AdministratorPassword.Value = $userName
  $shellSetupComponent.UserAccounts.AdministratorPassword.PlainText = 'true'
  $shellSetupComponent.UserAccounts.LocalAccounts.LocalAccount.Password.Value= $userName
  $shellSetupComponent.UserAccounts.LocalAccounts.LocalAccount.Password.PlainText = 'true'
  $shellSetupComponent.UserAccounts.LocalAccounts.LocalAccount.Description = "$userName User"
  $shellSetupComponent.UserAccounts.LocalAccounts.LocalAccount.DisplayName = $userName
  $shellSetupComponent.UserAccounts.LocalAccounts.LocalAccount.Group = 'administrators'
  $shellSetupComponent.UserAccounts.LocalAccounts.LocalAccount.Name = $userName
  $shellSetupComponent.AutoLogon.Password.Value = $userName
  $shellSetupComponent.AutoLogon.Password.PlainText = 'true'
  $shellSetupComponent.AutoLogon.Username = $userName
  $shellSetupComponent.AutoLogon.Enabled = 'true'

  # Update logon commands
  $disablePWExprCmd = $shellSetupComponent.FirstLogonCommands.SynchronousCommand | Where-Object { $_.Description -eq 'Disable password expiration for user' }
  $commandText = 'cmd.exe /c wmic useraccount where "name=''{0}''" set PasswordExpires=FALSE' -f $userName
  $disablePWExprCmd.CommandLine = $commandText

  $setDefaultPwCmd = $shellSetupComponent.FirstLogonCommands.SynchronousCommand | Where-Object { $_.Description -eq 'Set Default Password' }
  $commandText = '%SystemRoot%\System32\reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "{0}" /f' -f $userName
  $setDefaultPwCmd.CommandLine = $commandText

}
else {
  Write-Host "Component with the name 'Microsoft-Windows-Shell-Setup' not found."

}

# Save the modified XML back to the file
$xmlContent.Save($newFile)

