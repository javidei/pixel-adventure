extends "res://scripts/main_v048.gd"

# 0.4.9: control de pantalla completa y compatibilidad de caracteres españoles.
# El botón es solo icono y permanece disponible en juego y diálogos.

const FULLSCREEN_RECT := Rect2(300, 4, 16, 16)
const FULLSCREEN_ICON := Color("e9e4ee")
const FULLSCREEN_ICON_HOVER := Color("ffffff")

var fullscreen_hover := false

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.4.9", 164, Color("555564"), 6)

func _input(event: InputEvent) -> void:
	var pointer_position := Vector2(-1, -1)
	var activate := false

	if event is InputEventMouseMotion:
		pointer_position = (event as InputEventMouseMotion).position
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		pointer_position = mouse.position
		activate = mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		pointer_position = touch.position
		activate = touch.pressed
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.keycode == KEY_F11:
			_toggle_fullscreen()
			accept_event()
			return

	if pointer_position.x >= 0.0:
		var hover_now := FULLSCREEN_RECT.has_point(pointer_position)
		if hover_now != fullscreen_hover:
			fullscreen_hover = hover_now
			queue_redraw()
		if activate and hover_now:
			cursor_position = pointer_position
			_toggle_fullscreen()
			accept_event()
			return

	super._input(event)

func _draw() -> void:
	super._draw()
	_draw_fullscreen_button()

func _toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	queue_redraw()

func _draw_fullscreen_button() -> void:
	var color := FULLSCREEN_ICON_HOVER if fullscreen_hover else FULLSCREEN_ICON
	if fullscreen_hover:
		draw_rect(FULLSCREEN_RECT, Color(0, 0, 0, 0.38))

	var x := FULLSCREEN_RECT.position.x + 4.0
	var y := FULLSCREEN_RECT.position.y + 4.0
	var r := x + 8.0
	var b := y + 8.0

	# Cuatro esquinas pixel-art: icono de pantalla completa sin texto ni marco.
	draw_rect(Rect2(x, y, 4, 1), color)
	draw_rect(Rect2(x, y, 1, 4), color)
	draw_rect(Rect2(r - 3, y, 4, 1), color)
	draw_rect(Rect2(r, y, 1, 4), color)
	draw_rect(Rect2(x, b, 4, 1), color)
	draw_rect(Rect2(x, b - 3, 1, 4), color)
	draw_rect(Rect2(r - 3, b, 4, 1), color)
	draw_rect(Rect2(r, b - 3, 1, 4), color)

func _npc_text(text: String, x: float, y: float, color: Color, size: int) -> void:
	var cursor_x := x
	for run in _font_runs(text, NORMAL_DIALOGUE_FONT, UI_FONT, COMMODORE_FONT):
		var font: Font = run["font"]
		var chunk := str(run["text"])
		draw_string_outline(
			font,
			Vector2(cursor_x, y),
			chunk,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			size,
			NPC_OUTLINE_SIZE_V046,
			NPC_DIALOGUE_OUTLINE
		)
		draw_string(
			font,
			Vector2(cursor_x, y),
			chunk,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			size,
			color
		)
		cursor_x += font.get_string_size(chunk, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x

func _response_text(text: String, x: float, y: float, color: Color, size: int) -> void:
	var cursor_x := x
	for run in _font_runs(text, UI_FONT, COMMODORE_FONT, NORMAL_DIALOGUE_FONT):
		var font: Font = run["font"]
		var chunk := str(run["text"])
		draw_string(font, Vector2(cursor_x, y), chunk, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)
		cursor_x += font.get_string_size(chunk, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x

func _wrap_dialogue_text(text: String, max_width: float) -> Array[String]:
	var result: Array[String] = []
	var words := text.split(" ", false)
	var current := ""

	for word in words:
		var candidate := str(word) if current.is_empty() else current + " " + str(word)
		var width := _text_width_with_fallback(candidate, NORMAL_DIALOGUE_FONT, UI_FONT, COMMODORE_FONT, NPC_DIALOGUE_SIZE)
		if width <= max_width or current.is_empty():
			current = candidate
		else:
			result.append(current)
			current = str(word)

	if not current.is_empty():
		result.append(current)
	return result

func _font_runs(text: String, primary: Font, secondary: Font, tertiary: Font) -> Array[Dictionary]:
	var runs: Array[Dictionary] = []
	var current_text := ""
	var current_font: Font = primary
	var has_run := false

	for character in text:
		var font := _font_for_character(character, primary, secondary, tertiary)
		if not has_run:
			current_font = font
			current_text = character
			has_run = true
		elif font == current_font:
			current_text += character
		else:
			runs.append({"font": current_font, "text": current_text})
			current_font = font
			current_text = character

	if has_run:
		runs.append({"font": current_font, "text": current_text})
	return runs

func _font_for_character(character: String, primary: Font, secondary: Font, tertiary: Font) -> Font:
	if character == " ":
		return primary
	var code := character.unicode_at(0)
	if primary.has_char(code):
		return primary
	if secondary.has_char(code):
		return secondary
	if tertiary.has_char(code):
		return tertiary
	return primary

func _text_width_with_fallback(text: String, primary: Font, secondary: Font, tertiary: Font, size: int) -> float:
	var width := 0.0
	for run in _font_runs(text, primary, secondary, tertiary):
		var font: Font = run["font"]
		width += font.get_string_size(str(run["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x
	return width

func _natural_text(text: String) -> String:
	var normalized := text.strip_edges().to_lower()
	if normalized.is_empty():
		return normalized

	# Ortografía española del diálogo de la demo.
	normalized = normalized.replace("asi que tu eres", "así que tú eres")
	normalized = normalized.replace("naranjal del rio", "Naranjal del Río")
	normalized = normalized.replace("quien quiere", "quién quiere")
	normalized = normalized.replace("que se supone que tengo que buscar?", "qué se supone que tengo que buscar?")
	normalized = normalized.replace("ensename", "enséñame")
	normalized = normalized.replace("aqui", "aquí")
	normalized = normalized.replace("que deberia", "qué debería")
	normalized = normalized.replace("deberia", "debería")
	normalized = normalized.replace("esta torcido", "está torcido")
	normalized = normalized.replace("esta a plena vista", "está a plena vista")
	normalized = normalized.replace("traemelo", "tráemelo")
	normalized = normalized.replace("lo buscare", "lo buscaré")
	normalized = normalized.replace("cartografo", "cartógrafo")

	return normalized.substr(0, 1).to_upper() + normalized.substr(1)
