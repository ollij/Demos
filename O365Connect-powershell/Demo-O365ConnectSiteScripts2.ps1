Connect-PnPOnline -Url https://your-admin.sharepoint.com -Credentials your

$siteDesign = Get-PnPSiteDesign  | Where-Object { $_.Title -eq "Site with PnP Provisioning"}
Get-PnPSiteScript -SiteDesign $siteDesign.Id

$siteScript = Get-PnPSiteScript -Identity $siteDesign.SiteScriptIds[2]

$siteScript.Content