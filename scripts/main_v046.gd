extends "res://scripts/main_v045.gd"

# 0.4.6: retrato real del cartografo y dialogos en texto normal.
# NPC: Onesize normal, morado con contorno negro de 2 px.
# Respuestas: Windows Regular, verdes y sin mayusculas forzadas.

const CARTOGRAPHER_PORTRAIT: Texture2D = preload("res://assets/characters/cartographer_portrait.png")
const RESPONSE_GREEN := Color("61d89a")
const RESPONSE_GREEN_HOVER := Color("9af0bd")
const NPC_OUTLINE_SIZE_V046 := 2

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.4.6", 164, Color("555564"), 6)

func _draw_cartographer_portrait() -> void:
	# Retrato aprobado, escalado con nearest al panel superior.
	draw_texture_rect(
		CARTOGRAPHER_PORTRAIT,
		Rect2(4, 2, 76, 114),
		false
	)

func _draw_simple_dialogue() -> void:
	var npc_x := 365.0 - camera_x
	var text_x := clampf(npc_x - 52.0, 7.0, 205.0)
	var combined := ""
	for raw_line in simple_lines:
		if not combined.is_empty():
			combined += " "
		combined += _natural_text(str(raw_line))

	var lines := _wrap_dialogue_text(combined, 108.0)
	var y := 60.0
	for line in lines:
		_npc_text(line, text_x, y, NPC_DIALOGUE_FILL, NPC_DIALOGUE_SIZE)
		y += NPC_DIALOGUE_LINE_HEIGHT

func _draw_important_dialogue() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 116), Color("7b3f23"))
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 14), Color("171018"))
	for stripe: int in range(5):
		draw_rect(Rect2(0, 78 + stripe * 7, VIEW_WIDTH, 4), Color("41241f"))

	_draw_cartographer_portrait()

	var node: Dictionary = IMPORTANT_DIALOGUE[important_node]
	var npc_lines: Array = node.get("npc", [])
	var combined := ""
	for raw_line in npc_lines:
		if not combined.is_empty():
			combined += " "
		combined += _natural_text(str(raw_line))

	var wrapped := _wrap_dialogue_text(combined, 220.0)
	var y := 31.0
	for line in wrapped:
		_npc_text(line, 88.0, y, NPC_DIALOGUE_FILL, NPC_DIALOGUE_SIZE)
		y += NPC_DIALOGUE_LINE_HEIGHT

	draw_rect(Rect2(0, 116, VIEW_WIDTH, 64), Color.BLACK)

	if response_phase == "player":
		_response_text(chosen_response, 8, 140, RESPONSE_GREEN_HOVER, 8)
		return

	var responses: Array = node.get("responses", [])
	for index: int in range(responses.size()):
		var response: Dictionary = responses[index]
		var color := RESPONSE_GREEN_HOVER if index == response_hover else RESPONSE_GREEN
		_response_text(
			_natural_text(str(response.get("text", ""))),
			8,
			130 + index * 14,
			color,
			8
		)

func _npc_text(text: String, x: float, y: float, color: Color, size: int) -> void:
	draw_string_outline(
		NORMAL_DIALOGUE_FONT,
		Vector2(x, y),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		size,
		NPC_OUTLINE_SIZE_V046,
		NPC_DIALOGUE_OUTLINE
	)
	draw_string(
		NORMAL_DIALOGUE_FONT,
		Vector2(x, y),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		size,
		color
	)

func _choose_response(index: int) -> void:
	var responses: Array = IMPORTANT_DIALOGUE[important_node].get("responses", [])
	if index < 0 or index >= responses.size():
		return

	var response: Dictionary = responses[index]
	chosen_response = _natural_text(str(response.get("text", "")))
	pending_next_node = int(response.get("next", -1))
	response_phase = "player"
	response_timer = 0.85
	response_hover = -1
	queue_redraw()

func _natural_text(text: String) -> String:
	var normalized := text.strip_edges().to_lower()
	if normalized.is_empty():
		return normalized

	# Correcciones visuales basicas para que el espanol no parezca texto de debug.
	normalized = normalized.replace("naranjal del rio", "Naranjal del Río")
	normalized = normalized.replace("ensename", "enséñame")
	normalized = normalized.replace("aqui", "aquí")

	return normalized.substr(0, 1).to_upper() + normalized.substr(1)
