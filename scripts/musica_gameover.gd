extends AudioStreamPlayer2D

@onready var timer = $Timer

func _ready():
	timer.start(2.0)

func _on_timer_timeout():
	self.play()
