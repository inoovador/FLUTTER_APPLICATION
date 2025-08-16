# 🚀 INSTRUCCIONES PARA EJECUTAR LA APLICACIÓN

## 📱 APLICACIÓN DE TORNEOS DEPORTIVOS

### ✅ REQUISITOS PREVIOS
- Flutter instalado
- Emulador Android o dispositivo físico conectado
- VS Code o Android Studio

### 🎯 PASOS PARA EJECUTAR

1. **Abrir terminal en la carpeta del proyecto**
   ```bash
   cd C:\Users\limac\OneDrive\Escritorio\flutter_application_1
   ```

2. **Limpiar el proyecto**
   ```bash
   flutter clean
   ```

3. **Obtener dependencias**
   ```bash
   flutter pub get
   ```

4. **Verificar dispositivos conectados**
   ```bash
   flutter devices
   ```

5. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

### 🧪 CÓMO TESTEAR LA APLICACIÓN

#### 👥 FLUJO COMO JUGADOR

1. **Pantalla de Login**
   - Correo: `test@example.com`
   - Contraseña: `123456`
   - Clic en "Iniciar Sesión"

2. **Pantalla Principal - 4 Tabs**
   - **Dashboard**: Resumen y estadísticas
   - **Torneos**: Lista de torneos disponibles ⭐
   - **Mis Inscripciones**: Historial de inscripciones
   - **Perfil**: Información del usuario

3. **Inscribirse a un Torneo**
   - Ir al tab "Torneos"
   - Seleccionar un torneo (ej: "Copa Verano 2024")
   - Ver detalles
   - Clic en "Inscribir mi Equipo"

4. **Proceso de Pago**
   - Seleccionar método de pago:
     - **Yape** (recomendado para pruebas)
     - Visa
     - Mastercard
     - Transferencia
   
   - **Si eliges Yape**:
     - Número: 932 744 546
     - Yapear manualmente
     - Clic en "Confirmar Pago"

5. **Ver Inscripciones**
   - Ir al tab "Mis Inscripciones"
   - Ver estado del pago

#### 👔 FLUJO COMO ORGANIZADOR

1. **Pantalla de Login**
   - Clic en botón "Soy Organizador"

2. **Dashboard del Organizador - 4 Tabs**
   - **Torneos**: Lista de torneos creados
   - **Estadísticas**: Métricas generales
   - **Finanzas**: Balance y transacciones
   - **Configuración**: Métodos de pago

3. **Crear Nuevo Torneo**
   - En tab "Torneos", clic en "+" (arriba derecha)
   - Llenar formulario:
     - Nombre: "Mi Torneo de Prueba"
     - Descripción: "Torneo de prueba"
     - Deporte: Fútbol
     - Fecha: Seleccionar
     - Ubicación: "Estadio Local"
     - Precio: 50
     - Equipos: 16

4. **Ver Inscritos**
   - Clic en un torneo existente
   - Tab "Inscritos"
   - Ver pagos pendientes y confirmados
   - Confirmar pagos pendientes

5. **Configurar Métodos de Pago**
   - Tab "Configuración"
   - "Métodos de Pago"
   - Configurar Yape, Plin o Banco

### 📊 DATOS DE PRUEBA

#### Torneos Disponibles:
1. **Copa Verano 2024**
   - Organizador: Academia Deportiva Juan
   - Yape: 932744546
   - Precio: S/ 50 por jugador

2. **Liga Amateur Sub-17**
   - Organizador: Academia Deportiva Juan
   - Yape: 932744546
   - Precio: S/ 75 por jugador

3. **Torneo Mixto de Vóley**
   - Organizador: Club Voley Masters
   - Yape: 987654321
   - Precio: S/ 40 por jugador

### ❗ SOLUCIÓN DE PROBLEMAS

**Error de Gradle:**
```bash
cd android
gradlew clean
cd ..
flutter run
```

**Error de caché:**
```bash
flutter pub cache clean
flutter pub get
flutter run
```

**Error al compilar:**
```bash
flutter doctor
# Verificar que todo esté en verde
```

### 💡 TIPS

1. **Para probar pagos**: Usa Yape y simula el pago
2. **Para ver ambos flujos**: Abre la app en 2 emuladores
3. **Hot Reload**: Presiona 'r' en la terminal mientras la app corre
4. **Hot Restart**: Presiona 'R' para reiniciar completamente

### 🎯 FLUJO COMPLETO DE PRUEBA

1. **Como Organizador**: Crear torneo → Definir precio
2. **Como Jugador**: Ver torneo → Inscribirse → Pagar
3. **Como Organizador**: Ver inscripción → Confirmar pago
4. **Como Jugador**: Ver inscripción confirmada

¡La aplicación está lista para usar! 🚀