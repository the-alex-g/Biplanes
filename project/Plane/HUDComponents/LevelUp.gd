class_name UpgradeMenu
extends Panel

signal launch
signal upgrade(field)

enum OptionSets {MAIN, ENGINES, GUNS, FRAME}
enum ButtonMaps {A, B, X, Y}

const UPGRADE_FIELDS := [
	["Engines", "Guns", "Frame", "Launch"],
	["speed", "fuel", "", "Back"],
	["damage", "ammo", "reload", "Back"],
	["health", "manuverability", "", "Back"],
]

onready var option_text_1 : Label = $VBoxContainer/Option1/Text
onready var option_text_2 : Label = $VBoxContainer/Option2/Text
onready var option_text_3 : Label = $VBoxContainer/Option3/Text
onready var option_text_4 : Label = $VBoxContainer/Option4/Text
onready var resources_label : Label = $VBoxContainer/Label

export var disabled := false

var id := 0
var resources := 0 setget _set_resources
var _menu : int = OptionSets.MAIN setget _set_menu
var _costs := {
	"speed":10, "fuel":10,
	"damage":10, "ammo":10, "reload":5,
	"health":15, "manuverability":10,
}


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
							ButtonMaps.A:
								_set_menu(OptionSets.ENGINES)
							ButtonMaps.X:
								_set_menu(OptionSets.GUNS)
							ButtonMaps.Y:
								_set_menu(OptionSets.FRAME)
							ButtonMaps.B:
								emit_signal("launch")
					OptionSets.ENGINES:
						match event.button_index:
							ButtonMaps.A:
								_upgrade("speed")
							ButtonMaps.X:
								_upgrade("fuel")
							ButtonMaps.B:
								_set_menu(OptionSets.MAIN)
					OptionSets.GUNS:
						match event.button_index:
							ButtonMaps.A:
								_upgrade("damage")
							ButtonMaps.X:
								_upgrade("ammo")
							ButtonMaps.Y:
								_upgrade("reload")
							ButtonMaps.B:
								_set_menu(OptionSets.MAIN)
					OptionSets.FRAME:
						match event.button_index:
							ButtonMaps.A:
								_upgrade("health")
							ButtonMaps.X:
								_upgrade("manuverability")
							ButtonMaps.B:
								_set_menu(OptionSets.MAIN)


func _set_menu(value:int)->void:
	_menu = value
	for i in 4:
		var field_name : String = UPGRADE_FIELDS[value][i]
		if field_name != "":
			var text := field_name.capitalize()
			if field_name != "Back" and field_name != "Launch" and _menu != OptionSets.MAIN:
				text += ": " + str(_costs[field_name])
			get("option_text_" + str(i + 1)).text = text
			get_node("VBoxContainer/Option" + str(i+1)).visible = true
		else:
			get_node("VBoxContainer/Option" + str(i+1)).visible = false


func _upgrade(field:String)->void:
	var cost : int = _costs[field]
	if resources >= cost:
		_set_resources(resources - cost)
		_costs[field] += 5
		emit_signal("upgrade", field)
		_set_menu(_menu)


func _set_resources(value:int)->void:
	resources = value
	resources_label.text = "Resources: " + str(resources)
