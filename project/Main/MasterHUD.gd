extends CanvasLayer


func _on_World_export_viewport_texture(texture:ViewportTexture, port:int)->void:
	get_node("Control/Viewport" + str(port)).set("texture", texture)
