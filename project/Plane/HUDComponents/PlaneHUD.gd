extends CanvasLayer

signal upgrade(field_name)
signal launch

onready var _fuel_bar : ProgressBar = $Control/VBoxContainer/FuelBar
onready var _ammo_bar : ProgressBar = $Control/VBoxContainer/AmmoBar
onready var _health_bar : ProgressBar = $Control/HealthBar
onready var _altitude_label : Label = $Control/Altitude
onready var _radar : Radar = $Control/Radar
onready var _level_up_menu : UpgradeMenu = $Control/LevelUp
onready var _airspeed_label : Label = $Control/Airspeed

var _kills := 0
var _life_time := 0.0
var _kill_banners := {}


func _process(delta:float)->void:
	_life_time += delta


func _on_PlaneHandler_update_fuel(value:float)->void:
	_fuel_bar.value = value


func _on_PlaneHandler_update_ammo(value:float)->void:
	_ammo_bar.value = value


func _on_PlaneHandler_update_health(value:float)->void:
	_health_bar.value = value


func _on_PlaneHandler_update_altitude(value:float)->void:
	_altitude_label.text = "altitude: " + str(floor(value * 7 / 3)) + " ft"


func _on_PlaneHandler_update_radar(from:Vector2, direction:float, points:PoolVector2Array)->void:
	_radar.update_radar(from, direction, points)


func _on_PlaneHandler_plane_down(_plane_id:int, killer:int)->void:
	_level_up_menu.visible = true
	_level_up_menu.disabled = false
	if killer != -1:
		_level_up_menu.resources += 10
	elif _life_time >= 45.0:
		_level_up_menu.resources += 10
	_level_up_menu.resources += _kills * 10


func _on_LevelUp_upgrade(field:String)->void:
	match field:
		"fuel":
			_fuel_bar.max_value += 10
		"ammo":
			_ammo_bar.max_value += 5
		"health":
			_health_bar.max_value += 1
	emit_signal("upgrade", field)


func _on_LevelUp_launch()->void:
	_fuel_bar.value = _fuel_bar.max_value
	_ammo_bar.value = _ammo_bar.max_value
	_health_bar.value = _health_bar.max_value
	emit_signal("launch")
	_level_up_menu.disabled = true
	_level_up_menu.visible = false
	_kills = 0


func _on_PlaneHandler_setup_plane(id:int)->void:
	_level_up_menu.id = id


func _on_PlaneHandler_update_kills(value:int, color:Color)->void:
	_kills = value
	if not _kill_banners.keys().has(color):
		var kill_banner : TextureRect = load("res://Plane/HUDComponents/KillBanner.tscn").instance()
		$Control/KillBanners.add_child(kill_banner)
		kill_banner.color = color
		_kill_banners[color] = kill_banner
	_kill_banners[color].kills += 1


func _on_PlaneHandler_can_hit(value:bool)->void:
	if value:
		$Control/FiringRing.modulate = Color(0, 1, 0, 0.75)
	else:
		$Control/FiringRing.modulate = Color(1, 0, 0, 0.75)


func _on_PlaneHandler_update_airspeed(value:float)->void:
	_airspeed_label.text = "airspeed: " + str(floor(value * 7 / 3)) + " ft/sec"
