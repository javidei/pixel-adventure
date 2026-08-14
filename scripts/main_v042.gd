extends "res://scripts/main_v041.gd"

# 0.4.2: comprobacion visual de ONESR y renderizado de dialogos reforzado.
# La fuente ONESR se usa en varios puntos visibles para detectar rapidamente
# cualquier problema de importacion/renderizado antes de entrar en una charla.

var font_probe_timer := 8.0

func _process(delta: float) -> void:
	if not intro_active and font_probe_timer > 0.0:
		font_probe_timer = maxf(0.0, font_probe_timer - delta)
	super._process(delta)

func _draw() -> void:
	super._draw()
	if not intro_active and dialogue_mode == "none" and font_probe_timer > 0.0:
		# Segunda prueba visible dentro del propio escenario.
		_npc_text("PRUEBA ONESR: CARTOGRAFO", 174, 12, Color("e6d4c5"), 9)

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 48, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 76, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 105, COL_GOLD, 8)

	# Prueba 1: esta linea DEBE verse con ONESR antes de empezar la partida.
	_npc_text("PRUEBA ONESR: HOLA VIAJERO", 63, 132, Color("e6d4c5"), 10)
	# Referencia directa para comparar: Windows Regular.
	_response_text("PRUEBA WINDOWS: RESPUESTAS", 78, 146, Color("9d789d"), 7)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.4.2", 168, Color("555564"), 6)

func _draw_simple_dialogue() -> void:
	var npc_x := 365.0 - camera_x
	var text_x := clampf(npc_x - 64.0, 7.0, 185.0)
	_npc_text("CARTOGRAFO", text_x, 54, COL_NPC_NAME, 11)
	if simple_lines.size() > 0:
		_npc_text(simple_lines[0], text_x, 68, COL_NPC, 11)
	if simple_lines.size() > 1:
		_npc_text(simple_lines[1], text_x, 81, COL_NPC, 11)

func _draw_important_dialogue() -> void:
	# Zona superior inspirada en las conversaciones clasicas: retrato y texto
	# del NPC. Se evita el antiguo rectangulo negro que ocultaba el escenario.
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 116), Color("7b3f23"))
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 14), Color("171018"))
	for stripe: int in range(5):
		draw_rect(Rect2(0, 78 + stripe * 7, VIEW_WIDTH, 4), Color("41241f"))

	_draw_cartographer_portrait()
	var node: Dictionary = IMPORTANT_DIALOGUE[important_node]
	var npc_lines: Array = node.get("npc", [])

	# ONESR: nombre + texto del NPC.
	_npc_text("CARTOGRAFO", 91, 26, COL_NPC_NAME, 12)
	if npc_lines.size() > 0:
		_npc_text(str(npc_lines[0]), 91, 45, COL_NPC, 11)
	if npc_lines.size() > 1:
		_npc_text(str(npc_lines[1]), 91, 60, COL_NPC, 11)

	# Windows Regular: respuestas del protagonista sobre fondo negro.
	draw_rect(Rect2(0, 116, VIEW_WIDTH, 64), Color.BLACK)
	if response_phase == "player":
		_response_text(chosen_response, 8, 140, Color("f1e7f0"), 8)
		return

	var responses: Array = node.get("responses", [])
	for index: int in range(responses.size()):
		var response: Dictionary = responses[index]
		var color := Color("f1e7f0") if index == response_hover else Color("aa77a8")
		_response_text(str(response.get("text", "")), 8, 130 + index * 14, color, 8)

func _npc_text(text: String, x: float, y: float, color: Color, size: int) -> void:
	# Esta version usa ONESR directamente. Todos los dialogos actuales usan
	# Basic Latin, que esta fuente contiene. Si por cualquier motivo Godot no
	# obtiene metricas validas, se muestra Windows Regular como salvavidas para
	# que el usuario nunca vuelva a quedarse con un dialogo invisible.
	var font: Font = DIALOGUE_FONT
	var measured := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size)
	if measured.x <= 0.5 or measured.y <= 0.5:
		font = UI_FONT

	# Sombra/contorno pixel de un pixel para conservar legibilidad.
	draw_string(font, Vector2(x + 1, y + 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, Color(0, 0, 0, 0.95))
	draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)
