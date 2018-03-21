Connect-SPOService -Url "https://yourtenant-admin.sharepoint.com"
$script = @"
{
    "$schema": "schema.json",
        "actions": [
            {
                "verb": "createSPList",
                "listName": "Ideas",
                "templateType": 100,
                "subactions": [
                    {
                        "verb": "setDescription",
                        "description": "List of ideas"
                    },
                    {
                        "verb": "addSPField",
                        "fieldType": "Note",
                        "displayName": "Description",
                        "isRequired": false,
                        "addToDefaultView": true
                    }
                ]
            },
            {
               "verb": "addNavLink",
               "url": "/Lists/Ideas",
               "displayName": "Ideas",
               "isWebRelative": true
            }
        ],
        "bindata": { },
        "version": 1
}
"@

# TO ADD NEW
Add-SPOSiteScript -Title "Create Ideas List" -Content $script

# TO UPDATE EXISTING
$siteScript = Get-SPOSiteScript | Where-Object -Property "Title" -EQ -Value "Create Ideas List" 
Set-SPOSiteScript -Identity $siteScript.Id -Content $script

# TO LIST ALL SITE SCRIPTS
Get-SPOSiteScript | select Id, Title
