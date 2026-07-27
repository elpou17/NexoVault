# NexoVault v0.1.0

Base móvil Flutter para Android, compatible con Visual Studio Code.

## Requisitos

- Flutter SDK estable
- Android Studio con Android SDK
- Visual Studio Code
- Extensiones Flutter y Dart
- Un emulador Android o teléfono con depuración USB

## Preparar el proyecto

En PowerShell, dentro de esta carpeta:

```powershell
flutter create --platforms=android,ios .
flutter pub get
dart run flutter_launcher_icons
flutter run
```

El primer comando genera las carpetas nativas de Android/iOS que no se incluyen precompiladas en este paquete.

## Ejecutar en Android

```powershell
flutter devices
flutter run -d <ID_DEL_DISPOSITIVO>
```

## Generar APK

```powershell
flutter build apk --release
```

Resultado:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Generar Android App Bundle

```powershell
flutter build appbundle --release
```

Resultado:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Estado de seguridad

Esta versión es un prototipo funcional. Usa almacenamiento seguro de plataforma para el MVP. Antes de producción se debe migrar la bóveda a cifrado autenticado por registro, incorporar Argon2id, bloqueo por inactividad, protección contra capturas, exportación cifrada y pruebas OWASP MASVS.
