@tool
extends Smart3D

func _init() -> void:
	register_color("plate")
	register_color("legs")


func _generate():
	if !self.mesh:
		self.mesh = ArrayMesh.new()
	var size = Vector3(size_x, size_y, size_z)
	var objects:Array[SmartObject] = []
	var tischplatte = Smart.get_object_position(size, Vector3(size_x, 0.04, size_z), Vector3.UP, -1)
	tischplatte.color_number = get_smart_val("plate")
	objects.append(tischplatte)
	
	var positions: PackedVector3Array = [
		Vector3(-1, -1, -1)
		, Vector3(-1, -1, 1)
		, Vector3(1, -1, -1)
		, Vector3(1, -1 , 1)
	]
	var fuesse = Smart.get_objectarray_positions(size, Vector3(0.1, size_y - tischplatte.size.y, 0.1), positions, -1, Vector3(-0.1, 0, -0.1))
	for i in range(fuesse.size()):
		fuesse[i].color_number = get_smart_val("legs")
	objects.append_array(fuesse)
	
	self.mesh = Smart.get_mesh_from_objectarray(objects, self.mesh)
