# Pixel Adventure

Aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje visual de las aventuras de finales de los 80 y principios de los 90.

## Estado actual · 0.4.3

El prototipo incluye:

- resolución interna **320×180** y escalado nítido;
- **cruz clásica pixel art** fija como cursor por defecto;
- **Commodore Pixelized** para interfaz, verbos, mensajes y pantalla inicial;
- **ONESR___ / Onesize Reverse** para los textos hablados por NPC;
- **Windows Regular** para las respuestas del protagonista;
- dos modos de conversación: diálogo corto sobre el escenario y conversación importante con retrato + respuestas seleccionables;
- diálogos NPC con **relleno morado, contorno negro, tamaño reducido y salto de línea automático**;
- interfaz inferior clásica con fondo negro, verbos verdes, inventario morado y flecha azul solo cuando hace falta paginar;
- escenario horizontal con cámara y **parallax multicapa**;
- inventario, hotspots, interacción `verbo + objeto` y puzle de ejemplo;
- animación visible del cofre;
- exportación Web automática mediante GitHub Actions.

### Corrección 0.4.3 · diálogos

Se elimina el nombre redundante del Cartógrafo en la conversación, se retiran los textos temporales de prueba de fuentes y se ajusta el renderizado de ONESR para que el texto no salga del área visible. El diálogo usa ahora contorno negro real en ocho direcciones y ajuste automático por palabras.

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
