extends "res://scripts/main.gd"

# 0.4.0: selector de cursor, UI clasica con Commodore y dialogos revisados.

const CURSOR_NAMES: Array[String] = [
	"CRUZ CLASICA",
	"CRUZ LUCAS",
	"CRUZ FINA",
	"CRUZ CUADRADA",
	"CRUZ AZUL",
	"CRUZ DIAGONAL",
	"CRUZ HUECA",
	"CRUZ DOBLE",
	"MIRA RETRO",
	"CRUZ GRUESA"
]

var cursor_menu_active := true
var selected_cursor := 1
var cursor_hover := -1
var cursor_position := Vector2(160, 90)

func _ready() -> void:
	super._ready()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	queue_redraw()

func _process(delta: float) -> void:
	if cursor_menu_active:
		queue_redraw()
		return
	super._process(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cursor_position = (event as InputEventMouseMotion).position
	elif event is InputEventMouseButton:
		cursor_position = (event as InputEventMouseButton).position
	elif event is InputEventScreenTouch:
		cursor_position = (event as InputEventScreenTouch).position

	if cursor_menu_active:
		_handle_cursor_menu_input(event)
		return

	super._input(event)

func _handle_cursor_menu_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cursor_hover = _cursor_option_at((event as InputEventMouseMotion).position)
		queue_redraw()
		return

	var click_position := Vector2(-1, -1)
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			click_position = mouse.position
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			click_position = touch.position
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.keycode >= KEY_1 and key.keycode <= KEY_9:
			selected_cursor = int(key.keycode - KEY_1)
			cursor_menu_active = false
			queue_redraw()
			accept_event()
			return

	if click_position.x >= 0.0:
		var option := _cursor_option_at(click_position)
		if option >= 0:
			selected_cursor = option
			cursor_menu_active = false
			queue_redraw()
			accept_event()

func _cursor_option_at(position: Vector2) -> int:
	for index: int in range(CURSOR_NAMES.size()):
		if _cursor_option_rect(index).has_point(position):
			return index
	return -1

func _cursor_option_rect(index: int) -> Rect2:
	var column := index % 5
	var row := int(index / 5)
	return Rect2(8 + column * 61, 52 + row * 50, 56, 43)

func _draw() -> void:
	if cursor_menu_active:
		_draw_cursor_menu()
		_draw_custom_cursor(cursor_position, selected_cursor)
		return

	super._draw()
	_draw_custom_cursor(cursor_position, selected_cursor)

func _draw_cursor_menu() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("ELIGE TU CURSOR", 24, COL_TEXT, 10)
	_comm_center("PULSA SOBRE UNA CRUCETA", 39, Color("777184"), 6)

	for index: int in range(CURSOR_NAMES.size()):
		var rect := _cursor_option_rect(index)
		var hovered := index == cursor_hover
		if hovered:
			draw_rect(rect, Color("151321"))
			draw_rect(rect, COL_ACTION_ACTIVE, false, 1.0)
		else:
			draw_rect(rect, Color("282432"), false, 1.0)

		var center := Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + 15)
		_draw_cursor_shape(center, index, false)
		var label_color := COL_TEXT if hovered else Color("8d8798")
		var number_text := str(index + 1)
		draw_string(COMMODORE_FONT, Vector2(rect.position.x + 3, rect.position.y + 39), number_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 5, label_color)
		draw_string(COMMODORE_FONT, Vector2(rect.position.x + 11, rect.position.y + 39), CURSOR_NAMES[index], HORIZONTAL_ALIGNMENT_LEFT, 42.0, 5, label_color)

	_comm_center("DESPUES PODRAS CAMBIARLO DESDE AJUSTES", 166, Color("55515f"), 5)

func _draw_custom_cursor(position: Vector2, cursor_index: int) -> void:
	_draw_cursor_shape(Vector2(roundf(position.x), roundf(position.y)), cursor_index, true)

func _draw_cursor_shape(center: Vector2, cursor_index: int, with_shadow: bool) -> void:
	if with_shadow:
		_draw_cursor_pixels(center + Vector2(1, 1), cursor_index, Color.BLACK)
	_draw_cursor_pixels(center, cursor_index, _cursor_color(cursor_index))

func _cursor_color(cursor_index: int) -> Color:
	if cursor_index == 4:
		return Color("70a5ff")
	if cursor_index == 8:
		return Color("9ac7ff")
	return Color("f2edf6")

func _draw_cursor_pixels(c: Vector2, cursor_index: int, color: Color) -> void:
	match cursor_index:
		0:
			draw_rect(Rect2(c.x - 5, c.y, 11, 1), color)
			draw_rect(Rect2(c.x, c.y - 5, 1, 11), color)
		1:
			draw_rect(Rect2(c.x - 6, c.y - 1, 5, 3), color)
			draw_rect(Rect2(c.x + 2, c.y - 1, 5, 3), color)
			draw_rect(Rect2(c.x - 1, c.y - 6, 3, 5), color)
			draw_rect(Rect2(c.x - 1, c.y + 2, 3, 5), color)
			draw_rect(Rect2(c.x, c.y, 1, 1), color)
		2:
			draw_rect(Rect2(c.x - 4, c.y, 9, 1), color)
			draw_rect(Rect2(c.x, c.y - 4, 1, 9), color)
		3:
			draw_rect(Rect2(c.x - 5, c.y, 4, 2), color)
			draw_rect(Rect2(c.x + 2, c.y, 4, 2), color)
			draw_rect(Rect2(c.x, c.y - 5, 2, 4), color)
			draw_rect(Rect2(c.x, c.y + 2, 2, 4), color)
			draw_rect(Rect2(c.x, c.y, 2, 2), color)
		4:
			draw_rect(Rect2(c.x - 6, c.y, 13, 1), color)
			draw_rect(Rect2(c.x, c.y - 6, 1, 13), color)
		5:
			for offset: int in range(-4, 5):
				draw_rect(Rect2(c.x + offset, c.y + offset, 1, 1), color)
				draw_rect(Rect2(c.x + offset, c.y - offset, 1, 1), color)
		6:
			draw_rect(Rect2(c.x - 6, c.y, 5, 1), color)
			draw_rect(Rect2(c.x + 2, c.y, 5, 1), color)
			draw_rect(Rect2(c.x, c.y - 6, 1, 5), color)
			draw_rect(Rect2(c.x, c.y + 2, 1, 5), color)
			draw_rect(Rect2(c.x - 1, c.y - 1, 3, 1), color)
			draw_rect(Rect2(c.x - 1, c.y + 1, 3, 1), color)
			draw_rect(Rect2(c.x - 1, c.y, 1, 1), color)
			draw_rect(Rect2(c.x + 1, c.y, 1, 1), color)
		7:
			draw_rect(Rect2(c.x - 6, c.y - 1, 13, 3), color)
			draw_rect(Rect2(c.x - 1, c.y - 6, 3, 13), color)
			draw_rect(Rect2(c.x - 2, c.y - 2, 5, 5), Color.BLACK)
			draw_rect(Rect2(c.x, c.y, 1, 1), color)
		8:
			draw_rect(Rect2(c.x - 7, c.y, 5, 1), color)
			draw_rect(Rect2(c.x + 3, c.y, 5, 1), color)
			draw_rect(Rect2(c.x, c.y - 7, 1, 5), color)
			draw_rect(Rect2(c.x, c.y + 3, 1, 5), color)
			draw_rect(Rect2(c.x - 2, c.y - 2, 5, 1), color)
			draw_rect(Rect2(c.x - 2, c.y + 2, 5, 1), color)
			draw_rect(Rect2(c.x - 2, c.y - 1, 1, 3), color)
			draw_rect(Rect2(c.x + 2, c.y - 1, 1, 3), color)
		9:
			draw_rect(Rect2(c.x - 6, c.y - 1, 13, 3), color)
			draw_rect(Rect2(c.x - 1, c.y - 6, 3, 13), color)

# UI principal: fondo negro, verbos verdes e inventario morado.
# Se usa Commodore Pixelized para recuperar la apariencia del prototipo inicial.
func _ui_text(text: String, x: float, y: float, color: Color, size: int) -> void:
	draw_string(COMMODORE_FONT, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func _draw_classic_ui() -> void:
	draw_rect(Rect2(0, UI_TOP, VIEW_WIDTH, VIEW_HEIGHT - UI_TOP), Color.BLACK)
	_ui_text(message, 5, 124, COL_STATUS, 6)

	for index: int in range(VERBS.size()):
		var rect := _verb_rect(index)
		var active := VERBS[index] == selected_verb
		_ui_text(VERBS[index], rect.position.x, rect.position.y + 8, COL_ACTION_ACTIVE if active else COL_ACTION, 6)

	var visible_count := mini(INVENTORY_PAGE_SIZE, inventory.size())
	if inventory.is_empty():
		_ui_text("(VACIO)", 196, 138, Color("8f4b87"), 6)
	else:
		for local_index: int in range(visible_count):
			var actual_index := inventory_scroll + local_index
			if actual_index >= inventory.size():
				actual_index -= inventory.size()
			var item := inventory[actual_index]
			var active_item := item == selected_item
			_ui_text(item, 196, 138 + local_index * 10, COL_INVENTORY_ACTIVE if active_item else COL_INVENTORY, 6)

	if inventory.size() > INVENTORY_PAGE_SIZE:
		_draw_inventory_arrow()

# Dialogo corto: aparece directamente sobre el escenario, sin caja negra.
func _draw_simple_dialogue() -> void:
	var npc_x := 365.0 - camera_x
	var text_x := clampf(npc_x - 64.0, 7.0, 185.0)
	_npc_text("CARTOGRAFO", text_x, 58, COL_NPC_NAME, 11)
	if simple_lines.size() > 0:
		_npc_text(simple_lines[0], text_x, 70, COL_NPC, 11)
	if simple_lines.size() > 1:
		_npc_text(simple_lines[1], text_x, 81, COL_NPC, 11)

# Conversacion importante: retrato/escena arriba y respuestas sobre negro abajo.
# NPC con ONESR___; respuestas del protagonista con Windows Regular.
func _draw_important_dialogue() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 116), Color("7b3f23"))
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 14), Color("171018"))
	for stripe: int in range(5):
		draw_rect(Rect2(0, 78 + stripe * 7, VIEW_WIDTH, 4), Color("41241f"))

	_draw_cartographer_portrait()
	var node: Dictionary = IMPORTANT_DIALOGUE[important_node]
	var npc_lines: Array = node.get("npc", [])
	_npc_text("CARTOGRAFO", 91, 27, COL_NPC_NAME, 12)
	if npc_lines.size() > 0:
		_npc_text(str(npc_lines[0]), 91, 45, COL_NPC, 11)
	if npc_lines.size() > 1:
		_npc_text(str(npc_lines[1]), 91, 59, COL_NPC, 11)

	draw_rect(Rect2(0, 116, VIEW_WIDTH, 64), Color.BLACK)
	if response_phase == "player":
		_response_text(chosen_response, 8, 140, Color("d9d2dd"), 8)
		return

	var responses: Array = node.get("responses", [])
	for index: int in range(responses.size()):
		var response: Dictionary = responses[index]
		var color := Color("f1e7f0") if index == response_hover else Color("aa77a8")
		_response_text(str(response.get("text", "")), 8, 130 + index * 14, color, 8)

func _npc_text(text: String, x: float, y: float, color: Color, size: int) -> void:
	var font := DIALOGUE_FONT if _font_supports_text(DIALOGUE_FONT, text) else UI_FONT
	# Sombra de un pixel para que el texto siga siendo visible sobre cualquier fondo.
	draw_string(font, Vector2(x + 1, y + 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, Color(0, 0, 0, 0.9))
	draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func _response_text(text: String, x: float, y: float, color: Color, size: int) -> void:
	draw_string(UI_FONT, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func _font_supports_text(font: Font, text: String) -> bool:
	for character in text:
		if character == " ":
			continue
		if not font.has_char(character.unicode_at(0)):
			return false
	return true

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.4.0", 164, Color("555564"), 6)
