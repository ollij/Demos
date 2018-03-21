$themeName = "Multicolored by Laura"
$builder = @{
"themePrimary" = "#102542"; #Navy
"themeLighterAlt" = "#d6e3f5";
"themeLighter" = "#fef1ef"; #Coral, themeLighter
"themeLight" = "#fde2df"; #Coral, themeLight
"themeTertiary" = "#6495da";
"themeSecondary" = "#3e7bd1";
"themeDarkAlt" = "#F87060"; #Coral
"themeDark" = "#F87060"; #Coral
"themeDarker" = "#193a68";
"neutralLighterAlt" = "#f8f8f8";
"neutralLighter" = "#f4f4f4";
"neutralLight" = "#eaeaea";
"neutralQuaternaryAlt" = "#dadada";
"neutralQuaternary" = "#d0d0d0";
"neutralTertiaryAlt" = "#c8c8c8";
"neutralTertiary" = "#e2e2e2";
"neutralSecondary" = "#53C7BD"; #Turquoise
"neutralPrimaryAlt" = "#656565";
"neutralPrimary" = "#6f6f6f";
"neutralDark" = "#4f4f4f";
"black" = "#3e3e3e";
"white" = "#ffffff";
"primaryBackground" = "#ffffff";
"primaryText" = "#6f6f6f";
"bodyBackground" = "#ffffff";
"bodyText" = "#6f6f6f";
"disabledBackground" = "#f4f4f4";
"disabledText" = "#c8c8c8";
"accent" = "#F87060"; #Coral
}

$theme = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.String]"
$builder.Keys | %{$theme.Add($_, $builder[$_])}

Add-SPOTheme -Name $themeName -Palette $theme -IsInverted:$false