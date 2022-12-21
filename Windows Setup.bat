@echo off
echo             Windows basic Setup
echo             ===================
echo.
echo   [1] Basic Setup
echo   [2] Cancel
echo.
set asw=0
set /p asw="Please select: "
if %asw%==1 goto Basic Setup
if %asw%==2 goto ENDE
goto END

:Basic Setup
@Echo off
Start instalation

::Owner setzen, Internetstartseite ändern
mkdir "%temp%\setup"
set /p NAME=Kundenname:
echo Windows Registry Editor Version 5.00>>"%temp%\setup\RegOwner.reg"
echo.>>"%temp%\setup\RegOwner.reg"
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion]>>"%temp%\setup\RegOwner.reg"
echo "RegisteredOrganization"="%NAME%">>"%temp%\setup\RegOwner.reg"
echo "RegisteredOwner"="%NAME%">>"%temp%\setup\RegOwner.reg"
echo [HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main]>>"%temp%\setup\RegOwner.reg"
echo.>>"%temp%\behle\RegOwner.reg">>"%temp%\setup\RegOwner.reg"
echo y|REG IMPORT "%temp%\setup\RegOwner.reg"
rmdir /s /q "%temp%\setup"

::Software instalation
"replace with network path"

::open User account control settings
cls
UserAccountControlSettings.exe
wscui.cpl

::start Mediaplayer, Internet Explorer
cls
start iexplore.exe  
start wmplayer.exe 

goto END
 
start wuapp.exe
winver.exe
UserAccountControlSettings.exe
wscui.cpl
control.exe system
start iexplore.exe  
start wmplayer.exe 
start AcroRd32.exe
goto END


:ENDE
goto END

:END
