add-pssnapin VMware.VimAutomation.Core
Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)
. .\BIN\include\Export-HtmlReport.ps1

$fecha= get-date -format "ddMMyyyy"
write-host "###############################################################" -foregroundcolor BLUE

cd inventario
md $fecha
cd $fecha
md infra


##VARIABLES!!
$OutputFileName	= "\inventario\$fecha\Datastore\cluster-Recursos.html"
$ReportTitle	= "Recursos Infraestructura VMWare - Recursos y Disponibilidad de los Clusters"
$Propsc = @()
$Resultsclus = @()
##CSV DE SALIDA
$outputstore = "ClusterRecursos.csv"
###############################################################################################
write-host "############# INVENTARIO HOSTS ###################" -foregroundcolor green

$x=100
$porc=0
foreach ($cluster in  get-datacenter )
	{
		Write-Host "Recolectando informacion del cluster : <"$cluster.Name"> "
		$recursos= $cluster | get-vmhost
		$memusada=0
		$memtotal=0
		foreach ($recurso in $recursos){
		$memusada+= $recurso.MemoryUsageGB
		$memtotal+= $recurso.MemoryTotalGB
		}
		$porc= ($memusada * 100) / $memtotal
		if ($porc -le $x) {
		$x=$porc
		$dis= $cluster.name
		}
	
		$Propsc = @{
								Cluster=$cluster.Name
								MemoriaTotal="{0:n2}" -f $Memtotal
								MemoriaUsada= "{0:n2}" -f $Memusada
								"Porcentaje de Uso"=  "{0:n2}" -f $porc
								}
								$Resultsclus += New-Object PSObject -Property $Propsc
		
	}
	
		
Write-Host "Creacion de archivos con la informacion de los hosts "



write-host "############# FIN INVENTARIO HOSTS ###################" -foregroundcolor green
###############################################################################################
$InputObject =  @{ 
					Title  = "Tabla de recursos de los Clusters";
					Object = $Resultsclus | Select-object Cluster, MemoriaTotal, MemoriaUsada, "Porcentaje de Uso"
				}
				
Export-HtmlReport -InputObject $InputObject -ReportTitle $ReportTitle -OutputFile $OutputFileName

Invoke-Item $OutputFileName


