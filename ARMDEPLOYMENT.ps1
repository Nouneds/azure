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
$SubscriptionID = #subscription parameter
$Location = 'West Europe'

Set-AzContext -tenant $TenantID -subscription $SubscriptionID

$TenantName = Get-aztenant | select -ExpandProperty Name
$mwrg = $tenantname + 'MW-RG'
$mwloganalytics = $tenantName +'MW-LogAnalyticsWorkspace'
$mwautomation = $tenantName +'MW-Automation'
$mwclaps = $tenantName +'MW-CLAPS'
$mwDefaultResourceGroup = $tenantName +'MW-DefaultResourceGroup-WEU'

#Resource group pre-creation
New-AzResourceGroup -Name $mwrg -Location $Location -ErrorAction Stop | Write-Host ($mwrg + ' Created Successfully') -BackgroundColor Green
New-AzResourceGroup -Name $mwloganalytics -Location $Location -ErrorAction Stop | Write-Host ($mwloganalytics + ' Created Successfully') -BackgroundColor Green
New-AzResourceGroup -Name $mwautomation -Location $Location -ErrorAction Stop | Write-Host ($mwautomation + ' Created Successfully') -BackgroundColor Green
New-AzResourceGroup -Name $mwclaps -Location $Location -ErrorAction Stop | Write-Host ($mwclaps + ' Created Successfully') -BackgroundColor Green
New-AzResourceGroup -Name $mwDefaultResourceGroup -Location $Location -ErrorAction Stop | Write-Host ($mwDefaultResourceGroup + ' Created Successfully') -BackgroundColor Green


#ARM Deployment
New-AzResourceGroupDeployment -ResourceGroupName $mwrg `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

New-AzResourceGroupDeployment -ResourceGroupName $mwloganalytics `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

New-AzResourceGroupDeployment -ResourceGroupName $mwautomation `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

New-AzResourceGroupDeployment -ResourceGroupName $mwclaps `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

#LogAnalytics ARM Deployment
New-AzResourceGroupDeployment -ResourceGroupName $mwDefaultResourceGroup `
-Name `
-TemplateFile `
-TemplateParameterFile `
-DeploymentDebugLogLevel RequestContent

#TO DO List
#errorcheck
#CLAPS FunctionApp veryfication
#Migration to DevOPS
