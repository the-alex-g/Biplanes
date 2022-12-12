extends StaticBody

const MESHES := [
	"res://Main/Scenery/Meshes/Tree1.obj",
	"res://Main/Scenery/Meshes/Tree2.obj",
]
const MESH_DIMENSIONS := [
	Vector3(8, 20, 8),
	Vector3(5, 22, 6),
]
const TEXTURES := [
	"res://Main/Scenery/Textures/Tree1.png",
	"res://Main/Scenery/Textures/Tree2.png",
]

onready var _mesh := $Mesh
onready var _collision_shape := $CollisionShape

func _ready()->void:
	var mesh_index := randi() % MESHES.size()
	_mesh.mesh = load(MESHES[mesh_index])
	_mesh.material.albedo_texture = load(TEXTURES[mesh_index])
	_mesh.translation.y = MESH_DIMENSIONS[mesh_index].y / 2
	_collision_shape.shape.extents = MESH_DIMENSIONS[mesh_index] / 2
