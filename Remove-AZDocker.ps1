param(
    [String]$ResourceGroupName = "consekdckr"
)

Import-AzureRmContext -Path .\connection.json

Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force