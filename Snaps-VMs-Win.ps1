#Requires -Version 2.0
Set-StrictMode -Version Latest

Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)
. .\BIN\include\Export-HtmlReport.ps1

# A simple example for the usage of Export-HtmlReport:
#
# A report is generated from a single PowerShell object
$fecha= get-date -format "ddMMyyyy"

cd inventario
md $fecha
cd $fecha
md infra


##VARIABLES!!
$outputhostHTML= "\inventario\$fecha\infra\VMS-Reportes-SNAP-WIN.html"
$ReportTitle	= "Recursos Infraestructura VMWare - Checkeo de Snapshots"
$Propsc = @()
$Resultsclus = @()
##CSV DE SALIDA

$outputhost = "\inventario\$fecha\infra\VMS-Reportes-SNAP-WIN.csv"

###############################################################################################
write-host "############# INVENTARIO HOSTS ###################" -foregroundcolor green

$Resultsvms = @()
$Propsv = @()	
				
					
					$vms= get-vm
					foreach ($vmx in $vms)
					{
					
					$vm=get-vm $vmx
					Write-Host "Buscando snaps en la VM: <"$vm.Name"> "
					$vmsnap= get-snapshot $vm 
					if ($vmsnap -eq $null)
					{
					$snapname="NO TIENE"
					$snapsize="NO TIENE"
					$snapcreated="NO TIENE"
					$SNAPDAYS="NO TIENE"
					}
					else
					{
					$snapname=$vmsnap.name
					$snapsize=$vmsnap.sizemb / 1024
					$snapcreated=$vmsnap.Created
					$SNAPDAYS=$vmsnap.daysold
					}
					Write-Host "Guardando la informacion de snaps en la VM: <"$vm.Name"> "
					$Propsv = @{
								
								Servidor=$vm
								Snapname=$snapname
								Snapsize="{0:f2}" -f $snapsize
								SnapDias=$SNAPDAYS
								Snapcreated=$snapcreated
								
							}
					
					$Resultsvms += New-Object PSObject -Property $Propsv
					}		
	


@{Object = $Resultsvms | Select-object Servidor,Snapname,Snapcreated,Snapsize,SnapDias } | Export-HtmlReport -OutputFile $outputhostHTML | Invoke-Item

Pop-Location

write-host "############# FIN INVENTARIO VMS ###################" -foregroundcolor green