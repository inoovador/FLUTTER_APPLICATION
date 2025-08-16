@echo off
title Tournament App - Build & Deploy
echo ========================================
echo    COMPILACION Y DESPLIEGUE
echo ========================================
echo.

cd /d "%~dp0"

echo [INFO] Limpiando builds anteriores...
flutter clean

echo [INFO] Obteniendo dependencias...
flutter pub get

echo.
echo ========================================
echo   OPCIONES DE COMPILACION
echo ========================================
echo 1. APK Android (para instalar en dispositivos)
echo 2. Web (para servidor web)
echo 3. Windows EXE (aplicacion de escritorio)
echo 4. Compilar TODOS
echo ========================================
set /p choice="Selecciona opcion (1-4): "

if "%choice%"=="1" goto android_build
if "%choice%"=="2" goto web_build
if "%choice%"=="3" goto windows_build
if "%choice%"=="4" goto all_builds

echo [ERROR] Opcion invalida
pause
exit /b 1

:android_build
echo.
echo [INFO] Compilando APK Android...
flutter build apk --release
echo [SUCCESS] APK creado en: build\app\outputs\flutter-apk\app-release.apk
echo [INFO] Tamaño aproximado: ~50-100MB
echo [INFO] Compatible con Android 5.0+
goto end

:web_build
echo.
echo [INFO] Compilando version Web...
flutter build web --release
echo [SUCCESS] Web app creada en: build\web\
echo [INFO] Subir esta carpeta a cualquier servidor web
echo [INFO] Tambien funciona abriendo index.html localmente
goto end

:windows_build
echo.
echo [INFO] Compilando aplicacion Windows...
flutter build windows --release
echo [SUCCESS] EXE creado en: build\windows\runner\Release\
echo [INFO] Incluye todas las DLLs necesarias
goto end

:all_builds
echo.
echo [INFO] Compilando TODAS las versiones...
echo.
echo [1/3] Compilando Android APK...
flutter build apk --release
echo.
echo [2/3] Compilando Web...
flutter build web --release
echo.
echo [3/3] Compilando Windows...
flutter build windows --release
echo.
echo [SUCCESS] Todas las versiones compiladas:
echo   - Android: build\app\outputs\flutter-apk\app-release.apk
echo   - Web: build\web\
echo   - Windows: build\windows\runner\Release\
goto end

:end
echo.
echo ========================================
echo   ARCHIVOS LISTOS PARA DISTRIBUCION
echo ========================================
echo.
echo PARA COMPARTIR LA APP:
echo.
echo 1. APK Android: 
echo    - Enviar archivo app-release.apk
echo    - Instalar en dispositivo Android
echo.
echo 2. Version Web:
echo    - Subir carpeta build\web\ a servidor
echo    - O abrir index.html en navegador
echo.
echo 3. Windows EXE:
echo    - Copiar carpeta Release completa
echo    - Ejecutar app.exe
echo.
pause