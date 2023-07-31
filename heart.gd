extends Node2D

signal healthPickup

func _on_area_2d_area_entered(area):
	queue_free()
	emit_signal('healthPickup')
