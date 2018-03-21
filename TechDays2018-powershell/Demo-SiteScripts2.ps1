$script = @"
{
    "$schema": "schema.json",
        "actions": [
            {
               "verb": "applyTheme",
               "themeName": "Multicolored by Laura"
            }
        ],
        "bindata": { },
        "version": 3
}
"@

# TO ADD NEW
Add-SPOSiteScript -Title "Theme and navigation" -Content $script

# TO UPDATE EXISTING
$siteScript = Get-SPOSiteScript | Where-Object -Property "Title" -EQ -Value "Theme and navigation" 
Set-SPOSiteScript -Identity $siteScript.Id -Content $script -Title "Multicolored theme"
