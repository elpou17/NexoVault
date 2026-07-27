@echo off
setlocal
cd /d "%~dp0"
title NexoVault - Compilar APK Release

echo ==============================================
echo   NexoVault v0.1.4 - Compilacion Android
 echo ==============================================

echo [1/7] Verificando Flutter...
where flutter >nul 2>&1
if errorlevel 1 (
  echo ERROR: Flutter no esta disponible en PATH.
  pause
  exit /b 1
)

echo [2/7] Limpiando resoluciones anteriores...
if exist pubspec.lock del /q pubspec.lock
if exist .dart_tool rmdir /s /q .dart_tool
call flutter clean
if errorlevel 1 goto :error

echo [3/7] Descargando dependencias compatibles...
call flutter pub get
if errorlevel 1 goto :error

echo [4/7] Verificando que JNI quede fijado en 1.0.0...
findstr /C:"version: \"1.0.0\"" pubspec.lock >nul 2>&1
if errorlevel 1 (
  echo ADVERTENCIA: No se pudo confirmar jni 1.0.0 en pubspec.lock.
  echo Ejecuta: flutter pub deps ^| findstr jni
)

echo [5/7] Analizando el proyecto...
call flutter analyze
if errorlevel 1 goto :error

echo [6/7] Generando iconos Android...
call dart run flutter_launcher_icons
if errorlevel 1 echo ADVERTENCIA: No se pudieron regenerar los iconos; se continuara.

echo [7/7] Compilando APK release...
call flutter build apk --release
if errorlevel 1 goto :error

echo.
echo ==============================================
echo APK GENERADA CORRECTAMENTE
echo build\app\outputs\flutter-apk\app-release.apk
echo ==============================================
start "" "build\app\outputs\flutter-apk"
pause
exit /b 0

:error
echo.
echo ERROR: La compilacion fallo. Revisa el mensaje anterior.
echo Para diagnostico ejecuta: flutter build apk --release -v
pause
exit /b 1
