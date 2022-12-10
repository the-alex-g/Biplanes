extends CanvasLayer

onready var _pilot_view : TextureRect = $Control/PilotView
onready var _fuel_bar : ProgressBar = $Control/FuelBar


func _on_PlaneHandler_update_pilot_view(texture:ViewportTexture)->void:
	_pilot_view.texture = texture


func _on_PlaneHandler_update_fuel(value:float)->void:
	_fuel_bar.value = value
