@tool
extends Smart3D


func _init():
	# Mesh Auswahl erstellen
	register_dropdown("smart_mesh", "box")

func _ready() -> void:
	if !self.mesh:
		self.mesh = ArrayMesh.new()
		
func _generate():
	if _smart_properties.is_empty(): return
	
	# eine Box erstellen
	var sb = Smart.calc_size(Vector3(self.size_x, self.size_y, self.size_z), 0)
	sb.mesh_id = get_smart_val("smart_mesh")
	
	Smart.smart_to_mesh([sb], self.mesh)
