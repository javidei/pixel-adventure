extends SceneTree

func _initialize() -> void:
	const PATH := "res://data/rooms/demo_room.json"
	if not FileAccess.file_exists(PATH):
		_fail("falta demo_room.json")
		return

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("demo_room.json no es un objeto JSON")
		return

	var data := parsed as Dictionary
	var hotspots: Variant = data.get("hotspots", [])
	if typeof(hotspots) != TYPE_ARRAY or (hotspots as Array).size() < 5:
		_fail("la habitación no contiene suficientes hotspots")
		return

	var required := ["painting", "key", "npc", "chest", "map_piece", "door"]
	var ids: Array[String] = []
	for raw_entry in hotspots as Array:
		if typeof(raw_entry) == TYPE_DICTIONARY:
			ids.append(str((raw_entry as Dictionary).get("id", "")))
	for required_id in required:
		if not ids.has(required_id):
			_fail("falta el hotspot %s" % required_id)
			return

	print("PIXEL ADVENTURE SMOKE OK: escena, datos y puzle base presentes")
	quit(0)


func _fail(reason: String) -> void:
	push_error("PIXEL ADVENTURE SMOKE FAIL: " + reason)
	quit(1)
