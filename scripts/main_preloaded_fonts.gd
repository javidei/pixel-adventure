extends "res://scripts/main.gd"

# En la exportación Web cargamos las fuentes en tiempo de compilación.
# Esto evita que ResourceLoader.exists() devuelva false para el archivo fuente
# original una vez Godot lo ha remapeado al recurso importado dentro del PCK.
const UI_FONT_PRELOADED: Font = preload("res://assets/fonts/Windows Regular.ttf")
const DIALOGUE_FONT_PRELOADED: Font = preload("res://assets/fonts/ONESR___.TTF")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ui_font = UI_FONT_PRELOADED
	dialogue_font = DIALOGUE_FONT_PRELOADED
	_load_room()
	queue_redraw()

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_text_center("BIENVENIDO A", 52, COL_DIM, 8)
	_text_center("NARANJAL DEL RÍO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_text_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_text_center("PIXEL ADVENTURE · PROTOTIPO 0.2.2", 164, Color("555564"), 6)
