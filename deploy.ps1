$rgName = 'dev-vm'
$location = 'uksouth'
$deploymentName = 'dev-vm-deploy'

az group create -n $rgName --location $location

az deployment group create -n $deploymentName -g $rgName -f .\main.bicep --mode Incremental

$vmName = az deployment group show -n $deploymentName -g $rgName --query properties.outputs.vmName.value

az vm restart -g $rgName -n $vmName