extends Control

const ROOM_DATA_PATH := "res://data/rooms/demo_room.json"
const FONT_PATH := "res://assets/fonts/Commodore Pixelized v1.2.ttf"
const ROOM_BOTTOM := 112.0
const UI_TOP := 124.0
const VERBS := [
	"ABRIR", "CERRAR", "EMPUJAR",
	"TIRAR", "MIRAR", "USAR",
	"DAR", "COGER", "HABLAR"
]

const COL_BG := Color("080b14")
const COL_WALL := Color("151b2c")
const COL_WALL_2 := Color("20293d")
const COL_FLOOR := Color("38283a")
const COL_FLOOR_2 := Color("4b3444")
const COL_CYAN := Color("79d9d0")
const COL_GOLD := Color("e5b96d")
const COL_TEXT := Color("f3e7c8")
const COL_DIM := Color("938ca4")
const COL_UI := Color("10131e")
const COL_UI_2 := Color("1c2231")
const COL_RED := Color("d95d6b")

var ui_font: Font = ThemeDB.fallback_font
var room_title := "PIXEL ADVENTURE"
var hotspots: Array[Dictionary] = []
var selected_verb := "MIRAR"
var selected_item := ""
var inventory: Array[String] = []
var message := "PRUEBA LOS VERBOS. EL CUADRO PARECE SOSPECHOSO."
var hovered_id := ""
var player_x := 42.0
var player_target_x := 42.0

var state := {
	"painting_moved": false,
	"key_taken": false,
	"chest_open": false,
	"map_taken": false,
	"solved": false
}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_setup_font()
	_load_room_data()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if absf(player_x - player_target_x) > 0.1:
		player_x = move_toward(player_x, player_target_x, 72.0 * delta)
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		hovered_id = _hotspot_at(motion.position)
		queue_redraw()
		return

	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_handle_click(mouse.position)
			accept_event()


func _setup_font() -> void:
	if ResourceLoader.exists(FONT_PATH):
		var loaded := load(FONT_PATH)
		if loaded is Font:
			ui_font = loaded as Font
			return

	var system_font := SystemFont.new()
	system_font.font_names = PackedStringArray([
		"Commodore 64 Pixelized",
		"Commodore Pixelized",
		"Courier New",
		"monospace"
	])
	ui_font = system_font


func _load_room_data() -> void:
	if not FileAccess.file_exists(ROOM_DATA_PATH):
		message = "NO SE HA PODIDO CARGAR LA HABITACION."
		return

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROOM_DATA_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		message = "LOS DATOS DE LA HABITACION NO SON VALIDOS."
		return

	var data := parsed as Dictionary
	room_title = str(data.get("title", room_title))
	hotspots.clear()
	var raw_hotspots: Variant = data.get("hotspots", [])
	if typeof(raw_hotspots) != TYPE_ARRAY:
		return

	for raw_entry in raw_hotspots as Array:
		if typeof(raw_entry) != TYPE_DICTIONARY:
			continue
		var entry := (raw_entry as Dictionary).duplicate(true)
		var raw_rect: Variant = entry.get("rect", [])
		if typeof(raw_rect) != TYPE_ARRAY or (raw_rect as Array).size() != 4:
			continue
		var values := raw_rect as Array
		entry["_rect"] = Rect2(
			float(values[0]),
			float(values[1]),
			float(values[2]),
			float(values[3])
		)
		hotspots.append(entry)


func _handle_click(position: Vector2) -> void:
	if position.y >= UI_TOP:
		if _handle_verb_click(position):
			return
		if _handle_inventory_click(position):
			return

	if position.y < ROOM_BOTTOM:
		player_target_x = clampf(position.x, 12.0, 306.0)
		var hotspot_id := _hotspot_at(position)
		if not hotspot_id.is_empty():
			_interact(hotspot_id)
		queue_redraw()


func _handle_verb_click(position: Vector2) -> bool:
	for index in range(VERBS.size()):
		var rect := _verb_rect(index)
		if rect.has_point(position):
			selected_verb = VERBS[index]
			selected_item = ""
			message = "%s... CON QUE?" % selected_verb
			queue_redraw()
			return true
	return false


func _handle_inventory_click(position: Vector2) -> bool:
	if position.x < 190.0:
		return false
	for index in range(inventory.size()):
		var rect := Rect2(197.0, 142.0 + float(index * 12), 115.0, 10.0)
		if rect.has_point(position):
			selected_item = inventory[index]
			selected_verb = "USAR"
			message = "USAR %s CON..." % selected_item
			queue_redraw()
			return true
	return false


func _interact(hotspot_id: String) -> void:
	var hotspot := _get_hotspot(hotspot_id)
	var name := str(hotspot.get("name", hotspot_id.to_upper()))

	if selected_verb == "MIRAR":
		message = str(hotspot.get("look", "NO VES NADA ESPECIAL."))
		if hotspot_id == "chest" and bool(state["chest_open"]):
			message = "EL COFRE ESTA ABIERTO. DENTRO HAY UN FRAGMENTO DE MAPA."
		queue_redraw()
		return

	match hotspot_id:
		"painting":
			_interact_painting()
		"key":
			_interact_key()
		"chest":
			_interact_chest()
		"map_piece":
			_interact_map_piece()
		"npc":
			_interact_npc()
		"door":
			_interact_door()
		_:
			message = "%s %s NO PARECE UNA GRAN IDEA." % [selected_verb, name]
	queue_redraw()


func _interact_painting() -> void:
	if selected_verb == "EMPUJAR":
		if bool(state["painting_moved"]):
			message = "YA LO HAS MOVIDO."
		else:
			state["painting_moved"] = true
			message = "EL CUADRO SE DESLIZA. DETRAS HAY UNA LLAVE DE COBRE."
	elif selected_verb == "TIRAR":
		message = "NO QUIERES ARRANCARLO. SOLO ESTA MAL COLOCADO."
	else:
		message = "ESO NO HACE NADA UTIL CON EL CUADRO."


func _interact_key() -> void:
	if selected_verb != "COGER":
		message = "PARECE QUE LA LLAVE PREFIERE QUE LA COJAS."
		return
	if bool(state["key_taken"]):
		message = "YA TIENES LA LLAVE."
		return
	state["key_taken"] = true
	inventory.append("LLAVE")
	message = "COGES LA LLAVE DE COBRE."


func _interact_chest() -> void:
	if selected_verb == "ABRIR":
		if bool(state["chest_open"]):
			message = "EL COFRE YA ESTA ABIERTO."
		else:
			message = "CERRADO. LA CERRADURA PIDE UNA LLAVE PEQUENA."
		return

	if selected_verb == "USAR":
		if selected_item == "LLAVE" and inventory.has("LLAVE"):
			state["chest_open"] = true
			selected_item = ""
			message = "CLAC. EL COFRE SE ABRE Y DEJA VER UN FRAGMENTO DE MAPA."
		else:
			message = "ESO NO ENCAJA EN LA CERRADURA."
		return

	message = "EL COFRE NO REACCIONA A ESO."


func _interact_map_piece() -> void:
	if selected_verb != "COGER":
		message = "LO MEJOR SERIA GUARDAR EL FRAGMENTO."
		return
	if bool(state["map_taken"]):
		message = "YA LO HAS RECOGIDO."
		return
	state["map_taken"] = true
	inventory.append("FRAGMENTO")
	message = "GUARDAS EL FRAGMENTO DE MAPA."


func _interact_npc() -> void:
	if selected_verb == "HABLAR":
		if bool(state["solved"]):
			message = "CARTOGRAFO: SABIA QUE PODIA CONFIAR EN TI."
		elif bool(state["map_taken"]):
			message = "CARTOGRAFO: SI HAS ENCONTRADO ALGO, DAMelo."
		else:
			message = "CARTOGRAFO: A VECES LAS COSAS TORCIDAS ESCONDEN ALGO."
		return

	if selected_verb == "DAR":
		if selected_item == "FRAGMENTO" and inventory.has("FRAGMENTO"):
			inventory.erase("FRAGMENTO")
			selected_item = ""
			state["solved"] = true
			message = "PUZLE COMPLETADO: EL CARTOGRAFO UNE EL FRAGMENTO AL MAPA."
		else:
			message = "NO PARECE INTERESADO EN ESO."
		return

	message = "EL CARTOGRAFO TE MIRA SIN ENTENDER."


func _interact_door() -> void:
	if selected_verb != "ABRIR":
		message = "ES UNA PUERTA. ABRIRLA SUELE FUNCIONAR MEJOR."
		return
	if bool(state["solved"]):
		message = "LA PUERTA SE ABRE. FIN DE LA PEQUENA DEMO."
	else:
		message = "ANTES DE IRTE, EL CARTOGRAFO PARECE ESPERAR ALGO DE TI."


func _hotspot_at(position: Vector2) -> String:
	for hotspot in hotspots:
		var hotspot_id := str(hotspot.get("id", ""))
		if not _is_hotspot_visible(hotspot_id):
			continue
		var rect: Variant = hotspot.get("_rect", Rect2())
		if typeof(rect) == TYPE_RECT2 and (rect as Rect2).has_point(position):
			return hotspot_id
	return ""


func _get_hotspot(hotspot_id: String) -> Dictionary:
	for hotspot in hotspots:
		if str(hotspot.get("id", "")) == hotspot_id:
			return hotspot
	return {}


func _is_hotspot_visible(hotspot_id: String) -> bool:
	match hotspot_id:
		"key":
			return bool(state["painting_moved"]) and not bool(state["key_taken"])
		"map_piece":
			return bool(state["chest_open"]) and not bool(state["map_taken"])
	return true


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 180), COL_BG)
	_draw_room()
	_draw_player()
	_draw_hotspot_highlight()
	_draw_ui()


func _draw_room() -> void:
	draw_rect(Rect2(0, 0, 320, 82), COL_WALL)
	draw_rect(Rect2(0, 82, 320, 30), COL_FLOOR)

	for y in range(8, 82, 12):
		var offset := 8 if int(y / 12) % 2 == 1 else 0
		for x in range(6 + offset, 320, 18):
			draw_rect(Rect2(x, y, 10, 1), Color(COL_WALL_2, 0.45))

	for x in range(0, 320, 20):
		var floor_color := COL_FLOOR_2 if int(x / 20) % 2 == 0 else COL_FLOOR
		draw_rect(Rect2(x, 83, 19, 29), floor_color)

	# Ventana nocturna.
	draw_rect(Rect2(12, 16, 42, 48), Color("0b0e19"))
	draw_rect(Rect2(15, 19, 36, 42), Color("172a3d"))
	draw_rect(Rect2(32, 19, 2, 42), Color("596278"))
	draw_rect(Rect2(15, 39, 36, 2), Color("596278"))
	draw_rect(Rect2(21, 27, 2, 2), COL_GOLD)
	draw_rect(Rect2(44, 49, 1, 1), COL_GOLD)

	# Cuadro desplazable.
	var painting_x := 76.0 if bool(state["painting_moved"]) else 68.0
	draw_rect(Rect2(painting_x, 28, 40, 35), Color("6b4b3f"))
	draw_rect(Rect2(painting_x + 3, 31, 34, 29), Color("26344a"))
	draw_rect(Rect2(painting_x + 13, 36, 10, 9), Color("d6c7a4"))
	draw_rect(Rect2(painting_x + 10, 45, 17, 12), Color("443d58"))

	if bool(state["painting_moved"]) and not bool(state["key_taken"]):
		draw_rect(Rect2(86, 66, 8, 3), COL_GOLD)
		draw_rect(Rect2(91, 64, 2, 7), COL_GOLD)

	# Estanteria y frascos.
	draw_rect(Rect2(198, 18, 62, 3), Color("6d4c43"))
	draw_rect(Rect2(198, 44, 62, 3), Color("6d4c43"))
	for x in [203, 215, 229, 244]:
		draw_rect(Rect2(x, 10 + (x % 3), 6, 8), Color("658a8d"))
	for x in [205, 222, 238, 250]:
		draw_rect(Rect2(x, 34 + (x % 2), 5, 9), Color("9b6f78"))

	# Cofre.
	draw_rect(Rect2(232, 90, 48, 20), Color("6c4638"))
	draw_rect(Rect2(235, 86, 42, 8), Color("805444"))
	draw_rect(Rect2(253, 94, 6, 8), COL_GOLD)
	if bool(state["chest_open"]):
		draw_rect(Rect2(235, 78, 42, 7), Color("805444"))
		draw_rect(Rect2(241, 84, 30, 5), Color("17131c"))
	if bool(state["chest_open"]) and not bool(state["map_taken"]):
		draw_rect(Rect2(248, 79, 14, 7), Color("d7c38a"))
		draw_rect(Rect2(254, 81, 2, 2), COL_RED)

	# Puerta.
	draw_rect(Rect2(282, 24, 30, 86), Color("3f2b36"))
	draw_rect(Rect2(286, 28, 22, 78), Color("5b3b45"))
	draw_rect(Rect2(303, 66, 3, 3), COL_GOLD)

	_draw_npc(Vector2(146, 74))
	_text(room_title, 4, 10, COL_DIM, 7)
	if bool(state["solved"]):
		_text("PUZLE COMPLETADO", 207, 10, COL_CYAN, 7)


func _draw_npc(position: Vector2) -> void:
	var x := floori(position.x)
	var y := floori(position.y)
	draw_rect(Rect2(x - 4, y - 20, 8, 8), Color("d6b08c"))
	draw_rect(Rect2(x - 6, y - 12, 12, 15), Color("52637a"))
	draw_rect(Rect2(x - 5, y + 3, 4, 12), Color("2a2534"))
	draw_rect(Rect2(x + 2, y + 3, 4, 12), Color("2a2534"))
	draw_rect(Rect2(x - 5, y - 22, 10, 3), Color("5a3f39"))


func _draw_player() -> void:
	var x := floori(player_x)
	var y := 92
	draw_rect(Rect2(x - 4, y - 24, 8, 8), Color("e0b99a"))
	draw_rect(Rect2(x - 5, y - 26, 10, 3), Color("35283a"))
	draw_rect(Rect2(x - 6, y - 16, 12, 17), Color("7b455d"))
	draw_rect(Rect2(x - 7, y - 13, 2, 12), Color("e0b99a"))
	draw_rect(Rect2(x + 6, y - 13, 2, 12), Color("e0b99a"))
	draw_rect(Rect2(x - 5, y + 1, 4, 15), Color("30384a"))
	draw_rect(Rect2(x + 2, y + 1, 4, 15), Color("30384a"))
	draw_rect(Rect2(x - 7, y + 15, 6, 2), Color("11131c"))
	draw_rect(Rect2(x + 2, y + 15, 6, 2), Color("11131c"))


func _draw_hotspot_highlight() -> void:
	if hovered_id.is_empty():
		return
	var hotspot := _get_hotspot(hovered_id)
	var rect: Variant = hotspot.get("_rect", Rect2())
	if typeof(rect) == TYPE_RECT2:
		var hotspot_rect: Rect2 = rect
		draw_rect(hotspot_rect, Color(COL_CYAN, 0.65), false, 1.0)
		_text(str(hotspot.get("name", "")), 5, 108, COL_CYAN, 7)


func _draw_ui() -> void:
	draw_rect(Rect2(0, ROOM_BOTTOM, 320, 12), COL_UI_2)
	draw_rect(Rect2(0, UI_TOP, 320, 56), COL_UI)
	_text(message, 5, 120, COL_TEXT, 7)

	for index in range(VERBS.size()):
		var rect := _verb_rect(index)
		var active := VERBS[index] == selected_verb
		draw_rect(rect, COL_UI_2 if not active else Color("283d4c"))
		draw_rect(rect, COL_CYAN if active else Color("3b4356"), false, 1.0)
		_text(VERBS[index], rect.position.x + 3, rect.position.y + 11, COL_CYAN if active else COL_TEXT, 7)

	draw_rect(Rect2(190, 126, 126, 50), COL_UI_2)
	draw_rect(Rect2(190, 126, 126, 50), Color("3b4356"), false, 1.0)
	_text("INVENTARIO", 197, 137, COL_GOLD, 7)

	if inventory.is_empty():
		_text("(VACIO)", 197, 150, COL_DIM, 7)
	else:
		for index in range(inventory.size()):
			var item := inventory[index]
			var is_selected := item == selected_item
			if is_selected:
				draw_rect(Rect2(195, 141 + index * 12, 117, 11), Color("283d4c"))
			_text(item, 198, 150 + index * 12, COL_CYAN if is_selected else COL_TEXT, 7)


func _verb_rect(index: int) -> Rect2:
	var column := index % 3
	var row := int(index / 3)
	return Rect2(4 + column * 61, 127 + row * 16, 58, 14)


func _text(text: String, x: float, y: float, color: Color = COL_TEXT, size: int = 8) -> void:
	draw_string(ui_font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)
