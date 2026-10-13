# Ivyroom

Armario digital para Android. Fotografías tu ropa, la app quita el fondo sola, y te propone outfits según el color, la ocasión y el clima del día. Funciona sin conexión; si quieres, guarda una copia en la nube y deja que otra persona vea tu armario.

Hecho con Flutter. El backend opcional usa [Convex](https://convex.dev) (plan gratuito) y login con Google.

## Qué hace

- **Alta de prendas con recorte automático**: ML Kit quita el fondo en el propio móvil. Si se equivoca, un editor de pincel permite borrar o restaurar zonas (restaurar recupera los píxeles reales de la foto).
- **Alta en tanda**: eliges muchas fotos de la galería, se recortan en segundo plano y solo queda etiquetar una tras otra.
- **Outfits**: motor de reglas propio (teoría del color, formalidad, abrigo según temperatura, ocasión, mood) que evita repetir lo que llevaste hace poco. Cada sugerencia explica por qué combina.
- **Clima**: temperatura del día por ubicación aproximada o ciudad ([Open-Meteo](https://open-meteo.com), sin clave).
- **Calendario y diario de looks**: planifica la semana, marca lo que te pusiste y añade la foto del espejo. El mes se ve como un álbum.
- **Lavado**: lo que te pones se marca como usado; la pestaña Lavado dice qué va a la lavadora, con grupos de lavado.
- **Buscador**: por nombre, marca, tipo, etiqueta o color ("negro", "celeste", "jean").
- **Olvidadas**: prendas que no te pones desde hace dos meses.
- **Compartir outfit como imagen**: collage 4:5 listo para WhatsApp o historias.
- **Aviso diario** opcional con el outfit planificado o una idea para el día.
- **Estadísticas** de uso, desgaste por lavadas y prendas más y menos usadas.
- **Respaldo** completo a un `.zip` (base de datos + imágenes).
- **Nube y modo visor** (opcional): inicia sesión con Google, tu armario se sincroniza con Convex, e invitas por correo a quien quieras. Esa persona lo ve en solo lectura, puede armarte un outfit con tu ropa y mandártelo como imagen.

Las imágenes se guardan en WebP con transparencia (unos 40 KB por prenda).

## Estructura

```
lib/
  app/        arranque, rutas, providers (Riverpod), configuración
  data/       base local (drift), imágenes, repositorios, clima, sync con Convex
  domain/     modelos y lógica pura: motor de outfits, color, estadísticas
  features/   pantallas
  ui/         sistema de diseño
backend/      funciones y esquema de Convex (TypeScript)
test/         ~325 tests de dominio, datos y UI
```

## Requisitos

| Para | Necesitas |
|---|---|
| Compilar la app | [Flutter](https://docs.flutter.dev/get-started/install) 3.44+ (Dart 3.12), Android SDK, JDK 17 |
| Probarla | Un móvil Android 7+ (el recorte automático necesita Google Play Services) |
| Nube y visor (opcional) | Node 20+, una cuenta de [Convex](https://convex.dev) y un proyecto de [Google Cloud](https://console.cloud.google.com) |

Sin la parte opcional la app funciona entera en local; la sección de cuenta simplemente no aparece.

## Instalación manual

### 1. Solo local

```bash
git clone https://github.com/TU-USUARIO/ivyroom.git
cd ivyroom
flutter pub get
flutter run
```

### 2. Con nube y modo visor

**Convex**

```bash
cd backend
npm install
npx convex dev --once        # te pide iniciar sesión y crea el proyecto
```

Genera el par de claves con el que el backend firma sus sesiones (Google se usa solo para entrar; luego la app usa una sesión propia de 30 días que se renueva sola):

```bash
node -e "import('jose').then(async({generateKeyPair,exportJWK})=>{const{publicKey,privateKey}=await generateKeyPair('RS256',{extractable:true});const pub={...await exportJWK(publicKey),kid:'k1',alg:'RS256',use:'sig'};const priv={...await exportJWK(privateKey),kid:'k1',alg:'RS256'};console.log('JWT_PRIVATE_KEY='+JSON.stringify(priv));console.log('JWKS='+JSON.stringify({keys:[pub]}))})"
```

Guarda los dos valores en Convex (copia cada JSON tal cual, entre comillas simples):

```bash
npx convex env set JWT_PRIVATE_KEY '{"kty":"RSA",...}'
npx convex env set JWKS '{"keys":[...]}'
npx convex env set GOOGLE_CLIENT_ID 'TU-CLIENT-ID-WEB.apps.googleusercontent.com'
npx convex dev --once
```

**Google Cloud**

1. Crea un proyecto y configura la pantalla de consentimiento OAuth (tipo *Externo*, modo prueba). Añade como usuarios de prueba los correos que vayan a entrar.
2. Crea un ID de cliente OAuth de tipo **Aplicación web**. Ese es tu `GOOGLE_WEB_CLIENT_ID`.
3. Crea un ID de cliente OAuth de tipo **Android** con el paquete `com.ivyroom.app` y el SHA-1 de tu clave de firma:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
   ```
   Si compilas en release con tu propia clave, crea otro cliente Android con el SHA-1 de esa clave.

**La app**

```bash
cp config.example.json config.json   # y rellénalo con tus valores
flutter run --dart-define-from-file=config.json
```

`config.json` está en `.gitignore`. Nada de lo que contiene es secreto (viaja dentro del APK), pero es de cada instalación.

### 3. APK para instalar en otro móvil

Crea una clave de firma y el fichero `android/key.properties`:

```bash
keytool -genkeypair -v -keystore android/app/ivyroom-release.jks -alias ivyroom -keyalg RSA -keysize 2048 -validity 10000
```

```properties
# android/key.properties
storePassword=...
keyPassword=...
keyAlias=ivyroom
storeFile=ivyroom-release.jks
```

```bash
flutter build apk --release --split-per-abi --target-platform android-arm64 --dart-define-from-file=config.json
```

El APK queda en `build/app/outputs/flutter-apk/`. Guarda la clave en un lugar seguro: sin ella no se pueden instalar actualizaciones encima.

## Dile a tu IA favorita esto

Copia y pega en Claude, ChatGPT o el asistente que uses (mejor si tiene acceso a una terminal):

```text
Quiero instalar y compilar Ivyroom, una app Flutter para Android:
https://github.com/TU-USUARIO/ivyroom

Guíame paso a paso, comprobando cada paso antes de pasar al siguiente:

1. Verifica que tengo Flutter 3.44+, Android SDK, JDK 17 y Node 20+. Si falta algo,
   dime cómo instalarlo en mi sistema operativo.
2. Clona el repo y ejecuta `flutter pub get` y `flutter test`.
3. Lee el README.md, sección "Con nube y modo visor", y ayúdame a:
   - crear el proyecto de Convex desde backend/ (npx convex dev --once),
   - generar el par de claves RS256 y guardarlas con `npx convex env set`
     (JWT_PRIVATE_KEY, JWKS, GOOGLE_CLIENT_ID),
   - crear en Google Cloud la pantalla de consentimiento OAuth (modo prueba),
     un cliente OAuth "Aplicación web" y otro "Android" con el paquete
     com.ivyroom.app y el SHA-1 de mi keystore de debug (sácalo tú con keytool).
4. Crea config.json a partir de config.example.json con mis valores.
5. Conecta mi móvil por USB con depuración activada y ejecuta
   `flutter run --dart-define-from-file=config.json`.

Si algo falla, lee el error, explícame la causa y propón el arreglo antes de
cambiar nada. No subas config.json, key.properties ni ningún .jks a git.
```

## Notas

- **Xiaomi / HyperOS**: para instalar por USB hay que activar también *Instalar vía USB* en Opciones de desarrollador.
- **Recorte automático en release**: ML Kit carga su modelo como módulo de Play Services y necesita las reglas de `android/app/proguard-rules.pro`; sin ellas falla solo en release.
- **Plan gratuito de Convex**: 1 GB de archivos y 1 GB de transferencia al mes. Con WebP caben decenas de miles de prendas, y la app solo sube las imágenes que el servidor no tiene.
