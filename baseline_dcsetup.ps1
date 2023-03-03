#Set Execution Policy to allow script to run
Set-ExecutionPolicy Bypass -Scope Process -Force 
#Choco install and Choco Apps
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install putty -y
choco install notepadplusplus -y
choco install winscp -y
choco install sysinternals -y
choco install bginfo -y
#Download Scripts to Set the rest of the Domain up when logged in
New-Item -Path "c:\" -Name "BaselabSetup" -ItemType "directory" -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jakewalsh90/Terraform-Azure/main/PowerShell/baselab_DomainSetup.ps1" -OutFile "C:\BaselabSetup\baselab_DomainSetup.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jakewalsh90/Terraform-Azure/main/PowerShell/baselab_LabStructure.ps1" -OutFile "C:\BaselabSetup\baselab_LabStructure.ps1"
#Setup and Partition Data Disk
Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false 
#Allow Ping
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -enabled True
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv6-In)" -enabled True
#Install Roles to make Server a Domain Controller
Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools
Install-windowsfeature -name DNS -IncludeManagementTools


Function Get-RandomPassword
{
    #define parameters
    param([int]$PasswordLength = 10)
 
    #ASCII Character set for Password
    $CharacterSet = @{
            Uppercase   = (97..122) | Get-Random -Count 10 | % {[char]$_}
            Lowercase   = (65..90)  | Get-Random -Count 10 | % {[char]$_}
            Numeric     = (48..57)  | Get-Random -Count 10 | % {[char]$_}
            SpecialChar = (33..47)+(58..64)+(91..96)+(123..126) | Get-Random -Count 10 | % {[char]$_}
    }
 
    #Frame Random Password from given character set
    $StringSet = $CharacterSet.Uppercase + $CharacterSet.Lowercase + $CharacterSet.Numeric + $CharacterSet.SpecialChar
 
    -join(Get-Random -Count $PasswordLength -InputObject $StringSet)
}
 
#Call the function to generate random password of 8 characters
$password = Get-RandomPassword -PasswordLength 8
 

Import-Module ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "F:\windows\NTDS" -DomainMode "WinThreshold" -DomainName "demo.local" -DomainNetbiosName ` "demo" -ForestMode "WinThreshold" -InstallDns:$true -LogPath "F:\windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "F:\windows\SYSVOL" -Force:$true `
-SafeModeAdministratorPassword $password