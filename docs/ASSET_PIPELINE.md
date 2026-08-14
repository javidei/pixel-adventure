# Pipeline de assets

A partir de la 0.4.8 el escenario deja de depender de dibujos hardcodeados para los elementos que más interesa sustituir.

## Resolución base

- Ventana interna del juego: `320x180`.
- Zona de escenario visible: `320x116`.
- Anchura total de la habitación actual: `680 px`.

## Fondos por capas

Cada capa usa PNG y se desplaza desde código con una velocidad de parallax distinta:

- `trees_far.png`: `680x116`, fondo transparente, factor 0.14.
- `trees_mid.png`: `680x116`, fondo transparente, factor 0.30.
- `trees_near.png`: `680x116`, fondo transparente, factor 0.50.
- `ground.png`: `680x28`, se dibuja desde `y=88` y se mueve 1:1 con la cámara.

Para sustituir una capa solo hay que exportar otro PNG con el mismo tamaño y nombre.

## NPC del mundo

Carpeta: `assets/sprites/cartographer/world/`

Tamaño actual de frame: `24x48`, PNG transparente.

Convención:

- `idle_0.png`
- `idle_1.png`
- `talk_0.png`
- `talk_1.png`

El código alterna automáticamente frames de reposo y habla. Después podemos añadir `walk`, `turn`, `gesture`, `blink`, etc.

## Retrato de conversación

Se conserva `assets/characters/cartographer_portrait.png`, el retrato transparente aprobado.

- Fuente de trabajo recomendada: `1024x1536`.
- Asset optimizado recomendado: `128x192` o `192x288`, PNG transparente.
- En pantalla se dibuja a `76x114`.

## Cofre

Carpeta: `assets/sprites/chest/`

Cada frame es `56x32`, PNG transparente:

- `chest_closed.png`
- `chest_opening.png`
- `chest_open.png`

El código selecciona el frame según el progreso de apertura.

## Recomendación

Para arte nuevo, conserva estos tamaños de exportación o múltiplos exactos de ellos. Godot usa filtrado nearest y pixel snap, así que los PNG pueden reemplazarse sin tocar la lógica del juego.
