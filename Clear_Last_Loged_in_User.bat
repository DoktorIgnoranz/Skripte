@echo off
goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions...
    
    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
    ) else (
        echo Failure: Current permissions inadequate.
	pause >nul 
	 echo Press any Key to exit
	exit /b 0
    )
    	echo Press any Key to Continue
    pause >nul


@echo off

reg delete  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\ /v LastLoggedOnDisplayName /f
reg delete  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\ /v LastLoggedOnSAMUser /f
reg delete  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\ /v LastLoggedOnUser /f
reg delete  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\ /v LastLoggedOnUserSID /f

shutdown -L
