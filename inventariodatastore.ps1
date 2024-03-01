#add-pssnapin VMware.VimAutomation.Core
#Requires -Version 2.0
Set-StrictMode -Version Latest

Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)
. .\BIN\include\Export-HtmlReport.ps1

$fecha= get-date -format "ddMMyyyy"

write-host "###############################################################" -foregroundcolor BLUE

cd inventario
md $fecha
cd $fecha
md datastores

##VARIABLES!!
$OutputFileName	= "\inventario\$fecha\datastores\datastore-ESXI.html"
$ReportTitle	= "Inventario de los Datastores de la Infraestructura Virtual -  WAYCLO"
$Propsd  = @()
$Resultsstore = @()
##CSV DE SALIDA
$outputstore = "\inventario\$fecha\datastores\datastore-ESXI.csv"
$ls=""

###############################################################################################
write-host "############# INVENTARIO DATASTORE ###################" -foregroundcolor green
$dcenters= 	get-datacenter


	foreach ($dcenter in $dcenters){
	
	$dstores= get-datacenter $dcenter | get-datastore 
	foreach ($dstore in $dstores)
		{
		$store= get-datastore $dstore
		$freegb= $store.freespacegb
		$capacitygb= $store.capacitygb
	    if ($capacitygb -gt 0) {
		$usedgb= $store.capacitygb - $store.freespacegb
		$version= $store.type
		$ver_vmfs=$store.extensiondata.info.vmfs.majorversion
		$vmfs=$version + $ver_vmfs
		$sioc=$store.StorageIOControlEnabled
		$freeporcentaje= ($store.FreeSpaceGB * 100)/$store.CapacityGB
		$datastore= $store | get-View -Property Name,Info
        $lunid = $Datastore.Info.Vmfs.Extent | select diskname
        $psps=$store | Get-ScsiLun | Select VMHost,MultipathPolicy 
		foreach ($l in $lunid){$ls += $l.diskname + "/"}
		foreach ($p in $psps){
		$hp=$p.vmhost.name
		$mp=$p.MultipathPolicy
				
		$Propsd = @{
			DATACENTER= $dcenter.name
			Datastore = $dstore.name
			Version=$vmfs
			Espacio_Usado="{0:f2}" -f $usedgb
			Espacio_Libre="{0:f2}" -f $freegb
			Espacio_Total="{0:f2}" -f $capacitygb
			Porcentaje_Libre= "{0:f2}" -f $freeporcentaje + "%"
			Estado=$store.extensiondata.overallstatus
			VMHOST=$hp
            PSP=$mp
            SIOC=$sioc
			LUNID=$ls
			}
			write-host "############# GUARDANDO INVENTARIO DATASTORE "$Dstore.NaME" ###################" -foregroundcolor green
				$Resultsstore += New-Object PSObject -Property $Propsd
				$ls=""
            }
		}
		}
		}



write-host "############# FIN INVENTARIO DATASTORE ###################" -foregroundcolor green
$objetos="DATACENTER","DATASTORE","VERSION","Estado","Porcentaje_Libre","Espacio_Total","Espacio_Usado","Espacio_Libre","SIOC","LUNID","VMHOST","PSP"


Write-Host "Creacion de archivos con la informacion de los DATASTORES "

$Resultsstore | Select-Object $objetos | Export-Csv $OutputFileName -NoTypeInformation

write-host "############# FIN INVENTARIO HOSTS ###################" -foregroundcolor green
###############################################################################################
$InputObject = @{
				Title= "TOP 10 DE DATASTORE CON MENOS ESPACIO EN DISCO"
				Object = $Resultsstore | Select-Object $objetos -FIRST 10 | Sort-object -property Porcentaje_Libre
				},
				@{
				Title= "Inventario Total de Datastores"
				Object = $ResultSstore | Select-Object $objetos
				}
				
Export-HtmlReport -InputObject $InputObject -ReportTitle $ReportTitle -OutputFile $OutputFileName




Invoke-Item $OutputFileName


Pop-Location

