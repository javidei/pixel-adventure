# Pixel Adventure

Aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje visual de las aventuras de finales de los 80 y principios de los 90.

## Estado actual · 0.4.7

El prototipo incluye:

- resolución interna **320×180** y escalado nítido;
- **cruz clásica pixel art** fija como cursor por defecto;
- **Commodore Pixelized** para interfaz, verbos, mensajes y pantalla inicial;
- **ONESIZE_ / Onesize normal** para los textos hablados por NPC;
- **Windows Regular** para las respuestas del protagonista;
- dos modos de conversación: diálogo corto sobre el escenario y conversación importante con retrato + respuestas seleccionables;
- diálogos NPC con **relleno morado, contorno negro de 2 px, tamaño reducido y salto de línea automático**;
- respuestas del protagonista en **verde y texto normal**, sin mayúsculas forzadas;
- retrato del **Cartógrafo con fondo transparente**, reutilizado también para que el NPC del escenario mantenga la misma apariencia;
- nuevo bosque nocturno con **tres capas de árboles y parallax**, manteniendo el cielo estrellado;
- suelo rehecho con tierra, hierba, piedras y pequeñas irregularidades;
- cofre redibujado con tablones, herrajes, cierre y tapa animada más detallada;
- interfaz inferior clásica con fondo negro, verbos verdes, inventario morado y flecha azul solo cuando hace falta paginar;
- escenario horizontal con cámara y **parallax multicapa**;
- inventario, hotspots, interacción `verbo + objeto` y puzle de ejemplo;
- exportación Web automática mediante GitHub Actions.

### Cambio 0.4.7 · Bosque, Cartógrafo y cofre

El horizonte deja de usar montañas triangulares y bloques rectangulares. Ahora se dibujan varias capas de árboles con distintas velocidades de parallax: los más lejanos aparecen como sombras y los cercanos tienen una silueta más marcada. El camino se ha rehecho para parecer terreno natural. El Cartógrafo utiliza un PNG transparente y su versión estática del escenario comparte el mismo aspecto. El cofre conserva su lógica interactiva y su animación, pero tiene más volumen y detalle visual.

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
