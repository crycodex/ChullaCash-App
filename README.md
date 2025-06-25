# 💰 ChullaCash - Gestión Financiera Personal

<div align="center">
  <img src="lib/assets/icons/icon.jpg" width="120" height="120" alt="ChullaCash Logo"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.6.0-02569B?logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
  [![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)](https://flutter.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  
  **La única aplicación que pone tu dinero en forma. Gestiona tu dinero sobre la marcha.**
</div>

---

## 📱 Sobre la Aplicación

ChullaCash es una aplicación completa de gestión financiera personal desarrollada en Flutter, diseñada para ayudarte a tomar control total de tus finanzas de manera intuitiva y segura.

### ✨ Características Principales

#### 💸 **Gestión de Transacciones**
- ➕ Registro de ingresos y gastos
- 📊 Categorización automática
- 🔍 Historial detallado con filtros
- 📈 Seguimiento en tiempo real

#### 📊 **Análisis y Reportes**
- 📈 Gráficos interactivos de balance diario
- 📊 Estadísticas de ingresos vs gastos
- 📅 Resúmenes mensuales y anuales
- 🎯 Balance total en tiempo real

#### 🎯 **Metas Financieras**
- 🎯 Creación y seguimiento de objetivos
- 📊 Progreso visual con indicadores
- 🎉 Notificaciones de logros
- 💪 Motivación constante

#### 🔐 **Seguridad Avanzada**
- 🔒 Bloqueo biométrico (Face ID/Touch ID)
- 📱 PIN de seguridad personalizable
- 🛡️ Autenticación robusta
- 🔒 Datos encriptados

#### 🎨 **Experiencia de Usuario**
- 🌙 Modo oscuro/claro
- 🎨 Interfaz moderna y fluida
- 📱 Diseño responsive
- 🎵 Efectos de sonido opcionales

#### 🌐 **Conectividad**
- ☁️ Sincronización en la nube
- 📱 Acceso multiplataforma
- 🔄 Respaldo automático
- 📶 Modo offline

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter 3.6.0+** - Framework multiplataforma
- **GetX** - Gestión de estado y navegación
- **FL Chart** - Gráficos interactivos
- **Lottie** - Animaciones fluidas

### Backend & Servicios
- **Firebase Core** - Plataforma de desarrollo
- **Cloud Firestore** - Base de datos NoSQL
- **Firebase Auth** - Autenticación
- **Firebase Storage** - Almacenamiento de archivos

### Autenticación
- **Google Sign-In** - Inicio de sesión con Google
- **Sign in with Apple** - Inicio de sesión con Apple
- **Local Authentication** - Biometría y PIN

### Monetización
- **Google Mobile Ads** - Anuncios integrados
- **AdMob** - Red publicitaria

### Utilidades
- **Shared Preferences** - Almacenamiento local
- **Image Picker** - Selección de imágenes
- **URL Launcher** - Enlaces externos
- **Connectivity Plus** - Estado de conexión

## 🏗️ Arquitectura

El proyecto sigue una arquitectura limpia con patrón **Atomic Design**:

```
lib/
├── 📱 main.dart
├── 🎨 presentation/
│   ├── atomic/
│   │   ├── atoms/          # Componentes básicos
│   │   ├── molecules/      # Combinaciones simples
│   │   ├── organisms/      # Componentes complejos
│   │   └── pages/          # Páginas completas
│   ├── controllers/        # Lógica de negocio (GetX)
│   ├── routes/            # Navegación
│   ├── theme/             # Temas y colores
│   └── utils/             # Utilidades
├── 📊 data/
│   └── models/            # Modelos de datos
├── 🔧 services/           # Servicios externos
└── 🎵 assets/             # Recursos multimedia
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.6.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Xcode (para iOS)
- Cuenta de Firebase

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/ChullaCash-App.git
cd ChullaCash-App
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Configurar Firebase

#### Android
1. Añade tu archivo `google-services.json` en `android/app/`
2. Configura Firebase en `android/app/build.gradle`

#### iOS
1. Añade tu archivo `GoogleService-Info.plist` en `ios/Runner/`
2. Configura Firebase en `ios/Runner/Info.plist`

### 4. Configurar AdMob
Actualiza los IDs de AdMob en:
- `lib/ad_helper.dart`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

### 5. Ejecutar la Aplicación
```bash
# Debug
flutter run

# Release
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📦 Build y Deploy

### Android
```bash
# APK
flutter build apk --release

# AAB (Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build para dispositivo
flutter build ios --release

# Archive en Xcode
open ios/Runner.xcworkspace
```

### Web
```bash
flutter build web --release
```

## 🧪 Testing

```bash
# Tests unitarios
flutter test

# Tests de integración
flutter drive --target=test_driver/app.dart
```

## 📝 Configuración Adicional

### Iconos y Splash Screen
```bash
# Generar iconos
flutter pub run flutter_launcher_icons:main

# Generar splash screen
flutter pub run flutter_native_splash:create
```

### Localización
La app soporta español (es_ES) por defecto. Los datos de localización se inicializan automáticamente.

## 🔧 Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:
```env
ADMOB_APP_ID_ANDROID=ca-app-pub-tu-id-android
ADMOB_APP_ID_IOS=ca-app-pub-tu-id-ios
FIREBASE_PROJECT_ID=tu-proyecto-firebase
```

## 📱 Capturas de Pantalla

<div align="center">
  <img src="screenshots/home.png" width="200" alt="Pantalla Principal"/>
  <img src="screenshots/stats.png" width="200" alt="Estadísticas"/>
  <img src="screenshots/goals.png" width="200" alt="Metas"/>
  <img src="screenshots/history.png" width="200" alt="Historial"/>
</div>

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. Haz fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📜 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 📞 Contacto

- **Desarrollador**: Cristhian Recalde
- **Email**: isnotcristhian@gmail.com
- **LinkedIn**: https://www.linkedin.com/in/isnotcristhianr/

## 🙏 Agradecimientos

- [Flutter Team](https://flutter.dev) por el increíble framework
- [Firebase](https://firebase.google.com) por los servicios backend
- [Comunidad Flutter](https://flutter.dev/community) por el soporte continuo

---

<div align="center">
  <strong>💰 ChullaCash - Tu compañero financiero de confianza</strong>
</div>
