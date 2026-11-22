# Guía de Configuración de Firebase para Dora

Esta guía te ayudará a configurar Firebase en tu proyecto Dora.

## 📋 Prerequisitos

- Cuenta de Google
- Acceso a [Firebase Console](https://console.firebase.google.com)
- Android Studio instalado (para Android)
- Xcode instalado (para iOS, solo en Mac)

---

## 🔥 Paso 1: Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Haz clic en **"Agregar proyecto"** o **"Add project"**
3. Nombre del proyecto: **Dora** (o el nombre que prefieras)
4. Acepta los términos y haz clic en **Continuar**
5. (Opcional) Habilita Google Analytics
6. Haz clic en **Crear proyecto**
7. Espera a que se cree el proyecto y haz clic en **Continuar**

---

## 📱 Paso 2: Configurar Firebase para Android

### 2.1 Registrar la App Android

1. En la página principal de tu proyecto Firebase, haz clic en el ícono de **Android**
2. Ingresa los siguientes datos:
   - **Package name**: `com.example.dora`
   - **App nickname** (opcional): `Dora Android`
   - **Debug signing certificate SHA-1** (opcional por ahora)
3. Haz clic en **Registrar app**

### 2.2 Descargar google-services.json

1. Descarga el archivo `google-services.json`
2. **IMPORTANTE**: Coloca este archivo en la siguiente ubicación:
   ```
   c:\Users\julia\AndroidStudioProjects\Dora\android\app\google-services.json
   ```
3. Verifica que el archivo esté en la carpeta `android/app/` (NO en `android/`)

### 2.3 Verificar Configuración de Android

Los archivos de configuración de Android ya están listos:
- ✅ `settings.gradle.kts` - Plugin de Google Services agregado
- ✅ `app/build.gradle.kts` - Plugin aplicado y minSdk configurado a 21

---

## 🍎 Paso 3: Configurar Firebase para iOS

### 3.1 Registrar la App iOS

1. En Firebase Console, haz clic en **Agregar app** y selecciona **iOS**
2. Ingresa los datos:
   - **iOS bundle ID**: `com.example.dora`
   - **App nickname** (opcional): `Dora iOS`
3. Haz clic en **Registrar app**

### 3.2 Descargar GoogleService-Info.plist

1. Descarga el archivo `GoogleService-Info.plist`
2. **IMPORTANTE**: Coloca este archivo en:
   ```
   c:\Users\julia\AndroidStudioProjects\Dora\ios\Runner\GoogleService-Info.plist
   ```

### 3.3 Configurar AppDelegate.swift

✅ **YA CONFIGURADO** - El archivo `AppDelegate.swift` ya ha sido actualizado para inicializar Firebase.

Verifica que contenga:
```swift
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()  // ← Inicializa Firebase
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3.4 Instalar CocoaPods (Dependencias de iOS)

✅ **Podfile creado** - El archivo `Podfile` ya está configurado.

**Ejecuta los siguientes comandos:**

```bash
cd c:\Users\julia\AndroidStudioProjects\Dora\ios
pod install
cd ..
```

Si `pod` no está instalado, necesitarás instalarlo primero (requiere Ruby):
```bash
gem install cocoapods
```

**Nota para Windows:** Si no tienes acceso a CocoaPods en Windows, necesitarás:
- Usar WSL (Windows Subsystem for Linux)
- O compilar en un Mac
- O usar un servicio de CI/CD que compile para iOS

### 3.5 Agregar GoogleService-Info.plist a Xcode (Si tienes Mac)

Si tienes acceso a Xcode:

1. Abre el proyecto:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Arrastra `GoogleService-Info.plist` a la carpeta `Runner` en Xcode

3. Asegúrate de marcar:
   - ✅ **"Copy items if needed"**
   - ✅ **"Add to targets: Runner"**



---

## 🔧 Paso 4: Habilitar Servicios de Firebase

### 4.1 Habilitar Cloud Firestore

1. En Firebase Console, ve a **Build** → **Firestore Database**
2. Haz clic en **Crear base de datos** o **Create database**
3. Selecciona **Iniciar en modo de prueba** (Start in test mode)
4. Elige una ubicación (recomendado: `us-central1` o la más cercana)
5. Haz clic en **Habilitar**

### 4.2 Configurar Reglas de Seguridad

Una vez creada la base de datos, ve a la pestaña **Reglas** y reemplaza con:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir acceso solo a usuarios autenticados
    match /players/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /practice_history/{docId} {
      allow read, write: if request.auth != null && 
                           resource.data.userId == request.auth.uid;
    }
  }
}
```

Haz clic en **Publicar**.

### 4.3 Habilitar Firebase Authentication

1. Ve a **Build** → **Authentication**
2. Haz clic en **Comenzar** o **Get started**
3. En la pestaña **Sign-in method**, habilita:
   - **Anónimo** (Anonymous) - Ya está configurado en el código
   - (Opcional) **Correo electrónico/contraseña** - Para futuras implementaciones
   - (Opcional) **Google** - Para login con Google

---

## 🚀 Paso 5: Instalar Dependencias

Ejecuta el siguiente comando en la terminal:

```bash
cd c:\Users\julia\AndroidStudioProjects\Dora
flutter pub get
```

---

## ✅ Paso 6: Verificar Instalación

### Verificar archivos de configuración:

**Android:**
```
c:\Users\julia\AndroidStudioProjects\Dora\android\app\google-services.json
```

**iOS:**
```
c:\Users\julia\AndroidStudioProjects\Dora\ios\Runner\GoogleService-Info.plist
```

### Probar la app:

```bash
flutter run
```

Si todo está configurado correctamente, deberías ver en los logs:
```
Firebase initialized successfully
User ID: [un ID único]
```

---

## 📊 Paso 7: Verificar Datos en Firebase Console

1. Ejecuta la app y realiza algunas acciones (ganar monedas, actualizar racha)
2. Ve a Firebase Console → **Firestore Database**
3. Deberías ver una colección llamada `players` con tu documento de usuario
4. Verifica que los datos se actualicen en tiempo real

---

## 🔍 Solución de Problemas

### Error: "google-services.json not found"
- Verifica que el archivo esté en `android/app/google-services.json`
- NO debe estar en `android/google-services.json`

### Error: "Default FirebaseApp is not initialized"
- Asegúrate de que `google-services.json` esté en el lugar correcto
- Ejecuta `flutter clean` y luego `flutter pub get`
- Reconstruye la app

### Error de permisos en Firestore
- Verifica que las reglas de seguridad estén configuradas correctamente
- En modo de desarrollo, puedes usar reglas más permisivas (solo para pruebas):
  ```javascript
  allow read, write: if request.auth != null;
  ```

### La app no se conecta a Firebase
- Verifica tu conexión a Internet
- Revisa que Firebase esté habilitado en Firebase Console
- Verifica los logs de la app para ver errores específicos

---

## 📝 Próximos Pasos

Una vez que Firebase esté funcionando:

1. **Implementar autenticación completa** (email/password, Google Sign-In)
2. **Agregar Firebase Analytics** para tracking de eventos
3. **Configurar Cloud Functions** para lógica del servidor
4. **Implementar notificaciones push** con Firebase Cloud Messaging
5. **Agregar Remote Config** para configuración dinámica

---

## 🔗 Recursos Útiles

- [Documentación de Firebase](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

## ⚠️ Importante

- **NO** subas los archivos `google-services.json` o `GoogleService-Info.plist` a repositorios públicos
- Estos archivos ya están incluidos en `.gitignore`
- Mantén tus reglas de seguridad de Firestore actualizadas
- Cambia a reglas de producción antes de lanzar la app
