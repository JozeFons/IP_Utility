@echo off
  mode con:cols=140 lines=1000

  set appcount="wmic process where name="IP_Utility.exe" | find "IP_Utility.exe" /c"
  for /f "tokens=*" %%i in (' %appcount% ') do set app=%%i

  if %app% gtr 1  ( goto :window
  ) else          (  goto :start
  )

  :window
  set "select="
  echo Already another instance is running... / Jedno okno aplikacie je uz aktualne otvorene...
  echo.
  set /p select="Do you want to open another instance? / Chcete otvorit dalsie okno aplikacie?  [Yes/No] : " 
  echo.

  call :isCorrect

  if "%wrong_input%" == "true" cls && goto :window

  if "%select%" == "NO"         ( goto exit
  ) else if "%select%" == "YES" ( goto :start
  )

  :start

  :ADAPTER_SELECTION
  cls
  setlocal EnableDelayedExpansion
  echo "======================================================================================================"
  echo    ver.1.3
  echo    Script created by: Jozef Fons
  echo    This script is free of charge. 
  echo    If you wish you can donate for a coffee on the BTC address below. Thanks and enjoy. =D
  echo    BTC: bc1qqepz4jcdxuqkjw60pqm9gq0are65yzf5qur5dw
  echo "======================================================================================================"
  echo                         Network adapter selection / Vyber sietoveho adaptera
  echo "======================================================================================================"

  set counter=0
  set "select="

  for /f "delims=" %%a In (' WMIC NIC Where "(Not NetConnectionStatus Is Null)" Get NetconnectionID ^| more +1 ') Do (
    for /f "Tokens=*" %%b In ("%%a") Do (
      for %%0 in ("%%b") do (
        set /a counter=counter+1
        set choice[!counter!]=%%0
      )
    )
  )
  
  for /l %%c in (1,1,!counter!) do (
    echo [%%c] !choice[%%c]!
  )

  if %counter% == 0 (
    echo.
    echo "Didn't find any network adapter... / Nenasiel sa ziadny sietovy adapter..."
    echo.
    SET /p a=Press ENTER to continue...
    goto :ADAPTER
  )

  echo "======================================================================================================"
  echo.
  set /p select= "Select a number of a network adapter 1 - %counter% / Vyber nejake cislo sietoveho adaptera 1 - %counter%: "

  set ID=!choice[%select%]!
  set ID=%ID: =%

  call :isValid

  if "%wrong_input%" == "true" cls && goto :ADAPTER_SELECTION 

  echo.
  echo "You selected network adapter / Vybral si sietovy adapter >>>> %ID%" 
  echo.

  call :Connection_status

  if "%adapter%" == "Disconnected" (
    msg * Network adapter %ID% is disconnected... /!^! Sietovy adapter %ID% je odpojeny...
  )

  SET /p a=Press ENTER to continue...
  
  goto :MENU
  
  :ADAPTER
  set "select="
  echo.
  set /p select="Do you want to open network adapter window? / Chcete otvorit okno sietovych adapterov?  [Yes/No] : " 
  echo.

  call :isCorrect

  if "%wrong_input%" == "true" cls && goto :ADAPTER

  if "%select%" == "NO" ( 
    goto :MENU
  ) else if "%select%" == "YES" (
    echo Opening network adapter window... / Otvara sa okno sietovych adapterov...
    timeout /t 2 /nobreak > nul
    start ncpa.cpl
    goto :MENU
  )

  :MENU
  cls
  set counter=15
  set "select="
  setlocal EnableDelayedExpansion
  echo "======================================================================================================"
  echo                                                  MENU
  echo "======================================================================================================"
  echo                                  Choose an option / Vyber jednu z moznosti:
  echo "======================================================================================================"
  echo    1 Set Static IP / Nastav Staticku IP
  echo.
  echo    2 Set Dynamic IP / Nastav Dynamicku IP
  echo.
  echo    3 PING an IP / Skontroluj stav IP
  echo.
  echo    4 Network adapter settings window / Okno nastavania sietovych adapterov
  echo.
  echo    5 Interface connection status / Stav pripojenia rozhrania
  echo.
  echo    6 Detailed network interfaces status / Podrobny stav sietovych rozhrani
  echo.
  echo    7 Change Network adapter selection - actually selected is: %ID% 
  echo      Zmena vyberu sietoveho adaptera - aktualne vybrany je: %ID%
  echo.
  echo    8 Check Private, Public Ip and MAC address / Skontroluj privatnu, verejnu ip a mac adresu
  echo.
  echo    9 Show network adapter statistics / Zobraz statistiku sietoveho adaptera 
  echo.
  echo    10 Show active and inactive connections / Zobraz aktivne a neaktivne pripojenia 
  echo.
  echo    15 Exit / Koniec
  echo "======================================================================================================="
  echo.
  set /p select="Select one of the options 1 - 15 and press ENTER / Vyber jednu z moznosti 1 - 15 a stlac ENTER: "

  call :isValid
  
  if "%wrong_input%" == "true" goto :MENU
 
  echo.
  echo "You selected an option / Vybral si moznost >>>> %select%" 
  timeout /t 2 /nobreak > nul

  if /i %select% == 1         ( goto :STATIC
  ) else if /i %select% == 2  ( goto :DYNAMIC
  ) else if /i %select% == 3  ( goto :PING_IP
  ) else if /i %select% == 4  ( goto :ADAPTER 
  ) else if /i %select% == 5  ( goto :CHECK_INTERFACE
  ) else if /i %select% == 6  ( goto :CHECK_STATUS
  ) else if /i %select% == 7  ( goto :ADAPTER_SELECTION
  ) else if /i %select% == 8  ( goto :CHECK_PPM
  ) else if /i %select% == 9  ( goto :ADAPTER_STATISTICS
  ) else if /i %select% == 10 ( goto :A_I_CONNECTIONS
  ) else if /i %select% == 11 ( goto :ALL_PORTS_LISTENING
  ) else if /i %select% == 12 ( goto :ALL_PORTS
  ) else if /i %select% == 13 ( goto :PORT
  ) else if /i %select% == 14 ( goto :INTERFACE_LIST
  ) else if /i %select% == 15 ( goto Exit
  ) 

  :STATIC
  cls
  setlocal EnableDelayedExpansion
  
  set counter=0
  set "select="
  
  call :checkFile & call :ipList

  echo "======================================================================================================"
  echo.
  set /p select= "Select an IP address 1 - %counter% from the list / Vyber jednu z IP adries 1 - %counter% zo zoznamu: "
    
  set IPs=!choice[%select%]!
  
  call :isValid

  if "%wrong_input%" == "true" goto :STATIC
  
  for /f "delims=abcefghijklmnoprstuvqwzyABCDEFGHIJKLMNOPRSTUVQWZY:_=-*,;""" %%i in (%IPs%) do set IP=%%i
  
  echo.
  echo "You selected IP address / Vybral si IP adresu >>>> %IPs%" 
  echo.
  
  call :Connection_status

  echo Changing to a static IP... / Menim IP na staticku... %IP%
  netsh interface ip set address name= %ID% static %IP%
  netsh interface ip show config name= %ID%
  SET /p a=Press ENTER to continue...
  goto :ADAPTER

  :DYNAMIC
  cls

  call :Connection_status

  if "%adapter%" == "Connected" (
  goto :success
  ) else (
    SET /p a=Press ENTER to continue...
    goto :unsuccess
  )

  :unsuccess
  cls
  set counter=4
  set "select="
  echo.
  @rem netsh int ip set address name = %ID% source = dhcp
  echo "======================================================================================================"
  netsh interface ip show interfaces
  echo "======================================================================================================"
  echo    === Warning ===
  echo    Network adapter %ID% is disconnected... 
  echo    In case you want to change the status from STATIC to DHCP you must to CONNECT the adapter
  echo    OR you must switch to DHCP manually
  echo "======================================================================================================"
  echo    === Upozornenie ===
  echo    Sietovy adapter %ID% je odpojeny... 
  echo    V pripade ak chcete zmenit stav zo STATIC na DHCP musite PRIPOJIT sietovy adapter
  echo    ALEBO v inom pripade musite vykonat tuto zmenu manualne
  echo "======================================================================================================"
  echo    Choose an option / Vyber jednu z moznosti:
  echo "======================================================================================================"
  echo    1 Check again the connection status if you re-connected the adapter %ID%
  echo      Skontroluj znova stav pripojenia ak si obnovil pripojenie na sietovom adapteri %ID%
  echo.
  echo    2 Change the status from STATIC to DHCP manually / Zmen stav zo STATIC na DHCP manualne
  echo.
  echo    3 Go to MENU / Chod do hlavneho MENU
  echo.
  echo    4 Exit / Koniec
  echo "======================================================================================================"
  echo.
  set /p select= "Select one of the options 1 - 4 and press ENTER / Vyber jednu z moznosti 1 - 4 a stlac ENTER: "

  call :isValid

  if "%wrong_input%" == "true" goto :unsuccess

  echo.
  echo "You selected an option / Vybral si moznost >>>> %select%" 
  timeout /t 2 /nobreak > nul

  if /i %select% == 1         ( goto :DYNAMIC
  ) else if /i %select% == 2  ( goto :ADAPTER
  ) else if /i %select% == 3  ( goto :MENU
  ) else if /i %select% == 4  ( goto Exit 
  )

  :success
  setlocal EnableDelayedExpansion
  echo.
  set _DHCP_=""
  for /f "tokens=2 delims=:" %%g in ('netsh interface ip show addresses %ID% ^| findstr "DHCP enabled:"') do set _DHCP_=%%g
  
  set _DHCP=!_DHCP_!
  set _DHCP=!_DHCP: =!
  
  if "%_DHCP%"=="No" (
    echo DHCP is not enabled...
    echo.
    echo Changing to a dynamic IP... / Menim na dynamicku IP...
    netsh int ip set address name = %ID% source = dhcp
    netsh interface ip show config name= %ID%
  ) else if "%_DHCP%"=="Yes" (
    echo DHCP is already enabled...
    echo.
    netsh int ip set address name = %ID% source = dhcp
    netsh interface ip show config name= %ID%
    echo.
  ) else (
    echo DHCP was not found for this interface. Please check the interface name.
  )
  SET /p a=Press ENTER to continue...
  goto :ADAPTER

  :PING_IP
  cls
  setlocal EnableDelayedExpansion
  
  set counter=0
  set "select="

  call :checkFile & call :ipList

  echo "======================================================================================================"
  echo.
  set /p select= "Select an IP address 1 - %counter% from the list / Vyber jednu z IP adries 1 - %counter% zo zoznamu: "
  
  set IPs=!choice[%select%]!

  call :isValid

  if "%wrong_input%" == "true" goto :PING_IP

  for /f "delims=abcefghijklmnoprstuvqwzyABCDEFGHIJKLMNOPRSTUVQWZY:_=-*,;""" %%i in (%IPs%) do set IP=%%i
  
  ::set IP=!IP1!
  ::set IP=!IP:~0,-1!
  echo.
  echo "You selected IP address / Vybral si IP adresu >>>> %IPs%"
  echo.
  
  call :Connection_status

  if "%adapter%" == "Connected" (
  echo Pinging IP... %IP% / Kontrola stavu IP... %IP%
  ping %IP%
  timeout /t 1 /nobreak > nul
  @rem netsh interface ip show config name= %ID%
  goto :OPTIONS
  ) else (
    SET /p a=Press ENTER to continue...
    goto :OPTIONS
  )
  
  :OPTIONS
  setlocal EnableDelayedExpansion
  set counter=4
  set "select="
  echo.
  echo "======================================================================================================"
  echo    Choose an option / Vyber jednu z moznosti:
  echo "======================================================================================================"
  echo    1 PING again another IP address / Skontroluj znova stav inej IP adresy
  echo.
  echo    2 Select another network adapter / Vyber iny sietovy adapter
  echo.
  echo    3 Go to MENU / Chod do hlavneho MENU
  echo.
  echo    4 Exit / Koniec
  echo "======================================================================================================"
  echo.
  set /p select= "Select one of the options 1 - 4 and press ENTER / Vyber jednu z moznosti 1 - 4 a stlac ENTER: "

  call :isValid

  if "%wrong_input%" == "true" cls && goto :OPTIONS

  echo.
  echo "You selected an option / Vybral si moznost >>>> %select%"
  timeout /t 2 /nobreak > nul

  if /i %select% == 1         ( goto :PING_IP
  ) else if /i %select% == 2  ( goto :ADAPTER_SELECTION
  ) else if /i %select% == 3  ( goto :MENU
  ) else if /i %select% == 4  ( goto Exit 
  )

  :CHECK_INTERFACE
  cls
  echo.
  echo Showing the interface connection status... / Zobrazujem stav pripojenia sietovych rozhrani...
  echo.
  echo "======================================================================================================"
  netsh interface ip show interfaces
  echo "======================================================================================================"
  echo.
  SET /p a=Press ENTER to continue...
  goto :MENU

  :CHECK_STATUS
  cls
  echo Showing detailed network interface status... / Zobrazujem detailny stav sietovych rozhrani...
  echo "======================================================================================================"
  ipconfig /all
  echo "======================================================================================================"
  echo.
  SET /p a=Press ENTER to continue...
  goto :MENU

  :CHECK_PPM
  cls
  echo.
  echo Showing (LAN ,Public)(IP) and MAC addresses ...
  echo.
  ::Set "LogFile=%~dpn0.txt"
  for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do (
    set "LAN_IP=%%a"
  )

  for /f "tokens=2 delims=: " %%A in (
    'nslookup myip.opendns.com. resolver1.opendns.com 2^>NUL^|find "Address:"'
  ) Do set ExtIP=%%A

  echo "======================================================================================================"
  echo  My Private LAN IP       : %LAN_IP%
  echo  My External Public IP   : %ExtIP%
  echo "======================================================================================================"
  wmic nic where PhysicalAdapter=True get MACAddress,NetConnectionID
  echo "======================================================================================================"
  echo.
  ::(
   :: echo My Private LAN IP      : %LAN_IP%
  ::  echo My External Public IP  : %ExtIP%
   :: echo MAC Address            : %MY_MAC%

  ::)>"%LogFile%"
  ::timeout /T 1 /NoBreak>nul
  ::Start "" "%LogFile%"
  SET /p a=Press ENTER to continue...
  goto :MENU

  :ADAPTER_STATISTICS
  cls
  echo.
  echo "======================================================================================================"
  echo    For process interuption press Ctrl + C / Stlacte klavesnice Ctrl + C pre prerusenie procesu
  echo             Then press ,n'- ,No' to interupt process or ,y'- ,Yes' to exit the script
  echo            Potom stlac ,n'- ,Nie' pre prerusenie alebo ,y'- ,Ano' pre ukoncenie scriptu
  echo "======================================================================================================"
  netstat -es
  echo "======================================================================================================"
  echo.
  SET /p a=Press ENTER to continue...
  goto :MENU

  :A_I_CONNECTIONS
  cls
  echo.
  echo "======================================================================================================"
  echo    For process interuption press Ctrl + C / Stlacte klavesnice Ctrl + C pre prerusenie procesu
  echo             Then press ,n'- ,No' to interupt process or ,y'- ,Yes' to exit the script
  echo            Potom stlac ,n'- ,Nie' pre prerusenie alebo ,y'- ,Ano' pre ukoncenie scriptu
  echo "======================================================================================================"
  netstat -a
  echo "======================================================================================================"
  echo.
  SET /p a=Press ENTER to continue...
  goto :MENU

  :ALL_PORTS_LISTENING
  cls
  echo.
  echo "======================================================================================================"
  netstat -ano | find "LISTENING"
  echo "======================================================================================================"
  echo.
  SET /p a=Press ENTER to continue...
  goto :MENU

  :ALL_PORTS
  cls
  echo.
  echo "======================================================================================================"
  netstat -ano
  echo "======================================================================================================"
  echo.
  SET /p a=Press ENTER to continue...
  goto :MENU

  :PORT
  cls
  echo "======================================================================================================"
  echo    For process interuption press Ctrl + C / Stlacte klavesnice Ctrl + C pre prerusenie procesu
  echo             Then press ,n'- ,No' to interupt process or ,y'- ,Yes' to exit the script
  echo            Potom stlac ,n'- ,Nie' pre prerusenie alebo ,y'- ,Ano' pre ukoncenie scriptu
  echo "======================================================================================================"
  netstat -b -o
  echo "======================================================================================================"
  echo.
  SET /p a=Press ENTER to continue...
  goto :MENU

  :INTERFACE_LIST
  cls
  echo.
  echo "======================================================================================================"
  netstat -r
  echo "======================================================================================================"
  echo.
  SET /p a=Press ENTER to continue...
  goto :MENU

  :checkFile
  cls
  echo "======================================================================================================"
  echo.
  echo    Reading IP.txt file...
  echo.

  if exist C:\IP_list\IP.txt (
    echo "======================================================================================================"
    echo    File exist... / Subor existuje...
    echo.
    echo    File path C:\IP_list\IP.txt
    echo "======================================================================================================"
    goto :eof
  ) else (
    echo "======================================================================================================"
    echo    File was not found.../ Subor nebol najdeny...
    echo "======================================================================================================"
    goto :dne
  )
  
  :ipList

  set counter=0

  for /f "delims=" %%x in (C:\IP_list\IP.txt) do (
    for %%0 in ("%%x") do (
      set /a counter=counter+1
      set choice[!counter!]=%%0
    )
  ) 

  for /l %%x in (1,1,!counter!) do (
    echo [%%x] !choice[%%x]!
  )

  if %counter% == 0 (
    echo.
    echo "Didn't find any IP address in the list... / Nenasla sa ziadna IP adresa..."
    echo
    SET /p a=Press ENTER to add addresses into the list... / Stlacte ENTER na pridanie IP adries do listu...
    goto :repeat
  ) else (
    goto :eof 
  )

  :isValid

  set "wrong_input="

  @REM echo %select%| findstr /r /x /c:"|',:;[()&'`\"]"""">nul && (
  @REM   echo Iinvalid input... Allowed input numbers are 1 - %counter% ONLY!!!    
  @REM   timeout /t 2 /nobreak > nul
  @REM   set "wrong_input=true"
  @REM   goto :eof
  @REM )

  echo %select%| findstr /r "^[1-9][0-9]*$">nul || (
    echo Invalid input... Allowed input numbers are 1 - %counter% ONLY!!!    
    timeout /t 2 /nobreak > nul
    set "wrong_input=true"
    goto :eof
  )
    
  if %select% gtr %counter% (
    echo Invalid input... Allowed input numbers are 1 - %counter% ONLY!!!
    set "wrong_input=true"
    timeout /t 2 /nobreak > nul
    goto :eof
  ) else (
    set "wrong_input=false"
    goto :eof
  )

  :dne

  set "select="
  echo.
  set /p select= "Do you want to create IP.txt file in IP_list folder in C:\ ? / Chcete vytvorit subor IP.txt v slozke IP_list a v priecinku C:\?  [Yes/No] : "
  echo.
  
  call :isCorrect

  if "%wrong_input%" == "true" goto :checkFile

  if "%select%" == "YES" (
    echo Creating IP_list file with IP.txt in C:\ local disk...
    timeout /t 2 /nobreak > nul
    md C:\IP_list
    echo .> "C:\IP_list\IP.txt"
    goto :repeat
  ) else if "%select%" == "NO" (
    echo "======================================================================================================"
    echo    Read "Readme" before first launch / Citaj "Readme" pred prvym spustenim...
    echo    Manually create or copy from source the IP_list folder with IP.txt file and paste into C:\ folder
    echo    C:\IP_list\IP.txt
    echo "======================================================================================================"
    echo.
    SET /p a=Press ENTER to continue...
    start C:\
    goto :MENU
  ) else (
    goto :checkFile
  )
  
  :repeat

  set "select="
  set "wrong_input="
  echo.
  set /p select="Do you want to open the IP.txt ? / Chcete otvorit subor IP.txt ?  [Yes/No] : " 

  call :isCorrect

  if "%wrong_input%" == "true" cls && goto :repeat

  if "%select%" == "YES"        ( start C:\IP_list\IP.txt && call :create_list
  ) else if "%select%" == "NO"  ( call :create_list && goto :checkFile
  )

  echo.
  SET /p a=Write a desired IP addresses to the IP.txt file and Press ENTER to continue...
  goto :checkFile

  :Connection_status
  set "adapter="
  netsh interface show interface name=%ID% ^ |find "Connected">nul ^ && goto :connected ^ || goto :disconnected

  :connected
  set "adapter=Connected"
  echo Network adapter  %ID% is connected / Sietovy adapter %ID% je pripojeny
  echo.
  @rem timeout /t 2 /nobreak > nul
  goto :eof

  :disconnected
  set "adapter=Disconnected"
  echo Network adapter %ID% is disconnected / Sietovy adapter %ID% je odpojeny...
  @rem msg * Network adapter %ID% is disconnected... / !^!Sietovy adapter %ID% je odpojeny...
  echo.
  @rem timeout /t 2 /nobreak > nul
  goto :eof

  :isCorrect

  set "wrong_input="

  echo %select% | findstr "Yes yes YES Y y No no NO N n" >nul || (
    echo "Invalid input... Allowed capital or lower letters ONLY such as (Yes, yes, YES, Y, y, No, no, NO, N, n) ..."  
    timeout /t 3 /nobreak > nul
    set "wrong_input=true"
    goto :eof
  )
  
  if /i "%select%" == "" set "wrong_input=true" && goto :eof
  if NOT '%select%'=='' set select=%select:~0,1%

  if /i '%select%'=='Y'           ( goto :YES 
  ) else if /i '%Select%'=='y'    ( goto :YES
  ) else if /i '%select%'=='yes'  ( goto :YES
  ) else if /i '%select%'=='Yes'  ( goto :YES
  ) else if /i '%select%'=='YES'  ( goto :YES
  ) else if /i '%select%'=='N'    ( goto :NO
  ) else if /i '%select%'=='n'    ( goto :NO
  ) else if /i '%select%'=='no'   ( goto :NO
  ) else if /i '%select%'=='No'   ( goto :NO
  ) else if /i '%select%'=='NO'   ( goto :NO
  ) else (
    set "select="
    set "wrong_input=true"
    goto :eof
  )

  :YES
  set "select=YES"
  set "wrong_input=false"
  goto :eof

  :NO
  set "select=NO"
  set "wrong_input=false"
  goto :eof

  :create_list
  (
    echo 168.192.0.1 Write an IP address in exact format with a comment if you like
    echo 10.1.0.1 Privat address
    echo 196.245.151.217 Exhausts on H8 VW Porsche PLC3
    echo 196.245.151.218 PLC1
    echo 196.245.151.219 255.255.255.0 unknown
    echo 196.242.150.200 PLC4
  ) > "C:\IP_list\IP.txt"
  goto :eof

Exit
