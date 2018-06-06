# Definitions
$GamePath = "C:\steamcmd\steamapps\common\conan exiles dedicated server"
$BackupLocation = "<Directory Path Here>"
$ConanProcess = Get-Process ConanSandboxServer-Win64-Test -ErrorAction SilentlyContinue
$CurrentVersion = Get-Content "$GamePath\currentversion.txt"
$Date = Get-Date -format "dd-MMM-yyyy-HH-mm"
$ServerName = "<Server Name Here>"
$SteamCMDPath = "C:\steamcmd"
Remove-Item "$SteamCMDPath\appcache\*.vdf"

Function NeedsUpdate() {
    $SteamCMD = & $SteamCMDPath\SteamCMD.exe +login anonymous +app_info_update 1 +app_info_print 443030 +app_info_print 443030 +quit | Select-String -Context 0,5 "branches" | foreach-object {$_.Context.Postcontext} | Select-String "BuildID"
    $A,$B,$C,$D = $SteamCMD -split """		"""
    $BuildID = $B -replace '"',''
    if ( $CurrentVersion -eq $BuildID)
    {
        return $false
    }
    else
    {
        $BuildID | Out-File "$GamePath\currentversion.txt"
        return $true
    }
}

Function BackUp() {
    Copy-Item "$GamePath\ConanSandbox\Saved\game.db" "$GamePath\ConanSandbox\Saved\game-$Date-updated-server.db"
}

Function DirectoryBackUp() {
$CurrentDate = Get-Date -UFormat %G-%m-%d
$Source = "$GamePath\ConanSandbox\Saved"
$DirectoryDestination = "$BackupLocation\$ServerName-Backup-$CurrentDate.zip"

Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($Source, $DirectoryDestination) 
}

Function RunServer() {
    & "$GamePath\ConanSandboxServer.exe" -log
}

Function ShutdownServer() {
$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate("ServerName" - Conan Exiles - press Ctrl+C to shutdown")
$wshell.SendKeys('^{C}')
}

Function UpdateServer() {
    & $SteamCMDPath\SteamCMD.exe +login anonymous +force_install_dir "$GamePath" +app_update 443030 validate +quit
}

Function Midnight() {
((Get-Date -UFormat %R) -eq '00:00') 
}


Function Main () {
    if (NeedsUpdate)
    {
        if ($ConanProcess) {& C:\Users\Zalaxy\Desktop\DiscordNotification.ps1 Start-Sleep -s 300 ShutdownServer}      
        Start-Sleep -s 300
        ShutdownServer
        Start-Sleep -s 15
        BackUp
        Start-Sleep -s 10
        UpdateServer
        Start-Sleep -s 120
        RunServer
        exit
    }elseif(Midnight) {
        ShutdownServer
        Start-Sleep -s 15
        DirectoryBackUp
        Start-Sleep -s 10
        RunServer
    }else    {
        if ( -Not $ConanProcess ) { RunServer }
        exit
    }
}

Main
