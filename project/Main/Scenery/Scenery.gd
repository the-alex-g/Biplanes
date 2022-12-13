extends StaticBody

const OBJECTS := [
	"Tree1",
	"Tree2",
	"Tree3",
	"Rock1",
]
const MESH_DIMENSIONS := [
	Vector3(8, 20, 8),
	Vector3(5, 22, 6),
	Vector3(8, 20, 8),
	Vector3(9, 2, 7),
]
const TEX_PATH := "res://Main/Scenery/Textures/"
const MESH_PATH := "res://Main/Scenery/Meshes/"

onready var _mesh := $Mesh
onready var _collision_shape := $CollisionShape

func _ready()->void:
	var mesh_index := randi() % OBJECTS.size()
	_mesh.mesh = load(MESH_PATH + OBJECTS[mesh_index] + ".obj")
	var material := SpatialMaterial.new()
	material.albedo_texture = load(TEX_PATH + OBJECTS[mesh_index] + ".png")
	_mesh.material = material
	_mesh.translation.y = MESH_DIMENSIONS[mesh_index].y / 2
	_collision_shape.shape.extents = MESH_DIMENSIONS[mesh_index] / 2
