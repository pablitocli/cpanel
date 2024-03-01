
Set-StrictMode -Version Latest

Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)
. .\BIN\include\Export-HtmlReport.ps1


$fecha= get-date -format "ddMMyyyy"

write-host "###############################################################" -foregroundcolor BLUE
d:
cd\
cd inventario
md $fecha
cd $fecha
md VMS

##VARIABLES!!
$OutputFileName	= "D:\inventario\$fecha\vms\countvms.html"
$ReportTitle	= "Inventario de los Sumario de la Infraestructura Virtual - WAYCLO "
##CSV DE SALIDA
$outputstore = "D:\inventario\$fecha\vms\countvms.csv"
$ls=""
$Propsv = @()
$Resultsv = @()
	foreach ($dcenter in Get-Datacenter)
	{
	Write-Host "Contando VMs en el Datacenter <"$dcenter.Name"> "
	$vms=get-datacenter $dcenter.name | get-vm | measure
    $clusters=get-datacenter $dcenter.name | get-cluster | measure
    $vmhosts=get-datacenter $dcenter.name | get-vmhost| measure
	$c_vms=$vms.count
    $c_clusters=$clusters.count
    $c_vmhosts=$vmhosts.count

	$Propsv = @{
		DATACENTER=$dcenter.name
		CANT_VMS=$c_vms
        CANT_CLUSTERS=$c_clusters
        CANT_VMHOSTS=$c_vmhosts
	}
	$Resultsv += New-Object PSObject -Property $Propsv
	}
@{Object = $Resultsv | Select-Object DATACENTER,CANT_VMS,CANT_CLUSTERS,CANT_VMHOSTS} | Export-HtmlReport -OutputFile $OutputFileName | Invoke-Item

Pop-Location