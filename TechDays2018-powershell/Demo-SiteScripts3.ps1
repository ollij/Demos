# WORKING WIHT HUB SITES - NOTE: ROLLING OUT THIS MONTH (03/2018)
$site = Get-SPOSite -Identity "https://yourtenant.sharepoint.com/sites/sitex"
Register-SPOHubSite -Site $site
Get-SPOHubSite

$script = @"
{
    "$schema": "schema.json",
        "actions": [
            {
                "verb": "joinHubSite",
                "hubSiteId": "54d7b158-2915-4efe-ba62-4dc99532b42c"
            }
        ],
        "bindata": { },
        "version": 1
}
"@

# TO ADD NEW
Add-SPOSiteScript -Title "Join the Hub Sites" -Content $script

# TO UPDATE EXISTING
$siteScript = Get-SPOSiteScript | Where-Object -Property "Title" -EQ -Value "Join the Hub Site" 
Set-SPOSiteScript -Identity $siteScript.Id -Content $script 

Get-SPOSiteScript
 