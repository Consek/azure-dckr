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