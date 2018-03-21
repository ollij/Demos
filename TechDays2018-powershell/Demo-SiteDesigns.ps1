

# TO ADD SITE DESIGN
Add-SPOSiteDesign -Title "Site with PnP Provisioning" -SiteScripts "ffa9a937-01ca-4274-a027-7c05428a5e20" -WebTemplate "64"

# TO UPDATE SITE DESIGN
$siteDesign = Get-SPOSiteDesign | Where-Object -Property "Title" -EQ -Value "Site with PnP Provisioning"
Set-SPOSiteDesign -Identity $siteDesign.Id -SiteScripts "a546f3ce-52a8-4b2e-898e-c41b18aeb1c3","e51491a4-ef1e-4464-818e-23bae519d4de","ffa9a937-01ca-4274-a027-7c05428a5e20"

# TO LIST ALL THE SITE DESIGNS
Get-SPOSiteDesign | select id, title