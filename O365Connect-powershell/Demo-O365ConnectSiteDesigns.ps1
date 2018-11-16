Connect-PnPOnline -Url https://your-admin.sharepoint.com -Credentials your

# TO ADD NEW SITE DESIGN
$contractDocSiteScript = Get-PnPSiteScript | Where-Object { $_.Title -eq "Contracts" }
Add-PnPSiteDesign -Title "Office 365 Connect Demo Design" -SiteScriptIds $contractDocSiteScript.Id -WebTemplate TeamSite

# TO UPDATE EXISTING SITE DESIGN
$siteDesign = Get-PnPSiteDesign  | Where-Object { $_.Title -eq "Office 365 Connect Demo Design"}
$themeScript = Get-PnPSiteScript | Where-Object { $_.Title -eq "Multicolored theme" }
Set-PnPSiteDesign -Identity $siteDesign.Id -SiteScriptIds $contractDocSiteScript.Id, $themeScript.Id

# TO LIST ALL SITE DESIGNS
Get-PnPSiteDesign

# TO REMOVE A SITE DESIGN
Remove-PnPSiteDesign -Identity $siteDesign.Id