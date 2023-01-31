#Checks and updates AZ module
Function CheckInstalledModule
{
$tabModules = @()
$modules = (Get-InstalledModule).Name

Foreach ($m in $modules)
{
$tabModules += $modules
}
if ($tabModules -notcontains "AZ")
{
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Write-Host "Installing AzureAD module" -ForegroundColor Cyan
}
if ($tabModules -contains "AZ")
{
Write-Host "AZ module is already installed" -ForegroundColor Green
}
}
CheckInstalledModule

Connect-azaccount

#Specify parameters

$TenantID = #tenant parameter
$TenantName = 'B0001' #tenant symbol (f.e. B000XX)
$SubscriptionID = #subscription parameter

#locks script to correct tenant and subscription
Set-AzContext -tenant $TenantID -subscription $SubscriptionID

#RG preset parameters
$Location = 'West Europe'
$mwrg = $tenantname + 'MW-RG'
$mwloganalytics = $tenantName +'MW-LogAnalyticsWorkspace'
$mwautomation = $tenantName +'MW-Automation'
$mwclaps = $tenantName +'MW-CLAPS'
$mwDefaultResourceGroup = $tenantName +'-MW-DefaultResourceGroup-WEU'

#Resource group pre-creation
New-AzResourceGroup -Name $mwrg -Location $Location -ErrorAction Stop
Write-Host ($mwrg + ' Created Successfully') -ForegroundColor Green
New-AzResourceGroup -Name $mwloganalytics -Location $Location -ErrorAction Stop
Write-Host ($mwloganalytics + ' Created Successfully') -ForegroundColor Green
New-AzResourceGroup -Name $mwautomation -Location $Location -ErrorAction Stop
Write-Host ($mwautomation + ' Created Successfully') -ForegroundColor Green
New-AzResourceGroup -Name $mwclaps -Location $Location -ErrorAction Stop
Write-Host ($mwclaps + ' Created Successfully') -ForegroundColor Green
New-AzResourceGroup -Name $mwDefaultResourceGroup -Location $Location -ErrorAction Stop
Write-Host ($mwDefaultResourceGroup + ' Created Successfully') -ForegroundColor Green


#ARM Deployment
New-AzResourceGroupDeployment -ResourceGroupName $mwrg `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

read-host “Validate if ARM was deployed sucessfully and press enter...”

New-AzResourceGroupDeployment -ResourceGroupName $mwloganalytics `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

read-host “Validate if ARM was deployed sucessfully and press enter...”

New-AzResourceGroupDeployment -ResourceGroupName $mwautomation `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

read-host “Validate if ARM was deployed sucessfully and press enter...”

New-AzResourceGroupDeployment -ResourceGroupName $mwclaps `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

read-host “Validate if ARM was deployed sucessfully and press enter...”

#LogAnalytics ARM Deployment
New-AzResourceGroupDeployment -ResourceGroupName $mwDefaultResourceGroup `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

read-host “Validate if ARM was deployed sucessfully and press enter...”
Write-Host 'Deployment completed' -BackgroundColor Green

#TO DO List
#errorcheck
#CLAPS FunctionApp veryfication
#Migration to DevOPS
