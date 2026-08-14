extends "res://scripts/main_v041.gd"

# 0.4.5: sustituye Onesize Reverse por la variante normal rellena.
# Los dialogos NPC usan ONESIZE_.TTF con interior morado y contorno negro.

const NORMAL_DIALOGUE_FONT: Font = preload("res://assets/fonts/ONESIZE_.TTF")
const NPC_DIALOGUE_FILL := Color("c487c6")
const NPC_DIALOGUE_OUTLINE := Color("000000")
const NPC_DIALOGUE_SIZE := 7
const NPC_DIALOGUE_LINE_HEIGHT := 11.0
const NPC_DIALOGUE_OUTLINE_SIZE := 1

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.4.5", 164, Color("555564"), 6)

func _draw_simple_dialogue() -> void:
	var npc_x := 365.0 - camera_x
	var text_x := clampf(npc_x - 52.0, 7.0, 205.0)
	var combined := " ".join(simple_lines)
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
		combined += str(raw_line)

	var wrapped := _wrap_dialogue_text(combined, 214.0)
	var y := 32.0
	for line in wrapped:
		_npc_text(line, 91.0, y, NPC_DIALOGUE_FILL, NPC_DIALOGUE_SIZE)
		y += NPC_DIALOGUE_LINE_HEIGHT

	# Windows Regular para las respuestas del protagonista.
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
	# La variante normal tiene el cuerpo del glifo relleno. Primero se dibuja
	# el borde negro y despues el mismo glifo morado, como en la referencia.
	draw_string_outline(
		NORMAL_DIALOGUE_FONT,
		Vector2(x, y),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		size,
		NPC_DIALOGUE_OUTLINE_SIZE,
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

func _wrap_dialogue_text(text: String, max_width: float) -> Array[String]:
	var result: Array[String] = []
	var words := text.split(" ", false)
	var current := ""

	for word in words:
		var candidate := str(word) if current.is_empty() else current + " " + str(word)
		var width := NORMAL_DIALOGUE_FONT.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, NPC_DIALOGUE_SIZE).x
		if width <= max_width or current.is_empty():
			current = candidate
		else:
			result.append(current)
			current = str(word)

	if not current.is_empty():
		result.append(current)

	return result
