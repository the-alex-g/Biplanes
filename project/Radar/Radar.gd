class_name Radar
extends Control

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
	draw_circle(Vector2.ONE * draw_radius, draw_radius, Color.darkgreen)
	draw_circle(Vector2.ONE * draw_radius, 6, Color.black)
	draw_line(Vector2.ONE * draw_radius, Vector2.ONE * draw_radius + (Vector2.RIGHT * 6).rotated(direction), Color.lightgreen, 2)
	if points.size() > 0:
		var points_to_draw : PoolVector2Array = []
		var nearest_point := Vector2.INF
		for point in points:
			if center_point.distance_squared_to(point) < scan_radius * scan_radius:
				points_to_draw.append(point)
			if center_point.distance_squared_to(point) < center_point.distance_squared_to(nearest_point):
				nearest_point = point
			
		if points_to_draw.size() == 0:
			var target := Vector2.ONE * draw_radius + (Vector2.RIGHT * draw_radius).rotated(nearest_point.angle_to_point(center_point))
			draw_line(Vector2.ONE * draw_radius, target, Color.lightgreen, 2)
		else:
			for point in points_to_draw:
				var target = Vector2(center_point.distance_to(point) * draw_radius / scan_radius, 0)
				target = Vector2.ONE * draw_radius + target.rotated(point.angle_to_point(center_point))
				draw_circle(target, 5, Color.lightgreen)
