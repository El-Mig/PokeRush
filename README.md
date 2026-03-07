# 🎮 PokeRush - Pokémon Heads Up

¡Bienvenido a **PokeRush**! Una experiencia vibrante y dinámica de "Heads Up" (Adivina la palabra) centrada en el universo Pokémon. Pon a prueba tus conocimientos, compite contra el reloj y completa tu Pokédex en este juego diseñado para fans de todas las generaciones.

## ✨ Características Principales

### 🕹️ Modos de Juego

- **Modo Clásico**: 60 segundos para adivinar tantos Pokémon como puedas. Usa filtros de generación y tipos para personalizar tu sesión.
- **Modo Supervivencia**: Empiezas con 30 segundos. Cada acierto te otorga **+3 segundos**. ¿Cuánto tiempo podrás aguantar?

### 📱 Jugabilidad con Sensores (Tilt to Play)

- **Correcto ✅**: Inclina el teléfono hacia **adelante** (pantalla al suelo).
- **Pasar ⏩**: Inclina el teléfono hacia **atrás** (pantalla al techo).
- _Ajustes_: Incluye calibración manual de sensibilidad en el menú de ajustes para una experiencia óptima.

### 🌐 Soporte Multi-idioma

- La aplicación está disponible en **Español** e **Inglés**.
- Cambia el idioma en tiempo real desde los ajustes sin perder tu progreso.

### 📕 Pokédex Completa & Shiny Hunter

- **1025 Pokémon**: Desde Kanto hasta Paldea.
- **Sistema Shiny ✨**: Los Pokémon Shiny pueden aparecer aleatoriamente. Si los aciertas, se marcan con una estrella plateada en tu Pokédex.
- **Buscador Inteligente**: Filtra y revisa tus capturas por nombre, generación o tipo.

### 🏆 Sistema de Logros

- Desbloquea más de **20 logros** únicos.
- Sigue tu progreso: Novato, Maestro de Kanto, Cazador de Shinies, y muchos más.
- Notificaciones hápticas al desbloquear nuevos hitos.

## 🛠️ Stack Tecnológico

- **Framework**: [Flutter](https://flutter.dev)
- **Gestión de Estado**: [Riverpod](https://riverpod.dev)
- **API**: [PokéAPI](https://pokeapi.co)
- **UI & Animaciones**: `flutter_animate`, `dynamic_backgrounds`
- **Sensores & Hardware**: `sensors_plus`, `vibration`, `wakelock_plus`
- **Persistencia**: `shared_preferences`
- **Networking**: `http`, `cached_network_image`

## 🚀 Cómo Empezar

### Requisitos Previos

- Flutter SDK (v3.0.0 o superior)
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

Para generar una versión instalable en Android:

```bash
flutter build apk --release
```

---

_Desarrollado con ❤️ para entrenadores Pokémon. ¡Hazte con todos!_
