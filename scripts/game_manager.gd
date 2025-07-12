extends Node2D

# REFERENCIAS A SPRITES (GOOMBA, etc.):
@onready var goomba_scene = preload("res://scenes/goomba.tscn")
@onready var goomba_spawns = $GoombaSpawns

@onready var bloque_scene = preload("res://scenes/bloque_sprite.tscn")
@onready var moneda_scene = preload("res://scenes/moneda_rotando.tscn")
@onready var seta_scene = preload("res://scenes/seta_sprite.tscn")
@onready var estrella_scene = preload("res://scenes/estrella_sprite.tscn")
@onready var gameover_scene = preload("res://scenes/gameover.tscn")
@onready var button_next_level_scene = preload("res://scenes/next_level_button.tscn")

# REFERENCIA A AREA2D (FallZone):
@onready var fallZones = $World1_1/FallZones

# REFERENCIAS A LA BANDERA Y GOAL-ZONE:
@onready var goalZone = $World1_1/GoalZone
@onready var flagPole = $World1_1/FlagPole

# REFERENCIA A LAS ZONAS INSTANCIA-GOOMBAS-PARACAIDAS:
@onready var zoneInstanciaParacaidas = $World1_1/ParacaidasZones

# REFERENCIA A MARIO/JUGADOR:
@onready var mario = $Mario

# FUNCION INICIALIZADORA:
func _ready():
	print("Start new game")
	
	# RESETEAR MARCADORES:
	FuncionesGenerales.reset_scores()
	FuncionesTilesMario.agregar_puntos_sin_texto(-99)
	FuncionesTilesMario.agregar_monedas(-99)
	
	# RESETEAR LISTA-DESACTIVADOS:
	GlobalValues.lista_desactivados = []
	
	# CONEXION A SEÑALES GAMEOVER y BUTTON-NEXT-LEVEL:
	FuncionesGenerales.connect("gameover_instance", Callable(self, "_on_gameover_instance"))
	FuncionesGenerales.connect("next_level_instance", Callable(self, "_on_next_level_instance"))
	
	# REFERENCIA ESTE NODO PRINCIPAL (MAIN):
	GlobalValues.game_manager_node = self

	# REFERENCIAR A MARIO EN GLOBAL-VALUES:
	GlobalValues.marioRG = mario
	
	# REFERENCIAS A LA BANDERA Y AL TILEMAP:
	GlobalValues.flag_sprite = $World1_1/FlagSprite
	GlobalValues.ref_tilemap = $World1_1/TileMapLayer
	
	# REFERENCIA A OCULTADOR DE LA INTERROGACION-VIDA-EXTRA:
	GlobalValues.ref_oculta_tile = $World1_1/OcultaTile
	GlobalValues.ref_oculta_tile.global_position = GlobalValues.lista_setas_extra[0] + Vector2(0, 16)
	
	# INSTANCIA DE UNA MONEDA-SPRITE (Posteriormente solo hace falta cambiar posicion):
	GlobalValues.monedaSprite = moneda_scene.instantiate()
	GlobalValues.monedaSprite.global_position = Vector2(-990, -890)
	add_child(GlobalValues.monedaSprite)
	
	# INSTANCIA DE UNA SETA (Posteriormente solo hace falta cambiar posicion):
	GlobalValues.setaSprite = seta_scene.instantiate()
	GlobalValues.setaSprite.global_position = Vector2(-990, -950)
	add_child(GlobalValues.setaSprite)
	
	# INSTANCIA DE UNA ESTRELLA (Posteriormente solo hace falta cambiar posicion):
	GlobalValues.estrellaSprite = estrella_scene.instantiate()
	GlobalValues.estrellaSprite.global_position = Vector2(-890, -950)
	GlobalValues.estrellaSprite.get_child(2).connect("body_entered", Callable(mario, "_on_estrella_body_entered"))
	add_child(GlobalValues.estrellaSprite)
	
	# INSTANCIAR GOOMBAS:
	for spawn_point in goomba_spawns.get_children():
		print("Instanciando Goomba en ", spawn_point.global_position)
		var goomba = goomba_scene.instantiate()
		goomba.global_position = spawn_point.global_position
		goomba.get_child(2).connect("body_entered", Callable(mario, "_on_goomba_body_entered").bind(goomba))
		goomba.get_child(3).connect("body_entered", Callable(mario, "_on_aplastar_goomba_body_entered").bind(goomba))
		add_child(goomba)
		GlobalValues.goombas_instancias.append(goomba)
	
	# MOSTRAR NUMERO DE CHILDRENS DE ESTA ESCENA (PRINCIPAL):
	print("Nro childrens: ", get_child_count())
	
	for child in get_children():
		print("Children: ", child)
	
	# CONECTAR SEÑAL de fallZone:
	for fallZone in fallZones.get_children():
		fallZone.connect("body_entered", Callable(mario, "_on_fall_zone_body_entered"))
	
	# CONECTAR SEÑALES de FlagPole y GoalZone:
	flagPole.connect("body_entered", Callable(mario, "_on_flag_pole_body_entered"))
	goalZone.connect("body_entered", Callable(mario, "_on_goal_zone_body_entered"))
	
	# CONECTAR SEÑALES de zoneInstanciaParacaidas:
	for zone in zoneInstanciaParacaidas.get_children():
		zone.connect("body_entered", Callable(mario, "_on_instancia_paracaidas_body_entered").bind(zone))

# CALL-DEFERRED INSTANCIAR-GOOMBA-PARACAIDAS:
func instanciar_goomba_paracaidas():
	var goomba = goomba_scene.instantiate()
	goomba.global_position = Vector2(mario.global_position.x + 124, -20)
	goomba.reset_tipo_goomba_cambio_a("paracaidas")
	goomba.get_child(2).connect("body_entered", Callable(mario, "_on_goomba_body_entered").bind(goomba))
	goomba.get_child(3).connect("body_entered", Callable(mario, "_on_aplastar_goomba_body_entered").bind(goomba))
	add_child(goomba)

# INSTANCIAR GAME OVER:
func _on_gameover_instance():
	var gameover = gameover_scene.instantiate()
	add_child(gameover)

# INSTANCIAR BUTTON-NEXT-LEVVEL:
func _on_next_level_instance():
	var buttonNextLevel = button_next_level_scene.instantiate()
	add_child(buttonNextLevel)
