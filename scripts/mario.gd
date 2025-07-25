extends CharacterBody2D

# QUE MUSICA DEBE SONAR:
var musica = null

# VELOCIDAD HORIZONAL
const VEL_MAX = 197.0
const ACELERACION = 175.0
const DECELERACION = 230.0

# SALTO Y GRAVEDAD:
const POTENCIA_SALTO = -250.0
const SALTO_EXTRA = -280.0
const DURACION_SALTO_EXTRA = 0.4

var acel_gravedad = 0.0

var salto = {
	"presionado": false,
	"tiempo": 0.0
}

# BONUS BANDERA:
var altura_alcanzada = Vector2.ZERO

# INVULNERABLE:
var invulnerability = false

# RESPAWN-POSITION:
const RESPAWN_POSITION = Vector2(96, 176)
const RESPAWN_MIDDLE_WORLD = Vector2(1650, 176)
const CHECK_POINT_MIDDLE = Vector2(1550, 176)

const RESPAWN_POSITION_UNDERGROUND_2 = Vector2(64, 0)
const RESPAWN_POSITION_UNDERGROUND = Vector2(112, -48)

var bandera_underground = false

# BONUS DE TIEMPO:
var tiempo_tick_acumulado := 0.0
const INTERVALO_TICK_TIEMPO := 0.05  # Cada cuánto bajar 1 segundo (en segundos)
const PUNTOS_POR_SEGUNDO := 50

# REFERENCIAS:
@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var camera_2 = $Camera2D2
@onready var cpuParticles = $CPUParticles2D
@onready var cpuParticlesFireworks = preload("res://scenes/fireworks.tscn")
#@onready var goomba_scene = preload("res://scenes/goomba.tscn")
@onready var panelShowVidas = $CanvasLayer/PanelContainer
@onready var panelTimeup = $CanvasLayer/PanelTimeup
@onready var timer = $Timer
@onready var timerColision = $TimerColision
@onready var timerTransicionVidaMenos = $TimerTransicionVidaMenos
@onready var timerEntrarTuberia = $TimerEntrarTuberia
@onready var timerEstrella = $TimerEstrella
@onready var sonido_salto = $SonidoSalto
@onready var sonido_coin = $SonidoCoin
@onready var sonido_lose_life = $SonidoLoseLife
@onready var sonido_aplastar = $SonidoAplastar
@onready var sonido_bonus_level_up = $SonidoBonusLevelUp
@onready var sonido_impacto = $SonidoImpacto
@onready var sonido_entrar_tuberia = $SonidoEntrarTuberia
@onready var musica_level_up = $MusicaLevelUp
@onready var musica_estrella = $MusicaEstrella
@onready var musica_fondo = $MusicaFondo
@onready var musica_fondo_under = $MusicaFondoUnderground
@onready var musica_gameover = $MusicaGameover

# REFERENCIAS OTRAS ESCENAS:
var fireworks: Node2D = null
var array_desactivar_goombas_paracaidas = []

# LISTA ESTADOS TRANSICIONES Y EN-JUEGO:
var lista_estados_transiciones = [
	"en_juego",
	"transicion_flag_pole",
	"transicion_goal_zone",
	"transicion_vida_menos",
	"transicion_next_vida",
	"transicion_fireworks",
	"fireworks"
]

# FUNCION INICIALIZADORA:
func _ready():
	#print("Instancia Mario")
	bandera_underground = false
	seleccionar_inicio_mario()
	FuncionesMovSaltoMario.reset_position(self, bandera_underground)
	sonido_salto.volume_db = -20.0
	GlobalValues.marcadores["time"] = GlobalValues.TIEMPO_INICIAL
	timer.start(0.2)
	timerColision.start(0.1)
	timerTransicionVidaMenos.start(3.1)
	timerEstrella.connect("timeout", _on_timer_timeout_estrella)
	seleccionar_musica()
	musica.play()

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	FuncionesAuxiliaresMario.inicio_fase_underground(delta, self)
	FuncionesAuxiliaresMario.transicion_flag_pole(delta, self)
	FuncionesAuxiliaresMario.transicion_goal_zone(delta, self)
	FuncionesAuxiliaresMario.transicion_vida_menos(delta, self)
	FuncionesAuxiliaresMario.transicion_fireworks(delta, self)
	FuncionesAuxiliaresMario.fireworks(delta, self)
	FuncionesAuxiliaresMario.transicion_next_vida(delta, self)
	FuncionesAuxiliaresMario.en_juego(delta, self)
	FuncionesAuxiliaresMario.otros_estados(delta, self)

# SELECCIONAR INICIOS DIFERENTES (FASES UNDERGROUND, ETC.):
func seleccionar_inicio_mario():
	camera.enabled = false if GlobalValues.marcadores["world"][1] == 2 else true
	camera_2.enabled = true if GlobalValues.marcadores["world"][1] != 2 else true
	
	if GlobalValues.marcadores["world"][1] == 2:
		FuncionesGenerales.reset_estados_cambio_estado_a("inicio_fase_underground")
	else:
		FuncionesGenerales.reset_estados_cambio_estado_a("en_juego")

# ----------------------------------------------------------------
#	S E Ñ A L E S
# ----------------------------------------------------------------
# MARIO FALL-ZONES:
func _on_fall_zone_body_entered(body):
	if body == self and GlobalValues.estado_juego["en_juego"]:
		actions_lose_life()

func _on_entrar_tuberia_body_entered(body):
	if body == self:
		print("entrar-tuberia")
		sonido_entrar_tuberia.play()
		timerEntrarTuberia.start(1.5)

# TRANSICIONAR DE ENTRAR-TUBERIA A ESTADO EN_JUEGO:
func _on_timer_entrar_tuberia_timeout():
	FuncionesGenerales.reset_estados_cambio_estado_a("en_juego")
	camera_2.enabled = false
	camera.enabled = true
	global_position = RESPAWN_POSITION_UNDERGROUND_2
	musica.stop()
	musica = musica_fondo_under
	musica.play()

# BAJADA DE BANDERA:
func _on_flag_pole_body_entered(body):
	if body == self:
		print("bonus-bandera:", global_position)
		altura_alcanzada = global_position
		FuncionesTilesMario.agregar_puntos(FuncionesAuxiliaresMario.select_bonus_bandera(self), altura_alcanzada)
		call_deferred("velocity_zero")
		salto["presionado"] = false
		FuncionesGenerales.reset_estados_cambio_estado_a("transicion_flag_pole")
		musica.stop()
		musica_level_up.play()
		var tween = create_tween()
		var bottom_pos = GlobalValues.flag_sprite.global_position + Vector2(0, 128) # 128 = posY bandera suelo
		tween.tween_property(GlobalValues.flag_sprite, "global_position", bottom_pos, 2.1)

# DESAPARECER POR LA PUERTA DEL CASITLLO:
func _on_goal_zone_body_entered(body):
	if body == self:
		print("goal - emitir señal next-level")
		velocity = Vector2.ZERO
		sprite.visible = false
		FuncionesGenerales.emitir_signal_next_level()
		FuncionesGenerales.reset_estados_cambio_estado_a("transicion_fireworks")
		sonido_bonus_level_up.play()

# ZONA INSTANCIA GOOMBA-PARACAIDAS:
func _on_instancia_paracaidas_body_entered(body, zone):
	if body == self and GlobalValues.estado_juego["en_juego"]:
		print("instancia paracaidas", zone.name)
		if zone.name in array_desactivar_goombas_paracaidas:
			return
		
		array_desactivar_goombas_paracaidas.append(zone.name)
		GlobalValues.game_manager_node.call_deferred("instanciar_goomba_paracaidas")

# COLISION VS ESTRELLA (INVULNERAB):
func _on_estrella_body_entered(body):
	if body == self:
		print("Invulnerable!")
		invulnerability = true
		timerEstrella.start(GlobalValues.DURACION_ESTRELLA)
		musica.stop()
		musica_estrella.play()
		# LA DESPLAZAMOS MUY ABAJO PARA QUE SE DETECTE BOTTOM-LIMIT Y DESACTIVARLA:
		GlobalValues.estrellaSprite.global_position += Vector2(0, 9990)

# COLISION VS GOOMBA (LOSE LIFE):
func _on_goomba_body_entered(body, goomba):
	if timerColision.time_left > 0:
		return
	
	if body == self and GlobalValues.estado_juego["en_juego"] and not goomba.aplastado:
		if invulnerability and not goomba.is_dying_not_aplastado:
			goomba.is_dying_not_aplastado = true
			goomba.timerGoombaAplastado.start(0.4)
			goomba.velocity.y = -200
			FuncionesTilesMario.agregar_puntos(200, global_position)
			sonido_impacto.play()
			return
		elif not invulnerability:
			velocity = Vector2(0, POTENCIA_SALTO * 2)
			actions_lose_life()

# COLISION VS GOOMBA (APLASTAR-GOOMBA):
func _on_aplastar_goomba_body_entered(body, goomba):
	if invulnerability:
		return
	
	if body == self and GlobalValues.estado_juego["en_juego"] and not goomba.aplastado:
		timerColision.start(0.1)
		goomba.aplastado = true
		goomba.velocity.x = 0
		goomba.timerGoombaAplastado.start(0.8)
		velocity = Vector2(velocity.x, POTENCIA_SALTO * 2.8)
		FuncionesTilesMario.agregar_puntos(100, global_position)
		sonido_aplastar.play()

# CHECK TIMEOUT ESTRELLA (y FIREWORKS):
func _on_timer_timeout_estrella():
	if GlobalValues.estado_juego["fireworks"]:
		fireworks = cpuParticlesFireworks.instantiate()
		add_child(fireworks)
		fireworks.get_child(0).emitting = true
		fireworks.get_child(1).emitting = true
		var rnd_position = Vector2(randf_range(3120 , 3350), randf_range(75, 150))
		fireworks.get_child(0).global_position = rnd_position
		fireworks.get_child(1).global_position = rnd_position
		fireworks.get_child(0).z_index = -1
		fireworks.get_child(1).z_index = -1
		fireworks.get_child(1).modulate = Color(1, 1, 1, 0.6)
		timerEstrella.start(2.1)
	else:
		print("Timeup invulnerabilidad")
		invulnerability = false
		modulate = Color(1, 1, 1, 1)
		musica_estrella.stop()
		musica.play()

# ACCIONES AL PERDER VIDA:
func actions_lose_life():
	FuncionesGenerales.reset_estados_cambio_estado_a("transicion_vida_menos")
	GlobalValues.marcadores["lives"] -= 1
	invulnerability = false
	GlobalValues.marcadores["time"] = GlobalValues.TIEMPO_INICIAL
	
	var newText = "x " + str(GlobalValues.marcadores["lives"])
	panelShowVidas.get_child(0).get_child(0).get_child(1).text = newText
	#panelShowVidasMiddle.get_child(0).get_child(0).get_child(1).text = newText
	
	timerTransicionVidaMenos.start(3.1)
	
	musica.stop()
	
	if GlobalValues.marcadores["lives"] <= 0:
		musica_gameover.play()
	else:
		sonido_lose_life.play()

# BONUS TIEMPO-SOBRANTE (FINAL NIVEL):
func procesar_bonus_tiempo(delta):
	tiempo_tick_acumulado += delta
	
	while tiempo_tick_acumulado >= INTERVALO_TICK_TIEMPO:
		tiempo_tick_acumulado -= INTERVALO_TICK_TIEMPO
		
		if GlobalValues.marcadores["time"] > 0:
			GlobalValues.marcadores["time"] -= 1
			FuncionesTilesMario.agregar_puntos_sin_texto(PUNTOS_POR_SEGUNDO)
		else:
			GlobalValues.marcadores["time"] = 0
			sonido_bonus_level_up.stop()
			FuncionesGenerales.reset_estados_cambio_estado_a("fireworks")
			timerEstrella.start(0.5)
			print("fin bonus")

# CHECK TIMEUP:
func check_timeup(delta):
	GlobalValues.marcadores["time"] -= delta
	if GlobalValues.marcadores["time"] <= 0:
		GlobalValues.marcadores["time"] = 0.0
		print("Time up")
		velocity = Vector2(0, POTENCIA_SALTO * 2)
		panelTimeup.visible = true
		#panelTimeup.global_position = global_position + Vector2(-75, -100)
		actions_lose_life()

# VELOCITY ZERO:
func velocity_zero():
	velocity = Vector2(0, 0)

# SELECCIONAR MUSICA:
func seleccionar_musica():
	musica = musica_fondo

# Pulsar ESC (salir):
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_1:
		print(global_position)
