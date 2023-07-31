extends Node2D

@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	Global.level_completed.connect(on_level_completed)
	
func on_level_completed():
	level_completed.show()
	get_tree().paused = true


	
