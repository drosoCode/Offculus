@echo off

:: https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    

:: Restore registry entries
regedit /s "%cd%\registry\oculus.reg"
regedit /s "%cd%\registry\uninstall.reg"
:: Get install dir from registry
FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKLM\SOFTWARE\WOW6432Node\Oculus VR, LLC\Oculus" /v Base`) DO (
    set oculusdir=%%A %%B
)
:: Remove blank space at the end, if present
if "%oculusdir:~-1%" EQU " " (
    set oculusdir=%oculusdir:~0,-1%
)
:: Ask for install dir
set /p installpath="Install Path [ENTER for %oculusdir%]:"
if "%installpath%" EQU "" (
    set installpath=%oculusdir%
) else (
    :: If not default install dir, replace install dir in registry
    reg add "HKLM\SOFTWARE\WOW6432Node\Oculus VR, LLC\Oculus" /t REG_SZ /v Base /f /d "%installpath%\"
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Oculus" /t REG_EXPAND_SZ /v DisplayIcon /f /d "%installpath%OculusSetup.exe"
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Oculus" /t REG_EXPAND_SZ /v InstallLocation /f /d "%installpath%\"
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Oculus" /t REG_EXPAND_SZ /v ModifyPath /f /d "%installpath%OculusSetup.exe /repair"
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Oculus" /t REG_EXPAND_SZ /v UninstallString /f /d "%installpath%OculusSetup.exe /uninstall"
)
:: Copy Oculus software
Xcopy /E "%cd%\Oculus" "%installpath%\" /y
:: Restore AppData backup
Xcopy /E "%cd%\appdata\Local\Oculus" "%appdata%\..\Local\Oculus\" /y
Xcopy /E "%cd%\appdata\Roaming\Oculus" "%appdata%\Oculus\" /y
:: Install Drivers
"%installpath%Support\oculus-drivers\oculus-driver.exe"
:: Add Environment Variables
setx /M PATH "%PATH%;%installpath%Support\oculus-runtime"
setx /M OculusBase "%installpath%\"
:: Install OVRService
"%installpath%Support\oculus-runtime\OVRServiceLauncher.exe" -install -start
:: Set OVRService start to manual
sc config OVRService start=demand
:: Backup hosts file
copy "%windir%\System32\drivers\etc\hosts" "%cd%\hosts"
:: Block facebook and oculus services
echo 127.0.0.1 graph.oculus.com >> "%windir%\System32\drivers\etc\hosts"
echo 127.0.0.1 edge-mqtt.facebook.com >> "%windir%\System32\drivers\etc\hosts"
echo 127.0.0.1 scontent.oculuscdn.com >> "%windir%\System32\drivers\etc\hosts"
echo 127.0.0.1 securecdn.oculus.com >> "%windir%\System32\drivers\etc\hosts"
echo 127.0.0.1 graph.facebook.com >> "%windir%\System32\drivers\etc\hosts"

PAUSE