Connect-SPOService "https://yourtenant-admin.sharepoint.com"

$addFrontPageSiteScript = @"
{
    "`$schema": "schema.json",
    "actions": [
    {
        "verb": "triggerFlow",
        "url": "https://prod-19.westeurope.logic.azure.com:443/workflows/550d4481a92f47ba8887d99b3e123456/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=FURFi0aEEhP0pJY11LFnC3fyh4aySA0vYzGJ1234567",
        "name": "Create custom front page",
        "parameters": {
            "event": "addFrontPage",
            "product": ""
        }
    }
    ],
    "bindata": {},
    "version": 1
}
"@
