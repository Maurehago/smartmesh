@tool
class_name SmartBox
extends Smart3D

## Smart Mesh angeben
@export var smart_mesh:SmartMesh:
	set(v): smart_mesh = v;_generate()

## Farbe
@export_range(0.0, 7.0, 1.0) var color_base:float = 0:
	set(v):color_base = v;_generate()
@export_range(0.0, 9.0, 1.0) var color_shade:float = 0:
	set(v):color_shade = v;_generate()

## Modifier
@export var modifiers:Array[SmartModifier] = []:
	set(v):modifiers = update_modifier_signals(modifiers, v);_generate()

## Generiert das Mesh
func _generate():
	# vererbte Funktion aufrufen
	super()
	if not is_inside_tree(): return
	
	# Größe in Vector3
	var size = Vector3(size_x, size_y, size_z)
	
	var color_number = Smart.get_color_index(color_base, color_shade)
	
	# Smart Object erstellen
	var obj = Smart.get_object_from_size(size, color_number)
	obj.mesh_id = "box/box"
	obj.modifiers = self.modifiers
	
	# Mesh erstellen
	Smart.get_mesh_from_objectarray([obj], self.mesh, self.smart_mesh)
