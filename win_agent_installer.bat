@ECHO OFF
:: MSI Options: https://documentation.wazuh.com/3.x/installation-guide/installing-wazuh-agent/deployment_variables_windows.html

SET _managerAddress=""

:: Check if command arguments were used to set the Client Identifier.
:: This is appended to the PASSWORD option.
:: Also Check if help was requested

SET _TEST=false
IF [%1] == [?] (SET _TEST=true)
IF [%1] == [help] (SET _TEST=true)
IF [%_TEST%] == [true] (GOTO HELP)

IF [%1] == [] (
:: No %1 variable defined.  Request from user.
	set /p _managerPass="Enter Auth Server Password:"
) ELSE (
	:: Store %1 in our own variable for readability
	SET _managerPass=%1
)


:: This is appended to the Agent Name and Agent Group options.

IF [%2] == [] (
:: No %2 variable defined.  Request from user.
	set /p _identifier="Enter Client Identifier (Ex. SomeCompany)"
) ELSE (
:: Store %2 in our own variable for readability
	SET _identifier=%2
)

:: Set the hostname as a variable for concatenation into Agent Name option.

FOR /F %%H IN ('hostname') DO SET _hostname=%%H

:: Install Wazuh MSI Package

CALL msiexec.exe /i PACKAGENAME.msi /q ADDRESS="%_managerAddress%" AUTHD_SERVER="%_managerAddress%" PASSWORD="%_managerPass%" AGENT_NAME="%_identifier%-%_hostname%" /l installer.log
"C:\Progra~2\ossec-agent\agent-auth.exe" -m %_managerAddress% -P %_managerPass% -I any -A %_identifier%-%_hostname%
net stop wazuh
net start wazuh
ECHO Agent Installed
GOTO :EOF

:HELP
ECHO Usage: win_agent_installer.bat authPassword clientIdentifier
ECHO Run as Administrator
ECHO Execute from directory containing agent installer MSI
