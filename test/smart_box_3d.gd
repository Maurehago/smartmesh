@tool
extends Smart3D

#@export_range(0.0,71.0,1.0) var color_number:float = 0

@export_group("Window")
@export_range(0.0,3.0,0.1) var window_base:float = 0.8:
	set(v):window_base = v;_generate()
@export_range(0.2,3.0,0.1) var window_width:float = 0.8:
	set(v):window_width = v;_generate()
@export_range(0.2,3.0,0.1) var window_height:float = 1.2:
	set(v):window_height = v;_generate()
@export_range(-8.0,8.0,0.1) var window_pos:Array[float] = []:
	set(v):window_pos = v;_generate()

func _init():
	# Mesh Auswahl erstellen
	register_color("color_number")
	register_dropdown("smart_mesh", "box")

func _ready() -> void:
	if !self.mesh:
		self.mesh = ArrayMesh.new()
		
func _generate():
	if _smart_properties.is_empty(): return
	
	# eine Box erstellen
	var sb = Smart.calc_size(Vector3(self.size_x, self.size_y, self.size_z), get_smart_val("color_number"))
	sb.mesh_id = get_smart_val("smart_mesh")
	
	# Fenster Ausschnitte
	var window_size:Vector3 = Vector3(window_width, window_height, 1)
	var cull_list:Array[SmartObject] = []
	for pos in window_pos:
		var window_box = Smart.calc_size(window_size)
		window_box.pos.x = pos
		cull_list.append(window_box)

	# Ausschnitte erstellen
	if cull_list.size() > 0:
		var list = Smart.split_3d_surface(sb,cull_list)
		Smart.smart_to_mesh(list, self.mesh)
	else:
		Smart.smart_to_mesh([sb], self.mesh)
