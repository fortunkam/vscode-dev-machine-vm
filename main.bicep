@secure()
param prefix string = 'mfdev'
param vmPassword string
param vmUserName string = 'AzureAdmin'

var vmName = '${prefix}-vm'
var publicIpName = '${prefix}-vm-ip'
var diskName = '${prefix}-vm-disk'
var nsgName = '${prefix}-vm-nsg'
var nicName = '${prefix}-vm-nic'
var ipconfigName = '${prefix}-vm-ipconfig'

var vnet_name='${prefix}-vnet'
var vnet_iprange='10.0.0.0/24'
var vm_subnet='vm'
var vm_subnet_iprange='10.0.0.0/24'

var location = resourceGroup().location


// vnet

resource vnet 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: vnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_iprange
      ]
    }
  }
}

//subnet
resource vmSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  name: '${vnet.name}/${vm_subnet}'
  properties: {
    addressPrefix: vm_subnet_iprange
  }
}

// public ip
resource vmPublicIP 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name:publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// nsg
resource vmNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name:nsgName
  location:location
}

// security rule
resource vmRdpSecurityRule 'Microsoft.Network/networkSecurityGroups/securityRules@2020-07-01' = {
  name:'${vmNSG.name}/rdp'
  properties:{
    priority:100
    direction:'Inbound'
    access:'Allow'
    protocol:'*'
    sourcePortRange:'*'
    destinationPortRange:'3389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'    
  }
}

//nic 

resource vmNic 'Microsoft.Network/networkInterfaces@2020-07-01' = {
  name:nicName
  location:location
  properties:{
    ipConfigurations:[
      {
        name: 'IpConfig1'
        properties: {
          primary:true
          privateIPAllocationMethod:'Dynamic'
          publicIPAddress:{
            id: vmPublicIP.id
          }
          subnet: {
            id: vmSubnet.id

          }
        }
      }
    ]
    networkSecurityGroup: {
      id: vmNSG.id
    }
  }
}

//vm
resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location:location
  identity:{
    type:'SystemAssigned'
  }
  properties: {  
    hardwareProfile:{
      vmSize:'Standard_D4_v3'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
    storageProfile:{
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '20h2-ent'
        version: 'latest'
      }
      osDisk: {
        name: 'osDisk'
        caching: 'ReadWrite'
        createOption:'FromImage'        
      }
      
    }
    osProfile: {
      adminUsername: vmUserName
      adminPassword: vmPassword
      computerName: vmName
      windowsConfiguration: {
        provisionVMAgent:true
      }      
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vm.name}/installchocolatey'
  location:location
  properties:{
    publisher:'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/fortunkam/dev-environment-vm-scripts/main/setup-dev-machine.ps1'
      ]
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File setup-dev-machine.ps1'
    }
  }
}

output vmName string =  vm.name





