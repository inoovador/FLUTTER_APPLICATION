# 🌐 Acceso Remoto a la Aplicación

## 🚀 Opciones de Acceso desde Otra Máquina

### 1. 📱 **APK para Android** (Más Fácil)

#### Crear APK
```bash
# Ejecutar desde el proyecto:
build_and_deploy.bat
# Seleccionar opción 1 (APK Android)
```

#### Distribuir APK
- **Archivo generado**: `build\app\outputs\flutter-apk\app-release.apk`
- **Tamaño**: ~50-100MB
- **Compatibilidad**: Android 5.0+

#### Instalar en Otro Dispositivo
1. Transferir `app-release.apk` al dispositivo
2. Habilitar "Fuentes desconocidas" en Android
3. Instalar APK
4. ¡Listo! App funciona sin conexión

---

### 2. 🌐 **Aplicación Web** (Acceso Universal)

#### Compilar Web
```bash
build_and_deploy.bat
# Seleccionar opción 2 (Web)
```

#### Método A: Servidor Local
```bash
# En la máquina principal:
quick_start_web.bat
# Se abre en: http://localhost:8080
```

**Para acceso remoto:**
- Obtener IP de la máquina: `ipconfig`
- Desde otra máquina: `http://IP_MAQUINA:8080`
- Ejemplo: `http://192.168.1.100:8080`

#### Método B: Servidor Web
1. Subir carpeta `build\web\` a servidor web
2. Acceder desde cualquier navegador
3. Servicios gratuitos:
   - **Netlify**: Arrastrar carpeta web
   - **Vercel**: Conectar con GitHub
   - **Firebase Hosting**: `firebase deploy`

---

### 3. 💻 **Aplicación de Escritorio Windows**

#### Compilar EXE
```bash
build_and_deploy.bat
# Seleccionar opción 3 (Windows)
```

#### Distribuir
- **Carpeta**: `build\windows\runner\Release\`
- **Archivo principal**: `flutter_application_1.exe`
- **Incluye**: Todas las DLLs necesarias

#### Instalar en Otra PC
1. Copiar carpeta `Release` completa
2. Ejecutar `flutter_application_1.exe`
3. No requiere instalación adicional

---

## 🔧 Scripts de Acceso Rápido

### `start_app.bat`
- **Propósito**: Launcher principal con opciones
- **Uso**: Doble click para elegir plataforma
- **Características**: Verificación automática de dependencias

### `quick_start_web.bat`
- **Propósito**: Inicio rápido en navegador
- **Uso**: Doble click para web inmediata
- **URL**: http://localhost:8080

### `build_and_deploy.bat`
- **Propósito**: Compilar para distribución
- **Opciones**: APK, Web, EXE, o Todos
- **Resultado**: Archivos listos para compartir

---

## 📋 Requisitos por Plataforma

### Para APK Android
- ✅ **Ninguno** - APK incluye todo
- ✅ Android 5.0 o superior
- ✅ ~100MB espacio libre

### Para Web
- ✅ Navegador moderno (Chrome, Firefox, Safari, Edge)
- ✅ JavaScript habilitado
- ✅ Conexión a internet (para primera carga)

### Para Windows EXE
- ✅ Windows 10 o superior
- ✅ Visual C++ Redistributable (usualmente ya instalado)
- ✅ ~200MB espacio libre

---

## 🌍 Configuración de Red para Acceso Remoto

### Servidor Local (Web)
```bash
# Obtener IP local
ipconfig

# Abrir puertos en firewall (Windows)
netsh advfirewall firewall add rule name="Flutter App" dir=in action=allow protocol=TCP localport=8080

# Iniciar servidor
quick_start_web.bat
```

### Acceso desde Red Local
- **Misma WiFi**: `http://IP_LOCAL:8080`
- **Ejemplo**: `http://192.168.1.100:8080`

### Acceso desde Internet
1. **Port Forwarding** en router (puerto 8080)
2. **IP Externa**: `http://IP_PUBLICA:8080`
3. **DNS Dinámico** para IP fija

---

## 📤 Distribución Recomendada

### Para Usuarios Finales
1. **APK Android** → Instalar y usar offline
2. **Web App** → Acceso desde cualquier dispositivo

### Para Desarrolladores
1. **Código fuente** → Clonar repositorio GitHub
2. **Scripts de inicio** → Usar `start_app.bat`

### Para Demos/Presentaciones
1. **Web local** → `quick_start_web.bat`
2. **Windows EXE** → Aplicación standalone

---

## 🔒 Consideraciones de Seguridad

- **Red local**: Firewall configurado correctamente
- **Internet**: HTTPS recomendado para producción
- **APK**: Firmar para distribución oficial
- **Datos**: Backup antes de distribución

---

## 🆘 Solución de Problemas

### "No se puede conectar"
- Verificar IP y puerto
- Desactivar firewall temporalmente
- Comprobar que el servidor está activo

### "APK no se instala"
- Habilitar "Fuentes desconocidas" en Android
- Verificar espacio disponible
- Comprobar compatibilidad Android 5.0+

### "EXE no ejecuta"
- Verificar Windows 10+
- Instalar Visual C++ Redistributable
- Ejecutar como administrador

---

**¡La app está lista para ejecutarse en cualquier máquina!** 🎉