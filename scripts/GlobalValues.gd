extends Node

# CONSTANTES GLOBALES:
const GRAVEDAD = 80.0
const DURACION_ESTRELLA = 8.1

# LIMITES MUNDO:
const LIMITE_IZ = 0
const LIMITE_DE = 3400
const BOTTOM_LIMIT = 900 # BOTTOM-LIMIT (si es necesario)

# ESCENAS (NIVELES):
var scenes = [
	null, # scene 0
	preload("res://scenes/world_1_1.tscn"),
	preload("res://scenes/world_1_2.tscn")
]

# REFERENCIAS GLOBALES:
var game_manager_node: Node2D = null
var ref_tilemap: TileMapLayer = null
var ref_oculta_tile: Sprite2D = null
var flag_sprite: AnimatedSprite2D = null
var bloqueSprite: CharacterBody2D = null
var monedaSprite: AnimatedSprite2D = null
var setaSprite: Node2D = null
var estrellaSprite: CharacterBody2D = null

# REFERENCIA GLOBAL A MARIO:
var marioRG: CharacterBody2D = null

# MARCADORES:
const TIEMPO_INICIAL = 59

var marcadores = {
	"score": 0,
	"coins": 0,
	"world": [1, 1],
	"time:": TIEMPO_INICIAL,
	"lives": 3
}

# ESTADOS DEL JUEGO
var estado_juego = {
	"prejuego": true,
	"en_juego": false,
	"transicion_flag_pole": false,
	"transicion_goal_zone": false,
	"transicion_vida_menos": false,
	"transicion_next_vida": false,
	"transicion_fireworks": false,
	"fireworks": false,
	"game_over": false
}

# LISTA DE GOOMBAS:
var goombas_instancias = []

# ITEMS (SETAS, y SETAS-EXTRA):
var lista_setas = [
	[], # scene 0
	[Vector2(344, 136), Vector2(1256, 136), Vector2(1752, 72)],
	[]
]

var lista_setas_extra = [
	[], # scene 0
	[Vector2(1032, 120)],
	[Vector2(64, 32)]
]

var lista_estrellas = [
	[], # scene 0
	[Vector2(1624, 136)],
	[]
]

var lista_repetitivas = [
	[], # scene 0
	[Vector2(1512, 136)],
	[]
]

var lista_desactivados = []
