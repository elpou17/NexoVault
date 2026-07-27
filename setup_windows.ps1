$ErrorActionPreference = "Stop"
Write-Host "Preparando NexoVault..." -ForegroundColor Cyan
flutter doctor
flutter create --platforms=android,ios .
flutter pub get
dart run flutter_launcher_icons
Write-Host "Proyecto preparado. Ejecuta: flutter run" -ForegroundColor Green
