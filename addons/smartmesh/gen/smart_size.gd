extends SmartGen
class_name SmartSize

# Größe angeben
@export_range(0.1, 8.0, 0.001) var size_x:float = 1.0:
	set(v):size_x = v; emit_changed()
@export_range(0.1, 8.0, 0.001) var size_y:float = 1.0:
	set(v):size_y = v; emit_changed()
@export_range(0.1, 8.0, 0.001) var size_z:float = 1.0:
	set(v):size_z = v; emit_changed()

@export_range(0.0, 7.0, 1.0) var color = 0.0:
	set(v):color = v; emit_changed()

func generate() -> Array[SmartObject]:
	var box = Smart.calc_size(Vector3(size_x, size_y, size_z), color)
	return [box]
