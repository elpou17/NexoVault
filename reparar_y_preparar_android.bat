@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter no esta disponible en PATH.
  pause
  exit /b 1
)
if exist android rmdir /s /q android
call flutter create --platforms=android --org com.sudotic --project-name nexovault .
if exist "test\widget_test.dart" del /q "test\widget_test.dart"
if errorlevel 1 exit /b 1
if not exist "android\app\src\main\kotlin\com\sudotic\nexovault" mkdir "android\app\src\main\kotlin\com\sudotic\nexovault"
copy /y "platform_templates\MainActivity.kt" "android\app\src\main\kotlin\com\sudotic\nexovault\MainActivity.kt" >nul
copy /y "platform_templates\AndroidManifest.xml" "android\app\src\main\AndroidManifest.xml" >nul
call flutter pub get
call dart run flutter_launcher_icons
call flutter analyze
if errorlevel 1 exit /b 1
echo Android Embedding V2 preparado correctamente.
exit /b 0
