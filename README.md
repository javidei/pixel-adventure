# Pixel Adventure

Aventura gráfica point & click original en **Godot 4.7.1**, inspirada en el lenguaje visual de las aventuras de finales de los 80 y principios de los 90.

## Estado actual · 0.5.3

El prototipo incluye:

- resolución interna **320×180** y escalado nítido;
- arranque en **pantalla completa** en escritorio y solicitud automática con el primer gesto en Web;
- botón de pantalla completa mediante icono en la esquina superior derecha, además de F11;
- hotspots sin recuadros visibles al pasar el cursor;
- portal derecho que cierra/sale del juego usando el verbo **USAR**;
- **Commodore Pixelized** para elementos del mundo, **ONESIZE_** para diálogos y **Windows Regular** para respuestas y UI inferior;
- fallback de fuente para tildes, ñ y caracteres españoles;
- respuestas del protagonista en verde y texto normal;
- diálogo corto del Cartógrafo centrado horizontalmente por encima de su cabeza, usando todo el ancho disponible;
- sección negra de verbos desplazada hacia abajo para ganar más espacio visual para el escenario;
- estado, verbos e inventario con Windows Regular, conservando sus colores verde, cian y morado;
- nombre del objeto bajo el nombre de la zona, en Windows Regular y color blanco;
- retrato transparente del Cartógrafo en conversaciones importantes;
- Cartógrafo del escenario con cuatro sprites pixel art independientes de **32×64 px**: dos de reposo/parpadeo y dos de habla;
- bosque y suelo separados en capas PNG de parallax;
- sector izquierdo renovado con un **naranjo pixel art**, eliminando las columnas y el mapa torcido;
- llave independiente en el suelo, visible desde el principio y con sprite PNG propio;
- cofre separado en sprites de cerrado, apertura y abierto;
- hoja escrita independiente sobre el cofre, con prioridad de clic frente al propio cofre;
- al usar **MIRAR** sobre la hoja se abre una pantalla de lectura con el código **14700**, usando Onesize en blanco con contorno negro y botón para volver;
- una vez recogida, la hoja puede volver a leerse desde el inventario con **MIRAR**;
- inventario, verbos, hotspots y exportación Web automática mediante GitHub Actions.

### Cambio 0.5.3 · naranjo, llave y lectura desde inventario

Se elimina el mapa torcido y el bloque de columnas del sector izquierdo y se sustituyen por un naranjo pixel art. La llave pasa a estar directamente en el suelo y dispone de un sprite más definido. Los nombres de los objetos aparecen bajo el nombre de la zona en blanco y con Windows Regular. La hoja del cofre también puede volver a abrirse desde el inventario usando **MIRAR**. El diálogo del Cartógrafo deja de dar pistas sobre el mapa torcido y pasa a orientar hacia la llave junto al naranjo.

### Cambio 0.5.2 · diálogos sobre el mundo y UI inferior

El diálogo corto del Cartógrafo deja de aparecer delante del sprite: ahora se compone a todo el ancho, centrado por líneas y situado por encima de su cabeza. La franja negra inferior baja 16 px y todo su contenido pasa a usar Windows Regular, manteniendo los colores existentes para estado, verbos e inventario.

### Cambio 0.5.1 · nuevos sprites del Cartógrafo

Se sustituyen los cuatro sprites del Cartógrafo del escenario por los nuevos diseños pixel art aprobados. El lienzo pasa de **24×48** a **32×64 px**, manteniendo la animación existente: `idle_0`, `idle_1`, `talk_0` y `talk_1`. También se ajusta su hotspot al nuevo tamaño sin modificar el retrato grande de conversación.

### Cambio 0.5.0 · interacción y presentación

Se mejora el Cartógrafo del mundo, se elimina el marco de depuración de los hotspots, se añade salida mediante el portal derecho y se convierte el objeto del cofre en una hoja interactiva con pantalla propia de lectura. También se configura el juego para iniciar en pantalla completa siempre que la plataforma lo permita.

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
  idle_0.png         32x64
  idle_1.png         32x64
  talk_0.png         32x64
  talk_1.png         32x64

assets/sprites/props/
  orange_tree.png    64x76

assets/sprites/items/
  key_ground.png     18x10

assets/sprites/chest/
  chest_closed.png   56x32
  chest_opening.png  56x32
  chest_open.png     56x32
  note_sheet.png     22x16
```

El retrato de conversación sigue en `assets/characters/cartographer_portrait.png`.

## Filosofía

La intención es mantener el motor **data-driven** y que el arte sea reemplazable: habitación, capas de fondo, sprites, diálogos, inventario y puzles deben poder evolucionar sin llenar el código principal de casos específicos.
