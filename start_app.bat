@echo off
title Tournament App Launcher
echo ========================================
echo    FLUTTER TOURNAMENT APP LAUNCHER
echo ========================================
echo.

:: Verificar si Flutter esta instalado
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter no encontrado en el sistema
    echo Por favor instala Flutter y agregalo al PATH
    echo Guia: README_SETUP.md
    pause
    exit /b 1
)

:: Cambiar al directorio del proyecto
cd /d "%~dp0"

echo [INFO] Verificando Flutter...
flutter doctor --version

echo.
echo [INFO] Instalando dependencias...
flutter pub get

echo.
echo ========================================
echo   SELECCIONA PLATAFORMA DE EJECUCION
echo ========================================
echo 1. Web (Chrome) - Recomendado
echo 2. Android (Emulador/Dispositivo)
echo 3. Windows (Escritorio)
echo 4. Compilar APK para distribucion
echo 5. Ver dispositivos disponibles
echo ========================================
set /p choice="Selecciona una opcion (1-5): "

if "%choice%"=="1" goto web
if "%choice%"=="2" goto android
if "%choice%"=="3" goto windows
if "%choice%"=="4" goto build
if "%choice%"=="5" goto devices

echo [ERROR] Opcion invalida
pause
exit /b 1

:web
echo.
echo [INFO] Iniciando en navegador web...
echo [INFO] La app se abrira en http://localhost:PORT
echo [INFO] Presiona Ctrl+C para detener
flutter run -d chrome --web-port=8080
goto end

:android
echo.
echo [INFO] Iniciando en Android...
echo [INFO] Asegurate de tener un emulador activo o dispositivo conectado
flutter run
goto end

:windows
echo.
echo [INFO] Iniciando aplicacion de escritorio Windows...
flutter run -d windows
goto end

:build
echo.
echo [INFO] Compilando APK para distribucion...
flutter build apk --release
echo [SUCCESS] APK creado en: build\app\outputs\flutter-apk\app-release.apk
echo [INFO] Puedes instalar este APK en cualquier dispositivo Android
pause
goto end

:devices
echo.
echo [INFO] Dispositivos disponibles:
flutter devices
echo.
pause
goto start

:end
echo.
echo [INFO] Aplicacion finalizada
pause