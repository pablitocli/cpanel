
Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)
. .\BIN\include\Export-HtmlReport.ps1

$fecha= get-date -format "ddMMyyyy"
# A simple example for the usage of Export-HtmlReport:
#
# A report is generated from a single PowerShell object
###################################SALIDA DE DATOS#####################################

cd inventario
md $fecha
cd $fecha
md host

##VARIABLES!!
$OutputFileName	= "\inventario\$fecha\host\NTP-HOST.html"
$ReportTitle	= "Verificación de Servicio de NTP TIME de la Infraestructura Virtual -  Administración Cloud YPF "
$Propsh = @()
$Resultshost = @()
$x= @()
##CSV DE SALIDA
$outputstore = "\inventario\$fecha\host\NTP-HOST.csv"


###############################################################################################


		foreach ($esx in get-vmhost){
		Write-Host "<<<<<<<<<<<<<"$esx.name" >>>>>>>>>>>>>>>>>>>>>>>>"
		$vmhost= get-vmhost $esx.name
		$ntp= Get-VMHostNtpServer -VMHost $vmhost
		$ntpserver= $ntp -join ", "
		get-vmhost $vmhost | %{$dts = get-view $_.ExtensionData.configManager.DateTimeSystem}
		#get host time
		$time = $dts.QueryDateTime().tolocaltime()
		#calculate time difference in secconds
		$timedife = ( $time - [DateTime]::Now).TotalSeconds
		$diferencia="{0:N2}" -f $timedife
		$Services= $vmhost | get-vmhostservice
		$ntpservices= $services | where {$_.key -eq "ntpd"}
		
		
		################################################################################
		
		$Propsh = @{
					HOST = $vmhost
					HORA_EQUIPO=$time
					DIFERENCIA_TIEMPO= $diferencia
					NTP_SERVER=$ntpserver
					NTP_POLITICA=$ntpservices.policy
					NTP_ESTADO=$ntpservices.running
					}

			
		################################################################################
			$Resultshost += New-Object PSObject -Property $Propsh
			
		}	
		Write-Host "Creacion de archivos con la informacion de los hosts "
		$objetos="HOST","HORA_EQUIPO","DIFERENCIA_TIEMPO","NTP_SERVER","NTP_POLITICA","NTP_ESTADO"
		
		$Resultshost | Select-Object $objetos | Export-Csv $outputstore -NoTypeInformation

		write-host "############# FIN INVENTARIO HOSTS ###################" -foregroundcolor green
		###############################################################################################
		$InputObject = @{Object = $Resultshost | Select-Object $objetos }
		Export-HtmlReport -InputObject $InputObject -ReportTitle $ReportTitle -OutputFile $OutputFileName
		Invoke-Item $OutputFileName
		Pop-Location

