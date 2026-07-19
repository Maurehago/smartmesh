@tool
extends Node3D

## Ganz oben im Raum-Skript:
#const WandSkript = preload("res://path/to/wand.gd")
#const BodenSkript = preload("res://path/to/boden.gd")
#
## Weiter unten in deiner Update-Funktion:
#func _update_room() -> void:
	#var wall_north = _get_or_create_part("Wall_North", WandSkript)
	#var floor_node = _get_or_create_part("Floor", BodenSkript)



# Übergib den Pfad zum Skript oder ein geladenes Skript-Objekt
func _get_or_create_part(part_name: String, script_or_class: Variant) -> Node3D:
	var existing_node = get_node_or_null(part_name)
	if existing_node:
		return existing_node

	# Falls ein Pfad (String) übergeben wurde, lade das Skript
	var resource = script_or_class
	if script_or_class is String:
		resource = load(script_or_class)

	# Erstellt die Node und instanziiert das Skript darauf
	var new_node = resource.new() 
	new_node.name = part_name
	add_child(new_node)
	
	if Engine.is_editor_hint():
		new_node.owner = get_tree().edited_scene_root
		
	return new_node
