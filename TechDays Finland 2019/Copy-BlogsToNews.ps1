Start-Transcript -Path "D:\PowerShell\Transcripts\transcript-copyblogstonews.txt"
Write-Host "Copy-BlogsToNews" 

############################################################################
## PARAMETERS

$sourceSiteUrl = "https://yourtenant.sharepoint.com/sites/old-intranet/news"
$sourceListTitle = "Posts"
if ($sourceCredentials -eq $null) { 
    $sourceCredentials = Get-Credential -Message "Source credentials" 
}

$destSiteUrl = "https://yourtenant.sharepoint.com/sites/intranet-news"
$destListTitle = "Site Pages"
if ($destCredentials -eq $null) { 
    # change this if you have different credentials for the destination site
    $destCredentials = $sourceCredentials 
}

############################################################################
## FUNCTIONS AND STUFF

function Get-CleanUrlString([string]$postTitle) {
    $retVal = ""
    $lPostTitle = $postTitle.ToLower()
    for($k=0; $k -lt $lPostTitle.Length; $k++) {
        $char = $lPostTitle[$k]              
        if ([char]::IsLetter($char)) {
            if ($char -eq "ä" -eq $char -eq "å") {
                $retVal = $retVal + "a"
            } elseif ($char -eq "ö") {
                $retVal = $retVal + "o"
            } else {
                $retVal = $retVal + $char
            }
        }
        if ([char]::IsDigit($char)) {
            $retVal = $retVal + $char
        }
        if ($char -eq " ") {
            $retVal = $retVal + "-"
        }
        if ($char -eq ".") {
            $retVal = $retVal + "-"
        }        
    }
    return $retVal
}

$authorsTemplate = @"
[
  {
    "id": "i:0#.f|membership|EMAIL",
    "upn": "EMAIL",
    "name": "NAME",
    "role": ""
  }
]
"@

$authorByLineTemplate = @"
[
  "i:0#.f|membership|EMAIL"
]
"@

############################################################################
## MAIN CODE

Write-Host "Establishing connections and opening lists..."
$sourceConnection = Connect-PnPOnline -Url $sourceSiteUrl -Credentials $sourceCredentials -ReturnConnection
$destConnection = Connect-PnPOnline -Url $destSiteUrl -Credentials $destCredentials -ReturnConnection

$sourceList = Get-PnPList -Connection $sourceConnection -Identity $sourceListTitle
$destList = Get-PnPList -Connection $destConnection -Identity $destListTitle

Write-Host "Reading all list items from source list..."
$allSourceItems = Get-PnPListItem -List $sourceList -Connection $sourceConnection

$itemCount = $allSourceItems.Count
Write-Host "Source list has $itemCount items" 

for ($i=0; $i -lt $itemCount; $i++) {    
    $sourceItem = $allSourceItems[$i]
    
    $s_Title = $sourceItem["Title"]
    Write-Host "Copying '$s_Title' - $i/$itemCount"
    $s_Body = $sourceItem["Body"]
    $s_Author = $sourceItem["Author"]
    $s_Editor = $sourceItem["Editor"]

    $s_Modified = $sourceItem["Modified"]
    $s_Created = $sourceItem["Created"]
    $s_PublishedDate = $sourceItem["PublishedDate"]
    $s_PostCategory = $sourceItem["PostCategory"]

    $cleanedString = Get-CleanUrlString($s_Title)
    $page = Get-PnPClientSidePage -Identity $cleanedString -Connection $destConnection -ErrorAction SilentlyContinue
    if ($page -eq $null) {
        $newPage = Add-PnPClientSidePage -Name $cleanedString -LayoutType Article -PromoteAs NewsArticle -Connection $destConnection        
        $newPage.PageListItem["FirstPublishedDate"] = $s_PublishedDate
        $newPage.PageListItem["Created"] = $s_Created
        $newPage.PageListItem["Modified"] = $s_Modified    
        $authorId = 16 # Check the default author which you want from the hidden user list (list item id)
        if ($s_Author.Email.Contains("other.author1")) { $authorId = 17 } # Do your mapping based on the information in the target site
        if ($s_Author.Email.Contains("other.author2")) { $authorId = 12 } # Do your mapping based on the information in the target site       
        $newPage.PageListItem["Author"] = $authorId        
        $editorId = 16 # Check the default editor which you want from the hidden user list (list item id)
        if ($s_Editor.Email.Contains("other.author1")) { $editorId = 17 } # Do your mapping based on the information in the target site
        if ($s_Editor.Email.Contains("other.author2")) { $editorId = 12 } # Do your mapping based on the information in the target site        
        $newPage.PageListItem["Editor"] = $editorId        
        $newPage.PageListItem.SystemUpdate()        
        $newSection = Add-PnPClientSidePageSection -Page $newPage -SectionTemplate OneColumn
        $newWebPart = Add-PnPClientSideText -Page $newPage -Text $s_Body -Order 1 -Section 1 -Column 1            
        $newPage = Get-PnPClientSidePage -Identity $cleanedString -Connection $destConnection        
        $newPage.PageTitle = $s_Title
        $newPage.PageHeader.LayoutType = "NoImage"
        $authorsString = $authorsTemplate.Replace("EMAIL",$s_Author.Email).Replace("NAME",$s_Author.LookupValue)
        $newPage.PageHeader.Authors = $authorsString
        $authorByLineString = $authorByLineTemplate.Replace("EMAIL",$s_Author.Email)
        $newPage.PageHeader.AuthorByLine = $authorsString
        $newPage.PageHeader.AuthorByLineId = -1
        $newPage.PageHeader.ShowPublishDate = $false
        $newPage.PageHeader.ShowTopicHeader = $true
        $newPage.PageHeader.TopicHeader = "News published "+$s_PublishedDate.Day+"."+$s_PublishedDate.Month+"."+$s_PublishedDate.Year
        $newPage.DisableComments()
        $newPage.Save()
        $newPage.Publish()                
     } else {
        Write-Host " page already exists."
     }
}
Stop-Transcript