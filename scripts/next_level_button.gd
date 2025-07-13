extends PanelContainer

func _on_button_pressed():
	FuncionesTilesMario.actualizar_world(1)
	get_tree().change_scene_to_file("res://scenes/game_manager.tscn")
