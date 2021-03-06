#Specify the name of the PC or the list of PCs, separated by commas
$Computers = "Name PC"
Invoke-Command -ComputerName $Computers -Scriptblock {

#Standard preliminary step - Uninstall Client Config Manager
 cmd.exe /c "C:\Windows\ccmsetup\ccmsetup.exe /uninstall"
 Start-Sleep -Seconds 120; 

 # Stop Services 
 Stop-Service -Name ccmsetup -Force -ErrorAction SilentlyContinue 
 Stop-Service -Name CcmExec -Force -ErrorAction SilentlyContinue
 Stop-Service -Name smstsmgr -Force -ErrorAction SilentlyContinue
 Stop-Service -Name CmRcService -Force -ErrorAction SilentlyContinue
 # Remove WMI Namespaces 
 Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='ccm'" -Namespace root | Remove-WmiObject 
 Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='sms'" -Namespace root\cimv2 | Remove-WmiObject 
 # Remove Services from Registry 
 $MyPath = "HKLM:\SYSTEM\CurrentControlSet\Services" 
 Remove-Item -Path $MyPath\CCMSetup -Force -Recurse -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\CcmExec -Force -Recurse -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\smstsmgr -Force -Recurse -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\CmRcService -Force -Recurse -ErrorAction SilentlyContinue 
 # Remove SCCM Client from Registry 
 $MyPath = "HKLM:\SOFTWARE\Microsoft" 
 Remove-Item -Path $MyPath\CCM -Force -Recurse -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\CCMSetup -Force -Recurse -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\SMS -Force -Recurse -ErrorAction SilentlyContinue 
 # Remove Folders and Files from (C:\Windows\..)
 $MyPath = $env:WinDir 
 Remove-Item -Path $MyPath\CCM -Force -Recurse -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\ccmsetup -Force -Recurse -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\ccmcache -Force -Recurse -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\SMSCFG.ini -Force -ErrorAction SilentlyContinue 
 Remove-Item -Path $MyPath\SMS*.mif -Force -ErrorAction SilentlyContinue
 # Remove Certificates (or mmc - SMS - 2 pieces)
 Remove-Item -path HKLM:\SOFTWARE\Microsoft\SystemCertificates\SMS\* -Recurse

#reboot
shutdown -r -t 160
}
