extends "res://scripts/main_v052.gd"

# 0.5.3: sustituye el mapa torcido y las ruinas del sector izquierdo por un
# naranjo, coloca la llave directamente en el suelo y mejora la identificación
# de hotspots. La hoja del cofre puede volver a leerse desde el inventario.

const ORANGE_TREE_TEXTURE: Texture2D = preload("res://assets/sprites/props/orange_tree.png")
const KEY_GROUND_TEXTURE: Texture2D = preload("res://assets/sprites/items/key_ground.png")

const ORANGE_TREE_WORLD_X := 170.0
const ORANGE_TREE_BASELINE_Y := 109.0
const KEY_WORLD_X := 240.0
const KEY_WORLD_Y := 99.0

const IMPORTANT_DIALOGUE_053: Array[Dictionary] = [
	{
		"npc": ["ASÍ QUE TÚ ERES EL QUE HA LLEGADO", "A NARANJAL DEL RÍO."],
		"responses": [
			{"text": "DEPENDE. ¿QUIÉN QUIERE SABERLO?", "next": 1},
			{"text": "HE VENIDO POR EL MAPA.", "next": 2},
			{"text": "SOLO ESTOY DE PASO.", "next": 3}
		]
	},
	{
		"npc": ["ALGUIEN QUE SABE QUE ESTE PUEBLO", "NO APARECE EN LOS MAPAS POR CASUALIDAD."],
		"responses": [
			{"text": "¿QUÉ SE SUPONE QUE TENGO QUE BUSCAR?", "next": 4},
			{"text": "NO ME GUSTAN LOS ACERTIJOS.", "next": 4}
		]
	},
	{
		"npc": ["ENTONCES HAS VENIDO AL SITIO CORRECTO.", "PERO UN MAPA NO SIEMPRE DICE LA VERDAD."],
		"responses": [
			{"text": "ENSÉÑAME LO QUE SABES.", "next": 4},
			{"text": "PREFIERO DESCUBRIRLO YO.", "next": 4}
		]
	},
	{
		"npc": ["NADIE PASA POR AQUÍ POR CASUALIDAD.", "MIRA BIEN ANTES DE MARCHARTE."],
		"responses": [
			{"text": "VALE. ¿QUÉ DEBERÍA MIRAR?", "next": 4},
			{"text": "YA VEREMOS.", "next": -1}
		]
	},
	{
		"npc": ["EMPIEZA POR LO QUE BRILLA JUNTO AL NARANJO.", "A VECES LO IMPORTANTE ESTÁ A PLENA VISTA."],
		"responses": [
			{"text": "ENTENDIDO.", "next": -1},
			{"text": "¿ESO ES TODO?", "next": 5}
		]
	},
	{
		"npc": ["POR AHORA.", "SI ENCUENTRAS UN FRAGMENTO, TRÁEMELO."],
		"responses": [
			{"text": "LO BUSCARÉ.", "next": -1}
		]
	}
]

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.5.3", 164, Color("555564"), 6)

func _draw_world() -> void:
	draw_texture(BG_GROUND, Vector2(-floorf(camera_x), 88))
	_draw_ruins()
	_draw_orange_tree()
	_draw_ground_key()
	_draw_campfire()
	_draw_static_cartographer()
	_draw_chest()
	_draw_archway()
	_ui_text(room_title, 5, 10, COL_DIM, 7)
	if bool(state["solved"]):
		_ui_text("PUZLE COMPLETADO", 196, 20, COL_ACTION_ACTIVE, 7)

func _draw_ruins() -> void:
	# Se eliminan las columnas del sector izquierdo. Solo permanecen las
	# piedras bajas del lado del cofre para conservar algo de ruina en escena.
	for index: int in range(8):
		var sx := 430.0 + float(index * 16) - camera_x
		draw_rect(Rect2(sx, 80 + (index % 2) * 3, 14, 9), COL_STONE)
		draw_rect(Rect2(sx + 2, 81 + (index % 2) * 3, 8, 2), COL_STONE_LIGHT)

func _draw_orange_tree() -> void:
	var x := floorf(ORANGE_TREE_WORLD_X - camera_x)
	if x < -70.0 or x > VIEW_WIDTH + 10.0:
		return
	draw_texture(
		ORANGE_TREE_TEXTURE,
		Vector2(x, ORANGE_TREE_BASELINE_Y - float(ORANGE_TREE_TEXTURE.get_height()))
	)

func _draw_ground_key() -> void:
	if bool(state["key_taken"]):
		return
	var x := floorf(KEY_WORLD_X - camera_x)
	if x < -24.0 or x > VIEW_WIDTH + 24.0:
		return
	draw_texture(KEY_GROUND_TEXTURE, Vector2(x, KEY_WORLD_Y))

func _visible_hotspot(hotspot_id: String) -> bool:
	if hotspot_id == "key":
		return not bool(state["key_taken"])
	return super._visible_hotspot(hotspot_id)

func _draw_hotspot_highlight() -> void:
	if hovered_id.is_empty() or dialogue_mode != "none":
		return
	var hotspot := _get_hotspot(hovered_id)
	var object_name := _natural_text(str(hotspot.get("name", "")))
	# Nombre del objeto justo bajo el nombre de la zona: Windows Regular,
	# como la interfaz negra, pero en blanco.
	_black_ui_text(object_name, 5, 21, Color.WHITE, 6)

func _handle_inventory_click(position: Vector2) -> bool:
	var visible_count := mini(INVENTORY_PAGE_SIZE, inventory.size())
	for local_index: int in range(visible_count):
		var actual_index := inventory_scroll + local_index
		if actual_index >= inventory.size():
			actual_index -= inventory.size()
		if _inventory_item_rect(local_index).has_point(position):
			var item := inventory[actual_index]
			if item == "FRAGMENTO" and selected_verb == "MIRAR":
				_open_note_from_inventory()
				return true
			selected_item = item
			selected_verb = "USAR"
			message = "USAR %s CON" % selected_item
			queue_redraw()
			return true
	return false

func _handle_verb_click(position: Vector2) -> bool:
	for index: int in range(VERBS.size()):
		if _verb_rect(index).has_point(position):
			var verb := VERBS[index]
			if verb == "MIRAR" and selected_item == "FRAGMENTO" and inventory.has("FRAGMENTO"):
				selected_verb = "MIRAR"
				_open_note_from_inventory()
				return true
			selected_verb = verb
			selected_item = ""
			message = selected_verb
			queue_redraw()
			return true
	return false

func _open_note_from_inventory() -> void:
	note_view_active = true
	note_back_hover = false
	pending_hotspot_id = ""
	selected_item = ""
	message = ""
	queue_redraw()

func _handle_note_input(event: InputEvent) -> void:
	var was_active := note_view_active
	super._handle_note_input(event)
	if was_active and not note_view_active and bool(state["map_taken"]):
		message = "GUARDAS DE NUEVO LA HOJA EN EL INVENTARIO."
		queue_redraw()

func _start_cartographer_dialogue() -> void:
	pending_hotspot_id = ""
	if bool(state["met_cartographer"]):
		if not bool(state["key_taken"]):
			_start_simple_dialogue([
				"SIGUES AQUÍ.",
				"LA LLAVE JUNTO AL NARANJO NO SE VA A RECOGER SOLA."
			])
		elif not bool(state["chest_open"]):
			_start_simple_dialogue([
				"YA TIENES LA LLAVE.",
				"AHORA BUSCA QUÉ PUEDE ABRIR."
			])
		elif not bool(state["map_taken"]):
			_start_simple_dialogue([
				"EL COFRE ESTÁ ABIERTO.",
				"REVISA BIEN LO QUE HAY DENTRO."
			])
		else:
			_start_simple_dialogue([
				"YA TIENES LA HOJA.",
				"PUEDES VOLVER A MIRARLA DESDE EL INVENTARIO."
			])
		return
	important_node = 0
	response_phase = "choices"
	chosen_response = ""
	response_hover = -1
	dialogue_mode = "important"
	message = "CONVERSACION CON EL CARTOGRAFO"
	queue_redraw()

func _finish_player_response() -> void:
	if pending_next_node < 0:
		dialogue_mode = "none"
		response_phase = "choices"
		chosen_response = ""
		message = "EL CARTOGRAFO VUELVE LA MIRADA HACIA EL SENDERO."
		state["met_cartographer"] = true
	else:
		important_node = pending_next_node
		response_phase = "choices"
		chosen_response = ""
	pending_next_node = -1
	queue_redraw()

func _response_at(position: Vector2) -> int:
	if position.y < 122.0:
		return -1
	var responses: Array = IMPORTANT_DIALOGUE_053[important_node].get("responses", [])
	for index: int in range(responses.size()):
		if _response_rect(index).has_point(position):
			return index
	return -1

func _choose_response(index: int) -> void:
	var responses: Array = IMPORTANT_DIALOGUE_053[important_node].get("responses", [])
	if index < 0 or index >= responses.size():
		return
	var response: Dictionary = responses[index]
	chosen_response = _natural_text(str(response.get("text", "")))
	pending_next_node = int(response.get("next", -1))
	response_phase = "player"
	response_timer = 0.85
	response_hover = -1
	queue_redraw()

func _draw_important_dialogue() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 116), Color("7b3f23"))
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 14), Color("171018"))
	for stripe: int in range(5):
		draw_rect(Rect2(0, 78 + stripe * 7, VIEW_WIDTH, 4), Color("41241f"))

	_draw_cartographer_portrait()

	var node: Dictionary = IMPORTANT_DIALOGUE_053[important_node]
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
