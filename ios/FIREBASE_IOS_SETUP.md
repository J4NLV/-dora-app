# ✅ Configuración de Firebase para iOS - Resumen

## 🎯 Estado Actual

### ✅ Pasos Completados Automáticamente

1. **✅ AppDelegate.swift actualizado**
   - Importa `FirebaseCore`
   - Inicializa Firebase con `FirebaseApp.configure()`
   - Ubicación: `ios/Runner/AppDelegate.swift`

2. **✅ Podfile creado**
   - Configurado para iOS 13.0+
   - Gestiona dependencias de Firebase
   - Ubicación: `ios/Podfile`

3. **✅ Dependencias de Firebase en pubspec.yaml**
   - `firebase_core: ^2.24.2`
   - `cloud_firestore: ^4.13.6`
   - `firebase_auth: ^4.15.3`
   - `firebase_analytics: ^10.7.4`

---

## 📋 Pasos que DEBES Completar Manualmente

### 🔴 PASO 1: Descargar GoogleService-Info.plist

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto **Dora**
3. Ve a **Configuración del proyecto** (⚙️) → **Tus apps**
4. Si no ves una app iOS registrada:
   - Haz clic en **"Agregar app"** → Selecciona **iOS**
   - **Bundle ID**: `com.example.dora`
   - **Nombre de la app**: `Dora iOS`
   - Haz clic en **"Registrar app"**
5. **Descarga `GoogleService-Info.plist`**

### 🔴 PASO 2: Colocar el archivo en tu proyecto

Copia el archivo descargado a:
```
c:\Users\julia\AndroidStudioProjects\Dora\ios\Runner\GoogleService-Info.plist
```

### 🔴 PASO 3: Instalar CocoaPods

**⚠️ IMPORTANTE: Esto requiere un entorno macOS o WSL en Windows**

Opción A - Si tienes Mac:
```bash
cd c:\Users\julia\AndroidStudioProjects\Dora\ios
pod install
cd ..
```

Opción B - Si estás en Windows con WSL:
```bash
cd /mnt/c/Users/julia/AndroidStudioProjects/Dora/ios
pod install
cd ..
```

Opción C - Si no tienes acceso a CocoaPods:
- Necesitarás compilar en un Mac
- O usar un servicio de CI/CD (como Codemagic, GitHub Actions con macOS runner)

### 🔴 PASO 4: Agregar el archivo a Xcode (Si tienes Mac)

1. Abre el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. En el navegador de proyectos (panel izquierdo), arrastra `GoogleService-Info.plist` a la carpeta **Runner**

3. En el diálogo que aparece, asegúrate de marcar:
   - ✅ **"Copy items if needed"**
   - ✅ **"Add to targets: Runner"**

4. Haz clic en **"Add"**

---

## 🧪 Verificación

### Verificar que el archivo está en su lugar:

```bash
dir ios\Runner\GoogleService-Info.plist
```

### Ejecutar la app en iOS:

```bash
flutter run -d ios
```

### Verificar en los logs:

Deberías ver:
```
Firebase initialized successfully
User ID: [un ID único]
```

---

## 🔍 Solución de Problemas Comunes

### "CocoaPods not installed"

Instala CocoaPods (requiere Ruby):
```bash
sudo gem install cocoapods
```

### "pod install" falla

Intenta:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Error: "GoogleService-Info.plist not found"

1. Verifica que el archivo esté en `ios/Runner/`
2. Verifica que esté agregado al proyecto en Xcode
3. Limpia y reconstruye:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   flutter run
   ```

### No puedo compilar para iOS en Windows

**Soluciones:**

1. **Usar WSL2** (Windows Subsystem for Linux):
   - Instala WSL2 con Ubuntu
   - Instala Ruby y CocoaPods en WSL
   - Ejecuta `pod install` desde WSL

2. **Usar un servicio de CI/CD**:
   - Codemagic (tiene plan gratuito)
   - GitHub Actions con runner macOS
   - Bitrise

3. **Acceso remoto a un Mac**:
   - MacStadium
   - MacinCloud
   - Pedir prestado un Mac

4. **Solo desarrollar para Android por ahora**:
   - Puedes desarrollar y probar en Android
   - Compilar para iOS cuando tengas acceso a un Mac

---

## 📱 Alternativa: Solo Android por Ahora

Si no tienes acceso a un Mac, puedes:

1. Desarrollar y probar completamente en Android
2. Firebase funcionará igual en ambas plataformas
3. Cuando tengas acceso a un Mac, completar la configuración de iOS
4. El código de Flutter es el mismo para ambas plataformas

---

## ✅ Checklist Final

- [ ] `GoogleService-Info.plist` descargado de Firebase Console
- [ ] Archivo colocado en `ios/Runner/GoogleService-Info.plist`
- [ ] CocoaPods instalado (`pod install` ejecutado exitosamente)
- [ ] Archivo agregado al proyecto Xcode (si tienes Mac)
- [ ] App ejecutada sin errores en iOS
- [ ] Firebase inicializado correctamente (verificar logs)

---

## 🎯 Siguiente Paso

Una vez completados estos pasos, ejecuta:

```bash
flutter run -d ios
```

Y verifica que la app se conecte correctamente a Firebase.
