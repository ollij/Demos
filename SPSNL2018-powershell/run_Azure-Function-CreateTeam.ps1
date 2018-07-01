# POST method: $req
$requestBody = Get-Content $req -Raw -Encoding UTF8 | ConvertFrom-Json
$title = $requestBody.title
$type = $requestBody.type
$division = $requestBody.division
$createdBy = $requestBody.createdBy

Write-Output "title: '$title' type: '$type' division: '$division'"

function Get-UrlAlias {
    PARAM(
        [string]$Title,
        [string]$Type
    )
    $prefix="project-"
    if ($Type -eq "Team") {
        $prefix="team-"
    
    }
        
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
$teamsUrl = $null
$alias = Get-UrlAlias -Title $title -Type $type

$username = $env:Teams_Username
$password = $env:Teams_Password | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username,$password)

Connect-MicrosoftTeams -Credential $credential

Write-Output "Creating Team with alias '$alias'..."
$teamsObject = New-Team -DisplayName $title -Alias $alias -AccessType Private 
if ($createdBy -ne $username) {
    Write-Output "Adding '$createdBy' as owner..."
    Add-TeamUser -GroupId $teamsObject.GroupId -User $createdBy -Role Owner
}
If($type -eq "Team") {
    Write-Output "Type 'Team' spesific modifications..."
    Write-Output "  Adding Announcements channel..."
    New-TeamChannel -GroupId $teamsObject.GroupId -DisplayName "Announcements"
}
If($type -eq "Project") {
    Write-Output "Type 'Project' spesific modifications..."
    Write-Output "  Adding Weekly channel..."
    New-TeamChannel -GroupId $teamsObject.GroupId -DisplayName "Weekly"
}

$channel = Get-TeamChannel -GroupId $teamsObject.GroupId | Where-Object { $_.DisplayName -eq "General" }
$teamsUrl = "https://teams.microsoft.com/_#/conversations/"+$channel.DisplayName+"?threadId="+$channel.Id
$groupId = $teamsObject.GroupId
Write-Output "groupId: $groupId"

[string]$resultJson = '{ message: "", status:"Team ready", url: "'+$teamsUrl+'", groupId: "'+$groupId+'", alias: "'+$alias+'" }'
Out-File -Encoding UTF8 -FilePath $res -inputObject $resultJson