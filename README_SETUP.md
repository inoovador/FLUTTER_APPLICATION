# 🏆 Flutter Tournament App - Guía de Instalación

Aplicación móvil completa para gestión de torneos deportivos con sistema de equipos, pagos y calificaciones.

## 📋 Requisitos del Sistema

### Herramientas Necesarias
- **Flutter SDK** 3.8.1 o superior
- **Dart SDK** (incluido con Flutter)
- **Git** para control de versiones
- **Visual Studio Code** o **Android Studio**

### Para Desarrollo Android
- **Android Studio** con SDK
- **Android SDK** API 21+ (Android 5.0)
- **Java JDK** 11 o superior

### Para Desarrollo iOS (solo macOS)
- **Xcode** 14.0+
- **iOS SDK** 12.0+
- **CocoaPods**

### Para Desarrollo Web
- **Chrome** o navegador compatible

## 🚀 Instalación Paso a Paso

### 1. Instalar Flutter

#### Windows
```bash
# Descargar Flutter
git clone https://github.com/flutter/flutter.git -b stable
# Agregar al PATH del sistema
set PATH=%PATH%;C:\flutter\bin
```

#### macOS
```bash
# Usar Homebrew
brew install flutter
# O descargar manualmente
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

#### Linux
```bash
# Descargar Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verificar Instalación
```bash
flutter doctor
```
Resolver cualquier problema que aparezca.

### 3. Clonar el Proyecto
```bash
git clone https://github.com/inoovador/FLUTTER_APPLICATION.git
cd FLUTTER_APPLICATION
```

### 4. Instalar Dependencias
```bash
flutter pub get
```

### 5. Configurar Plataformas

#### Android
```bash
# Aceptar licencias
flutter doctor --android-licenses
# Verificar dispositivos
flutter devices
```

#### iOS (solo macOS)
```bash
cd ios
pod install
cd ..
```

### 6. Ejecutar la Aplicación

#### En Emulador/Simulador
```bash
# Android
flutter run

# iOS (macOS)
flutter run -d ios

# Web
flutter run -d chrome
```

#### En Dispositivo Físico
```bash
# Habilitar modo desarrollador en el dispositivo
# Conectar por USB
flutter run
```

## 🔧 Configuración del Entorno

### Visual Studio Code
Instalar extensiones:
- **Flutter**
- **Dart**
- **Flutter Intl**

### Android Studio
Instalar plugins:
- **Flutter**
- **Dart**

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada principal
├── main_optimized.dart       # Versión optimizada
├── models/                   # Modelos de datos
├── screens/                  # Pantallas de la app
├── services/                 # Lógica de negocio
├── widgets/                  # Componentes reutilizables
└── utils/                    # Utilidades
```

## 🎯 Funcionalidades Principales

- **Gestión de Torneos**: Crear, editar y administrar torneos
- **Equipos**: Formación de equipos y gestión de jugadores
- **Pagos**: Sistema de pagos integrado
- **Calificaciones**: Sistema de rating para jugadores
- **Chat**: Comunicación entre equipos
- **Notificaciones**: Alertas en tiempo real
- **Seguridad**: Encriptación y auditoría

## 🛠️ Comandos Útiles

### Desarrollo
```bash
# Hot reload
r (en la terminal de flutter run)

# Hot restart
R (en la terminal de flutter run)

# Limpiar build
flutter clean

# Actualizar dependencias
flutter pub upgrade
```

### Build para Producción
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS)
flutter build ios --release

# Web
flutter build web --release
```

### Testing
```bash
# Ejecutar tests
flutter test

# Coverage
flutter test --coverage
```

## 🐛 Solución de Problemas

### Error: Visual Studio Toolchain
```bash
# Instalar Visual Studio Community
# Asegurar "Desktop development with C++" esté seleccionado
flutter doctor
```

### Error: Android SDK
```bash
# Abrir Android Studio > SDK Manager
# Instalar Android SDK y tools necesarios
flutter doctor --android-licenses
```

### Error: Conflictos de Dependencias
```bash
flutter clean
flutter pub get
```

### Performance Issues
- Usar `main_optimized.dart` en lugar de `main.dart`
- Verificar uso de memoria en DevTools
- Compilar en release mode para testing real

## 📱 Plataformas Soportadas

- ✅ **Android** (API 21+)
- ✅ **iOS** (12.0+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🔐 Configuración de Seguridad

### Variables de Entorno
Crear archivo `.env` (no incluir en git):
```
API_KEY=your_api_key_here
ENCRYPTION_KEY=your_encryption_key_here
```

### Firebase (Opcional)
1. Crear proyecto en Firebase Console
2. Descargar `google-services.json` (Android)
3. Descargar `GoogleService-Info.plist` (iOS)
4. Descomentar dependencias de Firebase en `pubspec.yaml`

## 🤝 Contribuir

1. Fork el repositorio
2. Crear rama: `git checkout -b feature/nueva-funcionalidad`
3. Commit: `git commit -m 'Agregar nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Crear Pull Request

## 📞 Soporte

- **Issues**: GitHub Issues
- **Documentación**: Carpeta `/docs`
- **Wiki**: GitHub Wiki

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

---

**¡Happy Coding!** 🎉