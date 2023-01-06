@echo off

reg delete  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\ /v LastLoggedOnDisplayName /f
reg delete  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\ /v LastLoggedOnSAMUser /f
reg delete  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\ /v LastLoggedOnUser /f
reg delete  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\ /v LastLoggedOnUserSID /f

shutdown -s -t 15
