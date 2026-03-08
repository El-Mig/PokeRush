# 🎮 PokeRush - Pokémon Heads Up

¡Bienvenido a **PokeRush**! Una experiencia vibrante y dinámica de "Heads Up" (Adivina la palabra) centrada en el universo Pokémon. Pon a prueba tus conocimientos, compite contra el reloj y completa tu Pokédex en este juego diseñado para fans de todas las generaciones.

## ✨ Características Principales

### 🕹️ Modos de Juego y Dificultad

- **Modo Clásico**: 60 segundos para adivinar tantos Pokémon como puedas.
- **Modo Supervivencia**: Empiezas con 30 segundos. Cada acierto te otorga **+3 segundos**.
- **Dificultad Normal vs Experto**: Juega en modo Normal para una experiencia casual o en Experto con cartas ocultas e información en idiomas aleatorios.

### 🎛️ Filtros y Categorías Temáticas

- **Generaciones y Tipos**: Filtra exactamente qué Pokémon quieres que aparezcan, cruzando hasta 9 generaciones con 18 tipos elementales.
- **Categorías Temáticas**: Juega partidas exclusivas con la opción "Solo Iniciales" o "Solo Legendarios" para un desafío concentrado.

### 📱 Jugabilidad con Sensores (Tilt to Play)

- **Correcto ✅**: Inclina el teléfono hacia **adelante** (pantalla al suelo).
- **Pasar ⏩**: Inclina el teléfono hacia **atrás** (pantalla al techo).
- _Ajustes_: Incluye calibración manual de sensibilidad giroscópica en el menú de ajustes.

### 🌐 Soporte Multi-idioma

- La aplicación y la base de datos están disponibles íntegramente en **Español** e **Inglés**.
- Cambia el idioma en tiempo real desde los ajustes.

### 💳 Trainer Card & Pokédex Completa

- **Trainer Card**: Tu perfil de jugador interactivo que registra tus estadísticas globales, racha máxima, pokémon favoritos (tipos más jugados) e ID único.
- **1025 Pokémon**: Desde Kanto hasta Paldea.
- **Sistema Shiny ✨**: Los Pokémon Shiny pueden aparecer aleatoriamente (1% base). Si los aciertas, se marcan permanentemente en tu Pokédex.

### 🏆 Sistema de Logros

- Desbloquea más de **20 logros** únicos basados en tu rendimiento, horario de juego y suerte.

## 🛠️ Stack Tecnológico y Arquitectura

- **Framework**: [Flutter](https://flutter.dev) (Cross-platform Mobile, Web & Desktop)
- **Gestión de Estado Centralizada**: [Riverpod](https://riverpod.dev)
- **Consumo API HTTP**: [PokéAPI](https://pokeapi.co) con abstracción de repositorio.
- **Caché Progresiva y Resiliencia**: Sistema inteligente `SharedPreferences` que almacena metadatos y mitigación de errores `QuotaExceededError` en entornos limitados (Web LocalStorage).
- **Sensores Físicos**: `sensors_plus` para acelerómetro y giroscopio.
- **UX Inmersivo**: `vibration` (feedback háptico), `wakelock_plus` (anti-screen sleep), `dynamic_backgrounds` (fondos adaptativos).
- **Localización**: Implementación nativa con `flutter_localizations` y `.arb` files.

## 🚀 Cómo Empezar

### Requisitos Previos

- Flutter SDK (v3.19.0 o superior)
- Git instalado

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

Para generar una versión instalable optimizada (Release) en Android:

```bash
flutter build apk --release
```

---

_Desarrollado con ❤️ para entrenadores Pokémon. ¡Hazte con todos!_
