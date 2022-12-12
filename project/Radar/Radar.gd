class_name Radar
extends Control

export var point_radius := 3.0
export var pointer_length := 6.0

var scan_radius := 500.0
var draw_radius := 50.0
var center_point := Vector2.ZERO
var direction := 0.0
var points : PoolVector2Array = []


func update_radar(from:Vector2, new_direction:float, other_points:PoolVector2Array)->void:
	center_point = from
	points = other_points
	direction = new_direction
	update()


func _draw():
	draw_circle(Vector2.ONE * draw_radius, draw_radius + 2, Color.black)
	draw_circle(Vector2.ONE * draw_radius, draw_radius, Color.forestgreen)
	draw_circle(Vector2.ONE * draw_radius, pointer_length, Color.black)
	draw_line(Vector2.ONE * draw_radius, Vector2.ONE * draw_radius + (Vector2.RIGHT * (pointer_length + 2)).rotated(direction + PI/2), Color.white, 2)
	if points.size() > 0:
		var points_to_draw : PoolVector2Array = []
		var far_points : PoolVector2Array = []
		for point in points:
			if center_point.distance_squared_to(point) < scan_radius * scan_radius:
				var target = Vector2(center_point.distance_to(point) * draw_radius / scan_radius, 0)
				target = Vector2.ONE * draw_radius + target.rotated(point.angle_to_point(center_point) + PI/2)
				target.x = draw_radius + (draw_radius - target.x)
				draw_circle(target, point_radius, Color.lightgreen)
			else:
				var target := Vector2.ONE * draw_radius + (Vector2.RIGHT * draw_radius).rotated(point.angle_to_point(center_point) + PI/2)
				target.x = draw_radius + (draw_radius - target.x)
				draw_circle(target, point_radius, Color.red)
