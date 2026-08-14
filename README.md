# Pixel Adventure

Aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje visual de las aventuras de finales de los 80 y principios de los 90.

## Estado actual · 0.4.2

El prototipo incluye:

- resolución interna **320×180** y escalado nítido;
- **cruz clásica pixel art** fija como cursor por defecto;
- **Commodore Pixelized** para interfaz, verbos, mensajes y pantalla inicial;
- **ONESR___ / Onesize Reverse** para los textos hablados por NPC;
- **Windows Regular** para las respuestas del protagonista;
- dos modos de conversación: diálogo corto sobre el escenario y conversación importante con retrato + respuestas seleccionables;
- interfaz inferior clásica con fondo negro, verbos verdes, inventario morado y flecha azul solo cuando hace falta paginar;
- escenario horizontal con cámara y **parallax multicapa**;
- inventario, hotspots, interacción `verbo + objeto` y puzle de ejemplo;
- animación visible del cofre;
- exportación Web automática mediante GitHub Actions.

### Corrección 0.4.2 · ONESR

La copia anterior de `ONESR___.TTF` estaba truncada. El archivo del repositorio tenía **6656 bytes**, aunque las tablas internas del propio TTF apuntaban a datos por encima de los **9000 bytes**. La fuente original ronda los **9.7 KB**.

La CI ahora valida el tamaño del TTF y restaura la copia completa antes de importar/exportar si detecta una versión incompleta. También hay dos pruebas visuales temporales con ONESR: una en la pantalla inicial y otra durante los primeros segundos del escenario.

Demo:

`https://javidei.github.io/pixel-adventure/`

## Fuentes

```text
assets/fonts/Commodore Pixelized v1.2.ttf
assets/fonts/Windows Regular.ttf
assets/fonts/ONESR___.TTF
```

## Estructura

```text
pixel-adventure/
├── .github/workflows/deploy-web.yml
├── assets/fonts/
├── assets/theme/
├── data/rooms/
├── docs/
├── scenes/
├── scripts/
├── export_presets.cfg
└── project.godot
```

## Filosofía

La intención es mantener el motor **data-driven**: habitaciones, hotspots, diálogos, inventario y puzles deberán poder ampliarse mediante datos sin llenar el código principal de casos específicos.
