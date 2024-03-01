

$C= Read-Host "IP VCENTER:"
$cred= get-credential

$connect = Connect-VIServer $C -credential $cred -force}


write-host "! COMPILADO DE SCRIPS DE POWERCLI PARA INFRAESTRUCTURA VMWARE VSPHERE - WAYCLO !" -foregroundcolor "YELLOW"
write-host "! CONECTANDO VCENTER SERVER !" -foregroundcolor "yellow"