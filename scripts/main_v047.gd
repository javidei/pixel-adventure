extends "res://scripts/main_v046.gd"

# 0.4.7: entorno nocturno rehecho y cartografo integrado con retrato transparente.
# Se eliminan las montanas triangulares y los bloques del horizonte para usar
# capas de arboles con parallax, suelo mas organico y un cofre mas detallado.

const FAR_TREE := Color("111a35")
const MID_TREE := Color("152443")
const NEAR_TREE := Color("1c2f45")
const TREE_TRUNK := Color("2a2327")
const GROUND_TOP := Color("4a3a35")
const GROUND_SOIL := Color("362a2a")
const GROUND_DARK_V047 := Color("241f25")
const GRASS_DARK := Color("314538")
const GRASS_LIGHT := Color("526149")
const ROCK_DARK := Color("454651")
const ROCK_LIGHT := Color("676876")

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.4.7", 164, Color("555564"), 6)

func _draw_parallax_horizon() -> void:
	_draw_tree_layer(0.14, 88.0, 44.0, 12, FAR_TREE, 54.0)
	_draw_tree_layer(0.30, 93.0, 38.0, 10, MID_TREE, 47.0)
	_draw_tree_layer(0.50, 98.0, 31.0, 9, NEAR_TREE, 41.0)

func _draw_tree_layer(parallax: float, base_y: float, height: float, count: int, color: Color, spacing: float) -> void:
	var shift := fposmod(camera_x * parallax, spacing)
	for index: int in range(-2, count):
		var x := float(index) * spacing - shift + float((index * 17) % 13)
		var variation := float((index * 11) % 9) - 4.0
		_draw_pine_tree(x, base_y, height + variation, color)

func _draw_pine_tree(x: float, base_y: float, height: float, color: Color) -> void:
	var trunk_top := base_y - height * 0.56
	draw_rect(Rect2(roundf(x - 1.0), roundf(trunk_top), 3, roundf(height * 0.56)), TREE_TRUNK)
	for level: int in range(5):
		var t := float(level) / 4.0
		var y := base_y - height + t * height * 0.72
		var half_width := 5.0 + t * 12.0
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(roundf(x), roundf(y - 3.0)),
				Vector2(roundf(x - half_width), roundf(y + 12.0)),
				Vector2(roundf(x + half_width), roundf(y + 12.0))
			]),
			color
		)

func _draw_world() -> void:
	draw_rect(Rect2(-camera_x, 88, WORLD_WIDTH, 4), GRASS_DARK)
	draw_rect(Rect2(-camera_x, 92, WORLD_WIDTH, 13), GROUND_TOP)
	draw_rect(Rect2(-camera_x, 105, WORLD_WIDTH, 11), GROUND_SOIL)

	for index: int in range(52):
		var sx := float(index * 14 + 5) - camera_x
		if sx < -10.0 or sx > VIEW_WIDTH + 10.0:
			continue
		var grass_y := 90.0 + float((index * 7) % 3)
		if index % 2 == 0:
			draw_rect(Rect2(sx, grass_y, 1, 3), GRASS_LIGHT)
			draw_rect(Rect2(sx + 2, grass_y + 1, 1, 2), GRASS_DARK)
		if index % 4 == 0:
			var rock_y := 99.0 + float((index * 5) % 9)
			draw_rect(Rect2(sx + 3, rock_y, 6, 3), ROCK_DARK)
			draw_rect(Rect2(sx + 4, rock_y, 3, 1), ROCK_LIGHT)
		elif index % 3 == 0:
			draw_rect(Rect2(sx + 4, 102 + (index % 5), 3, 2), GROUND_DARK_V047)

	_draw_ruins()
	_draw_map_panel()
	_draw_campfire()
	_draw_static_cartographer()
	_draw_chest()
	_draw_archway()
	_ui_text(room_title, 5, 10, COL_DIM, 7)
	if bool(state["solved"]):
		_ui_text("PUZLE COMPLETADO", 196, 20, COL_ACTION_ACTIVE, 7)

func _draw_static_cartographer() -> void:
	var x := floorf(365.0 - camera_x)
	if x < -32.0 or x > VIEW_WIDTH + 32.0:
		return

	draw_rect(Rect2(x - 8, 106, 18, 3), Color("171923"))
	draw_rect(Rect2(x - 6, 89, 5, 18), Color("273449"))
	draw_rect(Rect2(x + 2, 89, 5, 18), Color("273449"))
	draw_rect(Rect2(x - 7, 106, 6, 2), Color("10131b"))
	draw_rect(Rect2(x + 2, 106, 6, 2), Color("10131b"))

	draw_texture_rect(
		CARTOGRAPHER_PORTRAIT,
		Rect2(x - 17, 43, 34, 51),
		false
	)

func _draw_chest() -> void:
	var chest_x := 500.0 - camera_x
	var body_y := 91.0

	draw_rect(Rect2(chest_x - 3, 108, 54, 3), Color("17171d"))
	draw_rect(Rect2(chest_x, body_y, 48, 18), Color("4a2b25"))
	draw_rect(Rect2(chest_x + 2, body_y + 2, 44, 14), Color("75442d"))
	draw_rect(Rect2(chest_x + 3, body_y + 4, 42, 2), Color("9a633c"))
	draw_rect(Rect2(chest_x + 3, body_y + 9, 42, 2), Color("5d3428"))
	draw_rect(Rect2(chest_x + 3, body_y + 14, 42, 1), Color("a46a45"))

	draw_rect(Rect2(chest_x + 5, body_y + 1, 3, 16), Color("393640"))
	draw_rect(Rect2(chest_x + 40, body_y + 1, 3, 16), Color("393640"))
	draw_rect(Rect2(chest_x + 21, body_y + 4, 7, 8), Color("b28b46"))
	draw_rect(Rect2(chest_x + 23, body_y + 6, 3, 5), Color("e0b75c"))
	draw_rect(Rect2(chest_x + 24, body_y + 8, 1, 3), Color("554125"))

	var lid_y := 84.0 - roundf(chest_open_progress * 10.0)
	var lid_h := maxf(5.0, 9.0 - roundf(chest_open_progress * 2.0))
	draw_rect(Rect2(chest_x + 1, lid_y, 46, lid_h), Color("442723"))
	draw_rect(Rect2(chest_x + 3, lid_y + 1, 42, maxf(3.0, lid_h - 2.0)), Color("865033"))
	draw_rect(Rect2(chest_x + 5, lid_y + 2, 38, 2), Color("b07146"))
	draw_rect(Rect2(chest_x + 1, lid_y + lid_h - 1, 46, 2), Color("35333a"))

	if chest_open_progress > 0.38:
		draw_rect(Rect2(chest_x + 4, 87, 40, 5), Color("151318"))
		draw_rect(Rect2(chest_x + 7, 88, 34, 1), Color("30231e"))

	if bool(state["chest_open"]) and chest_open_progress >= 0.72 and not bool(state["map_taken"]):
		draw_rect(Rect2(chest_x + 17, 82, 14, 7), Color("d7c38a"))
		draw_rect(Rect2(chest_x + 20, 83, 8, 1), Color("e95355"))
