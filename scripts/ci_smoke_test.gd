extends SceneTree

func _initialize() -> void:
	const PATH := "res://data/rooms/demo_room.json"
	const ONESR_PATH := "res://assets/fonts/ONESR___.TTF"
	const ORANGE_TREE_PATH := "res://assets/sprites/props/orange_tree.png"
	const KEY_SPRITE_PATH := "res://assets/sprites/items/key_ground.png"

	if not FileAccess.file_exists(PATH):
		_fail("falta demo_room.json")
		return

	if not FileAccess.file_exists(ONESR_PATH):
		_fail("falta ONESR___.TTF")
		return

	if not FileAccess.file_exists(ORANGE_TREE_PATH):
		_fail("falta orange_tree.png")
		return

	if not FileAccess.file_exists(KEY_SPRITE_PATH):
		_fail("falta key_ground.png")
		return

	var font_bytes := FileAccess.get_file_as_bytes(ONESR_PATH)
	if font_bytes.size() < 9000:
		_fail("ONESR___.TTF esta truncada: %d bytes" % font_bytes.size())
		return

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("demo_room.json no es un objeto JSON")
		return

	var data := parsed as Dictionary
	var hotspots: Variant = data.get("hotspots", [])
	if typeof(hotspots) != TYPE_ARRAY or (hotspots as Array).size() < 5:
		_fail("la habitacion no contiene suficientes hotspots")
		return

	var required := ["key", "npc", "chest", "map_piece", "door"]
	var ids: Array[String] = []
	for raw_entry in hotspots as Array:
		if typeof(raw_entry) == TYPE_DICTIONARY:
			ids.append(str((raw_entry as Dictionary).get("id", "")))
	for required_id in required:
		if not ids.has(required_id):
			_fail("falta el hotspot %s" % required_id)
			return

	if ids.has("painting"):
		_fail("el hotspot painting ya no debe existir en 0.5.3")
		return

	print("PIXEL ADVENTURE SMOKE OK: ONESR=%d bytes, naranjo, llave y puzle 0.5.3 presentes" % font_bytes.size())
	quit(0)

func _fail(reason: String) -> void:
	push_error("PIXEL ADVENTURE SMOKE FAIL: " + reason)
	quit(1)
