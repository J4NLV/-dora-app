@echo off
echo ========================================
echo Verificacion de Firebase iOS - Dora
echo ========================================
echo.

echo [1/4] Verificando AppDelegate.swift...
if exist "ios\Runner\AppDelegate.swift" (
    findstr /C:"import FirebaseCore" ios\Runner\AppDelegate.swift >nul
    if %errorlevel% equ 0 (
        echo [OK] AppDelegate.swift contiene import FirebaseCore
    ) else (
        echo [ERROR] AppDelegate.swift NO tiene import FirebaseCore
    )
    
    findstr /C:"FirebaseApp.configure()" ios\Runner\AppDelegate.swift >nul
    if %errorlevel% equ 0 (
        echo [OK] AppDelegate.swift inicializa Firebase
    ) else (
        echo [ERROR] AppDelegate.swift NO inicializa Firebase
    )
) else (
    echo [ERROR] AppDelegate.swift no encontrado
)
echo.

echo [2/4] Verificando Podfile...
if exist "ios\Podfile" (
    echo [OK] Podfile existe
) else (
    echo [ERROR] Podfile no encontrado
)
echo.

echo [3/4] Verificando GoogleService-Info.plist...
if exist "ios\Runner\GoogleService-Info.plist" (
    echo [OK] GoogleService-Info.plist encontrado
) else (
    echo [PENDIENTE] GoogleService-Info.plist NO encontrado
    echo            Debes descargarlo de Firebase Console
)
echo.

echo [4/4] Verificando dependencias en pubspec.yaml...
findstr /C:"firebase_core" pubspec.yaml >nul
if %errorlevel% equ 0 (
    echo [OK] firebase_core en pubspec.yaml
) else (
    echo [ERROR] firebase_core NO en pubspec.yaml
)

findstr /C:"cloud_firestore" pubspec.yaml >nul
if %errorlevel% equ 0 (
    echo [OK] cloud_firestore en pubspec.yaml
) else (
    echo [ERROR] cloud_firestore NO en pubspec.yaml
)

findstr /C:"firebase_auth" pubspec.yaml >nul
if %errorlevel% equ 0 (
    echo [OK] firebase_auth en pubspec.yaml
) else (
    echo [ERROR] firebase_auth NO en pubspec.yaml
)
echo.

echo ========================================
echo Resumen
echo ========================================
echo.
echo Archivos configurados automaticamente:
echo   - AppDelegate.swift (con Firebase)
echo   - Podfile
echo   - pubspec.yaml (dependencias)
echo.
echo Pasos pendientes MANUALES:
echo   1. Descargar GoogleService-Info.plist de Firebase Console
echo   2. Colocar en: ios\Runner\GoogleService-Info.plist
echo   3. Ejecutar: cd ios ^&^& pod install ^&^& cd ..
echo   4. (Si tienes Mac) Agregar archivo a Xcode
echo.
echo Para mas detalles, ver: ios\FIREBASE_IOS_SETUP.md
echo.
pause
