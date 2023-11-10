extends TextureRect

var kills := 0 setget _set_kills
var color : Color setget _set_color


func _set_kills(value:int)->void:
	kills = value
	$Label.text = str(kills)


func _set_color(value:Color)->void:
	color = value
	self_modulate = color
