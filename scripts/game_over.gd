extends PanelContainer

func _on_button_pressed():
	GlobalValues.marcadores["world"][0] = 1
	GlobalValues.marcadores["world"][1] = 1
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
