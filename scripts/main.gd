extends Control

const ROOM_DATA_PATH := "res://data/rooms/demo_room.json"
const FONT_PATH := "res://assets/fonts/Commodore Pixelized v1.2.ttf"
const ROOM_BOTTOM := 112.0
const UI_TOP := 124.0
const VERBS: Array[String] = [
	"ABRIR", "CERRAR", "EMPUJAR",
	"TIRAR", "MIRAR", "USAR",
	"DAR", "COGER", "HABLAR"
]

const COL_BG := Color("080b14")
const COL_WALL := Color("151b2c")
const COL_FLOOR := Color("38283a")
const COL_UI := Color("10131e")
const COL_UI_2 := Color("1c2231")
const COL_TEXT := Color("f3e7c8")
const COL_DIM := Color("938ca4")
const COL_CYAN := Color("79d9d0")
const COL_GOLD := Color("e5b96d")

var ui_font: Font = ThemeDB.fallback_font
var room_title := "PIXEL ADVENTURE"
var hotspots: Array[Dictionary] = []
var selected_verb := "MIRAR"
var selected_item := ""
var inventory: Array[String] = []
var hovered_id := ""
var message := "PRUEBA LOS VERBOS. EL CUADRO PARECE SOSPECHOSO."
var player_x := 42.0
var player_target_x := 42.0
var state: Dictionary = {
	"painting_moved": false,
	"key_taken": false,
	"chest_open": false,
	"map_taken": false,
	"solved": false
}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if ResourceLoader.exists(FONT_PATH):
		var resource: Resource = load(FONT_PATH)
		if resource is Font:
			ui_font = resource as Font
	_load_room()
	queue_redraw()


func _process(delta: float) -> void:
	if absf(player_x - player_target_x) > 0.1:
		player_x = move_toward(player_x, player_target_x, 72.0 * delta)
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		hovered_id = _hotspot_at(motion.position)
		queue_redraw()
	elif event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_handle_click(mouse.position)
			accept_event()


func _load_room() -> void:
	if not FileAccess.file_exists(ROOM_DATA_PATH):
		message = "NO SE HA PODIDO CARGAR LA HABITACION."
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROOM_DATA_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		message = "LOS DATOS DE LA HABITACION NO SON VALIDOS."
		return
	var data: Dictionary = parsed as Dictionary
	room_title = str(data.get("title", room_title))
	var raw_hotspots: Variant = data.get("hotspots", [])
	if typeof(raw_hotspots) != TYPE_ARRAY:
		return
	for raw_entry: Variant in raw_hotspots as Array:
		if typeof(raw_entry) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = (raw_entry as Dictionary).duplicate(true)
		var raw_rect: Variant = entry.get("rect", [])
		if typeof(raw_rect) != TYPE_ARRAY:
			continue
		var values: Array = raw_rect as Array
		if values.size() != 4:
			continue
		entry["_rect"] = Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))
		hotspots.append(entry)


func _handle_click(position: Vector2) -> void:
	if position.y >= UI_TOP:
		if _handle_verb_click(position):
			return
		if _handle_inventory_click(position):
			return
	if position.y < ROOM_BOTTOM:
		player_target_x = clampf(position.x, 12.0, 306.0)
		var hotspot_id: String = _hotspot_at(position)
		if not hotspot_id.is_empty():
			_interact(hotspot_id)
		queue_redraw()


func _handle_verb_click(position: Vector2) -> bool:
	for index: int in range(VERBS.size()):
		var rect: Rect2 = _verb_rect(index)
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
	for index: int in range(inventory.size()):
		var rect := Rect2(197.0, 142.0 + float(index * 12), 115.0, 10.0)
		if rect.has_point(position):
			selected_item = inventory[index]
			selected_verb = "USAR"
			message = "USAR %s CON..." % selected_item
			queue_redraw()
			return true
	return false


func _interact(hotspot_id: String) -> void:
	var hotspot: Dictionary = _get_hotspot(hotspot_id)
	if selected_verb == "MIRAR":
		message = str(hotspot.get("look", "NO VES NADA ESPECIAL."))
		if hotspot_id == "chest" and bool(state["chest_open"]):
			message = "EL COFRE ESTA ABIERTO. DENTRO HAY UN FRAGMENTO."
		queue_redraw()
		return

	match hotspot_id:
		"painting":
			if selected_verb == "EMPUJAR":
				state["painting_moved"] = true
				message = "EL CUADRO SE DESLIZA. DETRAS HAY UNA LLAVE."
			else:
				message = "EL CUADRO NO REACCIONA A ESO."
		"key":
			if selected_verb == "COGER" and not bool(state["key_taken"]):
				state["key_taken"] = true
				inventory.append("LLAVE")
				message = "COGES LA LLAVE DE COBRE."
			else:
				message = "PARECE QUE LA LLAVE PREFIERE QUE LA COJAS."
		"chest":
			if selected_verb == "USAR" and selected_item == "LLAVE" and inventory.has("LLAVE"):
				state["chest_open"] = true
				selected_item = ""
				message = "CLAC. EL COFRE SE ABRE Y APARECE UN FRAGMENTO."
			elif selected_verb == "ABRIR" and not bool(state["chest_open"]):
				message = "ESTA CERRADO. NECESITAS UNA LLAVE."
			else:
				message = "EL COFRE NO REACCIONA A ESO."
		"map_piece":
			if selected_verb == "COGER" and not bool(state["map_taken"]):
				state["map_taken"] = true
				inventory.append("FRAGMENTO")
				message = "GUARDAS EL FRAGMENTO DE MAPA."
			else:
				message = "LO MEJOR SERIA GUARDARLO."
		"npc":
			if selected_verb == "HABLAR":
				message = "CARTOGRAFO: A VECES LAS COSAS TORCIDAS ESCONDEN ALGO."
			elif selected_verb == "DAR" and selected_item == "FRAGMENTO" and inventory.has("FRAGMENTO"):
				inventory.erase("FRAGMENTO")
				selected_item = ""
				state["solved"] = true
				message = "PUZLE COMPLETADO: EL CARTOGRAFO UNE EL FRAGMENTO."
			else:
				message = "EL CARTOGRAFO TE MIRA SIN ENTENDER."
		"door":
			if selected_verb == "ABRIR" and bool(state["solved"]):
				message = "LA PUERTA SE ABRE. FIN DE LA PEQUENA DEMO."
			elif selected_verb == "ABRIR":
				message = "ANTES DE IRTE, EL CARTOGRAFO ESPERA ALGO DE TI."
			else:
				message = "ES UNA PUERTA. ABRIRLA SUELE FUNCIONAR MEJOR."
	queue_redraw()


func _hotspot_at(position: Vector2) -> String:
	for hotspot: Dictionary in hotspots:
		var hotspot_id := str(hotspot.get("id", ""))
		if not _visible_hotspot(hotspot_id):
			continue
		var rect_value: Variant = hotspot.get("_rect", Rect2())
		if typeof(rect_value) == TYPE_RECT2:
			var rect: Rect2 = rect_value
			if rect.has_point(position):
				return hotspot_id
	return ""


func _visible_hotspot(hotspot_id: String) -> bool:
	if hotspot_id == "key":
		return bool(state["painting_moved"]) and not bool(state["key_taken"])
	if hotspot_id == "map_piece":
		return bool(state["chest_open"]) and not bool(state["map_taken"])
	return true


func _get_hotspot(hotspot_id: String) -> Dictionary:
	for hotspot: Dictionary in hotspots:
		if str(hotspot.get("id", "")) == hotspot_id:
			return hotspot
	return {}


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 180), COL_BG)
	_draw_room()
	_draw_character(player_x, 92, Color("7b455d"))
	_draw_hotspot_highlight()
	_draw_ui()


func _draw_room() -> void:
	draw_rect(Rect2(0, 0, 320, 82), COL_WALL)
	draw_rect(Rect2(0, 82, 320, 30), COL_FLOOR)
	for x: int in range(0, 320, 20):
		if int(x / 20) % 2 == 0:
			draw_rect(Rect2(x, 84, 18, 27), Color("4b3444"))

	draw_rect(Rect2(12, 16, 42, 48), Color("172a3d"))
	draw_rect(Rect2(32, 19, 2, 42), Color("596278"))
	draw_rect(Rect2(15, 39, 36, 2), Color("596278"))

	var painting_x := 76.0 if bool(state["painting_moved"]) else 68.0
	draw_rect(Rect2(painting_x, 28, 40, 35), Color("6b4b3f"))
	draw_rect(Rect2(painting_x + 3, 31, 34, 29), Color("26344a"))
	if bool(state["painting_moved"]) and not bool(state["key_taken"]):
		draw_rect(Rect2(86, 66, 8, 3), COL_GOLD)

	draw_rect(Rect2(198, 18, 62, 3), Color("6d4c43"))
	draw_rect(Rect2(198, 44, 62, 3), Color("6d4c43"))

	draw_rect(Rect2(232, 90, 48, 20), Color("6c4638"))
	draw_rect(Rect2(235, 86, 42, 8), Color("805444"))
	draw_rect(Rect2(253, 94, 6, 8), COL_GOLD)
	if bool(state["chest_open"]):
		draw_rect(Rect2(235, 78, 42, 7), Color("805444"))
	if bool(state["chest_open"]) and not bool(state["map_taken"]):
		draw_rect(Rect2(248, 79, 14, 7), Color("d7c38a"))

	draw_rect(Rect2(282, 24, 30, 86), Color("3f2b36"))
	draw_rect(Rect2(286, 28, 22, 78), Color("5b3b45"))
	draw_rect(Rect2(303, 66, 3, 3), COL_GOLD)

	_draw_character(146, 92, Color("52637a"))
	_text(room_title, 4, 10, COL_DIM, 7)
	if bool(state["solved"]):
		_text("PUZLE COMPLETADO", 207, 10, COL_CYAN, 7)


func _draw_character(x_value: float, y_value: float, shirt: Color) -> void:
	var x := floori(x_value)
	var y := floori(y_value)
	draw_rect(Rect2(x - 4, y - 24, 8, 8), Color("e0b99a"))
	draw_rect(Rect2(x - 5, y - 26, 10, 3), Color("35283a"))
	draw_rect(Rect2(x - 6, y - 16, 12, 17), shirt)
	draw_rect(Rect2(x - 5, y + 1, 4, 15), Color("30384a"))
	draw_rect(Rect2(x + 2, y + 1, 4, 15), Color("30384a"))


func _draw_hotspot_highlight() -> void:
	if hovered_id.is_empty():
		return
	var hotspot := _get_hotspot(hovered_id)
	var rect_value: Variant = hotspot.get("_rect", Rect2())
	if typeof(rect_value) == TYPE_RECT2:
		var rect: Rect2 = rect_value
		draw_rect(rect, COL_CYAN, false, 1.0)
		_text(str(hotspot.get("name", "")), 5, 108, COL_CYAN, 7)


func _draw_ui() -> void:
	draw_rect(Rect2(0, ROOM_BOTTOM, 320, 12), COL_UI_2)
	draw_rect(Rect2(0, UI_TOP, 320, 56), COL_UI)
	_text(message, 5, 120, COL_TEXT, 7)

	for index: int in range(VERBS.size()):
		var rect := _verb_rect(index)
		var active: bool = VERBS[index] == selected_verb
		draw_rect(rect, Color("283d4c") if active else COL_UI_2)
		draw_rect(rect, COL_CYAN if active else Color("3b4356"), false, 1.0)
		_text(VERBS[index], rect.position.x + 3, rect.position.y + 11, COL_CYAN if active else COL_TEXT, 7)

	draw_rect(Rect2(190, 126, 126, 50), COL_UI_2)
	draw_rect(Rect2(190, 126, 126, 50), Color("3b4356"), false, 1.0)
	_text("INVENTARIO", 197, 137, COL_GOLD, 7)
	if inventory.is_empty():
		_text("(VACIO)", 197, 150, COL_DIM, 7)
	else:
		for index: int in range(inventory.size()):
			var item: String = inventory[index]
			var active_item: bool = item == selected_item
			_text(item, 198, 150 + index * 12, COL_CYAN if active_item else COL_TEXT, 7)


func _verb_rect(index: int) -> Rect2:
	var column: int = index % 3
	var row: int = int(index / 3)
	return Rect2(4 + column * 61, 127 + row * 16, 58, 14)


func _text(text: String, x: float, y: float, color: Color, size: int) -> void:
	draw_string(ui_font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)
