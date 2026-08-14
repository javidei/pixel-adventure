# Pixel Adventure

Base de una aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje de diseño de las aventuras de finales de los 80 y principios de los 90, sin reutilizar personajes, fondos, música ni recursos de juegos comerciales.

## Estado actual · 0.1.0

El prototipo ya incluye:

- resolución interna **320×180** y escalado nítido;
- interfaz clásica de **9 verbos**;
- hotspots clicables en la habitación;
- inventario básico;
- interacción `verbo + objeto`;
- pequeño puzle de ejemplo: mover un cuadro, encontrar una llave, abrir un cofre y entregar un fragmento;
- escena dibujada de forma procedural para poder probar el motor sin depender todavía de arte definitivo;
- datos básicos de la habitación separados en JSON;
- exportación Web automática mediante GitHub Actions.

La demo Web se publica en:

`https://javidei.github.io/pixel-adventure/`

## Fuente Commodore 64 Pixelized

El proyecto está preparado para utilizar **Commodore 64 Pixelized**. Si existe este archivo:

`assets/fonts/Commodore Pixelized v1.2.ttf`

Godot lo utiliza automáticamente en la interfaz del prototipo. Mientras el TTF no esté dentro del proyecto, se utiliza la fuente de respaldo de Godot para que la build Web siga siendo autocontenida y estable.

El archivo de la fuente de terceros no se incluye en este repositorio. Consulta `assets/fonts/README.md` para añadir tu copia.

## Estructura

```text
pixel-adventure/
├── .github/workflows/deploy-web.yml
├── assets/fonts/
├── data/rooms/
├── docs/
├── scenes/
├── scripts/
├── export_presets.cfg
└── project.godot
```

## Filosofía

La intención es que el motor sea **data-driven**: habitaciones, hotspots, diálogos, inventario y puzles deberán poder ampliarse progresivamente mediante datos sin llenar el código principal de casos específicos.

La siguiente fase está descrita en `docs/ROADMAP.md`.
