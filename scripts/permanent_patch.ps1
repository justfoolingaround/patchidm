if (!
    (New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
) {
    throw "Please run this script in an elevated (Administrator) PowerShell window.";
}
function promptForChoice($prompt_string) {
    $user_choice = (Read-Host "$prompt_string [y/N] ").ToLower();

    if ($user_choice -eq "y") {
        return $true
    }
    else {
        if (!($user_choice -eq "n")) {
            Write-Output "Invalid choice: $user_choice, defaulting to N."
        }
        return $false
    }
}

function escapeQuotes($string) {
    return $string -replace "`"", "\`""
}

function promptIDMCredentials($credentialName, $defaultValue) {
    $credential = Read-Host "Enter the $credentialName to register IDM with [$defaultValue]"

    if ($null -eq $credential -or $credential -eq "") {
        $credential = $defaultValue
    }

    return escapeQuotes($credential)
}



$idmPatchRegistryUpstream = "https://raw.githubusercontent.com/J2TEAM/idm-trial-reset/8d85c475094c5b941ab917e2b6e5732e72076f1c/src/idm_reg.reg"

$tempFile = "idm_reg.reg"

curl.exe -L $idmPatchRegistryUpstream -o $tempFile

$registryData = Get-Content $tempFile

$defaultFirstName = $env:USERNAME
$defaultLastName = "(User)"
$defaultEmail = "example@example.com"

$firstName = promptIDMCredentials("First Name", $defaultFirstName)
$lastName = promptIDMCredentials("Last Name", $defaultLastName)
$email = promptIDMCredentials("Email", $defaultEmail)


$registryData = ((($registryData `
                -replace "IDM Trial Reset", $firstName) `
            -replace "\(http://bit\.ly/IDMresetTrialForum\)", $lastName) `
        -replace "your@email\.com", $email) `



Write-Output $registryData | Out-File -Encoding UTF8 -Force $tempFile
reg.exe import $tempFile
Remove-Item $tempFile

function getAbsentHosts($currentHosts) {

    $absentHosts = ""

    foreach ($target in (
            "127.0.0.1           registeridm.com",
            "127.0.0.1           www.registeridm.com",
            "127.0.0.1           secure.registeridm.com",
            "127.0.0.1           www.internetdownloadmanager.com",
            "127.0.0.1           secure.internetdownloadmanager.com",
            "127.0.0.1           mirror.internetdownloadmanager.com",
            "127.0.0.1           mirror2.internetdownloadmanager.com",
            "127.0.0.1           mirror3.internetdownloadmanager.com"
        )) {
        $found = $false;
        foreach ($currentHost in $currentHosts) {

            if ($target -eq $currentHost) {
                $found = $true;
                break;
            }
        }
        if (!$found) {
            $absentHosts += $target + "`n";
        }
    }
    return $absentHosts;
}



if (promptForChoice "Do you want to disable the counterfeit serial key by letting us edit your host file?") {

    $hostFile = "${env:WINDIR}\system32\drivers\etc\hosts"

    $rawContent = (Get-Content $hostFile)

    if ($null -eq $rawContent) {
        $rawContent = ""
    }

    $hostFileContents = $rawContent.Split("`r`n")
    $isHostFileReadOnly = (Get-ChildItem -Path $hostFile).IsReadOnly
    $stateChange = $false

    $newHosts = getAbsentHosts($hostFileContents)

    if ($newHosts -eq "") {
        Write-Output "Will not edit the host file as it already blocks the IDM registration checks."
        exit
    }

    if ($isHostFileReadOnly) {
        attrib.exe -r $hostFile
        $stateChange = $true
    }
    Write-Output $newHosts >> $hostFile
    
    if ($stateChange) {
        attrib.exe +r $hostFile
    }
    else {
        if (promptForChoice "Change the host file to be read-only, this will prevent IDM from tampering with it on startup?") {
            attrib.exe +r $hostFile
        }
    }
}
