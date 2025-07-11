extends Node

# =================================================================
# 	T R A N S I C I O N E S
# -----------------------------------------------------------------
func transicion_flag_pole(delta, context):
	if not GlobalValues.estado_juego["transicion_flag_pole"]:
		return
	
	FuncionesGenerales.aplicar_gravedad_leve(delta, context)
	check_start_go_goal_zone(context)
	context.move_and_slide()
	AnimacionesMario.update_animation(context)

func transicion_goal_zone(delta, context):
	if not GlobalValues.estado_juego["transicion_goal_zone"]:
		return
	
	FuncionesGenerales.aplicar_gravedad(delta, context)
	context.move_and_slide()
	AnimacionesMario.update_animation(context)
	FuncionesMovSaltoMario.aplicar_clamps(context)

func transicion_vida_menos(delta, context):
	if not GlobalValues.estado_juego["transicion_vida_menos"]:
		return
	
	FuncionesGenerales.aplicar_gravedad(delta, context)
	context.move_and_slide()
	AnimacionesMario.update_animation(context)
	FuncionesMovSaltoMario.aplicar_clamps(context)
	
	if GlobalValues.marcadores["lives"] <= 0:
		print("señal gameover")
		FuncionesGenerales.reset_estados_cambio_estado_a("game_over")
		FuncionesGenerales.emitir_signal_gameover()
		return
	
	if context.timerTransicionVidaMenos.time_left == 0.0 and GlobalValues.estado_juego["transicion_vida_menos"]:
		context.timerTransicionVidaMenos.start(2.1)
		context.panelTimeup.visible = false
		FuncionesGenerales.reset_estados_cambio_estado_a("transicion_next_vida")
		FuncionesMovSaltoMario.reset_position(context)
		context.panelShowVidas.visible = true if not GlobalValues.estado_juego["game_over"] else false
		return

func transicion_fireworks(delta, context):
	if not GlobalValues.estado_juego["transicion_fireworks"]:
		return
	
	context.procesar_bonus_tiempo(delta)

func fireworks(delta, context):
	if not GlobalValues.estado_juego["fireworks"]:
		return
	
	#print("Fireworks instancia agregada:", is_instance_valid(fireworks))
	FuncionesGenerales.aplicar_gravedad(delta, context)
	context.move_and_slide()

func transicion_next_vida(delta, context):
	if not GlobalValues.estado_juego["transicion_next_vida"]:
		return
	
	FuncionesGenerales.aplicar_gravedad(delta, context)
	context.move_and_slide()
	AnimacionesMario.update_animation(context)
	
	if context.timerTransicionVidaMenos.time_left == 0.0:
		FuncionesGenerales.reset_estados_cambio_estado_a("en_juego")
		context.panelShowVidas.visible = false
		context.musica_fondo.play()

func en_juego(delta, context):
	if not GlobalValues.estado_juego["en_juego"]:
		return
	
	FuncionesGenerales.aplicar_gravedad(delta, context)
	FuncionesMovSaltoMario.movimiento_horizontal(delta, context)
	FuncionesMovSaltoMario.salto_jugador(delta, context)
	FuncionesMovSaltoMario.aplicar_clamps(context)
	FuncionesMovSaltoMario.check_world_bottom_limit(context)
	context.move_and_slide()
	AnimacionesMario.update_animation(context)
	FuncionesTilesMario.identificar_tile(context.global_position, context.salto, context.timer, context.sonido_coin)
	FuncionesGenerales.efecto_intermitente_invulnerable(delta, context)
	context.check_timeup(delta)

func otros_estados(delta, context):
	for estado in context.lista_estados_transiciones:
		if GlobalValues.estado_juego[estado]:
			return
	
	FuncionesGenerales.aplicar_gravedad(delta, context)
	context.move_and_slide()

# ================================================================
# 	FUNCIONES AUXILIARES MARIO
#-----------------------------------------------------------------
# CHECK START-GO-GOAL-ZONE:
func check_start_go_goal_zone(context):
	if context.is_on_floor():
		context.velocity = Vector2(abs(context.VEL_MAX / 9), 0)
		FuncionesGenerales.reset_estados_cambio_estado_a("transicion_goal_zone")

# SELECT BONUS BANDERA (En funcion de la altura alcanzada):
func select_bonus_bandera(context):
	if context.altura_alcanzada.y < 60:
		return 5000
	elif context.altura_alcanzada.y < 95:
		return 2000
	elif context.altura_alcanzada.y < 150:
		return 800
	return 400
