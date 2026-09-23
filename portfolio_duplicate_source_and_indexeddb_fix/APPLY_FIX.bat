@echo off
setlocal
set "FIX_DIR=%~dp0"
set "PROJECT_ROOT=%~dp0"

if exist "%PROJECT_ROOT%pubspec.yaml" goto root_found
if exist "%PROJECT_ROOT%..\pubspec.yaml" (
  for %%I in ("%PROJECT_ROOT%..") do set "PROJECT_ROOT=%%~fI\"
  goto root_found
)

echo.
echo ERROR: Put the extracted fix folder directly inside the Flutter project folder.
echo The project folder must contain pubspec.yaml, lib, and web.
pause
exit /b 1

:root_found
cd /d "%PROJECT_ROOT%"
echo Applying the portfolio storage fix in:
echo %PROJECT_ROOT%
echo.

if not exist "lib\services" mkdir "lib\services"
copy /Y "%FIX_DIR%_fix_payload\pubspec.yaml" "pubspec.yaml" >nul
copy /Y "%FIX_DIR%_fix_payload\lib\services\project_persistence_web.dart" "lib\services\project_persistence_web.dart" >nul

rem These are duplicate Flutter source folders incorrectly placed inside web.
rem They make VS Code keep showing the obsolete dart:indexed_db import.
if exist "web\lib" rmdir /S /Q "web\lib"
if exist "web\test" rmdir /S /Q "web\test"

echo Cleaning Flutter generated files...
call flutter clean
if errorlevel 1 goto flutter_error

echo Downloading the idb_shim dependency...
call flutter pub get
if errorlevel 1 goto flutter_error

echo.
echo FIX APPLIED SUCCESSFULLY.
echo Close and reopen VS Code, then run:
echo flutter run -d chrome --web-port 8080
pause
exit /b 0

:flutter_error
echo.
echo Flutter could not complete the command.
echo Confirm Flutter is installed and available in PATH, then run this file again.
pause
exit /b 1
