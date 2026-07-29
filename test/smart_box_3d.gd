@tool
extends SmartGen
class_name  SmartWall

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

@export_group("Door")
@export_range(0.8,3.0,0.1) var door_width:float = 1.0:
	set(v):door_width = v;_generate()
@export_range(1.8,3.0,0.1) var door_height:float = 2.0:
	set(v):door_height = v;_generate()
@export_range(-8.0,8.0,0.1) var door_pos:Array[float] = []:
	set(v):door_pos = v;_generate()


func _init():
	super()
	# Mesh Auswahl erstellen
	register_color("color_number")
	register_dropdown("smart_mesh", ["box", "test"])

func _ready() -> void:
	if !self.mesh:
		self.mesh = ArrayMesh.new()
		
func _generate():
	super()
	if _smart_properties.is_empty(): 
		return
	
	# eine Box erstellen
	var sb = Smart.get_object_from_smart3d(self, get_smart_val("color_number"))
	sb.mesh_id = get_smart_val("smart_mesh")
	
	# Fenster Ausschnitte
	var window_size:Vector3 = Vector3(window_width, window_height, 1)
	var cull_list:Array[SmartObject] = []
	var base_height = (window_base + (window_height/2)) - sb.size.y/2
	for pos in window_pos:
		var window_box = Smart.get_object_from_size(window_size)
		window_box.pos.x = pos
		window_box.pos.y = base_height
		cull_list.append(window_box)

	# Tür Ausschnitte
	var door_size:Vector3 = Vector3(door_width, door_height, 1)
	var door_base_height = (door_size.y/2) - (sb.size.y/2)
	for pos in door_pos:
		var door_box = Smart.get_object_from_size(door_size)
		door_box.pos.x = pos
		door_box.pos.y = door_base_height
		cull_list.append(door_box)

	# Ausschnitte erstellen
	if cull_list.size() > 0:
		var list = Smart.split_3d_surface(sb,cull_list)
		Smart.get_mesh_from_objectarray(list, self.mesh)
	else:
		Smart.get_mesh_from_objectarray([sb], self.mesh)
