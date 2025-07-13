extends Node

# MOVIMIENTO HORIZONTAL MARIO:
func movimiento_horizontal(delta, context):
	var input_direccion = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input_direccion != 0:
		context.velocity.x = move_toward(context.velocity.x, input_direccion * context.VEL_MAX, context.ACELERACION * delta)
		context.sprite.flip_h = input_direccion < 0
	else:
		context.velocity.x = move_toward(context.velocity.x, 0, context.DECELERACION * delta)

# SALTO MARIO:
func salto_jugador(delta, context):
	if context.is_on_floor() and Input.get_action_strength("ui_accept"):
		context.salto["presionado"] = true
		context.salto["tiempo"] = 0.0
		context.sonido_salto.play()
		
		# SALTO BASE + impulso adicional
		var impulso_extra = abs(context.velocity.x) * 0.5
		context.velocity.y = context.POTENCIA_SALTO - impulso_extra
		context.cpuParticles.emitting = true
		context.cpuParticles.global_position = context.global_position + Vector2(0, 16)
	
	if context.salto["presionado"]:
		context.salto["tiempo"] += delta
		
		if Input.get_action_strength("ui_accept") and context.salto["tiempo"] < context.DURACION_SALTO_EXTRA and not context.is_on_ceiling():
			context.velocity.y += context.SALTO_EXTRA * delta
		else:
			context.salto["presionado"] = false

# CHECK WORLD-BOTTOM-LIMIT:
func check_world_bottom_limit(context):
	if context.global_position.y > GlobalValues.BOTTOM_LIMIT:
		#reset_position(context)
		context.actions_lose_life()

# WORLD CLAMPS:
func aplicar_clamps(context):
	# CLAMP Velocity.y:
	context.velocity.y = clamp(context.velocity.y, -500, 500)
	
	# CHECK WORLD-LIMITS-HOR:
	context.global_position.x = clamp(context.global_position.x, GlobalValues.LIMITE_IZ, GlobalValues.LIMITE_DE)

# RESETEAR-RESPAWNEAR JUGADOR A SU POSICION INICIAL:
func reset_position(context):
	print(context.global_position)
	
	if context.global_position.x < context.CHECK_POINT_MIDDLE.x or GlobalValues.estado_juego["prejuego"]:
		context.global_position = context.RESPAWN_POSITION
		respawn_position_exceptions(context)
	else:
		context.global_position = context.RESPAWN_MIDDLE_WORLD
	
	context.velocity = Vector2.ZERO
	context.sprite.flip_h = false

func respawn_position_exceptions(context):
	if GlobalValues.marcadores["world"][1] == 2:
		context.global_position = context.RESPAWN_POSITION_UNDERGROUND
