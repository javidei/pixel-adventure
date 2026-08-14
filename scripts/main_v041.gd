extends "res://scripts/main_v040.gd"

# 0.4.1: la cruz clasica (opcion 1) queda fija por defecto.
# Se elimina el selector inicial de cursor del flujo de arranque.

func _ready() -> void:
	super._ready()
	cursor_menu_active = false
	selected_cursor = 0
	cursor_hover = -1
	queue_redraw()

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.4.1", 164, Color("555564"), 6)
