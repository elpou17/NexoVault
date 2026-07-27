# Corrección JNI / Gradle

Esta versión fija temporalmente `jni` en `1.0.0` porque una resolución reciente puede seleccionar `jni 1.0.1`, cuya configuración Android puede producir el error:

```text
Could not find method kotlin() ... on project ':jni'
```

## Compilar

Ejecuta `compilar_apk_release.bat` desde la raíz del proyecto.

El script elimina `pubspec.lock` y `.dart_tool`, resuelve nuevamente las dependencias y genera:

```text
build\app\outputs\flutter-apk\app-release.apk
```

También puedes ejecutar manualmente:

```powershell
flutter clean
Remove-Item pubspec.lock -ErrorAction SilentlyContinue
Remove-Item .dart_tool -Recurse -Force -ErrorAction SilentlyContinue
flutter pub get
flutter analyze
flutter build apk --release
```
