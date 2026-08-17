extends "res://scripts/main_v053.gd"

# 0.5.4: el protagonista usa los 14 sprites subidos a player/world.
# 01 = idle; 02..07 = seis frames de caminar.

const PLAYER_IDLE_RIGHT: Texture2D = preload("res://assets/sprites/player/world/sprite_01_derecha.png")
const PLAYER_IDLE_LEFT: Texture2D = preload("res://assets/sprites/player/world/sprite_01_izquierda.png")
const PLAYER_WALK_RIGHT_0: Texture2D = preload("res://assets/sprites/player/world/sprite_02_derecha.png")
const PLAYER_WALK_RIGHT_1: Texture2D = preload("res://assets/sprites/player/world/sprite_03_derecha.png")
const PLAYER_WALK_RIGHT_2: Texture2D = preload("res://assets/sprites/player/world/sprite_04_derecha.png")
const PLAYER_WALK_RIGHT_3: Texture2D = preload("res://assets/sprites/player/world/sprite_05_derecha.png")
const PLAYER_WALK_RIGHT_4: Texture2D = preload("res://assets/sprites/player/world/sprite_06_derecha.png")
const PLAYER_WALK_RIGHT_5: Texture2D = preload("res://assets/sprites/player/world/sprite_07_derecha.png")
const PLAYER_WALK_LEFT_0: Texture2D = preload("res://assets/sprites/player/world/sprite_02_izquierda.png")
const PLAYER_WALK_LEFT_1: Texture2D = preload("res://assets/sprites/player/world/sprite_03_izquierda.png")
const PLAYER_WALK_LEFT_2: Texture2D = preload("res://assets/sprites/player/world/sprite_04_izquierda.png")
const PLAYER_WALK_LEFT_3: Texture2D = preload("res://assets/sprites/player/world/sprite_05_izquierda.png")
const PLAYER_WALK_LEFT_4: Texture2D = preload("res://assets/sprites/player/world/sprite_06_izquierda.png")
const PLAYER_WALK_LEFT_5: Texture2D = preload("res://assets/sprites/player/world/sprite_07_izquierda.png")

const PLAYER_DRAW_HEIGHT := 64.0
const PLAYER_BASELINE_Y := 109.0
const PLAYER_WALK_FRAME_TIME := 0.105

var player_facing_right := true
var player_walk_frame := 0
var player_walk_clock := 0.0

func _process(delta: float) -> void:
	if dialogue_mode == "none":
		if player_target_x > player_x + 0.1:
			player_facing_right = true
		elif player_target_x < player_x - 0.1:
			player_facing_right = false

	var previous_x := player_x
	super._process(delta)

	var walking_now := dialogue_mode == "none" and absf(player_x - previous_x) > 0.001
	if walking_now:
		player_walk_clock += delta
		while player_walk_clock >= PLAYER_WALK_FRAME_TIME:
			player_walk_clock -= PLAYER_WALK_FRAME_TIME
			player_walk_frame = (player_walk_frame + 1) % 6
			queue_redraw()
	else:
		if player_walk_frame != 0 or player_walk_clock != 0.0:
			player_walk_frame = 0
			player_walk_clock = 0.0
			queue_redraw()

func _draw_player() -> void:
	var moving := dialogue_mode == "none" and absf(player_x - player_target_x) > 0.9
	var texture := _player_texture(moving)
	var source_rect := _player_source_rect(moving)
	var scale_factor := PLAYER_DRAW_HEIGHT / source_rect.size.y
	var draw_width := maxf(1.0, roundf(source_rect.size.x * scale_factor))
	var screen_x := floorf(player_x - camera_x)
	var destination := Rect2(
		floorf(screen_x - draw_width * 0.5),
		floorf(PLAYER_BASELINE_Y - PLAYER_DRAW_HEIGHT),
		draw_width,
		PLAYER_DRAW_HEIGHT
	)
	draw_texture_rect_region(texture, destination, source_rect)

func _player_texture(moving: bool) -> Texture2D:
	if not moving:
		return PLAYER_IDLE_RIGHT if player_facing_right else PLAYER_IDLE_LEFT
	if player_facing_right:
		match player_walk_frame:
			0: return PLAYER_WALK_RIGHT_0
			1: return PLAYER_WALK_RIGHT_1
			2: return PLAYER_WALK_RIGHT_2
			3: return PLAYER_WALK_RIGHT_3
			4: return PLAYER_WALK_RIGHT_4
			_: return PLAYER_WALK_RIGHT_5
	match player_walk_frame:
		0: return PLAYER_WALK_LEFT_0
		1: return PLAYER_WALK_LEFT_1
		2: return PLAYER_WALK_LEFT_2
		3: return PLAYER_WALK_LEFT_3
		4: return PLAYER_WALK_LEFT_4
		_: return PLAYER_WALK_LEFT_5

func _player_source_rect(moving: bool) -> Rect2:
	if not moving:
		return Rect2(386, 10, 499, 1184) if player_facing_right else Rect2(193, 0, 571, 1404)
	match player_walk_frame:
		0: return Rect2(8, 8, 173, 451)
		1: return Rect2(8, 8, 188, 458)
		2: return Rect2(8, 8, 310, 449)
		3: return Rect2(8, 8, 171, 448)
		4: return Rect2(8, 8, 245, 453)
		_: return Rect2(8, 8, 255, 444)

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.5.4", 164, Color("555564"), 6)
