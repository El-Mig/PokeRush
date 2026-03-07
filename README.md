# 🎮 PokeRush - Pokémon Heads Up

¡Bienvenido a **PokeRush**! Una experiencia vibrante y dinámica de "Heads Up" (Adivina la palabra) centrada en el universo Pokémon. Pon a prueba tus conocimientos, compite contra el reloj y completa tu Pokédex en este juego diseñado para fans de todas las generaciones.

## ✨ Características Principales

### 🕹️ Modos de Juego

- **Modo Clásico**: 60 segundos para adivinar tantos Pokémon como puedas. Usa filtros de generación y tipos para personalizar tu sesión.
- **Modo Supervivencia**: Empiezas con 30 segundos. Cada acierto te otorga **+3 segundos**. ¿Cuánto tiempo podrás aguantar?

### 📱 Jugabilidad con Sensores

- **Tilt to Play**: Inclina el teléfono hacia **adelante** (pantalla al suelo) para marcar como **Correcto**.
- **Tilt to Skip**: Inclina el teléfono hacia **atrás** (pantalla al techo) para **Pasar** al siguiente.
- _Nota: Incluye calibración manual en los ajustes para adaptarse a cualquier posición._

### 📕 Pokédex Completa & Shiny Hunter

- **1025 Pokémon**: Desde Kanto hasta Paldea, todos están presentes.
- **Buscador Inteligente**: Filtra por nombre y generación para revisar tus capturas.
- **Sistema Shiny**: ¡Los Pokémon Shiny pueden aparecer en cualquier momento! Si los aciertas, se marcarán permanentemente en tu Pokédex con una medalla especial.

### 🏆 Sistema de Logros

- Más de **20 logros** para desbloquear.
- Categorías: Velocidad, Rachas, Coleccionismo de Tipos y Exploración de Generaciones.

### 📶 Modo Offline - ¡Juega donde quieras!

- **Caché Proactivo**: La aplicación descarga automáticamente los datos básicos e imágenes para que puedas jugar sin conexión a internet.
- **Rendimiento Optimizado**: Imágenes cacheadas para una carga instantánea y sin esperas.

## 🛠️ Stack Tecnológico

- **Framework**: [Flutter](https://flutter.dev)
- **Gestión de Estado**: [Riverpod](https://riverpod.dev)
- **API**: [PokéAPI](https://pokeapi.co)
- **Persistencia**: Shared Preferences
- **Sensores**: `sensors_plus`
- **UI/UX**: Diseño premium con fondos dinámicos y micro-animaciones.

## 🚀 Cómo Empezar

### Requisitos Previos

- Flutter SDK (v3.0.0 o superior)
- Android Studio / VS Code con plugins de Flutter y Dart.

### Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/pokerush.git
   ```
2. Obtén las dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## 📦 Generación de APK

Para generar una versión instalable en Android:

```bash
flutter build apk --release
```

---

_Desarrollado con ❤️ para entrenadores Pokémon._
