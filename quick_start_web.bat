@echo off
title Tournament App - Web Quick Start
echo ========================================
echo    INICIO RAPIDO - APLICACION WEB
echo ========================================
echo.

:: Cambiar al directorio del proyecto
cd /d "%~dp0"

:: Verificar Flutter
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter no instalado. Ver README_SETUP.md
    pause
    exit /b 1
)

echo [INFO] Instalando dependencias...
flutter pub get

echo.
echo [INFO] Iniciando servidor web...
echo [INFO] Abriendo en: http://localhost:8080
echo [INFO] Presiona Ctrl+C para detener
echo.

start http://localhost:8080
flutter run -d chrome --web-port=8080

pause