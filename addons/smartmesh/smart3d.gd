@tool
@icon("res://addons/smartmesh/mesh_icon.svg")
extends MeshInstance3D
class_name Smart3D

@export var smart_gen:SmartGen:
	set(v):smart_gen = _set_gen_func(smart_gen, v, generate)

# Die universelle Helfer-Funktion
func _set_gen_func(old_gen:SmartGen, new_gen:SmartGen, fu:Callable):
	if old_gen is SmartGen and old_gen.changed.is_connected(fu):
		old_gen.changed.disconnect(fu)
	if new_gen is SmartGen:
		new_gen.changed.connect(fu)
	return new_gen

# Generiert das Mesh
func generate():
	#print("generate wall")
	if !self.mesh:
		self.mesh = ArrayMesh.new()
		
	Smart.create_mesh(smart_gen.generate(), self.mesh)


#func _set(property: StringName, value: Variant) -> bool:
	## 1. Prüfen, ob der neue Wert eine Resource ist
	#if value is SmartGen:
		## Altes Signal trennen (falls vorhanden)
		#var old_gen = get(property)
		#if old_gen is SmartGen and old_gen.changed.is_connected(_on_smart_changed):
			#old_gen.changed.disconnect(_on_smart_changed)
		#
		## Neues Signal verbinden
		#if not value.changed.is_connected(_on_smart_changed):
			#value.changed.connect(_on_smart_changed.bind(value))
	#
	## WICHTIG: Standard-Zuweisung erlauben
	#return false 
	## 'false' sagt Godot: "Ich hab's gesehen, aber setz die Variable bitte trotzdem ganz normal."
