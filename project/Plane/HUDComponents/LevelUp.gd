class_name UpgradeMenu
extends Panel

signal launch
signal upgrade(field)

enum OptionSets {MAIN, ENGINES, GUNS, FRAME, SPECIAL}

const BUTTON_MAPS := {"A":0, "B":1, "X":2, "Y":3, "Back":10}

onready var option_text_1 : Label = $VBoxContainer/Option1/Text
onready var option_text_2 : Label = $VBoxContainer/Option2/Text
onready var option_text_3 : Label = $VBoxContainer/Option3/Text
onready var option_text_4 : Label = $VBoxContainer/Option4/Text
onready var option_text_5 : Label = $VBoxContainer/Option5/Text
onready var resources_label : Label = $VBoxContainer/Label

export var disabled := false

var id := 0
var _advanced_flight := false
var resources := 0 setget _set_resources
var _menu : int = OptionSets.MAIN setget _set_menu
var _costs := {
	"speed":10, "fuel":10,
	"damage":10, "ammo":10, "reload":5, "range":10,
	"health":15, "manuverability":10, "targeter":15, "new plane":-20,
	"auto_right":10, "advanced_flight":0
}
var _upgrade_fields := [
	["engines", "guns", "frame", "special", "launch"],
	["speed", "fuel", "", "", "back"],
	["damage", "ammo", "reload", "range", "back"],
	["health", "manuverability", "", "", "back"],
	["auto_right", "advanced_flight", "targeter", "new plane", "back"],
]

onready var _starting_costs := _costs.duplicate()


func _ready()->void:
	_set_menu(OptionSets.MAIN)


func _input(event:InputEvent)->void:
	if disabled:
		return
	
	if event.device == id:
		if event is InputEventJoypadButton:
			if event.is_pressed():
				match _menu:
					OptionSets.MAIN:
						match event.button_index:
							BUTTON_MAPS.A:
								_set_menu(OptionSets.ENGINES)
							BUTTON_MAPS.X:
								_set_menu(OptionSets.GUNS)
							BUTTON_MAPS.Y:
								_set_menu(OptionSets.FRAME)
							BUTTON_MAPS.B:
								_set_menu(OptionSets.SPECIAL)
							BUTTON_MAPS.Back:
								emit_signal("launch")
					OptionSets.ENGINES:
						match event.button_index:
							BUTTON_MAPS.A:
								_upgrade("speed")
							BUTTON_MAPS.X:
								_upgrade("fuel")
							BUTTON_MAPS.Back:
								_set_menu(OptionSets.MAIN)
					OptionSets.GUNS:
						match event.button_index:
							BUTTON_MAPS.A:
								_upgrade("damage")
							BUTTON_MAPS.X:
								_upgrade("ammo")
							BUTTON_MAPS.Y:
								_upgrade("reload")
							BUTTON_MAPS.B:
								_upgrade("range")
							BUTTON_MAPS.Back:
								_set_menu(OptionSets.MAIN)
					OptionSets.FRAME:
						match event.button_index:
							BUTTON_MAPS.A:
								_upgrade("health")
							BUTTON_MAPS.X:
								_upgrade("manuverability")
							BUTTON_MAPS.Back:
								_set_menu(OptionSets.MAIN)
					OptionSets.SPECIAL:
						match event.button_index:
							BUTTON_MAPS.A:
								_upgrade_fields[4][0] = ""
								_upgrade("auto_right")
							BUTTON_MAPS.X:
								_upgrade("advanced_flight")
							BUTTON_MAPS.Y:
								_upgrade_fields[4][2] = ""
								_upgrade("targeter")
							BUTTON_MAPS.B:
								_reset()
							BUTTON_MAPS.Back:
								_set_menu(OptionSets.MAIN)


func _set_menu(value:int)->void:
	_menu = value
	for i in 5:
		var field_name : String = _upgrade_fields[value][i]
		if field_name != "":
			var text := field_name
			if field_name != "back" and field_name != "launch" and _menu != OptionSets.MAIN:
				text += ": " + str(_costs[field_name])
			get("option_text_" + str(i + 1)).text = text
			get_node("VBoxContainer/Option" + str(i+1)).visible = true
		else:
			get_node("VBoxContainer/Option" + str(i+1)).visible = false


func _upgrade(field:String)->void:
	var cost : int = _costs[field]
	if field != "":
		if resources >= cost:
			_set_resources(resources - cost)
			if field != "advanced_flight":
				_costs[field] += 5
			else:
				_advanced_flight = ! _advanced_flight
				$Label.text = "advanced flight: " + ("enabled" if _advanced_flight else "disabled")
			emit_signal("upgrade", field)
			_set_menu(_menu)


func _set_resources(value:int)->void:
	resources = value
	resources_label.text = "Resources: " + str(resources)


func _reset()->void:
	for field in _costs:
		_costs[field] = _starting_costs[field]
	_advanced_flight = false
	_upgrade_fields[4][0] = "auto_right"
	_upgrade_fields[4][2] = "targeter"
	emit_signal("upgrade", "reset")
	_set_menu(_menu)
