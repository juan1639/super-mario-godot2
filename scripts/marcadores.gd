extends PanelContainer

# REFERENCIAS:
@onready var score = $MarginContainer/HBoxContainer/VBoxContainer0/ScoreNum
@onready var monedas = $MarginContainer/HBoxContainer/VBoxContainer1/CoinsNum
@onready var world = $MarginContainer/HBoxContainer/VBoxContainer2/WorldNum
@onready var tiempo = $MarginContainer/HBoxContainer/VBoxContainer3/TimeNum

var signalConnect = false

func _ready():
	print("Instanciando marcadores")
	
	if FuncionesTilesMario.has_signal("marcador_actualizado"):
		#print("FuncionesTilesMario tiene señal marcador_actualizado")
		FuncionesTilesMario.connect("marcador_actualizado", Callable(self, "_actualizar_score"))
	
	if FuncionesTilesMario.has_signal("monedas_actualizadas"):
		#print("FuncionesTilesMario tiene señal monedas_actualizadas")
		FuncionesTilesMario.connect("monedas_actualizadas", Callable(self, "_actualizar_monedas"))
	
	if FuncionesTilesMario.has_signal("world_actualizado"):
		#print("FuncionesTilesMario tiene señal world_actualizado")
		FuncionesTilesMario.connect("world_actualizado", Callable(self, "_actualizar_world"))

# FUNCION EJECUTANDOSE A 60 FPS (PARA RENDERIZAR EL TIEMPO):
func _process(delta):
	tiempo.text = str(int(GlobalValues.marcadores["time"]))

func _actualizar_score():
	score.text = str(GlobalValues.marcadores["score"])

func _actualizar_monedas():
	monedas.text = "x " + str(GlobalValues.marcadores["coins"])

func _actualizar_world():
	world.text = "1-" + str(GlobalValues.marcadores["world"][1])
