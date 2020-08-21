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

:: Get oculus install dir from the registry
FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKLM\SOFTWARE\WOW6432Node\Oculus VR, LLC\Oculus" /v Base`) DO (
    set oculusdir=%%A %%B
)
:: Remove blank space at the end, if present
if "%oculusdir:~-1%" EQU " " (
    set oculusdir=%oculusdir:~0,-1%
)
:: Execute oculus uninstaller
"%oculusdir%OculusSetup.exe" /uninstall
:: Restore hosts file
copy "%cd%\hosts" "%windir%\System32\drivers\etc\hosts" /y

PAUSE