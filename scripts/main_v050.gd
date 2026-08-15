extends "res://scripts/main_v049.gd"

# 0.5.0: pantalla completa al arrancar, hotspots sin recuadro,
# salida por el portal y hoja escrita interactiva sobre el cofre.

const NOTE_TEXTURE: Texture2D = preload("res://assets/sprites/chest/note_sheet.png")
const NOTE_BACK_RECT := Rect2(108, 146, 104, 22)
const NOTE_CODE := "14700"

var note_view_active := false
var note_back_hover := false

func _ready() -> void:
	super._ready()
	# En escritorio puede entrar en pantalla completa inmediatamente.
	# En Web los navegadores exigen un gesto del usuario, así que también
	# se vuelve a solicitar con el primer clic/tecla de la pantalla inicial.
	if not OS.has_feature("web"):
		call_deferred("_try_enter_fullscreen")

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.5.0", 164, Color("555564"), 6)

func _process(delta: float) -> void:
	if note_view_active:
		queue_redraw()
		return
	super._process(delta)

func _input(event: InputEvent) -> void:
	if note_view_active:
		_handle_note_input(event)
		return

	if intro_active and _is_activation_event(event):
		_try_enter_fullscreen()

	super._input(event)

func _is_activation_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		return mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	if event is InputEventKey:
		var key := event as InputEventKey
		return key.pressed and not key.echo
	return false

func _try_enter_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN and mode != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	queue_redraw()

func _draw() -> void:
	if note_view_active:
		_draw_note_screen()
		_draw_fullscreen_button()
		_draw_custom_cursor(cursor_position, selected_cursor)
		return
	super._draw()

func _draw_hotspot_highlight() -> void:
	# Mantiene el nombre del elemento bajo el cursor, pero elimina por completo
	# el rectángulo de selección que rodeaba los hotspots.
	if hovered_id.is_empty() or dialogue_mode != "none":
		return
	var hotspot := _get_hotspot(hovered_id)
	_ui_text(str(hotspot.get("name", "")), 5, 112, COL_STATUS, 7)

func _hotspot_at(world_position: Vector2) -> String:
	# La hoja está físicamente encima del cofre, por lo que debe tener prioridad
	# de clic frente al rectángulo más grande del cofre.
	if bool(state["chest_open"]) and chest_open_progress >= 0.72 and not bool(state["map_taken"]):
		var note_hotspot := _get_hotspot("map_piece")
		var note_rect_value: Variant = note_hotspot.get("_rect", Rect2())
		if typeof(note_rect_value) == TYPE_RECT2 and (note_rect_value as Rect2).has_point(world_position):
			return "map_piece"
	return super._hotspot_at(world_position)

func _interact(hotspot_id: String) -> void:
	if hotspot_id == "door" and selected_verb == "USAR":
		_exit_game()
		return

	if hotspot_id == "map_piece" and selected_verb == "MIRAR" and bool(state["chest_open"]):
		note_view_active = true
		note_back_hover = false
		pending_hotspot_id = ""
		message = ""
		queue_redraw()
		return

	super._interact(hotspot_id)

func _exit_game() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (window.history.length > 1) { window.history.back(); } else { window.location.replace('about:blank'); }")
	else:
		get_tree().quit()

func _draw_chest() -> void:
	var chest_x := 500.0 - camera_x
	var texture := CHEST_CLOSED
	if chest_open_progress >= 0.72:
		texture = CHEST_OPEN
	elif chest_open_progress > 0.08:
		texture = CHEST_OPENING
	draw_texture(texture, Vector2(chest_x - 4.0, 79.0))

	# La hoja se dibuja después del cofre para que quede visualmente encima.
	if bool(state["chest_open"]) and chest_open_progress >= 0.72 and not bool(state["map_taken"]):
		draw_texture(NOTE_TEXTURE, Vector2(chest_x + 12.0, 73.0))

func _draw_note_screen() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color("09080c"))

	# Hoja grande de lectura.
	draw_rect(Rect2(25, 16, 270, 120), Color("5f4a38"))
	draw_rect(Rect2(28, 19, 264, 114), Color("d8c59d"))
	for line_y: float in [45.0, 61.0, 77.0, 109.0]:
		draw_rect(Rect2(48, line_y, 224, 1), Color("a89575"))

	var code_size := 22
	var code_width := NORMAL_DIALOGUE_FONT.get_string_size(NOTE_CODE, HORIZONTAL_ALIGNMENT_LEFT, -1.0, code_size).x
	var code_x := (VIEW_WIDTH - code_width) * 0.5
	draw_string_outline(
		NORMAL_DIALOGUE_FONT,
		Vector2(code_x, 94),
		NOTE_CODE,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		code_size,
		2,
		Color.BLACK
	)
	draw_string(
		NORMAL_DIALOGUE_FONT,
		Vector2(code_x, 94),
		NOTE_CODE,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		code_size,
		Color.WHITE
	)

	var button_color := Color("3b3741") if note_back_hover else Color("211f27")
	draw_rect(NOTE_BACK_RECT, button_color)
	draw_rect(NOTE_BACK_RECT, Color("8b8493"), false, 1.0)
	var label := "VOLVER AL JUEGO"
	var label_size := 6
	var label_width := COMMODORE_FONT.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, label_size).x
	_ui_text(label, NOTE_BACK_RECT.position.x + (NOTE_BACK_RECT.size.x - label_width) * 0.5, NOTE_BACK_RECT.position.y + 14, Color("f2edf6"), label_size)

func _handle_note_input(event: InputEvent) -> void:
	var pointer_position := Vector2(-1, -1)
	var activate := false

	if event is InputEventMouseMotion:
		pointer_position = (event as InputEventMouseMotion).position
		cursor_position = pointer_position
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		pointer_position = mouse.position
		cursor_position = pointer_position
		activate = mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		pointer_position = touch.position
		cursor_position = pointer_position
		activate = touch.pressed
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo:
			if key.keycode == KEY_F11:
				_toggle_fullscreen()
				accept_event()
				return
			if key.keycode == KEY_ESCAPE:
				note_view_active = false
				note_back_hover = false
				queue_redraw()
				accept_event()
				return

	if pointer_position.x >= 0.0:
		var fs_hover := FULLSCREEN_RECT.has_point(pointer_position)
		if fs_hover != fullscreen_hover:
			fullscreen_hover = fs_hover
			queue_redraw()
		if activate and fs_hover:
			_toggle_fullscreen()
			accept_event()
			return

		var back_hover_now := NOTE_BACK_RECT.has_point(pointer_position)
		if back_hover_now != note_back_hover:
			note_back_hover = back_hover_now
			queue_redraw()
		if activate and back_hover_now:
			note_view_active = false
			note_back_hover = false
			message = "La hoja sigue sobre el cofre."
			queue_redraw()
			accept_event()
