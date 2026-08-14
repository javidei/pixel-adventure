# Pixel Adventure

Aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje visual de las aventuras de finales de los 80 y principios de los 90, sin reutilizar personajes, fondos, música ni recursos de juegos comerciales.

## Estado actual · 0.2.0

El prototipo ya incluye:

- resolución interna **320×180** y escalado nítido;
- fuente **Commodore Pixelized v1.2** cargada desde `assets/fonts/` para toda la interfaz y los textos del juego;
- pantalla inicial negra con **“Bienvenido a Naranjal del Río”**;
- interfaz clásica de **9 verbos**;
- escenario horizontal más ancho que la cámara;
- movimiento lateral del personaje con seguimiento de cámara;
- **parallax multicapa**: estrellas, montañas, colinas/pueblo lejano y primer plano se desplazan a velocidades distintas;
- hotspots clicables en coordenadas de mundo;
- inventario básico e interacción `verbo + objeto`;
- acercamiento automático del personaje al objeto antes de ejecutar la acción;
- animación visible al abrir el cofre;
- pequeño puzle de ejemplo: mover un mapa, encontrar una llave, abrir el cofre, recoger un fragmento y entregarlo al cartógrafo;
- escena dibujada proceduralmente en pixel art para probar cámara, capas e interacción sin depender todavía del arte definitivo;
- datos básicos del escenario separados en JSON;
- exportación Web automática mediante GitHub Actions.

Demo:

`https://javidei.github.io/pixel-adventure/`

## Fuente

El proyecto usa directamente:

`assets/fonts/Commodore Pixelized v1.2.ttf`

Todos los textos actuales pasan por las funciones de dibujo del juego y utilizan esa misma fuente. Además, la escena raíz hereda un `Theme` global con esa fuente para los controles que se añadan después.

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
