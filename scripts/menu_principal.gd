extends PanelContainer

func _on_button_salir_pressed():
	print("Salir")
	get_tree().quit()

func _on_button_jugar_pressed():
	get_tree().change_scene_to_file("res://scenes/game_manager.tscn")
