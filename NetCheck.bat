@ECHO OFF
:: Created by Patrick Seiter
::
:: Created on 2013-05-23 04:44 AM

:: File variables
SET HOME=%USERPROFILE%\netcheck\
SET LOCK=%HOME%netcheck.lck
SET RECORD=%HOME%record.txt
SET URLFILE=%HOME%website.txt

:: Iterative variables
SET WHILE=TRUE
SET ISDOWN=FALSE

:: Migrate script
IF NOT EXIST %HOME% MKDIR %HOME%
IF NOT %0==%HOME%%~n0%~x0 (
	REM PAUSE
	MOVE /Y %0 %HOME%%~n0%~x0
	START %HOME%%~n0%~x0
	GOTO :EOF
	REM DEL %0
)

:: If lock file exists, exit
IF EXIST %LOCK% EXIT /B

:: Check that URL and lock files exist
IF NOT EXIST %URLFILE% ECHO www.google.com > %URLFILE%
IF NOT EXIST %LOCK% ECHO. > %LOCK%

:: TODO: Return to current directory afterwards
CD %HOME%

:WHILE
SET /P URL=<%URLFILE%

ping -n 1 %URL%
SET EL=%ERRORLEVEL%

SETLOCAL ENABLEDELAYEDEXPANSION
IF %EL%==0 (
	IF %ISDOWN%==TRUE (
		SET UPTIME=%DATE%%TIME%
		
		ECHO !UPTIME! Internet UPTIME.
		ECHO "!DOWNTIME!--!UPTIME!" >> %RECORD%
	)
	SET WHILE=FALSE
) ELSE (
	IF %ISDOWN%==FALSE (
		SET DOWNTIME=%DATE%%TIME%
		SET ISDOWN=TRUE
		ECHO !DOWNTIME! Internet down.
	)
)
ENDLOCAL

IF %WHILE%==TRUE GOTO WHILE

IF EXIST %LOCK% DEL %LOCK%