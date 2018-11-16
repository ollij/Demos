# POST method: $req
$requestBody = Get-Content $req -Raw -Encoding UTF8 | ConvertFrom-Json
$name = $requestBody.name
$template = $requestBody.template
$external = $requestBody.external
Write-Output "name: $name"
Write-Output "template: $template"
Write-Output "external: $external"

function Get-UrlAlias {
    PARAM(
        [string]$Title,
        [string]$WorkspaceType
    )
    $prefix="project_"
        
    $s = $Title.ToLowerInvariant(); $s = $s.Replace(" ", "-"); $s = $s.Replace("ä", "a"); $s = $s.Replace("ö", "o"); $s = $s.Replace("å", "a");
    $str = ""; $prevAddedChar = ""
    for ($i = 0; $i -lt $s.Length; $i++) {
        [char]$c = $s[$i]
        $charToAdd = ""
        if (([char]::IsLetter($c) -and $c -ge "a" -and $c -le "z")-or [char]::IsDigit($c) -or $c -eq "-") {            
            $charToAdd = $c
        } else {            
            $charToAdd = "-"
        }
        if (!($prevAddedChar -eq "-" -and $charToAdd -eq "-")) {
            $str += $charToAdd
            $prevAddedChar = $charToAdd
        }
    }
    [string]$s = $prefix+$str
    if ($s.Length -gt 50) {
        $s = $s.Substring(0, 50)        
    }
    return $s
}
$targetSiteUrl = $null
$alias = Get-UrlAlias -Title $name -WorkspaceType $template

$username = $env:Teams_Username
$password = $env:Teams_Password | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Connect-PnPOnline -Credential $credential -Url "https://opax.sharepoint.com"

$newSite = New-PnPSite -Type TeamSite -Title $name -Alias $alias -Classification "External" 

$targetSiteUrl = $newSite
Write-Output "site is $targetSiteUrl"

Connect-PnPOnline -Credential $credential -Url $targetSiteUrl
Write-Output "Create navigation"
Add-PnPNavigationNode -Title "Google" -Url "https://google.com" -Location QuickLaunch -External
Write-Output "Create document libraries"
New-PnPList -Title "Steering group documents" -Template DocumentLibrary -Url "steering-group-docs" -EnableVersioning -QuickLaunchOptions On -OnQuickLaunch

Connect-PnPOnline -AppId $env:SPO_AppId -AppSecret $env:SPO_AppSecret -Url $newSite
$site = Get-PnPSite -Includes GroupId
$groupId = $site.GroupId.ToString("B")

# Create Teams
Connect-MicrosoftTeams -TenantId "259934ef-1234-4737-1234-4c8308442a58" -Credential $credential
New-Team -Group $groupId 

# Add Teams link to SharePoint site 
$channel = Get-TeamChannel -GroupId $groupId
$channelIdTeam = ""+$channel.Id
$channelIdTeam = $channelIdTeam.Replace("-","")
$teamsUrl = "https://teams.microsoft.com/_#/conversations/"+$channel.DisplayName+"?threadId="+$channelIdTeam+"&ctx=channel"
Add-PnPNavigationNode -Title "Open in Teams" -Url $teamsUrl -Location QuickLaunch -External

Out-File -Encoding Ascii -FilePath $res -inputObject $targetSiteUrl