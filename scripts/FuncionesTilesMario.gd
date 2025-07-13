extends Node

signal marcador_actualizado
signal monedas_actualizadas
signal world_actualizado

# TILE-INTERROGACION = (2,1) | TILE-BLOQUE-LADRILLO = (3,1):
const INTERROGACION = Vector2i(2, 1)
const BLOQUE_LADRILLO = Vector2i(3, 1)
const BLOQUE_LADRILLO_UNDER = Vector2i(8, 3)
const BLOQUE_INVISIBLE = Vector2i(0, 0)
const BLOQUE_DESACTIVADO = Vector2i(7, 3)

# REFERENCIAS:
@onready var show_bonus_scene = preload("res://scenes/show_bonus.tscn")
@onready var bloques_scene = preload("res://scenes/bloque_sprite.tscn")

# IDENTIFICAR TILE (EN LA POSICION DE MARIO):
func identificar_tile(global_position, salto, timer, sonido_coin):
	var tilemap = GlobalValues.ref_tilemap
	
	# OBTENEMOS EL TILE EN LA POSICION DE MARIO (y restamos (0,-1) encima de mario)
	var tile_pos = tilemap.local_to_map(global_position)
	tile_pos += Vector2i(0, -1)

	# Asegurar de que haya un tile ahí
	var source_id = tilemap.get_cell_source_id(tile_pos)
	
	if source_id == -1:
		return
	
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	#print("Coords del tile golpeado:", atlas_coords)
	
	if timer.time_left > 0.0:
		return
	
	timer.start(0.2)
	
	if atlas_coords == INTERROGACION:
		impacto_bloques_tween(tilemap, tile_pos, source_id, INTERROGACION, global_position, salto, sonido_coin)
	elif atlas_coords == BLOQUE_LADRILLO or atlas_coords == BLOQUE_LADRILLO_UNDER:
		impacto_bloques_tween(tilemap, tile_pos, source_id, atlas_coords, global_position, salto, sonido_coin)

# TWEEN TILES:
func impacto_bloques_tween(tilemap, tile_pos, source_id, TIPO_BLOQUE, global_position, salto, sonido_coin):
	# SUSTITUIR TEMPORALMENTE POR TILE(0,0)=CIELO_AZUL (efecto desaparece temporalmente):
	tilemap.set_cell(tile_pos, source_id, Vector2i(0, 0))
	# RESETEAR salto["presionado"]:
	salto["presionado"] = false
	#velocity.y = 0
	
	# PONER UN BLOQUE-SPRITE (IDENTICO AL TILE):
	var pos_mario_cabeza = global_position + Vector2(0, -16)
	var bloque_pos = tilemap.local_to_map(tilemap.to_local(pos_mario_cabeza))
	var bloque_pos2 = tilemap.map_to_local(bloque_pos) + tilemap.position
	var item_pos = bloque_pos2 + Vector2(0, -16)
	
	var instanciaBloque: CharacterBody2D
	
	# QUE TIPO DE BLOQUE? (INTERROGACION O LADRILLO):
	if TIPO_BLOQUE == INTERROGACION:
		instanciaBloque = instanciar_bloque(3, bloque_pos2)
		moneda_tween(item_pos, sonido_coin, global_position)
		
	elif TIPO_BLOQUE == BLOQUE_LADRILLO or TIPO_BLOQUE == BLOQUE_LADRILLO_UNDER:
		instanciaBloque = instanciar_bloque(2, bloque_pos2)
		item_ladrillos(item_pos, sonido_coin, global_position)
	
	# TWEEN DEL TILE (desplazamiento hacia arriba):
	var tween = create_tween()
	var startPos = instanciaBloque.global_position
	var offset = instanciaBloque.global_position + Vector2(0, -8)
	
	tween.tween_property(instanciaBloque, "global_position", offset, 0.08)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(instanciaBloque, "global_position", startPos, 0.08)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# VOLVER A COLOCAR EL TILE:
	tween.tween_callback(Callable(self, "restore_block").bind(tilemap, tile_pos, source_id, TIPO_BLOQUE))
	
	# CALLDEFERRED ELIMINAR INSTANCIA:
	tween.tween_callback(Callable(self, "eliminar_instancia"))
	#tween.tween_property(GlobalValues.bloqueSprite, "modulate", Color(0, 0, 0, 0), 0.1).set_ease(Tween.EASE_IN)
	
	# COLOCAR EL TILE-DESACTIVADO:
	if TIPO_BLOQUE == INTERROGACION:
		tween.tween_callback(Callable(self, "restore_block").bind(tilemap, tile_pos, source_id, BLOQUE_DESACTIVADO))

# VOLVER A COLOCAR EL TILE (tras el tween):
func restore_block(tilemap: TileMapLayer, tile_pos: Vector2i, source_id: int, TIPO_BLOQUE: Vector2i):
	tilemap.set_cell(tile_pos, source_id, TIPO_BLOQUE)

# INSTANCIAR BLOQUE (INTERROGACION O LADRILLO):
func instanciar_bloque(frameId, bloque_pos2):
	GlobalValues.bloqueSprite = bloques_scene.instantiate()
	GlobalValues.bloqueSprite.global_position = bloque_pos2
	GlobalValues.bloqueSprite.get_child(0).frame = frameId
	GlobalValues.bloqueSprite.z_index = 6
	#get_tree().root.get_node("GameManager").add_child(GlobalValues.bloqueSprite)
	GlobalValues.game_manager_node.add_child(GlobalValues.bloqueSprite)
	return GlobalValues.bloqueSprite

# ELIMINAR INSTANCIA:
func eliminar_instancia():
	GlobalValues.bloqueSprite.queue_free()

# CREAR TWEEN MONEDA ROTANDO HACIA ARRIBA:
func moneda_tween(item_pos, sonido_coin, global_position):
	print(item_pos, GlobalValues.lista_setas)
	
	var world = GlobalValues.marcadores["world"][1]
	
	if item_pos in GlobalValues.lista_setas[world] or item_pos in GlobalValues.lista_setas_extra[world]:
		if not item_pos in GlobalValues.lista_desactivados:
			
			if item_pos in GlobalValues.lista_setas_extra[world]:
				GlobalValues.ref_oculta_tile.visible = false
			
			GlobalValues.setaSprite.global_position = item_pos
			GlobalValues.setaSprite.activa = true
			GlobalValues.setaSprite.sonido_seta.play()
			GlobalValues.lista_desactivados.append(item_pos)
	
	elif not item_pos in GlobalValues.lista_desactivados:
		sonido_coin.play()
		agregar_puntos(200, global_position)
		agregar_monedas(1)
		GlobalValues.monedaSprite.global_position = item_pos
		GlobalValues.lista_desactivados.append(item_pos)
		
		# CREAR TWEEN MONEDA ROTANDO HACIA ARRIBA:
		var tween = create_tween()
		var offset = item_pos + Vector2(0, -32)
		print("item_pos", item_pos)
		
		tween.tween_property(GlobalValues.monedaSprite, "global_position", offset, 0.3)\
			.set_trans(Tween.TRANS_LINEAR)
		
		# DESAPARECER:
		tween.tween_callback(Callable(self, "fin_moneda_ocultar"))

func fin_moneda_ocultar():
	GlobalValues.monedaSprite.global_position += Vector2(-990, -890)

# ESTRELLA, MONEDAS REPETITIVAS, etc.
func item_ladrillos(item_pos, sonido_coin, global_position):
	print(item_pos)
	
	var world = GlobalValues.marcadores["world"][1]
	
	if item_pos in GlobalValues.lista_estrellas[world]:
		if not item_pos in GlobalValues.lista_desactivados:
			GlobalValues.estrellaSprite.global_position = item_pos
			GlobalValues.estrellaSprite.activa = true
			GlobalValues.setaSprite.sonido_seta.play()
			GlobalValues.lista_desactivados.append(item_pos)
	
	elif item_pos in GlobalValues.lista_repetitivas[world]:
		if not item_pos in GlobalValues.lista_desactivados:
			moneda_tween(item_pos, sonido_coin, global_position)
	
	elif item_pos in GlobalValues.lista_setas[world]:
		GlobalValues.setaSprite.global_position = item_pos
		GlobalValues.setaSprite.activa = true
		GlobalValues.setaSprite.sonido_seta.play()
		GlobalValues.lista_desactivados.append(item_pos)

# SCORES:
func agregar_puntos(cantidad, global_position):
	GlobalValues.marcadores["score"] += cantidad
	emit_signal("marcador_actualizado")
	var showBonus = show_bonus_scene.instantiate()
	showBonus.global_position = global_position
	showBonus.frame_ssheet = showBonus.choose_bonus[str(cantidad)]
	add_child(showBonus)

# SOLO SUMAR PUNTOS (BONUS-FINAL-NIVEL):
func agregar_puntos_sin_texto(cantidad):
	GlobalValues.marcadores["score"] += cantidad
	
	if cantidad < 0:
		GlobalValues.marcadores["score"] = 0
	
	emit_signal("marcador_actualizado")

# SUMAR MONEDAS:
func agregar_monedas(cantidad):
	GlobalValues.marcadores["coins"] += cantidad
	
	if cantidad < 0:
		GlobalValues.marcadores["coins"] = 0
	
	emit_signal("monedas_actualizadas")

# ACTUALIZAR WORLD:
func actualizar_world(world):
	GlobalValues.marcadores["world"][1] += world
	emit_signal("world_actualizado")
