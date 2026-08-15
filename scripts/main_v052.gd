extends "res://scripts/main_v051.gd"

# 0.5.2: diálogo corto centrado sobre el NPC y rediseño visual de la UI inferior.
# El texto corto usa todo el ancho disponible y la sección negra baja 16 px.
# Verbos, estado e inventario usan Windows Regular, conservando sus colores.

const UI_VISUAL_TOP := 132.0
const UI_STATUS_BASELINE := 139.0
const BLACK_UI_FONT_SIZE := 7
const SIMPLE_DIALOGUE_MAX_WIDTH := 296.0

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.5.2", 164, Color("555564"), 6)

func _draw_simple_dialogue() -> void:
	var combined := ""
	for raw_line in simple_lines:
		if not combined.is_empty():
			combined += " "
		combined += _natural_text(str(raw_line))

	var lines := _wrap_dialogue_text(combined, SIMPLE_DIALOGUE_MAX_WIDTH)
	if lines.is_empty():
		return

	# Se coloca siempre por encima de la cabeza del Cartógrafo. Cada línea se
	# centra de forma independiente para que dos líneas queden equilibradas.
	var y := 32.0 if lines.size() == 1 else 27.0
	for line in lines:
		var width := _text_width_with_fallback(
			line,
			NORMAL_DIALOGUE_FONT,
			UI_FONT,
			COMMODORE_FONT,
			NPC_DIALOGUE_SIZE
		)
		var x := floorf((VIEW_WIDTH - width) * 0.5)
		_npc_text(line, x, y, NPC_DIALOGUE_FILL, NPC_DIALOGUE_SIZE)
		y += NPC_DIALOGUE_LINE_HEIGHT

func _draw_classic_ui() -> void:
	# La zona jugable gana 16 px visuales hacia abajo. Se prolonga el tramo
	# inferior del suelo para que la separación no se vea como una banda vacía.
	draw_texture_rect_region(
		BG_GROUND,
		Rect2(0, ROOM_BOTTOM, VIEW_WIDTH, UI_VISUAL_TOP - ROOM_BOTTOM),
		Rect2(floorf(camera_x), 12, VIEW_WIDTH, UI_VISUAL_TOP - ROOM_BOTTOM)
	)

	draw_rect(Rect2(0, UI_VISUAL_TOP, VIEW_WIDTH, VIEW_HEIGHT - UI_VISUAL_TOP), Color.BLACK)

	_black_ui_text(message, 5, UI_STATUS_BASELINE, COL_STATUS, BLACK_UI_FONT_SIZE)

	for index: int in range(VERBS.size()):
		var rect := _verb_rect(index)
		var active := VERBS[index] == selected_verb
		_black_ui_text(
			VERBS[index],
			rect.position.x,
			rect.position.y + 8,
			COL_ACTION_ACTIVE if active else COL_ACTION,
			BLACK_UI_FONT_SIZE
		)

	var visible_count := mini(INVENTORY_PAGE_SIZE, inventory.size())
	if inventory.is_empty():
		_black_ui_text("(VACIO)", 196, 150, Color("8f4b87"), BLACK_UI_FONT_SIZE)
	else:
		for local_index: int in range(visible_count):
			var actual_index := inventory_scroll + local_index
			if actual_index >= inventory.size():
				actual_index -= inventory.size()
			var item := inventory[actual_index]
			var active_item := item == selected_item
			var rect := _inventory_item_rect(local_index)
			_black_ui_text(
				item,
				rect.position.x + 6,
				rect.position.y + 8,
				COL_INVENTORY_ACTIVE if active_item else COL_INVENTORY,
				BLACK_UI_FONT_SIZE
			)

	if inventory.size() > INVENTORY_PAGE_SIZE:
		_draw_inventory_arrow()

func _black_ui_text(text: String, x: float, y: float, color: Color, size: int) -> void:
	# Misma tipografía que las respuestas del diálogo importante: Windows Regular
	# con fallback automático para caracteres que la fuente no incluya.
	_response_text(text, x, y, color, size)

func _verb_rect(index: int) -> Rect2:
	var column := index % 3
	var row := int(index / 3)
	return Rect2(8 + column * 57, 142 + row * 13, 52, 11)

func _inventory_item_rect(index: int) -> Rect2:
	return Rect2(190, 142 + index * 9, 112, 9)

func _inventory_arrow_rect() -> Rect2:
	return Rect2(302, 165, 14, 12)
