@echo off

REM Go to project root (folder where this script is located)
cd /d %~dp0

flutter build windows

REM Path to the Flutter Windows release build
set RELEASE_DIR=build\windows\x64\runner\Release

REM Name of the zip file
set ZIP_NAME=NotebookApp.zip

REM Remove old zip if it exists
if exist %ZIP_NAME% del %ZIP_NAME%

echo Creating ZIP package...

powershell -Command "Compress-Archive -Path '%RELEASE_DIR%\*' -DestinationPath '%ZIP_NAME%'"

echo.
echo Package created: %ZIP_NAME%
pause