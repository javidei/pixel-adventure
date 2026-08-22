extends "res://scripts/main_v054.gd"

# 0.5.5: cuando Pixel Adventure se abre desde Entre líneas, el portal cierra
# realmente la pestaña creada por el juego principal en vez de dejar about:blank.

func _exit_game() -> void:
	if not OS.has_feature("web"):
		get_tree().quit()
		return

	var close_script := """
(() => {
	const params = new URLSearchParams(window.location.search);
	const fromEntreLineas = params.get('source') === 'entre-lineas';

	if (fromEntreLineas) {
		try {
			if (window.opener && !window.opener.closed) {
				window.opener.focus();
				if (window.opener.__pixelAdventureTab && !window.opener.__pixelAdventureTab.closed) {
					window.opener.__pixelAdventureTab.close();
					return;
				}
			}
		} catch (_error) {}

		window.close();
		return;
	}

	if (window.history.length > 1) {
		window.history.back();
		return;
	}

	window.close();
})();
"""
	JavaScriptBridge.eval(close_script, true)


func _draw_intro() -> void:
	draw_rect(Rect2(0, 0, VIEW_WIDTH, VIEW_HEIGHT), Color.BLACK)
	_comm_center("BIENVENIDO A", 52, Color("918a9c"), 8)
	_comm_center("NARANJAL DEL RIO", 82, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA COMENZAR", 114, COL_GOLD, 8)
	_comm_center("PIXEL ADVENTURE - PROTOTIPO 0.5.5", 164, Color("555564"), 6)
