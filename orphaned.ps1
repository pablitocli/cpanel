
#Requires -Version 2.0
Set-StrictMode -Version Latest

Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)
. .\BIN\include\Export-HtmlReport.ps1

$fecha= get-date -format "ddMMyyyy"
write-host "###############################################################" -foregroundcolor BLUE

cd inventario
md $fecha
cd $fecha
md datastore


##VARIABLES
$OutputFileName	= "\inventario\$fecha\datastore\Huerfanos-DISK.html"
$ReportTitle	= "Recursos Infraestructura VMWare- Disco HUERFANOS "
$Propsd = @()
$Propsrecuros = @()

##CSV DE SALIDA
$outputstore = "Huerfanos-DISK.csv"


 $arrUsedDisks = Get-VM | Get-HardDisk | %{$_.filename}
 $arrUsedDisks += get-template | Get-HardDisk | %{$_.filename}
 $arrDS = Get-Datastore 
 Foreach ($strDatastore in $arrDS)
 {
 $strDatastoreName = $strDatastore.name
 $ds = Get-Datastore -Name $strDatastoreName | %{Get-View $_.Id}
 $fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
 $fileQueryFlags.FileSize = $true
 $fileQueryFlags.FileType = $true
 $fileQueryFlags.Modification = $true
 $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
 $searchSpec.details = $fileQueryFlags
 $searchSpec.sortFoldersFirst = $true
 $dsBrowser = Get-View $ds.browser
 $rootPath = "["+$ds.summary.Name+"]"
 $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)
 $myCol = @()
 foreach ($folder in $searchResult)
 {
 foreach ($fileResult in $folder.File)
 {
 $file = "" | select Name, FullPath 
 $file.Name = $fileResult.Path
 $strFilename = $file.Name
 IF ($strFilename)
 {
 IF ($strFilename.Contains(".vmdk")) 
 {
 IF (!$strFilename.Contains("-flat.vmdk"))
 {
 IF (!$strFilename.Contains("delta.vmdk")) 
 {
 $strCheckfile = "*"+$file.Name+"*"
 IF ($arrUsedDisks -Like $strCheckfile){}
 ELSE 
 { 
 write-host "#############  $strOutput ###################" -foregroundcolor green
 $strOutput = $strDatastoreName + " Orphaned VMDK Found: " + $strFilename

 $Propsd  = @{
									DATASTORE=$strDatastoreName
									FILE=$strFilename
											}
											$Propsrecuros += New-Object PSObject -Property  $Propsd
						

 } 
 }
 } 
 }
 }
 }
 } 
 } 


write-host "############# FIN INVENTARIO HOSTS ###################" -foregroundcolor green
###############################################################################################
$InputObject =  @{ 
				   
					 Object = $Propsrecuros | Select-object DATASTORE, FILE
				}
					
Export-HtmlReport -InputObject $InputObject -ReportTitle $ReportTitle -OutputFile $OutputFileName
Invoke-Item $OutputFileName

Pop-Location