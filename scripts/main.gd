extends Control

const ROOM_DATA_PATH := "res://data/rooms/demo_room.json"
const FONT_PATH := "res://assets/fonts/Commodore Pixelized v1.2.ttf"
const VIEW_WIDTH := 320.0
const VIEW_HEIGHT := 180.0
const WORLD_WIDTH := 680.0
const ROOM_BOTTOM := 112.0
const MESSAGE_TOP := 112.0
const UI_TOP := 124.0
const VERBS: Array[String] = [
	"ABRIR", "CERRAR", "EMPUJAR",
	"TIRAR", "MIRAR", "USAR",
	"DAR", "COGER", "HABLAR"
]

const COL_BG := Color("050814")
const COL_SKY_1 := Color("081128")
const COL_SKY_2 := Color("101d42")
const COL_SKY_3 := Color("162657")
const COL_FAR := Color("17244b")
const COL_MID := Color("20284d")
const COL_GROUND := Color("302d43")
const COL_GROUND_DARK := Color("1d1b2c")
const COL_STONE := Color("4b4b62")
const COL_STONE_LIGHT := Color("68677a")
const COL_UI := Color("0b0d16")
const COL_UI_2 := Color("171b29")
const COL_TEXT := Color("f3e7c8")
const COL_DIM := Color("938ca4")
const COL_CYAN := Color("79d9d0")
const COL_GOLD := Color("e5b96d")
const COL_FIRE := Color("ff9b45")
const COL_FIRE_LIGHT := Color("ffd06a")

var ui_font: Font = ThemeDB.fallback_font
var room_title := "MIRADOR DEL CARTOGRAFO"
var hotspots: Array[Dictionary] = []
var selected_verb := "MIRAR"
var selected_item := ""
var inventory: Array[String] = []
var hovered_id := ""
var message := "EXPLORA EL MIRADOR. ALGO EN ESE MAPA NO ENCAJA."

var intro_active := true
var player_x := 86.0
var player_target_x := 86.0
var camera_x := 0.0
var camera_target_x := 0.0
var pending_hotspot_id := ""
var action_pose_timer := 0.0
var chest_open_progress := 0.0
var fire_phase := 0.0

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
	fire_phase += delta
	if intro_active:
		queue_redraw()
		return
	var moved := false
	if absf(player_x - player_target_x) > 0.1:
		player_x = move_toward(player_x, player_target_x, 70.0 * delta)
		moved = true
	camera_target_x = clampf(player_x - 145.0, 0.0, WORLD_WIDTH - VIEW_WIDTH)
	if absf(camera_x - camera_target_x) > 0.05:
		camera_x = move_toward(camera_x, camera_target_x, 92.0 * delta)
		moved = true
	if not pending_hotspot_id.is_empty() and absf(player_x - player_target_x) <= 0.75:
		var hotspot_to_use := pending_hotspot_id
		pending_hotspot_id = ""
		_interact(hotspot_to_use)
		action_pose_timer = 0.42
	if action_pose_timer > 0.0:
		action_pose_timer = maxf(0.0, action_pose_timer - delta)
		moved = true
	var chest_target := 1.0 if bool(state["chest_open"]) else 0.0
	if absf(chest_open_progress - chest_target) > 0.01:
		chest_open_progress = move_toward(chest_open_progress, chest_target, 2.4 * delta)
		moved = true
	if moved or int(Time.get_ticks_msec() / 180) % 2 == 0:
		queue_redraw()

func _input(event: InputEvent) -> void:
	if intro_active:
		if event is InputEventMouseButton:
			var mouse_intro := event as InputEventMouseButton
			if mouse_intro.button_index == MOUSE_BUTTON_LEFT and mouse_intro.pressed:
				_start_demo()
				accept_event()
		elif event is InputEventKey:
			var key_intro := event as InputEventKey
			if key_intro.pressed and not key_intro.echo:
				_start_demo()
				accept_event()
		elif event is InputEventScreenTouch:
			var touch_intro := event as InputEventScreenTouch
			if touch_intro.pressed:
				_start_demo()
				accept_event()
		return
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		if motion.position.y < ROOM_BOTTOM:
			hovered_id = _hotspot_at(_screen_to_world(motion.position))
		else:
			hovered_id = ""
		queue_redraw()
	elif event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_handle_click(mouse.position)
			accept_event()
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			_handle_click(touch.position)
			accept_event()

func _start_demo() -> void:
	intro_active = false
	message = "BIENVENIDO. CAMINA, EXAMINA Y PRUEBA LOS VERBOS."
	queue_redraw()

func _load_room() -> void:
	if not FileAccess.file_exists(ROOM_DATA_PATH):
		message = "NO SE HA PODIDO CARGAR EL ESCENARIO."
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROOM_DATA_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		message = "LOS DATOS DEL ESCENARIO NO SON VALIDOS."
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
		pending_hotspot_id = ""
		if _handle_verb_click(position):
			return
		if _handle_inventory_click(position):
			return
	if position.y < ROOM_BOTTOM:
		var world_position := _screen_to_world(position)
		var hotspot_id: String = _hotspot_at(world_position)
		if not hotspot_id.is_empty():
			player_target_x = _approach_x_for(hotspot_id)
			pending_hotspot_id = hotspot_id
			message = "%s %s..." % [selected_verb, str(_get_hotspot(hotspot_id).get("name", ""))]
		else:
			pending_hotspot_id = ""
			player_target_x = clampf(world_position.x, 18.0, WORLD_WIDTH - 18.0)
		queue_redraw()

func _approach_x_for(hotspot_id: String) -> float:
	var hotspot := _get_hotspot(hotspot_id)
	var rect_value: Variant = hotspot.get("_rect", Rect2())
	if typeof(rect_value) != TYPE_RECT2:
		return player_x
	var rect: Rect2 = rect_value
	var center_x := rect.position.x + rect.size.x * 0.5
	var stand_x := center_x - 18.0 if player_x <= center_x else center_x + 18.0
	return clampf(stand_x, 18.0, WORLD_WIDTH - 18.0)

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
			message = "EL COFRE ESTA ABIERTO. DENTRO BRILLA UN FRAGMENTO."
		queue_redraw()
		return
	match hotspot_id:
		"painting":
			if selected_verb == "EMPUJAR":
				state["painting_moved"] = true
				message = "EL MAPA SE DESLIZA. DETRAS HABIA UNA LLAVE."
			else:
				message = "EL MAPA NO REACCIONA A ESO."
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
				message = "CLAC. LA CERRADURA CEDE Y LA TAPA SE ABRE."
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
				message = "CARTOGRAFO: LAS COSAS TORCIDAS SUELEN ESCONDER ALGO."
			elif selected_verb == "DAR" and selected_item == "FRAGMENTO" and inventory.has("FRAGMENTO"):
				inventory.erase("FRAGMENTO")
				selected_item = ""
				state["solved"] = true
				message = "PUZLE COMPLETADO: EL CARTOGRAFO RECONOCE EL FRAGMENTO."
			else:
				message = "EL CARTOGRAFO TE MIRA SIN ENTENDER."
		"door":
			if selected_verb == "ABRIR" and bool(state["solved"]):
				message = "EL ARCO DA PASO AL SENDERO. FIN DE LA DEMO."
			elif selected_verb == "ABRIR":
				message = "ANTES DE IRTE, EL CARTOGRAFO ESPERA ALGO DE TI."
			else:
				message = "UN VIEJO PASO DE PIEDRA HACIA EL SENDERO."
	queue_redraw()

func _screen_to_world(position: Vector2) -> Vector2:
	return Vector2(position.x + camera_x, position.y)

func _hotspot_at(world_position: Vector2) -> String:
	for hotspot: Dictionary in hotspots:
		var hotspot_id := str(hotspot.get("id", ""))
		if not _visible_hotspot(hotspot_id):
			continue
		var rect_value: Variant = hotspot.get("_rect", Rect2())
		if typeof(rect_value) == TYPE_RECT2:
			var rect: Rect2 = rect_value
			if rect.has_point(world_position):
				return hotspot_id
	return ""

func _visible_hotspot(hotspot_id: String) -> bool:
	if hotspot_id == "key":
		return bool(state["painting_moved"]) and not bool(state["key_taken"])
	if hotspot_id == "map_piece":
		return bool(state["chest_open"]) and chest_open_progress >= 0.72 and not bool(state["map_taken"])
	return true

func _get_hotspot(hotspot_id: String) -> Dictionary:
	for hotspot: Dictionary in hotspots:
		if str(hotspot.get("id", "")) == hotspot_id:
			return hotspot
	return {}

func _draw() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), COL_BG)
	if intro_active:
		_draw_intro()
		return
	_draw_parallax_sky()
	_draw_parallax_horizon()
	_draw_world()
	_draw_player()
	_draw_hotspot_highlight()
	_draw_ui()

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_text_center("BIENVENIDO A", 52, COL_DIM, 8)
	_text_center("NARANJAL DEL RÍO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_text_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_text_center("PIXEL ADVENTURE · PROTOTIPO 0.2.0", 164, Color("555564"), 6)

func _draw_parallax_sky() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, 28), COL_SKY_1)
	draw_rect(Rect2(0, 28, VIEW_WIDTH, 30), COL_SKY_2)
	draw_rect(Rect2(0, 58, VIEW_WIDTH, 34), COL_SKY_3)
	for index: int in range(48):
		var base_x := float((index * 83 + 29) % 900)
		var star_x := fposmod(base_x - camera_x * 0.11, 900.0)
		if star_x > VIEW_WIDTH + 4.0:
			continue
		var star_y := float(6 + ((index * 37) % 54))
		var star_color := Color("8ca9ff") if index % 3 == 0 else Color("d9e1ff")
		draw_rect(Rect2(floorf(star_x), star_y, 1, 1), star_color)
		if index % 11 == 0:
			draw_rect(Rect2(floorf(star_x) - 2, star_y, 5, 1), star_color)
			draw_rect(Rect2(floorf(star_x), star_y - 2, 1, 5), star_color)

func _draw_parallax_horizon() -> void:
	for index: int in range(-2, 10):
		var x := float(index * 92) - camera_x * 0.24
		var peak := 42.0 + float((index * 17) % 18)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 20, 91), Vector2(x + 28, peak), Vector2(x + 78, 91)]), COL_FAR)
	for index: int in range(-2, 11):
		var x := float(index * 78) - camera_x * 0.48
		var hill_top := 61.0 + float((index * 13) % 12)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 28, 96), Vector2(x + 12, hill_top), Vector2(x + 52, 96)]), COL_MID)
	for index: int in range(16):
		var town_x := fposmod(float(28 + index * 57) - camera_x * 0.52, 900.0)
		if town_x < VIEW_WIDTH:
			var h := 8.0 + float((index * 7) % 10)
			draw_rect(Rect2(town_x, 87.0 - h, 16, h), Color("181a31"))
			if index % 2 == 0:
				draw_rect(Rect2(town_x + 4, 82.0 - h * 0.35, 2, 1), COL_GOLD)

func _draw_world() -> void:
	draw_rect(Rect2(-camera_x, 88, WORLD_WIDTH, 24), COL_GROUND)
	for index: int in range(35):
		var sx := float(index * 21 + 7) - camera_x
		if sx < -8 or sx > VIEW_WIDTH + 8:
			continue
		var stone_y := 94.0 + float((index * 11) % 13)
		draw_rect(Rect2(sx, stone_y, 7, 3), COL_GROUND_DARK)
		if index % 3 == 0:
			draw_rect(Rect2(sx + 1, stone_y, 3, 1), Color("575064"))
	_draw_ruins()
	_draw_map_panel()
	_draw_campfire()
	_draw_world_character(365.0, 91.0, Color("52637a"), false)
	_draw_chest()
	_draw_archway()
	_text(room_title, 5, 10, COL_DIM, 7)
	if bool(state["solved"]):
		_text("PUZLE COMPLETADO", 196, 20, COL_CYAN, 7)

func _draw_ruins() -> void:
	for column: int in range(5):
		var sx := 158.0 + float(column * 14) - camera_x
		var top_y := 32.0 + float((column % 2) * 5)
		draw_rect(Rect2(sx, top_y, 12, 58), COL_STONE)
		for row: int in range(4):
			draw_rect(Rect2(sx + 1, top_y + 3 + row * 13, 10, 2), COL_STONE_LIGHT)
	for index: int in range(8):
		var sx := 430.0 + float(index * 16) - camera_x
		draw_rect(Rect2(sx, 80 + (index % 2) * 3, 14, 9), COL_STONE)
		draw_rect(Rect2(sx + 2, 81 + (index % 2) * 3, 8, 2), COL_STONE_LIGHT)

func _draw_map_panel() -> void:
	var panel_world_x := 218.0 if bool(state["painting_moved"]) else 210.0
	var x := panel_world_x - camera_x
	draw_rect(Rect2(x, 28, 40, 35), Color("60443a"))
	draw_rect(Rect2(x + 3, 31, 34, 29), Color("203557"))
	for index: int in range(5):
		draw_rect(Rect2(x + 7 + index * 5, 39 + (index % 2) * 4, 4, 2), Color("9a8764"))
	if bool(state["painting_moved"]) and not bool(state["key_taken"]):
		var key_x := 229.0 - camera_x
		draw_rect(Rect2(key_x, 67, 8, 2), COL_GOLD)
		draw_rect(Rect2(key_x + 5, 65, 2, 5), COL_GOLD)

func _draw_campfire() -> void:
	var fire_x := 318.0 - camera_x
	for index: int in range(7):
		draw_rect(Rect2(fire_x - 13.0 + float(index * 4), 89 + (index % 2), 4, 3), COL_STONE)
	var flicker := 1.0 if int(fire_phase * 9.0) % 2 == 0 else 0.0
	draw_rect(Rect2(fire_x - 3, 81 + flicker, 6, 8), COL_FIRE)
	draw_rect(Rect2(fire_x - 1, 78 - flicker, 3, 9), COL_FIRE_LIGHT)
	draw_rect(Rect2(fire_x, 75 + flicker, 1, 4), Color("fff0a3"))
	for index: int in range(3):
		var spark_y := 72.0 - float((int(fire_phase * 18.0) + index * 7) % 12)
		draw_rect(Rect2(fire_x - 4 + index * 4, spark_y, 1, 1), COL_FIRE_LIGHT)

func _draw_chest() -> void:
	var chest_x := 500.0 - camera_x
	draw_rect(Rect2(chest_x, 91, 48, 19), Color("5f3b2d"))
	draw_rect(Rect2(chest_x + 2, 94, 44, 3), Color("84543b"))
	draw_rect(Rect2(chest_x + 21, 96, 6, 7), COL_GOLD)
	var lid_y := 85.0 - roundf(chest_open_progress * 9.0)
	var lid_height := 8.0 - roundf(chest_open_progress * 2.0)
	draw_rect(Rect2(chest_x + 2, lid_y, 44, maxf(4.0, lid_height)), Color("80513a"))
	draw_rect(Rect2(chest_x + 4, lid_y + 1, 40, 2), Color("a46a45"))
	if chest_open_progress > 0.45:
		draw_rect(Rect2(chest_x + 5, 86, 38, 4), Color("18131a"))
	if bool(state["chest_open"]) and chest_open_progress >= 0.72 and not bool(state["map_taken"]):
		draw_rect(Rect2(chest_x + 17, 82, 14, 7), Color("d7c38a"))
		draw_rect(Rect2(chest_x + 20, 83, 8, 1), Color("e95355"))

func _draw_archway() -> void:
	var x := 610.0 - camera_x
	for row: int in range(6):
		draw_rect(Rect2(x, 31 + row * 13, 12, 11), COL_STONE)
		draw_rect(Rect2(x + 2, 32 + row * 13, 8, 2), COL_STONE_LIGHT)
		draw_rect(Rect2(x + 46, 31 + row * 13, 12, 11), COL_STONE)
		draw_rect(Rect2(x + 48, 32 + row * 13, 8, 2), COL_STONE_LIGHT)
	for index: int in range(5):
		draw_rect(Rect2(x + 9 + index * 10, 22 + abs(index - 2) * 4, 12, 10), COL_STONE)
		draw_rect(Rect2(x + 11 + index * 10, 23 + abs(index - 2) * 4, 8, 2), COL_STONE_LIGHT)

func _draw_player() -> void:
	var moving := absf(player_x - player_target_x) > 0.9
	_draw_world_character(player_x, 91.0, Color("7b455d"), moving, true)

func _draw_world_character(world_x: float, y_value: float, shirt: Color, moving: bool, is_player: bool = false) -> void:
	var x := floori(world_x - camera_x)
	var y := floori(y_value)
	if x < -20 or x > 340:
		return
	var step := 0
	if moving:
		step = 2 if int(Time.get_ticks_msec() / 120) % 2 == 0 else -2
	var skin := Color("e0b99a")
	var hair := Color("2f2532")
	draw_rect(Rect2(x - 5, y - 28, 10, 3), hair)
	draw_rect(Rect2(x - 4, y - 25, 8, 8), skin)
	draw_rect(Rect2(x - 5, y - 17, 10, 3), Color("252332"))
	draw_rect(Rect2(x - 7, y - 14, 14, 15), shirt)
	if is_player and action_pose_timer > 0.0:
		draw_rect(Rect2(x + 6, y - 12, 8, 3), skin)
	else:
		draw_rect(Rect2(x - 8, y - 12, 3, 10), skin)
		draw_rect(Rect2(x + 5, y - 12, 3, 10), skin)
	draw_rect(Rect2(x - 5 + step, y + 1, 4, 15), Color("30384a"))
	draw_rect(Rect2(x + 2 - step, y + 1, 4, 15), Color("30384a"))
	draw_rect(Rect2(x - 6 + step, y + 15, 6, 2), Color("171824"))
	draw_rect(Rect2(x + 2 - step, y + 15, 6, 2), Color("171824"))
	if not is_player:
		draw_rect(Rect2(x - 3, y - 22, 2, 2), Color("1e2028"))
		draw_rect(Rect2(x + 2, y - 22, 2, 2), Color("1e2028"))

func _draw_hotspot_highlight() -> void:
	if hovered_id.is_empty():
		return
	var hotspot := _get_hotspot(hovered_id)
	var rect_value: Variant = hotspot.get("_rect", Rect2())
	if typeof(rect_value) == TYPE_RECT2:
		var world_rect: Rect2 = rect_value
		var screen_rect := Rect2(world_rect.position.x - camera_x, world_rect.position.y, world_rect.size.x, world_rect.size.y)
		draw_rect(screen_rect, COL_CYAN, false, 1.0)
		_text(str(hotspot.get("name", "")), 5, 108, COL_CYAN, 7)

func _draw_ui() -> void:
	draw_rect(Rect2(0, MESSAGE_TOP, VIEW_WIDTH, 12), COL_UI_2)
	draw_rect(Rect2(0, UI_TOP, VIEW_WIDTH, 56), COL_UI)
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

func _text_center(text: String, y: float, color: Color, size: int) -> void:
	draw_string(ui_font, Vector2(12, y), text, HORIZONTAL_ALIGNMENT_CENTER, 296.0, size, color)
