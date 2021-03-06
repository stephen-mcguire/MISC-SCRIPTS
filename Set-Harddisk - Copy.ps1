param(
    $vm,
    $add
    )

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

#Connect to VDI vCenter
Connect-VIServer SERVER_NAME_HERE

#Variable Input
if(!$vm)
	{
		$vm = Read-Host "Enter Machine Name"
	}
if(!$add)
    {
        $add = Read-Host "Enter Amount to Add"
    }
$Datastore = Get-Datastore -VM $vm | Select @{N="DataStoreName";E={$_.Name}},@{N="Percentage_Free";E={[math]::Round(($_.FreeSpaceGB)/($_.CapacityGB)*100,2)}}
$HD = get-harddisk -VM $vm -Name "Hard disk 1"
$HDNewSize = [decimal]::round($HD.CapacityGB + $add)

#Command to Increase HardDisk if Datastore is Not Low
if ( $Datastore.'Percentage_Free' -gt "15" )
	{
		$HD | Set-harddisk -CapacityGB  $HDNewSize -Confirm:$false
		# Run DISKPART in the guest OS
		Invoke-VMScript -vm $VM -ScriptText "echo rescan > c:\diskpart.txt && echo select vol c >> c:\diskpart.txt && echo extend >> c:\diskpart.txt && diskpart.exe /s c:\diskpart.txt" -ScriptType BAT
	}
else
	{
		Write-Host $Datastore.DataStoreName"has less than 15% free space."
	}

#Disconnect from VDI vCenter
Disconnect-VIServer -Confirm:$false