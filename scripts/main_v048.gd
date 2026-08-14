extends "res://scripts/main_v046.gd"

# 0.4.8: primera separación real de arte y lógica.
# El escenario usa capas PNG independientes; NPC y cofre usan sprites externos.
# El retrato de conversación usa la imagen aprobada adjunta por el usuario.

const BG_FAR: Texture2D = preload("res://assets/backgrounds/demo_room/trees_far.png")
const BG_MID: Texture2D = preload("res://assets/backgrounds/demo_room/trees_mid.png")
const BG_NEAR: Texture2D = preload("res://assets/backgrounds/demo_room/trees_near.png")
const BG_GROUND: Texture2D = preload("res://assets/backgrounds/demo_room/ground.png")

const NPC_IDLE_0: Texture2D = preload("res://assets/sprites/cartographer/world/idle_0.png")
const NPC_IDLE_1: Texture2D = preload("res://assets/sprites/cartographer/world/idle_1.png")
const NPC_TALK_0: Texture2D = preload("res://assets/sprites/cartographer/world/talk_0.png")
const NPC_TALK_1: Texture2D = preload("res://assets/sprites/cartographer/world/talk_1.png")

const CHEST_CLOSED: Texture2D = preload("res://assets/sprites/chest/chest_closed.png")
const CHEST_OPENING: Texture2D = preload("res://assets/sprites/chest/chest_opening.png")
const CHEST_OPEN: Texture2D = preload("res://assets/sprites/chest/chest_open.png")

const CARTOGRAPHER_DIALOGUE_PORTRAIT: Texture2D = preload("res://assets/characters/cartographer_portrait_v048.png")

func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.4.8", 164, Color("555564"), 6)

func _draw_parallax_horizon() -> void:
	# Cada capa es una imagen independiente de 680x116 px.
	draw_texture(BG_FAR, Vector2(-floorf(camera_x * 0.14), 0))
	draw_texture(BG_MID, Vector2(-floorf(camera_x * 0.30), 0))
	draw_texture(BG_NEAR, Vector2(-floorf(camera_x * 0.50), 0))

func _draw_world() -> void:
	# El suelo también queda separado del código como una tira de 680x28 px.
	draw_texture(BG_GROUND, Vector2(-floorf(camera_x), 88))
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
	# Recupera el aspecto sencillo anterior, pero ya como sprite PNG.
	var x := floorf(365.0 - camera_x)
	if x < -28.0 or x > VIEW_WIDTH + 28.0:
		return
	var now := int(Time.get_ticks_msec())
	var texture := NPC_IDLE_0
	if dialogue_mode == "simple":
		texture = NPC_TALK_0 if int(now / 180) % 2 == 0 else NPC_TALK_1
	else:
		texture = NPC_IDLE_0 if int(now / 850) % 2 == 0 else NPC_IDLE_1
	draw_texture(texture, Vector2(x - 12.0, 61.0))

func _draw_chest() -> void:
	var chest_x := 500.0 - camera_x
	var texture := CHEST_CLOSED
	if chest_open_progress >= 0.72:
		texture = CHEST_OPEN
	elif chest_open_progress > 0.08:
		texture = CHEST_OPENING
	draw_texture(texture, Vector2(chest_x - 4.0, 79.0))
	if bool(state["chest_open"]) and chest_open_progress >= 0.72 and not bool(state["map_taken"]):
		draw_rect(Rect2(chest_x + 17, 82, 14, 7), Color("d7c38a"))
		draw_rect(Rect2(chest_x + 20, 83, 8, 1), Color("e95355"))

func _draw_cartographer_portrait() -> void:
	# Imagen aprobada por el usuario, con fondo transparente.
	draw_texture_rect(
		CARTOGRAPHER_DIALOGUE_PORTRAIT,
		Rect2(4, 2, 76, 114),
		false
	)
