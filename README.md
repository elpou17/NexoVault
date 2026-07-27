# NexoVault v0.1.2

Proyecto Flutter corregido para Android Embedding V2 y preparado para abrirse en Visual Studio Code.

## Primera ejecución en Windows

1. Descomprime el proyecto.
2. Abre esta carpeta en Visual Studio Code.
3. Inicia un emulador Android.
4. Ejecuta `reparar_y_ejecutar.bat`.

El script elimina cualquier plataforma Android obsoleta, genera una plataforma moderna usando la versión de Flutter instalada, configura biometría, genera el icono y ejecuta la aplicación.

## Preparar Android sin ejecutar

```powershell
.\reparar_y_preparar_android.bat
```

## Ejecutar manualmente

```powershell
flutter pub get
flutter devices
flutter run
```

## Crear APK

```powershell
.\compilar_apk_release.bat
```

Resultado:

```text
build\app\outputs\flutter-apk\app-release.apk
```

## Identidad Android

- Application ID: `com.sudotic.nexovault`
- Min SDK: definido por el proyecto Flutter y el paquete; el icono configura mínimo 24.
- Android Embedding: V2.
- MainActivity: `FlutterFragmentActivity`, requerido para autenticación local.

> Esta es una versión MVP para validación. No debe usarse todavía como bóveda final para secretos críticos hasta completar cifrado de registros, bloqueo automático, protección del portapapeles y pruebas de seguridad.


## Corrección v0.1.3

Se elimina automáticamente el test de plantilla `test/widget_test.dart` que referencia la clase inexistente `MyApp`. La aplicación usa `NexoVaultApp`. También se desactiva la generación de iconos iOS en este paquete Android.
