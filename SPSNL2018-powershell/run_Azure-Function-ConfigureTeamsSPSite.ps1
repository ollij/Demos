# POST method: $req
$requestBody = Get-Content $req -Raw -Encoding UTF8 | ConvertFrom-Json
$groupId = $requestBody.groupId
$teamsUrl = $requestBody.teamsUrl
Write-Output "groupId: $groupId"
Write-Output "teamsUrl: $teamsUrl"

Connect-PnPOnline -AppId $env:Graph_AppId -AppSecret $env:Graph_AppSecret -AADDomain $env:Graph_AADDomain
$done = $false
$siteUrl = ""
$group = $null
$counter=0; $maxRetries = 20
do {
    Write-Output "Accessing group"
    $group = Get-PnPUnifiedGroup -Identity $groupId -ErrorAction SilentlyContinue
    $siteUrl = $group.SiteUrl
    if ($siteUrl -ne $null) {
        if($siteUrl.StartsWith("https://")) {
            $done = $true
        }
    }
    $counter++
    if ($counter -eq $maxRetries) {
        $done = $true
    } 
    if ($done -eq $false) {
        $Error.Clear()
        Write-Output "Take a break because site url is $siteUrl"
        Sleep -S 5
    }
} while ($done -eq $false)

Write-Output "siteUrl: $siteUrl"

if ($siteUrl -ne $null -and $siteUrl.StartsWith("https://")) {
    Write-Output "Modifying the navigation of the SharePoint site"
    Connect-PnPOnline -Url $siteUrl -AppId $env:SPO_AppId -AppSecret $env:SPO_AppSecret
    Get-PnPNavigationNode | Where-Object { $_.Title -eq "Conversations" } | Remove-PnPNavigationNode -Force
    Add-PnPNavigationNode -Location QuickLaunch -Title "Teams conversations" -Url $teamsUrl
}