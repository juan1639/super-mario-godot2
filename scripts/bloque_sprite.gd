extends CharacterBody2D

@onready var area2D = $Area2D

func _ready():
	area2D.connect("body_entered", _on_area2d_body_entered)

func _on_area2d_body_entered(body):
	if body.has_method("_on_bloque_sprite_body_entered"):
		body._on_bloque_sprite_body_entered(body)
