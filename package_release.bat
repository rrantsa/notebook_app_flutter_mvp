@echo off
setlocal

cd /d "%~dp0"

call flutter build windows
if errorlevel 1 (
    echo Build failed.
    pause
    exit /b 1
)

set "RELEASE_DIR=%CD%\build\windows\x64\runner\Release"
set "ZIP_NAME=%CD%\NotebookApp.zip"

if not exist "%RELEASE_DIR%" (
    echo Release folder not found: "%RELEASE_DIR%"
    pause
    exit /b 1
)

if exist "%ZIP_NAME%" del /f /q "%ZIP_NAME%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Compress-Archive -Path '%RELEASE_DIR%\*' -DestinationPath '%ZIP_NAME%' -Force"

if errorlevel 1 (
    echo ZIP creation failed.
    pause
    exit /b 1
)

echo.
echo Package created successfully:
echo "%ZIP_NAME%"
pause