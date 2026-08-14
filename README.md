# Pixel Adventure

Aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje visual de las aventuras de finales de los 80 y principios de los 90, sin reutilizar personajes, fondos, música ni recursos de juegos comerciales.

## Estado actual · 0.4.1

El prototipo ya incluye:

- resolución interna **320×180** y escalado nítido;
- **cruz clásica pixel art** fija como cursor por defecto, sin selector previo;
- cursor software dibujado dentro del propio juego para mantener el aspecto retro también en Web;
- **Commodore Pixelized** para pantalla inicial, textos de interfaz, verbos y mensajes;
- **ONESR___** para el texto hablado por NPC;
- **Windows Regular** para las respuestas del protagonista en conversaciones importantes;
- dos modos de conversación: diálogo corto sobre el escenario y conversación importante con retrato + respuestas seleccionables;
- interfaz clásica inferior con fondo negro, verbos verdes, inventario morado y flecha azul solo cuando hay más objetos de los visibles;
- pantalla inicial negra con **“Bienvenido a Naranjal del Río”**;
- interfaz clásica de **9 verbos**;
- escenario horizontal con seguimiento de cámara y **parallax multicapa**;
- hotspots clicables e inventario básico con interacción `verbo + objeto`;
- animación visible al abrir el cofre;
- pequeño puzle de ejemplo: mover un mapa, encontrar una llave, abrir el cofre, recoger un fragmento y entregarlo al cartógrafo;
- datos básicos del escenario separados en JSON;
- exportación Web automática mediante GitHub Actions.

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

La intención es mantener el motor **data-driven**: habitaciones, hotspots, diálogos, inventario y puzles deberán poder ampliarse progresivamente mediante datos sin llenar el código principal de casos específicos.

La siguiente fase está descrita en `docs/ROADMAP.md`.
