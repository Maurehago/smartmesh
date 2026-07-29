class_name SmartModifier
extends Resource

# Jede Modifikator-Art überschreibt diese Funktion
func apply_mod(vertices:PackedVector3Array, base_size:Vector3, save_area:Vector3 = Vector3.ZERO) -> PackedVector3Array:
	return vertices
