$in = Get-Content $triggerInput -Raw
Write-Output "Incoming request for '$in'"
Connect-PnPOnline -AppId $env:SPO_AppId -AppSecret $env:SPO_AppSecret -Url $in
Write-Output "Connected to site"

$site = Get-PnPSite -Includes Id
$web = Get-PnPWeb -Includes Id
$siteId = $site.Id
$webId = $web.Id
$properties = @"
{"displayMaps":{"1":{"headingText":{"sources":["SiteTitle"]},"headingUrl":{"sources":["SitePath"]},"title":{"sources":["UserName","Title"]},"personImageUrl
":{"sources":["ProfileImageSrc"]},"name":{"sources":["Name"]},"initials":{"sources":["Initials"]},"itemUrl":{"sources":["WebPath"]},"activity":{"sources":[
"ModifiedDate"]},"previewUrl":{"sources":["PreviewUrl","PictureThumbnailURL"]},"iconUrl":{"sources":["IconUrl"]},"accentColor":{"sources":["AccentColor"]},
"cardType":{"sources":["CardType"]},"tipActionLabel":{"sources":["TipActionLabel"]},"tipActionButtonIcon":{"sources":["TipActionButtonIcon"]}},"2":{"column
1":{"heading":"","sources":["FileExtension"],"width":34},"column2":{"heading":"Title","sources":["Title"],"linkUrls":["WebPath"],"width":250},"column3":{"h
eading":"Modified","sources":["ModifiedDate"],"width":100},"column4":{"heading":"Modified By","sources":["Name"],"width":150}},"3":{"id":{"sources":["Uniqu
eID"]},"edit":{"sources":["edit"]},"DefaultEncodingURL":{"sources":["DefaultEncodingURL"]},"FileExtension":{"sources":["FileExtension"]},"FileType":{"sourc
es":["FileType"]},"Path":{"sources":["Path"]},"PictureThumbnailURL":{"sources":["PictureThumbnailURL"]},"SiteID":{"sources":["SiteID"]},"SiteTitle":{"sourc
es":["SiteTitle"]},"Title":{"sources":["Title"]},"UniqueID":{"sources":["UniqueID"]},"WebId":{"sources":["WebId"]},"WebPath":{"sources":["WebPath"]}},"4":{
"headingText":{"sources":["SiteTitle"]},"headingUrl":{"sources":["SitePath"]},"title":{"sources":["UserName","Title"]},"personImageUrl":{"sources":["Profil
eImageSrc"]},"name":{"sources":["Name"]},"initials":{"sources":["Initials"]},"itemUrl":{"sources":["WebPath"]},"activity":{"sources":["ModifiedDate"]},"pre
viewUrl":{"sources":["PreviewUrl","PictureThumbnailURL"]},"iconUrl":{"sources":["IconUrl"]},"accentColor":{"sources":["AccentColor"]},"cardType":{"sources"
:["CardType"]},"tipActionLabel":{"sources":["TipActionLabel"]},"tipActionButtonIcon":{"sources":["TipActionButtonIcon"]}}},"query":{"contentLocation":3,"co
ntentTypes":[1],"sortType":1,"filters":[{"filterType":1,"value":"sharepoint"}],"documentTypes":[3],"advancedQueryText":""},"templateId":1,"maxItemsPerPage"
:8,"hideWebPartWhenEmpty":false,"sites":[],"layoutId":"Card","dataProviderId":"Search","webId":"$webId","siteId":"$siteId"}
"@
$frontPage = Add-PnPClientSidePage -Name "FrontPage" -LayoutType Home -CommentsEnabled:$true
Add-PnPClientSidePageSection -Page $frontPage -SectionTemplate OneColumn 
Add-PnPClientSideWebPart -Page $frontPage -Section 1 -Column 1 -DefaultWebPartType ContentRollup -WebPartProperties $properties
Set-PnPClientSidePage -Identity $frontPage -PublishMessage "PnP Script published me!" -Publish:$true
Set-PnPHomePage -RootFolderRelativeUrl "SitePages/FrontPage.aspx"

Write-Output "Provisioning ends"
