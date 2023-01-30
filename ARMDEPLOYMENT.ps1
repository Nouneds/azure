$SubscriptionID = #subscription parameter
$TenantName = Get-aztenant | select -ExpandProperty Name
$mwrg = $tenantname + 'MW-RG'
$mwloganalytics = $tenantName +'MW-LogAnalytics'
$Location = 'West Europe'

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
Set-AzContext -subscription $SubscriptionID

#Resource group pre-creation
New-AzResourceGroup -Name $mwrg -Location $Location -ErrorAction Stop | Write-Host ($mwrg + ' Created Successfully') -BackgroundColor Green
New-AzResourceGroup -Name $mwloganalytics -Location $Location -ErrorAction Stop | Write-Host ($mwloganalytics + ' Created Successfully') -BackgroundColor Green


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