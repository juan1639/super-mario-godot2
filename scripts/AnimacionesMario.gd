extends Node

# GESTIONAR-ANIMACIONES-JUGADOR:
func update_animation(context):
	if GlobalValues.estado_juego["transicion_flag_pole"]:
		context.sprite.play("FlagPole")
		return
	
	if GlobalValues.estado_juego["transicion_vida_menos"]:
		context.sprite.play("LoseLife")
		return
	
	if not context.is_on_floor():
		context.sprite.play("Jump")
	elif context.velocity.x != 0:
		context.sprite.play("Walk")
	else:
		context.sprite.play("Idle")
