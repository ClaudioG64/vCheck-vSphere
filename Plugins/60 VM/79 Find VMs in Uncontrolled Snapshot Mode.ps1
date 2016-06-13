# Start of Settings
# End of Settings

$VMFolder = @()
foreach ($eachVM in $FullVM) {
  if (!$eachVM.snapshot) { # Only process VMs without snapshots
    $eachVM.Summary.Config.VmPathName -match '^\[([^\]]+)\] ([^/]+)' > $null
    $Datastore = $matches[1]
    $VMPath = $matches[2]
    $DC = Get-Datacenter -VM (get-vm -Id $eachVM.moref)
    if ($DC.ParentFolder.Parent) { #Check if Datacenter has a parent folder
      $DCPath = $DC.ParentFolder.Name
    }
    else {
      $DCPath = ''
    }
    $gciloc = (Get-ChildItem vmstores: | Select -first 1).Name
    $fileList = Get-ChildItem "vmstores:\$gciloc\$DCPath\$DC\$Datastore\$VMPath" -Exclude *.log
    foreach ($file in $fileList) {
      if ($file.Name -match '-delta\.vmdk|-flat\.vmdk') {
        $Details = "" | Select-Object VM, Datacenter, Path
        $Details.VM = $eachVM.Name
        $Details.Datacenter = $DC.Name
        $Details.Path = $Datastore + '/' + $VMPath + '/' + $file.Name
        $VMFolder += $Details
        break
      }
    }
  }
}
$VMFolder

$Title = "VMs in uncontrolled snapshot mode"
$Header = "VMs in uncontrolled snapshot mode: $($VMFolder).Count)"
$Comments = "The following VMs are in snapshot mode, but vCenter isn't aware of it. See http://kb.vmware.com/kb/1002310"
$Display = "Table"
$Author = "Rick Glover, Matthias Koehler"
$PluginVersion = 1.3.1
$PluginCategory = "vSphere"
