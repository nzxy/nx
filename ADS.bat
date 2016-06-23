::ADS BATCH SCRIPT:
:: 1. Counts to 2000 and back.
:: 2. Reports a specified applications digital signature information using Sigcheck.
::       - Computers must be on the same domain and a text file must be made to specify which computers 
::         to run sigcheck on. Put the file in active directory and run the script as administrator.
::       - The script determines whether the computer is up or down by pinging and reporting its status. 
::       - The script creates a log in the C: folder under ADSlogs.
::       - Replace the executable and log file directories to report on other applications. 
::         The default application is Quicktime. 
:: 3. Exits the script.

@echo off
setlocal enabledelayedexpansion
set /a num=0


:start
cls
echo 1=Count from 1 to 2000 and back!!!
echo 2=Check Application Digital Signature.
echo 3=Exit the program!

set /p a=
if %a%==1 goto a
if %a%==2 goto b
if %a%==3 goto c
echo Incorrect Input.
pause
goto start


:a
cls
set /a num=%num%+1
echo %num%
if %num%==2000 goto goback
goto a

:goback
cls
set /a num=%num%-1
echo %num%
if %num%==0 goto start
goto goback


:b
mkdir c:\ADSlogs 2>nul
echo(  >> c:\ADSlogs\log.txt
echo * >> c:\ADSlogs\log.txt
echo --------------------------- >> c:\ADSlogs\log.txt

set /p txtfile="Enter the name of the text file you want to run the script on: "
echo Processing %txtfile% ...
echo Script is processing the computers listed in %txtfile% >> c:\ADSlogs\log.txt
echo --------------------------- >> c:\ADSlogs\log.txt

for /f %%i in (%txtfile%) do  (
  
  if exist x:\     (
     net use x: /delete
  )
  
  set comp_name=%%i
  set state=down
  echo Comp Name is !comp_name!
  echo Comp Name is !comp_name! >> c:\ADSlogs\log.txt  

  echo Pinging !comp_name!...
  echo Pinging !comp_name!... >> c:\ADSlogs\log.txt
  for /f "tokens=5,7" %%a in ('ping -n 1 !comp_name!') do   (
    if "x%%a"=="xReceived" if "x%%b"=="x1," set state=up
  )
  echo !comp_name! was !state! >> c:\ADSlogs\log.txt

  if exist x:\     (
     net use x: /delete
  )

  echo mapping x drive
  net use x: \\!comp_name!\c$ 

  if "!state!"=="up"    (
    echo Checking application installation logs...
    echo Checking application installation logs... >> c:\ADSlogs\log.txt
    if exist x:\ sigcheck.exe -ct "x:\Program Files (x86)\QuickTime\QuickTimePlayer.exe" >> c:\ADSlogs\log.txt
        echo !comp_name! file check complete >> c:\ADSlogs\log.txt
        xcopy x:\Windows\AppLogs\NG_QuickTm7*.* c:\ADSlogs\!comp_name!\ /Y
        echo !comp_name! logs copied to C:\ADSlogs >> c:\ADSlogs\log.txt

  if exist x:\     (
     net use x: /delete
  )

  )

  echo --------------------------- >> c:\ADSlogs\log.txt
)

if exist x:\     (
  net use x: /delete
)

pause
goto start


:C
cls
echo Goodbye!
pause
break

