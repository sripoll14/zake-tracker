# Guía: instalar, compilar, probar y publicar · Zake Tracker

> Pensada para **Windows** y para alguien que **nunca ha usado Flutter**. Sigue los pasos en orden; cada uno se hace una sola vez salvo los de "día a día".

---

## Índice

0. [Resumen rápido](#0-resumen-rápido)
1. [Qué necesitas](#1-qué-necesitas)
2. [Instalar las herramientas en Windows](#2-instalar-las-herramientas-en-windows)
3. [Preparar el proyecto](#3-preparar-el-proyecto)
4. [Probar la app](#4-probar-la-app)
5. [Crear el APK para instalarlo en Android](#5-crear-el-apk-para-instalarlo-en-android)
6. [¿Y el iPhone?](#6-y-el-iphone)
7. [Subir el proyecto a GitHub](#7-subir-el-proyecto-a-github)
8. [Publicar la versión web gratis (GitHub Pages)](#8-publicar-la-versión-web-gratis-github-pages)
9. [El día a día programando](#9-el-día-a-día-programando)
10. [Problemas frecuentes](#10-problemas-frecuentes)

---

## 0. Resumen rápido

```text
Instalar (una vez):  Git · VS Code + extensión Flutter · Flutter SDK · Android Studio
Preparar (una vez):  flutter create ... .   →   flutter pub get
Comprobar:           flutter analyze   →   flutter test
Probar:              flutter run -d chrome   |   flutter run   (emulador o móvil)
Android:             flutter build apk --release
iPhone sin Mac:      versión web en Safari → "Añadir a pantalla de inicio"
GitHub:              git init → commit → push
```

---

## 1. Qué necesitas

| Necesitas | Para qué | ¿Obligatorio? |
|---|---|---|
| PC con **Windows 10 u 11 de 64 bits**, 8 GB de RAM (mejor 16) y unos **15 GB libres** | Programar y compilar | Sí |
| **Git for Windows** | Flutter lo usa y sirve para GitHub | Sí |
| **Flutter SDK** (incluye Dart) | El "motor" que compila la app | Sí |
| **VS Code** + extensión **Flutter** | Editor de código | Muy recomendado |
| **Android Studio** | Herramientas de Android y el emulador | Sí, para Android |
| **Google Chrome** | Probar la versión web (la más rápida para empezar) | Recomendado |
| Un **móvil Android** con cable USB | Probar en un móvil real | Opcional |
| Cuenta de **GitHub** | Subir el proyecto | Para el paso 7 |
| **Un Mac** | Compilar la app *nativa* de iPhone | Solo para iOS nativo (ver paso 6) |

> 💡 **Sobre la máquina virtual con Linux:** Apple solo permite compilar apps de iPhone **desde macOS** (con Xcode). Linux no sirve para eso, ni en máquina virtual. Para usar la app en el iPhone sin Mac hay una alternativa gratuita en el [paso 6](#6-y-el-iphone).

---

## 2. Instalar las herramientas en Windows

### 2.1. Git

1. Descarga Git desde <https://git-scm.com/download/win> e instálalo con las opciones por defecto.
2. Comprueba en **PowerShell**:
   ```powershell
   git --version
   ```

### 2.2. VS Code y la extensión de Flutter

1. Instala VS Code desde <https://code.visualstudio.com/>.
2. Ábrelo, ve a **Extensiones** (`Ctrl + Shift + X`), busca **Flutter** (de Dart Code) e instálala. Instala también la de **Dart** automáticamente.

### 2.3. Flutter SDK (la forma más fácil: desde VS Code)

1. En VS Code pulsa `Ctrl + Shift + P`, escribe **flutter** y elige **Flutter: New Project**.
2. Te avisará de que no encuentra el SDK. Pulsa **Download SDK**.
3. Elige una carpeta **sin espacios ni tildes y que no necesite permisos de administrador**, por ejemplo `C:\dev`. Pulsa **Clone Flutter**.
4. Cuando termine, pulsa **Add SDK to PATH**.
5. **Cierra todas las ventanas de PowerShell y reinicia VS Code.**
6. Comprueba:
   ```powershell
   flutter --version
   ```

> Alternativa manual: descargar el zip de Flutter desde la web oficial, descomprimirlo en `C:\dev\flutter` y añadir `C:\dev\flutter\bin` a la variable `Path` del usuario. Instrucciones oficiales: <https://docs.flutter.dev/get-started/install/windows/mobile>.

### 2.4. Android Studio

1. Descárgalo de <https://developer.android.com/studio> e instálalo (versión completa).
2. Ábrelo. En la pantalla de bienvenida: **More Actions → SDK Manager**.
   - Pestaña **SDK Platforms**: marca la versión de Android más reciente.
   - Pestaña **SDK Tools**: marca **Android SDK Command-line Tools**, **Android SDK Build-Tools**, **Android SDK Platform-Tools** y **Android Emulator**.
   - Pulsa **Apply** y espera.
3. **Crear un emulador** (un móvil virtual): **More Actions → Virtual Device Manager → Create Device** → elige un Pixel → descarga una imagen del sistema → **Finish**.
   - Si va muy lento, activa la virtualización en la BIOS del PC (Intel VT-x / AMD-V).
4. Acepta las licencias en PowerShell (si te lo pide, ábrelo como administrador):
   ```powershell
   flutter doctor --android-licenses
   ```
   Responde `y` a todo.

### 2.5. Comprobación final

```powershell
flutter doctor
```

Debe salir ✓ en **Flutter**, **Android toolchain**, **Chrome** y **VS Code**. Es normal que salga ⚠ en **Visual Studio** (solo hace falta para apps de escritorio de Windows, que no vamos a hacer). Si algo falla, `flutter doctor -v` da más detalles.

---

## 3. Preparar el proyecto

1. Descomprime el proyecto en una carpeta sin espacios, por ejemplo `C:\proyectos\zake_tracker`.
2. Ábrelo en VS Code: **File → Open Folder**.
3. Abre la terminal de VS Code (`Ctrl + ñ` o **Terminal → New Terminal**) y ejecuta **una sola vez**:

   ```powershell
   flutter create --org com.sandra --project-name zake_tracker --platforms=android,ios,web .
   ```

   Esto genera las carpetas `android/`, `ios/` y `web/` (el código específico de cada plataforma). **No toca tu código de `lib/`**; solo crea lo que falta.

   > El `.` final es importante: significa "en esta carpeta".

4. Descarga los paquetes:
   ```powershell
   flutter pub get
   ```

5. Comprueba el código y pasa los tests:
   ```powershell
   flutter analyze
   flutter test
   ```
   - `flutter analyze` revisa el código en busca de errores. Puede que salgan algunos avisos de estilo ("info"): no impiden ejecutar la app.
   - `flutter test` debe terminar con **All tests passed!**

> ⚠️ **Importante:** este código se escribió sin poder compilarlo (no había Flutter disponible donde se generó). Si `flutter analyze` muestra algún **error** (en rojo, "error •"), copia el mensaje completo y pásaselo a Claude para corregirlo. Suelen ser arreglos de una línea.

### 3.1. Retoques de una vez (recomendados)

**Nombre visible de la app en Android.** En `android/app/src/main/AndroidManifest.xml`, cambia:
```xml
android:label="zake_tracker"
```
por:
```xml
android:label="Zake Tracker"
```

**Permiso de internet en Android** (para descargar las tipografías en la versión final). En el mismo archivo, justo encima de la línea `<application`, añade:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**Nombre en iPhone y web.** En `web/manifest.json` cambia `"name"` y `"short_name"` a `"Zake Tracker"`. En `web/index.html` cambia el `<title>`.

---

## 4. Probar la app

Primero mira qué "dispositivos" tienes disponibles:
```powershell
flutter devices
```

### 4.1. En Chrome (lo más rápido)
```powershell
flutter run -d chrome
```
Para verla con tamaño de móvil: en Chrome pulsa `F12` → icono de móvil (`Ctrl + Shift + M`) → elige un iPhone o Pixel.

### 4.2. En el emulador de Android
1. Arranca el emulador desde Android Studio (Device Manager → ▶) o con:
   ```powershell
   flutter emulators
   flutter emulators --launch <nombre_del_emulador>
   ```
2. Ejecuta:
   ```powershell
   flutter run
   ```
La primera compilación tarda varios minutos; las siguientes son mucho más rápidas.

### 4.3. En tu móvil Android real
1. En el móvil: **Ajustes → Información del teléfono → Número de compilación**, tócalo 7 veces para activar las **Opciones de desarrollador**.
2. En **Opciones de desarrollador**, activa **Depuración USB**.
3. Conecta el móvil por cable y acepta el aviso "¿Permitir depuración USB?".
4. Ejecuta `flutter devices` (debe aparecer tu móvil) y luego `flutter run`.

### 4.4. Mientras la app está abierta
En la terminal donde ejecutaste `flutter run`:

| Tecla | Hace |
|---|---|
| `r` | **Hot reload**: aplica los cambios del código al instante |
| `R` | Reinicia la app (pierde el estado de la pantalla) |
| `q` | Cierra |

En VS Code también puedes pulsar **F5** para ejecutar y basta con **guardar** (`Ctrl + S`) para hacer hot reload.

---

## 5. Crear el APK para instalarlo en Android

```powershell
flutter build apk --release
```

El archivo queda en:
```
build\app\outputs\flutter-apk\app-release.apk
```

Pásalo al móvil (por cable, Drive, Telegram…) y ábrelo. Android pedirá permiso para **instalar apps de origen desconocido**: acéptalo para esa app.

También puedes instalarlo directamente con el móvil conectado:
```powershell
flutter install
```

> Para publicarlo en Google Play haría falta una cuenta de desarrollador (pago único de 25 $) y firmar la app con una clave propia. Para uso personal y con amigos, el APK es suficiente.

---

## 6. ¿Y el iPhone?

Apple **solo permite compilar apps de iPhone desde un Mac** con Xcode. Ni Windows ni Linux (tampoco en máquina virtual) pueden hacerlo. Estas son las opciones:

### Opción A · Versión web en el iPhone ✅ (gratis y sin Mac, recomendada)

Flutter genera también una versión web de la app que, en el iPhone, **se usa como una app más**:

1. Publica la web en GitHub Pages (ver [paso 8](#8-publicar-la-versión-web-gratis-github-pages)).
2. En el iPhone, abre el enlace con **Safari**.
3. Pulsa **Compartir** (cuadrado con flecha) → **Añadir a pantalla de inicio**.
4. Aparece un icono en el iPhone que abre la app a pantalla completa.

Los datos (historial, comida a medias) se guardan en el propio Safari del iPhone.

### Opción B · App nativa, si consigues un Mac

Con un Mac (prestado, de la universidad, un Mac mini…):

1. Instala **Xcode** desde la App Store y Flutter para macOS.
2. Copia el proyecto (o clónalo desde GitHub) y ejecuta:
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   open ios/Runner.xcworkspace
   ```
3. En Xcode: **Runner → Signing & Capabilities** → elige tu **Apple ID** como *Team*.
4. Conecta el iPhone, activa el **Modo desarrollador** en el iPhone (**Ajustes → Privacidad y seguridad**) y ejecuta:
   ```bash
   flutter run
   ```
- Con un Apple ID **gratuito**, la app instalada caduca a los **7 días** (se reinstala repitiendo `flutter run`).
- Para que no caduque, o para compartirla con TestFlight o publicarla en la App Store, hace falta el **Apple Developer Program** (99 $ al año).

### Opción C · Compilar en la nube

Servicios como **Codemagic** o **GitHub Actions con macOS** compilan la app de iPhone en un Mac en la nube. Aun así, para instalarla en un iPhone hace falta firmarla con una cuenta de Apple Developer de pago, así que solo merece la pena si en algún momento se quiere publicar.

---

## 7. Subir el proyecto a GitHub

### 7.1. Primera vez

1. Configura tu nombre y correo en Git (una sola vez):
   ```powershell
   git config --global user.name "Tu nombre"
   git config --global user.email "tu_correo@ejemplo.com"
   ```
2. En <https://github.com/new> crea un repositorio llamado `zake-tracker`. **No marques** "Add a README" (el proyecto ya tiene uno).
3. En la terminal, dentro de la carpeta del proyecto:
   ```powershell
   git init
   git add .
   git commit -m "Primera versión de Zake Tracker"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/zake-tracker.git
   git push -u origin main
   ```
   La primera vez se abrirá una ventana para iniciar sesión en GitHub.

> El archivo `.gitignore` ya está preparado para **no subir** archivos generados (`build/`, `.dart_tool/`…) ni claves privadas. Las carpetas `android/`, `ios/` y `web/` **sí** se suben.

### 7.2. Cada vez que cambies algo
```powershell
git add .
git commit -m "Describe aquí el cambio"
git push
```

También puedes hacerlo desde VS Code con el icono de **Source Control** (`Ctrl + Shift + G`).

---

## 8. Publicar la versión web gratis (GitHub Pages)

El proyecto ya incluye un "robot" de GitHub (`.github/workflows/web.yml`) que, **cada vez que haces `git push`**:

1. revisa el código y pasa los tests,
2. compila la versión web,
3. la publica en internet.

Para activarlo **una sola vez**:

1. En tu repositorio de GitHub, ve a **Settings → Pages**.
2. En **Source**, elige **GitHub Actions**.
3. Haz un `git push` (o en la pestaña **Actions** pulsa **Run workflow**).
4. Cuando termine (marca verde ✓ en la pestaña **Actions**), la app estará en:
   ```
   https://TU_USUARIO.github.io/zake-tracker/
   ```

Si la marca sale roja ✗, entra en la ejecución y mira qué paso falló (por ejemplo, un test). Así sabes que algo se ha roto antes de usar la app.

> Si el repositorio es **público**, cualquiera con el enlace podrá abrir la app (pero cada persona ve solo sus propios datos, que se guardan en su navegador).

---

## 9. El día a día programando

1. Abre la carpeta en VS Code.
2. Arranca la app con **F5** (o `flutter run -d chrome`).
3. Cambia el código y **guarda**: el cambio aparece al momento (hot reload).
4. Antes de subir a GitHub:
   ```powershell
   flutter analyze
   flutter test
   ```
5. `git add .` → `git commit -m "..."` → `git push`.

**Dónde tocar cada cosa** (detalles en la [memoria](MEMORIA.md#13-cómo-modificar-o-ampliar-la-app)):

| Quiero cambiar… | Archivo |
|---|---|
| Precios del buffet | `lib/logic/pricing.dart` |
| Platos o sus costes | `lib/data/menu_data.dart` |
| Objetivos | `lib/models/goal.dart` |
| Colores | `lib/theme/app_theme.dart` |
| Una pantalla | `lib/screens/...` |

---

## 10. Problemas frecuentes

| Problema | Solución |
|---|---|
| `flutter` no se reconoce como comando | Flutter no está en el `Path`. Repite el paso 2.3 y **reinicia** PowerShell y VS Code. |
| `flutter doctor` dice que faltan licencias de Android | `flutter doctor --android-licenses` y responde `y`. |
| `cmdline-tools component is missing` | Android Studio → SDK Manager → SDK Tools → marca **Android SDK Command-line Tools**. |
| El emulador va muy lento o no arranca | Activa la virtualización en la BIOS (VT-x / AMD-V) y, en Windows, la "Plataforma de máquina virtual". |
| El móvil no aparece en `flutter devices` | Revisa que la depuración USB esté activa, acepta el aviso en el móvil y prueba otro cable (algunos solo cargan). |
| `did not install NDK 28.2.13676358` (o otra versión) | Android Studio → SDK Manager → SDK Tools → marca **Show package details** → despliega **NDK (Side by side)** → marca esa versión exacta → Apply. |
| Los avisos `WARNING: A restricted method in java.lang.System` o `sdkmanager is deprecated` | Son avisos internos de Gradle y Android, no errores. Se pueden ignorar. |
| Probar en el iPhone sin subir nada | Con el PC y el iPhone en el mismo WiFi: `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --release` y en Safari `http://IP_DEL_PC:8080`. Usa la IPv4 del adaptador **Wi-Fi** de `ipconfig` (no la de VirtualBox). Las redes de la universidad no lo permiten. |
| Error de Gradle en la primera compilación | Ejecuta `flutter clean` y luego `flutter pub get` y `flutter run`. La primera vez Gradle descarga mucho; necesita buena conexión. |
| Rutas con espacios o tildes dan errores raros | Mueve el SDK y el proyecto a rutas simples como `C:\dev\flutter` y `C:\proyectos\zake_tracker`. |
| Las letras salen con otra fuente | Las tipografías se descargan de internet la primera vez. Comprueba la conexión y el permiso de internet (paso 3.1). |
| `flutter analyze` muestra errores | Copia el mensaje completo y pásaselo a Claude. |
| Quiero empezar de cero con los datos | Desinstala la app (o borra los datos del sitio en el navegador). |
