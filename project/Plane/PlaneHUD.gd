extends CanvasLayer

onready var _pilot_view : TextureRect = $Control/PilotView
onready var _fuel_bar : ProgressBar = $Control/FuelBar
onready var _ammo_bar : ProgressBar = $Control/AmmoBar


func _on_PlaneHandler_update_pilot_view(texture:ViewportTexture)->void:
	_pilot_view.texture = texture


func _on_PlaneHandler_update_fuel(value:float)->void:
	_fuel_bar.value = value


func _on_PlaneHandler_update_ammo(value:float)->void:
	_ammo_bar.value = value
