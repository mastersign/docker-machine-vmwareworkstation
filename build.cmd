@ECHO OFF
SETLOCAL

::
:: This script builds the Go project and produces the
:: Docker Machine PlugIn docker-machine-driver-vmwareworkstation.exe
:: in the bin folder.
::
:: It is a simple replacement for the Makefile.
::

:: Configuration

SET ERROR_TIMEOUT=5
SET PROJECT_DIR=%~dp0
SET DRIVER_NAME=vmwareworkstation
SET GOOS=windows

:: Pre-Execution Checks ::

CALL:ASSERT_COMMAND go
IF ERRORLEVEL 1 GOTO:EARLY_ERROR

CALL:ASSERT_COMMAND dep
IF ERRORLEVEL 1 GOTO:EARLY_ERROR

:: Preparations ::

PUSHD %PROJECT_DIR%
ECHO.Downloading dependencies...
CALL dep ensure

:: ===================== Main Work ===================== ::

IF EXIST .\bin\ (
	ECHO.Removing existing output...
	RMDIR /S /Q .\bin
)

SET GOARCH=amd64
ECHO.Compiling main package for %GOARCH%...
CALL go build -i -o .\bin\docker-machine-driver-%DRIVER_NAME%-%GOARCH%.exe .\cmd\
IF ERRORLEVEL 1 GOTO:ERROR

SET GOARCH=386
ECHO.Compiling main package for %GOARCH%...
CALL go build -i -o .\bin\docker-machine-driver-%DRIVER_NAME%-%GOARCH%.exe .\cmd\
IF ERRORLEVEL 1 GOTO:ERROR

:: ===================================================== ::

:: Successful Exit ::

GOTO:END

:: Jump Points and Procedures ::

::
:: Procedure CLEANUP
:: Does everything necessary to leave a clean environment to the scripts caller.
::
:CLEANUP
POPD
GOTO:EOF

::
:: Jump Point END
:: Cleanup and exit the script with exit code 0
::
:END
CALL:CLEANUP
EXIT /B 0

::
:: Jump Point EARLY_ERROR
:: Exit the script with exit code 1
::
:EARLY_ERROR
ECHO.
ECHO.The preconditions were not fulfilled.
ECHO.The operation was canceled.
TIMEOUT %ERROR_TIMEOUT%
EXIT /B 1

::
:: Jump Point ERROR
:: Cleanup and exit the script with exit code 1
::
:ERROR
CALL:CLEANUP
ECHO.
ECHO.An error occured during the execution.
ECHO.The operation did not finish.
TIMEOUT %ERROR_TIMEOUT%
EXIT /B 1

::
:: Procedure ASSERT_COMMAND
:: Checks whether a command is in PATH.
:: Returns with ERRORLEVEL 1 if the command was not found.
::
:ASSERT_COMMAND
SET NAME=%1
WHERE %NAME% >NUL 2>&1
IF ERRORLEVEL 1 (
	ECHO.
	ECHO.The command '%NAME%' was not found in PATH.
	EXIT /B 1
)
EXIT /B 0
