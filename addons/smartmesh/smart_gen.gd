extends SmartObject
class_name SmartGen

var object_list:Array[SmartObject] = []

# Die universelle Helfer-Funktion
func _set_gen_func(old_gen:SmartGen, new_gen:SmartGen, fu:Callable):
	if old_gen is SmartGen and old_gen.changed.is_connected(fu):
		old_gen.changed.disconnect(fu)
	if new_gen is SmartGen:
		new_gen.changed.connect(fu)
	return new_gen

## Diese Funktion wird von Godot aufgerufen, wenn eine Property gesetzt wird
#func _set(property: StringName, value: Variant) -> bool:
	## Die Standard-Logik: Setzt den Wert der Variable
	#set(property, value) 
	#
	## Hier feuern wir das Signal für ALLE Änderungen
	#print("SmartGen._set: ", property)
	#emit_changed()
	#
	## true zurückgeben, damit Godot weiß, dass die Property verarbeitet wurde
	#return true

# Mesh generieren Funktion - überschreiben
func generate() -> Array[SmartObject]:
	object_list = []
	
	return object_list
