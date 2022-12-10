extends CanvasLayer

onready var _pilot_view : TextureRect = $Control/PilotView


func _on_PlaneHandler_update_pilot_view(texture:ViewportTexture)->void:
	_pilot_view.texture = texture
