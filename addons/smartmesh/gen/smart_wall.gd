@tool
extends SmartGen
class_name SmartWall

@export_group("Wall")
@export_range(0.0,5.0,1.0) var wall_mesh_number:float = 0.0:
	set(v):wall_mesh_number = v; emit_changed()
@export_range(0.5,8.0,0.1) var wall_width:float = 4.0:
	set(v):wall_width = v; emit_changed()
@export_range(0.5,8.0,0.1) var wall_height:float = 3.0:
	set(v):wall_height = v; emit_changed()
@export_range(0.1,1.0,0.1) var wall_deph:float = 0.1:
	set(v):wall_deph = v; emit_changed()

@export_group("Window")
@export_range(0.0,5.0,1.0) var window_mesh_number:float = 0.0:
	set(v):window_mesh_number = v; emit_changed()
@export_range(0.2,3.0,0.1) var window_width:float = 0.8:
	set(v):window_width = v; emit_changed()
@export_range(0.2,5.0,0.1) var window_height:float = 1.2:
	set(v):window_height = v; emit_changed()
@export_range(0.0,5.0,0.1) var window_base:float = 0.8:
	set(v):window_base = v; emit_changed()

@export var window:SmartWindow = SmartWindow.new():
	set(v):window = _set_gen_func(window,v,emit_changed)

# Erstellt ein Array, bei dem jedes Element ein Slider ist (Schrittweite 0.1)
@export_range(-4.0,4.0,0.1) var window_pos: Array[float] = []:
	set(v):window_pos = v; emit_changed()

@export_group("Door")
@export_range(0.5,3.0,0.1) var door_width:float = 1.0:
	set(v):door_width = v; emit_changed()
@export_range(1.5,4.0,0.1) var door_height:float = 2.0:
	set(v):door_height = v; emit_changed()

# Erstellt ein Array, bei dem jedes Element ein Slider ist (Schrittweite 0.1)
@export_range(-4.0,4.0,0.1) var door_pos: Array[float] = []:
	set(v):door_pos = v; emit_changed()


func generate() -> Array[SmartObject]:
	var list:Array[SmartObject] = []
	var wall = Smart.calc_size(Vector3(wall_width, wall_height, wall_deph), color_mask)
	wall.mesh_number = wall_mesh_number
	
	# Wenn keine Fenster
	if window_pos.size() <= 0 and door_pos.size() <= 0:
		return [wall]
	
	# Fenster Größe merken und Fenster Teile berechnen
	window.size = Vector3(window_width, window_height, wall_deph)
	var window_parts:Array[SmartObject] = window.generate()
	
	# Abstand vom Boden zur Fenster Mitte
	var height = -(wall_height/2) + window_base + (window_height/2) # halbe Fenster höche
	var window_list:Array[SmartObject] = []
	
	# alle Fenster durchgehen
	for p in window_pos:
		# Fenster Ausschnitt erstellen
		var obj = SmartObject.new()
		obj.size = window.size
		obj.pos = Vector3(p, height, wall.pos.z)
		
		# Fenster Ausschnitt Liste hinzufügen
		window_list.append(obj)
		
		# Fenster Teile hinzufügen
		Smart.append_smartObjects(list, window_parts, obj.pos, window_mesh_number)
		pass
	
	# Door
	for p in door_pos:
		var door = Smart.calc_size(Vector3(door_width, door_height, wall_deph), color_mask)
		door.pos.x = p
		door.pos.y = (-(wall_height/2) + (door_height/2)) -0.01
		window_list.append(door)
	
	# Wand in Rechteck aufsplitten
	list.append_array(Smart.split_3d_surface(wall, window_list))
	return list
