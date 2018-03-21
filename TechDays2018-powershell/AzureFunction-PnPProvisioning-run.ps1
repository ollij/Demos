$in = Get-Content $triggerInput -Raw
Write-Output "Incoming request for '$in'"
Connect-PnPOnline -AppId $env:SPO_AppId -AppSecret $env:SPO_AppSecret -Url $in
Write-Output "Connected to site"

$issuesList = Get-PnPList | Where-Object -Property "Title" -EQ -Value "Issues"
if ($issuesList -eq $null) {
    Write-Output "Creating Issues List"
    New-PnPList -Title "Issues" -Template GenericList -EnableVersioning -OnQuickLaunch
    $issuesList = Get-PnPList -Identity "Lists/Issues" 
} else {
    Write-Output "Issues List already exists" 
}
$issuesList.Context.Load($issuesList.Fields)
$issuesList.Context.ExecuteQuery()
$description = $issuesList.Fields | Where-Object -Property "Title" -EQ "Description"
if ($description -eq $null) {
    Write-Output "Adding Description field"
    Add-PnPField -List $issuesList -DisplayName "Description" -InternalName "pnpDescription" -Type Note 
} else {
    Write-Output "Description field already exists"
}
$status = $issuesList.Fields | Where-Object -Property "Title" -EQ "Status"
if ($status -eq $null) {
    Write-Output "Adding Status field"
    Add-PnPField -List $issuesList -DisplayName "Status" -InternalName "pnpStatus" -Type Choice -Choices "New","Open","Closed" -AddToDefaultView  
    Write-Output "Creating status based Views"
    $viewQueryNEW = @"
        <Where><Eq><FieldRef Name="pnpStatus" /><Value Type="Text">New</Value></Eq></Where>
        <OrderBy><FieldRef Name="Modified" Ascending="FALSE"/></OrderBy>
"@
    $viewQueryOPEN = @"
        <Where><Eq><FieldRef Name="pnpStatus" /><Value Type="Text">Open</Value></Eq></Where>
        <OrderBy><FieldRef Name="Modified" Ascending="FALSE"/></OrderBy>
"@
    $viewQueryCLOSED = @"
        <Where><Eq><FieldRef Name="pnpStatus" /><Value Type="Text">Closed</Value></Eq></Where>
        <OrderBy><FieldRef Name="Modified" Ascending="FALSE"/></OrderBy>
"@
    Add-PnPView -List $issuesList -Title "New Issues" -Fields "LinkTitle","Description" -Query $viewQueryNEW
    Add-PnPView -List $issuesList -Title "Open Issues" -Fields "LinkTitle","Description" -Query $viewQueryOPEN
    Add-PnPView -List $issuesList -Title "Closed Issues" -Fields "LinkTitle","Description" -Query $viewQueryCLOSED
} else {
    Write-Output "Stutus field already exists"
}
Write-Output "Ensuring that attachments are disabled"
$issuesList.EnableAttachments = $false
$issuesList.Update()
$issuesList.Context.ExecuteQuery()

Write-Output "Provisioning ends"
