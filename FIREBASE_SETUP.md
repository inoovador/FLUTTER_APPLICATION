# Configuración de Firebase para la App de Torneos

## Pasos para configurar Firebase:

### 1. Crear proyecto en Firebase Console
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Nombre sugerido: "torneo-app"

### 2. Configurar Firebase para Android
1. En Firebase Console, click en "Agregar app" > Android
2. Package name: `com.example.flutter_application_1`
3. Descarga el archivo `google-services.json`
4. Coloca el archivo en: `android/app/google-services.json`

### 3. Actualizar archivos de configuración Android

Ya hemos preparado la app, pero necesitas agregar estas líneas:

#### En `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### En `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

### 4. Habilitar servicios en Firebase Console
1. **Authentication**: 
   - Ve a Authentication > Sign-in method
   - Habilita "Email/Password"

2. **Firestore Database**:
   - Ve a Firestore Database
   - Crea la base de datos en modo "test" (temporal)
   - Selecciona la ubicación más cercana

### 5. Reglas de seguridad básicas para Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios pueden leer y escribir su propio documento
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Todos los usuarios autenticados pueden leer inscripciones
    match /inscriptions/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Equipos
    match /teams/{teamId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 6. Ejecutar la app
```bash
flutter clean
flutter pub get
flutter run
```

## Estructura de datos en Firestore

### Colección: users
```json
{
  "id": "uid",
  "email": "user@example.com",
  "name": "Juan Pérez",
  "role": "player",
  "photoUrl": "https://...",
  "createdAt": "2024-01-01T00:00:00",
  "teamIds": ["team1", "team2"],
  "playerProfile": {
    "position": "Delantero",
    "number": 9,
    "stats": {
      "goals": 10,
      "assists": 5,
      "matches": 20
    }
  }
}
```

### Colección: teams
```json
{
  "id": "teamId",
  "name": "Los Campeones",
  "captainId": "userId",
  "members": ["userId1", "userId2"],
  "createdAt": "2024-01-01T00:00:00"
}
```

### Colección: inscriptions
```json
{
  "id": "inscriptionId",
  "userId": "userId",
  "eventId": "eventId",
  "teamId": "teamId",
  "status": "pending", // pending, paid, confirmed
  "paymentStatus": "pending",
  "paymentDate": null,
  "amount": 50.00,
  "createdAt": "2024-01-01T00:00:00"
}
```