@echo off
setlocal
cd /d "%~dp0"

echo ==========================================
echo  NexoVault - Reparacion Android moderna
echo ==========================================

where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter no esta disponible en PATH.
  echo Ejecuta flutter doctor y configura Flutter antes de continuar.
  pause
  exit /b 1
)

echo [1/8] Eliminando plataforma Android obsoleta...
if exist android rmdir /s /q android

echo [2/8] Generando Android Embedding V2 con tu Flutter instalado...
call flutter create --platforms=android --org com.sudotic --project-name nexovault .
if exist "test\widget_test.dart" del /q "test\widget_test.dart"
if errorlevel 1 goto :error

echo [3/8] Configurando MainActivity compatible con biometria...
if not exist "android\app\src\main\kotlin\com\sudotic\nexovault" mkdir "android\app\src\main\kotlin\com\sudotic\nexovault"
copy /y "platform_templates\MainActivity.kt" "android\app\src\main\kotlin\com\sudotic\nexovault\MainActivity.kt" >nul

echo [4/8] Configurando manifiesto Android seguro...
copy /y "platform_templates\AndroidManifest.xml" "android\app\src\main\AndroidManifest.xml" >nul

echo [5/8] Descargando dependencias...
call flutter clean
call flutter pub get
if errorlevel 1 goto :error

echo [6/8] Generando iconos del launcher...
call dart run flutter_launcher_icons
if errorlevel 1 goto :error

echo [7/8] Analizando el codigo...
call flutter analyze
if errorlevel 1 goto :error

echo [8/8] Ejecutando NexoVault...
call flutter run
exit /b 0

:error
echo.
echo ERROR: El proceso no pudo completarse. Revisa el mensaje anterior.
pause
exit /b 1
