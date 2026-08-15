extends "res://scripts/main_v050.gd"

# 0.5.1: reemplazo completo de los cuatro sprites del Cartografo del mundo.
# Se aumenta su lienzo nativo de 24x48 a 32x64 para conservar mejor el detalle
# pixel art y se mantiene la misma logica idle/talk existente.

const NPC_WORLD_SIZE := Vector2(32, 64)
const NPC_WORLD_BASELINE_Y := 109.0

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.5.1", 164, Color("555564"), 6)

func _draw_static_cartographer() -> void:
	var x := floorf(365.0 - camera_x)
	if x < -40.0 or x > VIEW_WIDTH + 40.0:
		return

	var now := int(Time.get_ticks_msec())
	var texture := NPC_IDLE_0
	if dialogue_mode == "simple":
		texture = NPC_TALK_0 if int(now / 180) % 2 == 0 else NPC_TALK_1
	else:
		texture = NPC_IDLE_0 if int(now / 850) % 2 == 0 else NPC_IDLE_1

	var draw_position := Vector2(
		floorf(x - NPC_WORLD_SIZE.x * 0.5),
		NPC_WORLD_BASELINE_Y - NPC_WORLD_SIZE.y
	)
	draw_texture(texture, draw_position)
