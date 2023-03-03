Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "F:\windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "demo.local"`
-DomainNetbiosName "demo" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "F:\windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "F:\windows\SYSVOL" `
-Force:$true