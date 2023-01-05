class_name VariableStreamPlayer
extends AudioStreamPlayer

export var volume_variation := 0.4
export var pitch_variation := 0.3


func play(from_position := 0.0)->void:
	volume_db = lerp(-volume_variation, volume_variation, randf())
	pitch_scale = lerp(0.5, 1.0 + pitch_variation, randf())
	.play(from_position)
