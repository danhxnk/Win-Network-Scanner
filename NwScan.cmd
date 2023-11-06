@ECHO OFF
:: Define these variables. 
::		NW should be set to the first 3 bytes of the network you want to scan. For a 24 bit network of 192.168.1.0 set this to 192.168.1 
::		DNS1 should set to your DNS server usually your router/gateway.
::		DNS2 is optional.
SET NW=192.x.x
SET DNS1=192.x.x.x
SET DNS2=

::Reload NBT Cache
NbtStat -R > NUL

cls && for /l %%a in (1,1,254) do @for /f "tokens=3 delims=: " %%a in ('ping %NW%.%%a -n 1 -w 60  ^| find /i "ttl"') Do SET IP=%%a && Call :Step

Goto End

:Step
curl http://%IP% --connect-timeout 0.5 > NUL 2> NUL
IF %ERRORLEVEL% EQU 0 (ECHO %IP% http status: Port 80 Open)	ELSE (ECHO %IP% http status: Port 80 Closed)

curl https://%IP% --connect-timeout 0.5 > NUL 2> NUL
IF %ERRORLEVEL% EQU 0 (ECHO %IP% https status: Port 443 Open)	ELSE (ECHO %IP% https status: Port 443 Closed)
for /f "tokens=2" %%a in ('nslookup %IP% %DNS1% ^| FIND /i "Name"') Do ECHO %IP% DNS1 Resolution: %%a
IF "%DNS2%" NEQ "" for /f "tokens=2" %%a in ('nslookup %IP% %DNS2% ^| FIND /i "Name"') Do ECHO %IP% DNS2 Resolution: %%a
for /f "tokens=2" %%a in ('ping -a %IP% -w 60 -n 1 ^| FIND /i "Pinging"') DO ECHO %IP% Ping Resolution: %%a 
for /f "tokens=2" %%a in ('arp -a ^| FIND "%IP%"') do SET MAC=%%a && echo %IP% MAC Address: %%a
for /f "tokens=*" %%a in ('curl -get https://api.maclookup.app/v2/macs/%MAC:~0,9%00-00-00/company/name -s') do ECHO %IP% Nic Vendor: %%a
ECHO.

:End