extends CanvasLayer

onready var _wide_view : TextureRect = $Control/WideView
onready var _fuel_bar : ProgressBar = $Control/FuelBar
onready var _ammo_bar : ProgressBar = $Control/AmmoBar
onready var _health_bar : ProgressBar = $Control/HealthBar
onready var _altitude_label : Label = $Control/Altitude


func _on_PlaneHandler_update_pilot_view(texture:ViewportTexture)->void:
	_wide_view.texture = texture


func _on_PlaneHandler_update_fuel(value:float)->void:
	_fuel_bar.value = value


func _on_PlaneHandler_update_ammo(value:float)->void:
	_ammo_bar.value = value


func _on_PlaneHandler_update_health(value:float)->void:
	_health_bar.value = value


func _on_PlaneHandler_update_altitude(value:float)->void:
	_altitude_label.text = "Altitude: " + str(floor(value / 5))
