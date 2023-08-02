extends Node2D

@onready var level_completed = $CanvasLayer/LevelCompleted
@export var next_level: PackedScene

func _ready():
	on_level_completed()
	Global.level_completed.connect(on_level_completed)
	
func on_level_completed():
	level_completed.show()
 
func _on_level_completed_next_level():
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
