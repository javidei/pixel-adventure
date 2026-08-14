# Pixel Adventure

Aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje visual de las aventuras de finales de los 80 y principios de los 90.

## Estado actual · 0.4.6

El prototipo incluye:

- resolución interna **320×180** y escalado nítido;
- **cruz clásica pixel art** fija como cursor por defecto;
- **Commodore Pixelized** para interfaz, verbos, mensajes y pantalla inicial;
- **ONESIZE_ / Onesize normal** para los textos hablados por NPC;
- **Windows Regular** para las respuestas del protagonista;
- dos modos de conversación: diálogo corto sobre el escenario y conversación importante con retrato + respuestas seleccionables;
- diálogos NPC con **relleno morado, contorno negro de 2 px, tamaño reducido y salto de línea automático**;
- respuestas del protagonista en **verde y texto normal**, sin mayúsculas forzadas;
- retrato pixel del **Cartógrafo** integrado como imagen real en la conversación importante;
- interfaz inferior clásica con fondo negro, verbos verdes, inventario morado y flecha azul solo cuando hace falta paginar;
- escenario horizontal con cámara y **parallax multicapa**;
- inventario, hotspots, interacción `verbo + objeto` y puzle de ejemplo;
- animación visible del cofre;
- exportación Web automática mediante GitHub Actions.

### Cambio 0.4.6 · Conversación del Cartógrafo

La conversación importante usa el retrato aprobado del Cartógrafo en `assets/characters/cartographer_portrait.png`. Los textos del NPC dejan de mostrarse en mayúsculas forzadas y mantienen Onesize normal con relleno morado y contorno negro más marcado. Las respuestas del protagonista usan Windows Regular en verde y también se muestran como texto normal.

Demo:

`https://javidei.github.io/pixel-adventure/`

## Fuentes

```text
assets/fonts/Commodore Pixelized v1.2.ttf
assets/fonts/Windows Regular.ttf
assets/fonts/ONESIZE_.TTF
assets/fonts/ONESR___.TTF
```

## Estructura

```text
pixel-adventure/
├── .github/workflows/deploy-web.yml
├── assets/characters/
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
