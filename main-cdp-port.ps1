
Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)
. .\BIN\include\Export-HtmlReport.ps1
$fecha= get-date -format "ddMMyyyy"
$hora= get-date -format "T"
# A simple example for the usage of Export-HtmlReport:
#
# A report is generated from a single PowerShell object
###################################SALIDA DE DATOS#####################################

cd inventario
md $fecha
cd $fecha
md Networking

##VARIABLES!!
$OutputFileName	= "\inventario\$fecha\networking\CDP-HOST.html"
$ReportTitle	= "Verificación de CONEXIONES FISICAS de la Infraestructura Virtual -  WAYCLO @PABLITOCLI"
$Propsh = @()
$Resultshost = @()
$x= @()
##CSV DE SALIDA
$outputstore = "\inventario\$fecha\networking\CDP-HOST.csv"

$vmhosts=  get-vmhost
foreach ($vmhost in $vmhosts){
$vmh = Get-VMHost $VMHost
$v=$vmh | get-view
$serial=$v.Hardware.SystemInfo.OtherIdentifyingInfo | where {$_.IdentifierType.Key -eq "ServiceTag"}
$ci= $serial.IdentifierValue
Write-Host "VERIFICANDO NODO," $vmhost.name
If ($vmh.State -eq "Disconnected") {
  Write-Output "El Host $($vmh) Se encuentra en estado desconectado, Se continua con el proximo."
  }
Else {
  Get-View $vmh.ID | `
  % { $esxname = $_.Name; Get-View $_.ConfigManager.NetworkSystem} | `
  % { foreach ($physnic in $_.NetworkInfo.Pnic) {
    $pnicInfo = $_.QueryNetworkHint($physnic.Device)
    foreach( $hint in $pnicInfo ){
      # Write-Host $esxname $physnic.Device
      if ( $hint.ConnectedSwitchPort ) {
        $nicinfo=$hint.ConnectedSwitchPort
		$vmnic=$physnic.Device
		$swicth= $nicinfo.DevId
		$port= $nicinfo.PortId
		$vsms=$vmh | get-virtualswitch
		foreach ($vsm in $vsms)
		{
		$x=$vsm.nic
		if ($x -eq $null){$vswicht=$vsm.name}
		ELSE {
		$a=$x -contains $vmnic
		}
		if ($a -eq $true){$vswicht=$vsm.name}
		}
		$Propsh = @{
					CI_SF=$ci
					HOST=$esxname
					VMNIC= $vmnic
					SWICHT=$swicth
					PUERTO=$port
					VSWITCH=$vswicht
					}
		$Resultshost += New-Object PSObject -Property $Propsh
					
        }
      else {
        Write-Host "NO HAY INFORMACION DISPONIBLE POR CDP."
        }
      }
    
	}
	
  }
}

}

Write-Host "Creacion de archivos con la informacion de los hosts "
		$objetos="CI_SF","HOST","VMNIC","SWICHT","PUERTO","VSWITCH"
		
		$Resultshost | Select-Object $objetos | Export-Csv $outputstore -NoTypeInformation

		write-host "############# FIN INVENTARIO HOSTS ###################" -foregroundcolor green
		###############################################################################################
		$InputObject = @{Object = $Resultshost | Select-Object $objetos }
		Export-HtmlReport -InputObject $InputObject -ReportTitle $ReportTitle -OutputFile $OutputFileName
		
Pop-Location
		
		