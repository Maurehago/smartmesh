@tool
@icon("res://addons/smartmesh/csg_icon.svg")
extends CSGCombiner3D
class_name SmartCSG3D

@export_category("Smart Instance")
@export_tool_button("Mesh to Smartmesh", "Mesh")
var import_button = create_instance
#@export var mesh_instance: bool = false : set = _mesh_instance

var parent: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = self.get_parent_node_3d()
	pass # Replace with function body.


#func _mesh_instance(value):
	#if value:
		#create_instance()
		#mesh_instance = false

func create_instance():
	self._update_shape()
	var mesh_info = self.get_meshes()
	var mesh = mesh_info[1]
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	parent.add_child(mesh_instance)
	mesh_instance.owner = self.owner
	mesh_instance.transform = mesh_info[0]
