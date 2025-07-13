extends Node2D

@onready var plataformas = get_node("Plataformas")

# VELOCIDAD DE LAS PLATAFORMAS:
const VEL_PLATAFORMA = 40

func _ready():
	for plataf in plataformas.get_children():
		plataf.velocity = Vector2(0, -VEL_PLATAFORMA)

func _physics_process(delta):
	for plataf in plataformas.get_children():
		plataf.move_and_slide()
		
		if plataf.global_position.y < 0:
			plataf.global_position.y = 280
