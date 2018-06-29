Connect-PnPOnline -Url https://opax-admin.sharepoint.com

# TO ADD NEW SITE DESIGN
$contractDocSiteScript = Get-PnPSiteScript | Where-Object { $_.Title -eq "Contracts" }
Add-PnPSiteDesign -Title "SPSNL18 Demo Design" -SiteScriptIds $contractDocSiteScript.Id -WebTemplate TeamSite

# TO UPDATE EXISTING SITE DESIGN
$spsnl18SiteDesign = Get-PnPSiteDesign  | Where-Object { $_.Title -eq "SPSNL18 Demo Design"}
$themeScript = Get-PnPSiteScript | Where-Object { $_.Title -eq "Multicolored theme" }
Set-PnPSiteDesign -Identity $spsnl18SiteDesign.Id -SiteScriptIds $contractDocSiteScript.Id, $themeScript.Id

# TO LIST ALL SITE DESIGNS
Get-PnPSiteDesign