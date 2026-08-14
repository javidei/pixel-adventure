# Pixel Adventure

Aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje visual de las aventuras de finales de los 80 y principios de los 90.

## Estado actual · 0.4.9

El prototipo incluye:

- resolución interna **320×180** y escalado nítido;
- **botón de pantalla completa** mediante icono en la esquina superior derecha, además de F11;
- **cruz clásica pixel art** fija como cursor por defecto;
- **Commodore Pixelized** para interfaz, verbos, mensajes y pantalla inicial;
- **ONESIZE_ / Onesize normal** para los textos hablados por NPC;
- fallback automático de fuente para **tildes, ñ y otros caracteres españoles**, evitando glifos corruptos;
- **Windows Regular** para las respuestas del protagonista;
- dos modos de conversación: diálogo corto sobre el escenario y conversación importante con retrato + respuestas seleccionables;
- diálogos NPC con **relleno morado, contorno negro de 2 px, tamaño reducido y salto de línea automático**;
- respuestas del protagonista en **verde y texto normal**, sin mayúsculas forzadas;
- retrato transparente aprobado del **Cartógrafo** reservado para la conversación importante;
- Cartógrafo del escenario recuperado al aspecto sencillo anterior, ahora preparado como frames PNG independientes;
- bosque dividido en **tres PNG de parallax independientes**;
- suelo convertido en una capa PNG independiente;
- cofre convertido en sprites separados para cerrado, apertura y abierto;
- interfaz inferior clásica con fondo negro, verbos verdes e inventario morado;
- inventario, hotspots, interacción `verbo + objeto` y puzle de ejemplo;
- exportación Web automática mediante GitHub Actions.

### Cambio 0.4.9 · pantalla completa y textos españoles

Se añade un control de pantalla completa con solo icono en la esquina superior derecha. Los textos de diálogo ahora comprueban cada glifo y usan una fuente de respaldo únicamente cuando la fuente principal no contiene ese carácter, manteniendo el estilo Onesize sin romper las tildes o la `ñ`. También se normaliza la ortografía española del diálogo de la demo.

### Cambio 0.4.8 · assets desacoplados

La parte visual empieza a separarse de la lógica. Los fondos, el NPC del mundo y el cofre tienen una estructura de assets reemplazables sin reescribir el código. Los tamaños y convenciones están documentados en `docs/ASSET_PIPELINE.md`.

Demo:

`https://javidei.github.io/pixel-adventure/`

## Estructura de arte

```text
assets/backgrounds/demo_room/
  trees_far.png      680x116
  trees_mid.png      680x116
  trees_near.png     680x116
  ground.png         680x28

assets/sprites/cartographer/world/
  idle_0.png         24x48
  idle_1.png         24x48
  talk_0.png         24x48
  talk_1.png         24x48

assets/sprites/chest/
  chest_closed.png   56x32
  chest_opening.png  56x32
  chest_open.png     56x32
```

El retrato de conversación sigue en `assets/characters/cartographer_portrait.png`.

## Filosofía

La intención es mantener el motor **data-driven** y que el arte sea también reemplazable: habitación, capas de fondo, sprites, diálogos, inventario y puzles deben poder evolucionar sin llenar el código principal de casos específicos.
