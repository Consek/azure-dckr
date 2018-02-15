param(
    [String]$ResourceGroupName = "consekdckr",
    [String]$Location = 'westeurope'
)

Import-AzureRmContext -Path .\connection.json

if(-not (Get-AzureRmResourceGroup -Name $ResourceGroupName -EA SilentlyContinue)){
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
}

$DeployParams = @{
    Name = "dockerlearningdeployment"
    ResourceGroupName = $ResourceGroupName
    Mode = 'Complete'
    TemplateParameterFile = '.\parameters.json'
    TemplateFile = '.\CreateVMTemplate.json'
}

New-AzureRmResourceGroupDeployment @DeployParams -Force

$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("consek", $securePassword)

$VNetwork = Get-AzureRmVirtualNetwork -Name "dockerVNet" -ResourceGroupName $ResourceGroupName
$Subnet = $VNetwork.Subnets | Where-Object Name -eq "dockerSubnet"
$IPAddress = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName -Name "dockerPublicIPAddress3" -AllocationMethod "Dynamic" -DomainNameLabel "consekdckr03" -Location $Location
$IPConfig = New-AzureRmNetworkInterfaceIpConfig -Name "ipconfig3" -PrivateIpAddressVersion IPv4 -SubnetId $Subnet.Id -PrivateIpAddress "10.0.0.13" -PublicIpAddressId $IPAddress.Id
$IPInterface = New-AzureRmNetworkInterface -Name "dockerNic3" -ResourceGroupName consekdckr -Location $Location -IpConfiguration $IPConfig
Set-AzureRmVMDataDisk -Name 'dockerOSDisk3' -Caching ReadWrite
$VMConfig = New-AzureRmVMConfig -VMName "docker03" -VMSize "Standard_A2" |
    Set-AzureRmVMOperatingSystem -Linux -ComputerName "docker03" -DisablePasswordAuthentication -Credential $cred |
    Set-AzureRmVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "16.04-LTS" -Version "latest" |
    Add-AzureRmVMNetworkInterface -Id $IPInterface.Id |
    Add-AzureRmVMDataDisk -Name 'dockerOSDisk3' -Caching ReadWrite -CreateOption FromImage |
    Add-AzureRmVMSshPublicKey -KeyData "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg/YRrlmyKpLjuxtZI3fdSAVKYTxw8+Jt0L/F8UMddiHY8l8Kj5gInrzb3/f0lpCOfdsU4FPekrO26g4SeXBX/vv78lxWIR+P++eJAAoaLv8OV1LVDfW+AocuICJr6Mvw3Fnc4SziWCylTCXxDKiNBmHQ8nhYSDRQoWy5lQKOYxwrpNtimuGgmsyp4isFZaAZbv+IFHbXo570l5PzsBjrFfMNQ7y5W9nRAkEPIopLG737EMmLI98y8vJ2JZg7kc25u+c1aYNLNZquX9VRw99RcBMFGd0ax0bnrYIyOylq85ASizTkNI+fGF/gknTOl5Gju5cmRjOGm7Uz8PC4HEeTOw== rsa-key-20180210" -Path '/home/consek/.ssh/authorized_keys'
    



New-AzureRmVm -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig
