extends CenterContainer

signal next_level

@onready var button = %Button

func _on_button_pressed():
	next_level.emit()
